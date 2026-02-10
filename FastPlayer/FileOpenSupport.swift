import Foundation
import UniformTypeIdentifiers

enum MediaType {
    case video
    case audio
    case unknown
}

extension Notification.Name {
    static let requestMediaFilePicker = Notification.Name("FastPlayer.requestMediaFilePicker")
    static let requestOpenMediaURLs = Notification.Name("FastPlayer.requestOpenMediaURLs")
}

enum MediaOpenUserInfoKey {
    static let urls = "urls"
    static let targetWindowNumber = "targetWindowNumber"
}

enum MediaFileSupport {
    static let importerContentTypes: [UTType] = [
        .movie,
        .video,
        .audio,
        .mpeg4Movie,
        .quickTimeMovie,
        .mp3,
        .wav,
        .aiff
    ]
    
    private static let videoExtensions: Set<String> = [
        "mp4", "m4v", "mov", "avi", "mkv", "wmv", "flv", "webm"
    ]
    
    private static let audioExtensions: Set<String> = [
        "mp3", "aac", "wav", "flac", "m4a", "ogg", "wma", "aiff"
    ]
    
    private static let supportedExtensions: Set<String> = videoExtensions.union(audioExtensions)
    
    static func isSupported(url: URL) -> Bool {
        guard url.isFileURL else { return false }
        return supportedExtensions.contains(url.pathExtension.lowercased())
    }
    
    static func mediaType(for url: URL) -> MediaType {
        let fileExtension = url.pathExtension.lowercased()
        
        if videoExtensions.contains(fileExtension) {
            return .video
        }
        
        if audioExtensions.contains(fileExtension) {
            return .audio
        }
        
        return .unknown
    }
}
