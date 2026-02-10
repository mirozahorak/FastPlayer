import SwiftUI
import AVFoundation
import AVKit
import AppKit
import UniformTypeIdentifiers

struct ContentView: View {
    @StateObject private var appState = AppState()
    @State private var showFilePicker = false
    @State private var isDragTargeted = false
    @State private var hostWindow: NSWindow?

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black.opacity(0.92), Color.blue.opacity(0.32)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            if appState.player == nil {
                emptyState
            } else {
                mediaLayout
            }

            if isDragTargeted {
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(Color.white.opacity(0.9), style: StrokeStyle(lineWidth: 3, dash: [9]))
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color.white.opacity(0.08))
                    )
                    .padding(12)
            }
        }
        .frame(minWidth: 720, minHeight: 420)
        .background(
            WindowReader { window in
                if hostWindow?.windowNumber != window?.windowNumber {
                    hostWindow = window
                    updateWindowTitle(for: appState.currentFileURL)
                }
            }
        )
        .onDrop(of: [.fileURL], isTargeted: $isDragTargeted) { providers in
            handleDrop(providers: providers)
        }
        .fileImporter(isPresented: $showFilePicker, allowedContentTypes: MediaFileSupport.importerContentTypes) { result in
            switch result {
            case .success(let url):
                appState.loadVideo(url: url)
            case .failure(let error):
                print("Error: \(error)")
            }
        }
        .onChange(of: appState.playbackRate) {
            if appState.isPlaying {
                appState.player?.rate = appState.playbackRate
            }
        }
        .onChange(of: appState.currentFileURL) {
            updateWindowTitle(for: appState.currentFileURL)
        }
        .onReceive(NotificationCenter.default.publisher(for: .requestMediaFilePicker)) { _ in
            showFilePicker = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .requestOpenMediaURLs)) { notification in
            handleExternalOpenRequest(notification)
        }
        .onAppear {
            DispatchQueue.main.async {
                consumePendingURLIfAvailable()
                updateWindowTitle(for: appState.currentFileURL)
            }
        }
        .onDisappear {
            appState.stop()
        }
        .focusedValue(\.menuActions, appState)
    }

    private var mediaLayout: some View {
        VStack(spacing: 0) {
            if let player = appState.player, appState.currentMediaType != .audio {
                PlayerView(
                    player: player,
                    onFileDrop: { url in
                        appState.loadVideo(url: url)
                    },
                    onDropTargetedChanged: { isTargeted in
                        isDragTargeted = isTargeted
                    }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(Color.black.opacity(0.82))
            } else {
                Spacer(minLength: 0)
            }

            bottomPanel
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }

    private var bottomPanel: some View {
        VStack(spacing: 14) {
            waveformCard

            HStack(alignment: .center, spacing: 20) {
                transportControls
                Spacer(minLength: 12)
                speedControls
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.16), lineWidth: 1)
                )
        )
    }

    private var waveformCard: some View {
        VStack(spacing: 10) {
            HStack {
                Text(appState.timeString(from: appState.currentTime))
                    .font(.system(size: 16, weight: .semibold, design: .rounded).monospacedDigit())
                    .foregroundStyle(.white)

                Spacer()

                Text(appState.timeString(from: appState.duration))
                    .font(.system(size: 16, weight: .semibold, design: .rounded).monospacedDigit())
                    .foregroundStyle(.white.opacity(0.95))
            }

            ZStack {
                WaveformView(
                    data: appState.waveformData,
                    currentTime: appState.currentTime,
                    duration: appState.duration,
                    onSeek: appState.seekToProgress
                )
                .frame(height: 90)

                if appState.isGeneratingWaveform {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.black.opacity(0.42))
                        .overlay(
                            ProgressView("Generating waveform...")
                                .tint(.white)
                                .foregroundStyle(.white)
                        )
                }
            }
        }
    }

    private var transportControls: some View {
        HStack(spacing: 12) {
            TransportButton(systemName: "backward.end.fill", size: 42, isPrimary: false) {
                appState.seekToStart()
            }

            TransportButton(systemName: "gobackward.5", size: 42, isPrimary: false) {
                appState.rewind()
            }

            TransportButton(systemName: appState.isPlaying ? "pause.fill" : "play.fill", size: 62, isPrimary: true) {
                appState.playPause()
            }

            TransportButton(systemName: "goforward.5", size: 42, isPrimary: false) {
                appState.forward()
            }
        }
    }

    private var speedControls: some View {
        VStack(alignment: .trailing, spacing: 8) {
            Text("Playback Speed")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.9))

            Slider(value: $appState.playbackRate, in: 0.5...10.0, step: 0.1) {
                Text("Speed")
            }
            .frame(width: 280)

            Text("\(appState.playbackRate, specifier: "%.1f")x")
                .font(.system(size: 20, weight: .semibold, design: .rounded).monospacedDigit())
                .foregroundStyle(.white)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 18) {
            Image(systemName: "play.rectangle.on.rectangle")
                .font(.system(size: 66))
                .foregroundStyle(.white.opacity(0.92))

            Text("Drop a media file here")
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)

            Text("or")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.72))

            Button("Open Media File") {
                showFilePicker = true
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(28)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }

        provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
            guard let url = extractFileURL(from: item), MediaFileSupport.isSupported(url: url) else {
                return
            }

            DispatchQueue.main.async {
                appState.loadVideo(url: url)
            }
        }

        return true
    }

    private func handleExternalOpenRequest(_ notification: Notification) {
        guard
            let urls = notification.userInfo?[MediaOpenUserInfoKey.urls] as? [URL],
            let firstURL = urls.first
        else {
            return
        }

        if let targetWindowNumber = notification.userInfo?[MediaOpenUserInfoKey.targetWindowNumber] as? Int {
            guard hostWindow?.windowNumber == targetWindowNumber else { return }
        }

        appState.loadVideo(url: firstURL)
    }

    private func consumePendingURLIfAvailable() {
        guard let pendingURL = AppDelegate.popPendingURL() else { return }
        appState.loadVideo(url: pendingURL)
    }

    private func extractFileURL(from item: NSSecureCoding?) -> URL? {
        if let data = item as? Data {
            return URL(dataRepresentation: data, relativeTo: nil)
        }

        if let url = item as? URL {
            return url
        }

        if let url = item as? NSURL {
            return url as URL
        }

        return nil
    }

    private func updateWindowTitle(for url: URL?) {
        guard let hostWindow else { return }

        if let url {
            hostWindow.title = url.lastPathComponent
            hostWindow.representedURL = url
        } else {
            hostWindow.title = "FastPlayer"
            hostWindow.representedURL = nil
        }
    }
}

