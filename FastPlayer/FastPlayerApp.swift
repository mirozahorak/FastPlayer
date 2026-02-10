import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    private static let lock = NSLock()
    private static var _pendingURLs: [URL] = []
    private var openWindowAction: (() -> Void)?
    
    static func pushURLs(_ urls: [URL]) {
        lock.lock()
        _pendingURLs.append(contentsOf: urls)
        lock.unlock()
    }
    
    static func popPendingURL() -> URL? {
        lock.lock()
        defer { lock.unlock() }
        guard !_pendingURLs.isEmpty else { return nil }
        return _pendingURLs.removeFirst()
    }
    
    func setOpenWindowAction(_ action: @escaping () -> Void) {
        self.openWindowAction = action
    }
    
    func application(_ application: NSApplication, open urls: [URL]) {
        openMediaURLs(urls, in: application)
    }
    
    func openMediaURLsFromMenu(_ urls: [URL]) {
        openMediaURLs(urls, in: NSApp)
    }
    
    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        openMediaURLs([URL(fileURLWithPath: filename)], in: sender)
        return true
    }
    
    func application(_ application: NSApplication, openFiles filenames: [String]) {
        let urls = filenames.map { URL(fileURLWithPath: $0) }
        openMediaURLs(urls, in: application)
        application.reply(toOpenOrPrint: .success)
    }
    
    private func openPendingURLsInNewWindows(count: Int) {
        guard count > 0 else { return }
        
        for i in 0..<count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.2) {
                self.openWindowAction?()
            }
        }
    }
    
    private func openMediaURLs(_ urls: [URL], in application: NSApplication) {
        let supportedURLs = urls.filter { MediaFileSupport.isSupported(url: $0) }
        guard !supportedURLs.isEmpty else { return }
        
        if let targetWindow = application.keyWindow ?? application.mainWindow {
            NotificationCenter.default.post(
                name: .requestOpenMediaURLs,
                object: nil,
                userInfo: [
                    MediaOpenUserInfoKey.urls: [supportedURLs[0]],
                    MediaOpenUserInfoKey.targetWindowNumber: targetWindow.windowNumber
                ]
            )
            
            let remainingURLs = Array(supportedURLs.dropFirst())
            if !remainingURLs.isEmpty {
                AppDelegate.pushURLs(remainingURLs)
                openPendingURLsInNewWindows(count: remainingURLs.count)
            }
        } else {
            AppDelegate.pushURLs(supportedURLs)
            openPendingURLsInNewWindows(count: max(1, supportedURLs.count))
        }
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let bundleURL = CFBundleCopyBundleURL(CFBundleGetMainBundle()) {
            LSRegisterURL(bundleURL, true)
        }
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            openWindowAction?()
        }
        return true
    }
}

@main
struct FastPlayerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.openWindow) private var openWindow
    @FocusedValue(\.menuActions) private var menuActions
    
    var body: some Scene {
        WindowGroup(id: "mainWindow") {
            ContentView()
                .handlesExternalEvents(preferring: [], allowing: ["*"])
                .task {
                    appDelegate.setOpenWindowAction { [openWindow] in
                        openWindow(id: "mainWindow")
                    }
                }
        }
        .handlesExternalEvents(matching: ["mainWindow"])
        .restorationBehavior(.disabled)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Open Media File...") {
                    if let menuActions = menuActions {
                        menuActions.openFile()
                    } else {
                        NotificationCenter.default.post(name: .requestMediaFilePicker, object: nil)
                    }
                }
                .keyboardShortcut("o", modifiers: .command)
                
                let recentMediaURLs = NSDocumentController.shared.recentDocumentURLs.filter { MediaFileSupport.isSupported(url: $0) }
                
                Menu("Open Recent") {
                    if recentMediaURLs.isEmpty {
                        Text("No Recent Documents")
                    } else {
                        ForEach(recentMediaURLs, id: \.self) { url in
                            Button(url.lastPathComponent) {
                                appDelegate.openMediaURLsFromMenu([url])
                            }
                        }
                        
                        Divider()
                        
                        Button("Clear Menu") {
                            NSDocumentController.shared.clearRecentDocuments(nil)
                        }
                    }
                }
                .disabled(recentMediaURLs.isEmpty)
                
                Divider()
                
                Button("New Window") {
                    openWindow(id: "mainWindow")
                }
                .keyboardShortcut("n", modifiers: .command)
            }
            
            CommandMenu("Playback") {
                Button("Play/Pause") {
                    menuActions?.playPause()
                }
                .keyboardShortcut(.space, modifiers: [])
                
                Button("Stop") {
                    menuActions?.stop()
                }
                .keyboardShortcut("k", modifiers: [])
                
                Divider()
                
                Button("Back to Start") {
                    menuActions?.seekToStart()
                }
                .keyboardShortcut("0", modifiers: [])
                
                Button("Rewind 5s") {
                    menuActions?.rewind()
                }
                .keyboardShortcut("j", modifiers: [])
                
                Button("Forward 5s") {
                    menuActions?.forward()
                }
                .keyboardShortcut("l", modifiers: [])
                
                Divider()
                
                Button("Increase Speed") {
                    menuActions?.increaseSpeed()
                }
                .keyboardShortcut("]", modifiers: [])
                
                Button("Decrease Speed") {
                    menuActions?.decreaseSpeed()
                }
                .keyboardShortcut("[", modifiers: [])
                
                Button("Reset Speed") {
                    menuActions?.resetSpeed()
                }
                .keyboardShortcut("\\", modifiers: [])
            }
            
            CommandGroup(replacing: .appSettings) {
                Button("Settings...") {
                    openWindow(id: "settings")
                }
                .keyboardShortcut(",", modifiers: .command)
            }
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
        
        Window("Settings", id: "settings") {
            SettingsView()
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
        .defaultPosition(.center)
        .defaultSize(width: 500, height: 400)
        .restorationBehavior(.disabled)
    }
}
