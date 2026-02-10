//
//  AppState.swift
//  FastPlayer
//
//  Created by Miroslav Zahorak on 2/10/26.
//

import SwiftUI
import AVFoundation
import Combine
import AppKit

class AppState: ObservableObject, MenuActions {
    @Published var player: AVPlayer?
    @Published var isPlaying = false
    @Published var playbackRate: Float = 1.0
    @Published var waveformData: [Float] = []
    @Published var currentTime: Double = 0.0
    @Published var duration: Double = 0.0
    @Published var isGeneratingWaveform = false
    @Published var currentFileURL: URL?
    @Published var currentMediaType: MediaType = .unknown
    
    private var timer: Timer?
    
    init() {}
    
    func openFile() {
        NotificationCenter.default.post(name: .requestMediaFilePicker, object: nil)
    }
    
    func playPause() {
        if isPlaying {
            player?.pause()
        } else {
            player?.play()
            player?.rate = playbackRate
        }
        isPlaying.toggle()
    }
    
    func stop() {
        player?.pause()
        player?.seek(to: .zero)
        isPlaying = false
        currentTime = 0.0
    }
    
    func seekToStart() {
        player?.seek(to: .zero)
        currentTime = 0.0
    }
    
    func rewind() {
        guard let player = player else { return }
        let currentTime = player.currentTime()
        let newTime = CMTimeSubtract(currentTime, CMTime(seconds: 5, preferredTimescale: 1))
        player.seek(to: newTime)
    }
    
    func forward() {
        guard let player = player else { return }
        let currentTime = player.currentTime()
        let newTime = CMTimeAdd(currentTime, CMTime(seconds: 5, preferredTimescale: 1))
        player.seek(to: newTime)
    }
    
    func increaseSpeed() {
        playbackRate = min(10.0, playbackRate + 0.5)
    }
    
    func decreaseSpeed() {
        playbackRate = max(0.5, playbackRate - 0.5)
    }
    
    func resetSpeed() {
        playbackRate = 1.0
    }
    
    func loadVideo(url: URL) {
        let didStartAccessing = url.startAccessingSecurityScopedResource()
        currentFileURL = url
        currentMediaType = MediaFileSupport.mediaType(for: url)
        NSDocumentController.shared.noteNewRecentDocumentURL(url)
        player = AVPlayer(url: url)
        player?.rate = playbackRate  // Set the initial rate
        player?.pause()  // Ensure the player is paused when loading
        isPlaying = false  // Reset playing state for new video
        setupTimer()
        
        // Try to load cached waveform first
        if let cachedData = WaveformCacheManager.shared.loadWaveformData(for: url) {
            waveformData = cachedData
            isGeneratingWaveform = false
        } else {
            isGeneratingWaveform = true
            Task {
                await generateWaveform(for: url)
                isGeneratingWaveform = false
                if didStartAccessing {
                    url.stopAccessingSecurityScopedResource()
                }
            }
        }
        
        // Get duration
        Task {
            do {
                let asset = AVURLAsset(url: url)
                let durationCMTime = try await asset.load(.duration)
                duration = CMTimeGetSeconds(durationCMTime)
            } catch {
                print("Error loading duration: \(error)")
            }
        }
    }
    
    private func setupTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if let player = self.player {
                self.currentTime = CMTimeGetSeconds(player.currentTime())
            }
        }
    }
    
    func seekToProgress(_ progress: Double) {
        guard let player = player, duration > 0 else { return }
        let seekTime = CMTime(seconds: progress * duration, preferredTimescale: 1)
        player.seek(to: seekTime)
    }
    
    func timeString(from time: Double) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        let seconds = Int(time) % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    nonisolated private static func downsample(_ array: [Float], to count: Int) -> [Float] {
        guard array.count > count else { return array }
        let step = Double(array.count) / Double(count)
        var result: [Float] = []
        for i in 0..<count {
            let index = Int(Double(i) * step)
            result.append(array[index])
        }
        return result
    }
    
    private func generateWaveform(for url: URL) async {
        let asset = AVURLAsset(url: url)
        do {
            let tracks = try await asset.loadTracks(withMediaType: .audio)
            guard let audioTrack = tracks.first else { return }
            
            // Move the heavy processing to a background thread
            let downsampled = await Task.detached {
                let reader = try? AVAssetReader(asset: asset)
                let output = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: [
                    AVFormatIDKey: kAudioFormatLinearPCM,
                    AVLinearPCMBitDepthKey: 16,
                    AVLinearPCMIsBigEndianKey: false,
                    AVLinearPCMIsFloatKey: false,
                    AVLinearPCMIsNonInterleaved: false
                ])
                reader?.add(output)
                reader?.startReading()
                
                var samples: [Float] = []
                while let sampleBuffer = output.copyNextSampleBuffer() {
                    if let blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer) {
                        let length = CMBlockBufferGetDataLength(blockBuffer)
                        var data = Data(count: length)
                        _ = data.withUnsafeMutableBytes { bytes in
                            CMBlockBufferCopyDataBytes(blockBuffer, atOffset: 0, dataLength: length, destination: bytes.baseAddress!)
                        }
                        
                        let int16Array = data.withUnsafeBytes { $0.bindMemory(to: Int16.self) }
                        for value in int16Array {
                            samples.append(Float(value) / 32768.0)
                        }
                    }
                }
                
                // Downsample for waveform
                return Self.downsample(samples, to: 1000)
            }.value
            
            // Update UI on main thread
            await MainActor.run {
                waveformData = downsampled
                // Save to cache
                WaveformCacheManager.shared.saveWaveformData(downsampled, for: url)
            }
        } catch {
            print("Error generating waveform: \(error)")
        }
    }
}
