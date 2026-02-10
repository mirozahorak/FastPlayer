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
        ZStack {
            TabView(selection: $selectedTab) {
                ScrollView {
                    generalTab
                }
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag(0)
                
                ScrollView {
                    keyboardShortcutsTab
                }
                .tabItem {
                    Label("Shortcuts", systemImage: "keyboard")
                }
                .tag(1)
                
                ScrollView {
                    fileAssociationsTab
                }
                .tabItem {
                    Label("File Types", systemImage: "doc")
                }
                .tag(2)
                
                ScrollView {
                    aboutTab
                }
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
                .tag(3)
            }
            .frame(minWidth: 550, maxWidth: 550, minHeight: 550)
            .onAppear {
                updateCacheSize()
            }
            
            // Invisible view to set window constraints
            WindowConstraintSetter()
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
        .frame(maxWidth: .infinity)
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
        .frame(maxWidth: .infinity)
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
        .frame(maxWidth: .infinity)
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
            
            Spacer(minLength: 20)
            
            HStack {
                Button {
                    if let url = URL(string: "https://github.com/mirozahorak/FastPlayer") {
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
        .frame(maxWidth: .infinity)
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

struct WindowConstraintSetter: NSViewRepresentable {
    private static let fixedContentWidth: CGFloat = 550
    private static let minimumHeight: CGFloat = 550

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        view.isHidden = true
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        // Ensure the hosting window exists before applying constraints.
        DispatchQueue.main.async {
            if let window = nsView.window {
                context.coordinator.attach(to: window)
            }
        }
    }

    final class Coordinator {
        private weak var window: NSWindow?
        private var resizeObserver: NSObjectProtocol?
        private var liveResizeObserver: NSObjectProtocol?
        private var closeObserver: NSObjectProtocol?

        deinit {
            detach()
        }

        func attach(to window: NSWindow) {
            guard self.window !== window else {
                applyConstraints(to: window)
                return
            }

            detach()
            self.window = window

            resizeObserver = NotificationCenter.default.addObserver(
                forName: NSWindow.didResizeNotification,
                object: window,
                queue: .main
            ) { [weak self] notification in
                guard let resizedWindow = notification.object as? NSWindow else { return }
                self?.enforceFixedWidth(for: resizedWindow)
            }

            liveResizeObserver = NotificationCenter.default.addObserver(
                forName: NSWindow.didEndLiveResizeNotification,
                object: window,
                queue: .main
            ) { [weak self] notification in
                guard let resizedWindow = notification.object as? NSWindow else { return }
                self?.applyConstraints(to: resizedWindow)
            }

            closeObserver = NotificationCenter.default.addObserver(
                forName: NSWindow.willCloseNotification,
                object: window,
                queue: .main
            ) { [weak self] _ in
                self?.detach()
            }

            applyConstraints(to: window)
        }

        private func applyConstraints(to window: NSWindow) {
            window.styleMask.insert(.resizable)

            let fixedContentWidth = WindowConstraintSetter.fixedContentWidth
            let minimumHeight = WindowConstraintSetter.minimumHeight
            let decorationWidth = window.frame.width - window.contentRect(forFrameRect: window.frame).width
            let fixedFrameWidth = fixedContentWidth + decorationWidth

            window.contentMinSize = NSSize(width: fixedContentWidth, height: minimumHeight)
            window.contentMaxSize = NSSize(width: fixedContentWidth, height: CGFloat.greatestFiniteMagnitude)
            window.minSize = NSSize(width: fixedFrameWidth, height: minimumHeight)
            window.maxSize = NSSize(width: fixedFrameWidth, height: CGFloat.greatestFiniteMagnitude)

            enforceFixedWidth(for: window)
        }

        private func enforceFixedWidth(for window: NSWindow) {
            let fixedContentWidth = WindowConstraintSetter.fixedContentWidth
            let decorationWidth = window.frame.width - window.contentRect(forFrameRect: window.frame).width
            let fixedFrameWidth = fixedContentWidth + decorationWidth

            guard abs(window.frame.width - fixedFrameWidth) > 0.5 else { return }

            var frame = window.frame
            frame.size.width = fixedFrameWidth
            window.setFrame(frame, display: true)
        }

        private func detach() {
            if let resizeObserver {
                NotificationCenter.default.removeObserver(resizeObserver)
                self.resizeObserver = nil
            }
            if let liveResizeObserver {
                NotificationCenter.default.removeObserver(liveResizeObserver)
                self.liveResizeObserver = nil
            }
            if let closeObserver {
                NotificationCenter.default.removeObserver(closeObserver)
                self.closeObserver = nil
            }
            window = nil
        }
    }
}

#Preview {
    SettingsView()
}
