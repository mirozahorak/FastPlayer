//
//  WaveformCacheManager.swift
//  FastPlayer
//
//  Created by Miroslav Zahorak on 2/10/26.
//

import Foundation
import CryptoKit

class WaveformCacheManager {
    static let shared = WaveformCacheManager()
    
    private let fileManager = FileManager.default
    private let cacheDirectoryName = "WaveformCache"
    
    private var cacheDirectory: URL? {
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return documentsDirectory.appendingPathComponent(cacheDirectoryName)
    }
    
    private init() {
        createCacheDirectoryIfNeeded()
    }
    
    private func createCacheDirectoryIfNeeded() {
        guard let cacheDir = cacheDirectory else { return }
        
        if !fileManager.fileExists(atPath: cacheDir.path) {
            try? fileManager.createDirectory(at: cacheDir, withIntermediateDirectories: true)
        }
    }
    
    func cacheKey(for url: URL) -> String? {
        do {
            let attributes = try fileManager.attributesOfItem(atPath: url.path)
            let fileSize = attributes[.size] as? NSNumber ?? 0
            let modificationDate = attributes[.modificationDate] as? Date ?? Date()
            
            let fileName = url.lastPathComponent
            let sizeString = fileSize.stringValue
            let dateString = ISO8601DateFormatter().string(from: modificationDate)
            
            let combinedString = "\(fileName)_\(sizeString)_\(dateString)"
            
            // Create a hash of the combined string for a shorter, consistent key
            let hash = SHA256.hash(data: Data(combinedString.utf8))
            return hash.compactMap { String(format: "%02x", $0) }.joined()
            
        } catch {
            print("Error creating cache key: \(error)")
            return nil
        }
    }
    
    func saveWaveformData(_ data: [Float], for url: URL) {
        guard let cacheKey = cacheKey(for: url),
              let cacheDir = cacheDirectory else { return }
        
        let cacheFileURL = cacheDir.appendingPathComponent("\(cacheKey).waveform")
        
        do {
            let dataToSave = try JSONEncoder().encode(data)
            try dataToSave.write(to: cacheFileURL)
        } catch {
            print("Error saving waveform data: \(error)")
        }
    }
    
    func loadWaveformData(for url: URL) -> [Float]? {
        guard let cacheKey = cacheKey(for: url),
              let cacheDir = cacheDirectory else { return nil }
        
        let cacheFileURL = cacheDir.appendingPathComponent("\(cacheKey).waveform")
        
        guard fileManager.fileExists(atPath: cacheFileURL.path) else { return nil }
        
        do {
            let data = try Data(contentsOf: cacheFileURL)
            return try JSONDecoder().decode([Float].self, from: data)
        } catch {
            print("Error loading waveform data: \(error)")
            // Remove corrupted cache file
            try? fileManager.removeItem(at: cacheFileURL)
            return nil
        }
    }
    
    func clearAllCache() {
        guard let cacheDir = cacheDirectory else { return }
        
        do {
            let contents = try fileManager.contentsOfDirectory(at: cacheDir, includingPropertiesForKeys: nil)
            for fileURL in contents {
                try fileManager.removeItem(at: fileURL)
            }
        } catch {
            print("Error clearing cache: \(error)")
        }
    }
    
    func cacheSize() -> String {
        guard let cacheDir = cacheDirectory else { return "0 MB" }
        
        do {
            let contents = try fileManager.contentsOfDirectory(at: cacheDir, includingPropertiesForKeys: [.fileSizeKey])
            var totalSize: Int64 = 0
            
            for fileURL in contents {
                let attributes = try fileManager.attributesOfItem(atPath: fileURL.path)
                totalSize += attributes[.size] as? Int64 ?? 0
            }
            
            let sizeInMB = Double(totalSize) / (1024 * 1024)
            return String(format: "%.1f MB", sizeInMB)
        } catch {
            return "Unknown"
        }
    }
}