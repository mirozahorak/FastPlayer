# FastPlayer

A fast and lightweight media player for macOS built with SwiftUI and AVFoundation.

## Features

- **High-Performance Playback**: Smooth audio and video playback using AVFoundation
- **Waveform Visualization**: Real-time waveform display for audio files
- **Playback Speed Control**: Adjust playback speed from 0.25x to 4x
- **Intuitive Controls**: Play/pause, stop, rewind, forward, and seek functionality
- **Drag & Drop Support**: Easily open files by dragging them into the player
- **Multiple Windows**: Open multiple media files in separate windows
- **File Association**: Automatically opens supported media files when double-clicked
- **Keyboard Shortcuts**: Full keyboard navigation support

## Download

### Latest Release
Download the latest signed and notarized macOS build from the [Releases](https://github.com/mirozahorak/FastPlayer/releases) page.

**FastPlayer v1.0.0** - Stable release with proper code signing and notarization
- ✅ Signed with Developer ID certificate
- ✅ Notarized by Apple for maximum security
- ✅ Universal binary (Intel + Apple Silicon)
- ✅ Gatekeeper-compatible - runs without security warnings

[⬇️ Download FastPlayer v1.0.0 for macOS](https://github.com/mirozahorak/FastPlayer/releases/download/v1.0.0/FastPlayer-1.0.0.zip)

### Installation
1. Download the `FastPlayer-1.0.0.zip` file from the link above
2. Extract the zip file
3. Drag `FastPlayer.app` to your Applications folder
4. Double-click to launch - no security warnings required!

### System Requirements
- macOS 12.0 or later
- Apple Silicon or Intel Mac

## Supported Formats

### Video Formats
- MP4 (.mp4, .m4v)
- QuickTime (.mov)
- AVI (.avi)
- Matroska (.mkv)
- Windows Media Video (.wmv)
- Flash Video (.flv)
- WebM (.webm)

### Audio Formats
- MP3 (.mp3)
- AAC (.aac, .m4a)
- WAV (.wav)
- FLAC (.flac)
- OGG (.ogg)
- Windows Media Audio (.wma)
- AIFF (.aiff)

## Installation

### Prerequisites
- macOS 12.0 or later
- Xcode 14.0 or later

### Building from Source

1. Clone the repository:
   ```bash
   git clone https://github.com/mirozahorak/FastPlayer.git
   cd FastPlayer
   ```

2. Open the project in Xcode:
   ```bash
   open FastPlayer.xcodeproj
   ```

3. Select the FastPlayer target and build:
   - Choose "FastPlayer" from the target selector
   - Press `Cmd + B` to build or `Cmd + R` to run

4. The app will launch and you're ready to play media files!

## Usage

### Opening Files
- **File Menu**: Click "File" → "Open..." to browse and select a media file
- **Drag & Drop**: Drag media files directly onto the player window
- **Double-click**: Double-click supported media files in Finder (after first launch)
- **Command Line**: Open files from terminal or associate with file types

### Controls
- **Play/Pause**: Spacebar or click the play button
- **Stop**: Click the stop button or press K
- **Seek**: Click anywhere on the waveform to jump to that position
- **Rewind/Forward**: Use J/L keys for 5-second jumps, or rewind and forward buttons
- **Speed Control**: Use [/] keys or speed slider to adjust playback rate, \ to reset

### Keyboard Shortcuts
- `Space`: Play/Pause
- `K`: Stop
- `0`: Back to Start
- `J`: Rewind 5 seconds
- `L`: Forward 5 seconds
- `[`: Decrease Speed
- `]`: Increase Speed
- `\`: Reset Speed to 1x
- `Cmd + O`: Open Media File
- `Cmd + N`: New Window
- `Cmd + ,`: Open Settings
- `Cmd + W`: Close Window
- `Esc`: Close Settings

## Settings

Access settings through **FastPlayer → Settings...** or `Cmd + ,`.

### General
- **Waveform Cache**: View cache size and clear cached waveform data

### Keyboard Shortcuts
- View all available keyboard shortcuts
- Learn how to customize shortcuts in System Settings

### File Types
- View supported file formats
- Instructions for associating file types with FastPlayer
- Quick access to System Settings for file associations

### About
- App version and build information
- Developer credits
- Acknowledgments
- Link to GitHub repository

## Architecture

FastPlayer is built with:
- **SwiftUI**: Modern declarative UI framework
- **AVFoundation**: Apple's multimedia framework for playback
- **AVKit**: High-level AV player UI components
- **AppKit**: macOS-specific UI and window management

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with SwiftUI and AVFoundation
- Waveform generation using AVFoundation audio processing</content>
<parameter name="filePath">/Volumes/DEVEL/_SWIFT/FastPlayer/FastPlayer/README.md