struct TransportButton: View {
    let systemName: String
    let size: CGFloat
    let isPrimary: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: isPrimary ? 24 : 19, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(isPrimary ? Color.accentColor : Color.white.opacity(0.17))
                )
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(isPrimary ? 0.4 : 0.22), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

struct PlayerView: NSViewRepresentable {
    let player: AVPlayer
    let onFileDrop: (URL) -> Void
    let onDropTargetedChanged: (Bool) -> Void

    func makeNSView(context: Context) -> DroppablePlayerView {
        let view = DroppablePlayerView()
        view.player = player
        view.controlsStyle = .none
        view.onFileDrop = onFileDrop
        view.onDropTargetChange = onDropTargetedChanged
        return view
    }

    func updateNSView(_ nsView: DroppablePlayerView, context: Context) {
        nsView.player = player
        nsView.onFileDrop = onFileDrop
        nsView.onDropTargetChange = onDropTargetedChanged
    }
}

final class DroppablePlayerView: AVPlayerView {
    var onFileDrop: ((URL) -> Void)?
    var onDropTargetChange: ((Bool) -> Void)?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        registerForDraggedTypes([.fileURL])
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        registerForDraggedTypes([.fileURL])
    }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        guard firstSupportedURL(from: sender) != nil else {
            onDropTargetChange?(false)
            return []
        }

        onDropTargetChange?(true)
        return .copy
    }

    override func draggingExited(_ sender: NSDraggingInfo?) {
        onDropTargetChange?(false)
    }

    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        firstSupportedURL(from: sender) != nil
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        onDropTargetChange?(false)

        guard let url = firstSupportedURL(from: sender) else { return false }
        onFileDrop?(url)
        return true
    }

    private func firstSupportedURL(from draggingInfo: NSDraggingInfo) -> URL? {
        let fileURLs = draggingInfo.draggingPasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL]
        return fileURLs?.first(where: { MediaFileSupport.isSupported(url: $0) })
    }
}

struct WindowReader: NSViewRepresentable {
    let onResolve: (NSWindow?) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)
        DispatchQueue.main.async {
            onResolve(view.window)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            onResolve(nsView.window)
        }
    }
}

struct WaveformView: View {
    let data: [Float]
    let currentTime: Double
    let duration: Double
    let onSeek: (Double) -> Void

    @State private var isPressed = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(isPressed ? Color.blue.opacity(0.2) : Color.white.opacity(0.12))
                    .frame(width: geometry.size.width, height: geometry.size.height)

                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    let midY = height / 2

                    path.move(to: CGPoint(x: 0, y: midY))

                    for (index, sample) in data.enumerated() {
                        let x = CGFloat(index) / CGFloat(max(data.count, 1)) * width
                        let y = midY + CGFloat(sample) * midY
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                .stroke(Color.cyan.opacity(0.9), lineWidth: 1.6)

                if duration > 0 {
                    let progress = currentTime / duration
                    let x = progress * geometry.size.width
                    Path { path in
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: geometry.size.height))
                    }
                    .stroke(Color.white.opacity(0.95), lineWidth: 2.8)
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        isPressed = true
                    }
                    .onEnded { value in
                        isPressed = false
                        let progress = Double(value.location.x / geometry.size.width)
                        let clampedProgress = max(0, min(1, progress))
                        onSeek(clampedProgress)
                    }
            )
        }
    }
}

#Preview {
    ContentView()
}
