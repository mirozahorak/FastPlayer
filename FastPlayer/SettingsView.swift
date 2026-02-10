//
//  SettingsView.swift
//  FastPlayer
//
//  Created by Miroslav Zahorak on 2/10/26.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var cacheSize: String = ""
    @State private var showDeleteConfirmation = false
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            generalTab
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag(0)
            
            keyboardShortcutsTab
                .tabItem {
                    Label("Shortcuts", systemImage: "keyboard")
                }
                .tag(1)
            
            fileAssociationsTab
                .tabItem {
                    Label("File Types", systemImage: "doc")
                }
                .tag(2)
            
            aboutTab
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
                .tag(3)
        }
        .frame(width: 500, height: 400)
        .onAppear {
            updateCacheSize()
        }
    }
    
    private var generalTab: some View {
        Form {
            Section("Waveform Cache") {
                HStack {
                    Text("Cache Size")
                    Spacer()
                    Text(cacheSize)
                        .foregroundColor(.secondary)
                        .font(.system(.body, design: .monospaced))
                }
                
                Text("Waveform data is cached to improve performance when reopening files.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Text("Clear All Cache")
                }
                .alert("Clear Waveform Cache", isPresented: $showDeleteConfirmation) {
                    Button("Cancel", role: .cancel) { }
                    Button("Clear", role: .destructive) {
                        WaveformCacheManager.shared.clearAllCache()
                        updateCacheSize()
                    }
                } message: {
                    Text("This will delete all cached waveform data. Waveforms will be regenerated the next time you open files. This action cannot be undone.")
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }
    
    private var keyboardShortcutsTab: some View {
        Form {
            Section("Playback Controls") {
                ShortcutRow(shortcut: "Space", description: "Play/Pause")
                ShortcutRow(shortcut: "K", description: "Stop")
                ShortcutRow(shortcut: "0", description: "Back to Start")
                ShortcutRow(shortcut: "J", description: "Rewind 5 seconds")
                ShortcutRow(shortcut: "L", description: "Forward 5 seconds")
            }
            
            Section("Speed Controls") {
                ShortcutRow(shortcut: "[", description: "Decrease Speed")
                ShortcutRow(shortcut: "]", description: "Increase Speed")
                ShortcutRow(shortcut: "\\", description: "Reset Speed to 1x")
            }
            
            Section("Application") {
                ShortcutRow(shortcut: "⌘O", description: "Open Media File")
                ShortcutRow(shortcut: "⌘N", description: "New Window")
                ShortcutRow(shortcut: "⌘,", description: "Open Settings")
                ShortcutRow(shortcut: "⌘W", description: "Close Window")
                ShortcutRow(shortcut: "Esc", description: "Close Settings")
            }
            
            Section {
                Text("Keyboard shortcuts can be customized in System Settings → Keyboard → Keyboard Shortcuts → App Shortcuts.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .formStyle(.grouped)
        .padding()
    }
    
    private var fileAssociationsTab: some View {
        Form {
            Section("Supported File Types") {
                Text("FastPlayer can open the following file types:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("**Video Files:** MP4, M4V, MOV, AVI, MKV, WMV, FLV, WebM")
                        .font(.callout)
                    Text("**Audio Files:** MP3, AAC, WAV, FLAC, M4A, OGG, WMA, AIFF")
                        .font(.callout)
                }
                .padding(.vertical, 4)
            }
            
            Section("File Association") {
                VStack(alignment: .leading, spacing: 12) {
                    Text("To associate file types with FastPlayer:")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("**Method 1: Get Info**")
                        Text("1. Right-click a media file in Finder")
                        Text("2. Choose 'Get Info'")
                        Text("3. In 'Open with' section, select FastPlayer")
                        Text("4. Click 'Change All...'")
                        
                        Divider()
                        
                        Text("**Method 2: System Settings**")
                        Text("1. Open System Settings → Apps → Default Apps")
                        Text("2. Choose FastPlayer for supported file types")
                        
                        Divider()
                        
                        Text("**Method 3: Double-click**")
                        Text("After first launch, double-clicking supported files will automatically open them in FastPlayer.")
                    }
                    .font(.callout)
                    .foregroundColor(.secondary)
                }
            }
            
            Section {
                Button {
                    NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles")!)
                } label: {
                    Text("Open System Settings")
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }
    
    private var aboutTab: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Image(systemName: "play.circle.fill")
                    .resizable()
                    .frame(width: 64, height: 64)
                    .foregroundColor(.blue)
                
                Text("FastPlayer")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Version \(appVersion) (\(buildNumber))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("A fast and lightweight media player for macOS")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 12) {
                Text("**Developer**")
                    .font(.headline)
                Text("Miroslav Zahorak")
                    .foregroundColor(.secondary)
                
                Text("**Built with**")
                    .font(.headline)
                Text("SwiftUI, AVFoundation, AVKit")
                    .foregroundColor(.secondary)
                
                Text("**Acknowledgments**")
                    .font(.headline)
                Text("Thanks to the Swift and macOS communities for their excellent frameworks and documentation.")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            
            Spacer()
            
            HStack {
                Button {
                    if let url = URL(string: "https://github.com/yourusername/FastPlayer") {
                        NSWorkspace.shared.open(url)
                    }
                } label: {
                    Label("View on GitHub", systemImage: "link")
                }
                
                Spacer()
                
                Button("Close") {
                    dismiss()
                }
                .keyboardShortcut(.escape, modifiers: [])
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
    
    private func updateCacheSize() {
        cacheSize = WaveformCacheManager.shared.cacheSize()
    }
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}

struct ShortcutRow: View {
    let shortcut: String
    let description: String
    
    var body: some View {
        HStack {
            Text(description)
            Spacer()
            Text(shortcut)
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(4)
        }
    }
}

#Preview {
    SettingsView()
}