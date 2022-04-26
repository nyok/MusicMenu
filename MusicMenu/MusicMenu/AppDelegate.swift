//
//  AppDelegate.swift
//  MusicMenu
//

import Cocoa
import ScriptingBridge

@objc public protocol SBObjectProtocol: NSObjectProtocol {
    func get() -> Any!
}

@objc public protocol SBApplicationProtocol: SBObjectProtocol {
    func activate()
    var delegate: SBApplicationDelegate! { get set }
    var isRunning: Bool { get }
}

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.variableLength)
    let font = NSFont(name: "Helvetica", size: 12)
    
    let defaults = UserDefaults.standard
    
    let iconNone = NSImage(named:NSImage.Name("IconNone"))
    let iconPlay = NSImage(named:NSImage.Name("IconPlay"))
    let iconPause = NSImage(named:NSImage.Name("IconPause"))
    
    let spotify = SBApplication(bundleIdentifier: "com.spotify.client")! as SpotifyApplication
    let music = SBApplication(bundleIdentifier: "com.apple.music")! as MusicApplication
    
    var selectApp: String = ""
    var trackMenuTitle: String = ""
    
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var trackMenuItem: NSMenuItem!
    @IBOutlet weak var copyMenuItem: NSMenuItem!
    @IBOutlet weak var searchMenuItem: NSMenuItem!
    @IBOutlet weak var showTitleMenuItem: NSMenuItem!
    @IBOutlet weak var quitMenuItem: NSMenuItem!
    
    @IBAction func copyClicked(_ sender: NSMenuItem) {
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(trackMenuItem.title, forType: .string)
    }
    
    @IBAction func searchClicked(_ sender: NSMenuItem) {
        let trackMenu: String = trackMenuItem.title
        var allowedQueryParamAndKey = NSCharacterSet.urlQueryAllowed
        allowedQueryParamAndKey.remove(charactersIn: ";/?:@&=+$, ")
        let encodetrackMenu = trackMenu.addingPercentEncoding(withAllowedCharacters: allowedQueryParamAndKey)!
        let strURL = "https://www.google.ru/search?q=" + encodetrackMenu
        let url = URL(string: strURL)!
        NSWorkspace.shared.open(url)
    }
    
    @IBAction func showTitleClicked(_ sender: NSMenuItem) {
        sender.state = sender.state == .on ? .off : .on
        defaults.set(sender.state, forKey: "showTitleMenuValue")
        infoTrack()
    }
    
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApp.terminate(self)
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        defaults.register(defaults: ["showTitleMenuValue" : 0])
        createStatusMenu()
        infoTrack()
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(self.playbackStateChangedMusic(_:)), name: NSNotification.Name(rawValue: "com.apple.iTunes.playerInfo"), object: nil)
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(self.playbackStateChangedSpotify(_:)), name: NSNotification.Name(rawValue: "com.spotify.client.PlaybackStateChanged"), object: nil)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    func createStatusMenu() {
        statusItem.button!.font = font
        statusItem.button?.image = iconNone
        statusItem.menu = statusMenu
        trackMenuItem.isHidden = true
        copyMenuItem.isHidden = true
        searchMenuItem.isHidden = true
        showTitleMenuItem.isHidden = true
        if defaults.bool(forKey: "showTitleMenuValue") {
            showTitleMenuItem.state = .on
        } else {
            showTitleMenuItem.state = .off
        }
        copyMenuItem.title = NSLocalizedString("menuTextCopy", comment: "")
        searchMenuItem.title = NSLocalizedString("menuTextSearch", comment: "")
        showTitleMenuItem.title = NSLocalizedString("menuTextShowTitle", comment: "")
        quitMenuItem.title = NSLocalizedString("menuTextQuit", comment: "")
    }
    
    @objc
    func playbackStateChangedSpotify(_ aNotification : Notification) {
        selectApp = "spotify"
        infoTrack()
    }
    
    @objc
    func playbackStateChangedMusic(_ aNotification : Notification) {
        selectApp = "music"
        infoTrack()
    }
    
    @objc
    func infoTrack() {
        if self.music.isRunning && self.spotify.isRunning {
            switch selectApp {
            case "spotify":
                updateTrackInfoSpotify()
                break
            case "music":
                updateTrackInfoMusic()
                break
            default:
                break
            }
        }
        else if self.music.isRunning {
            selectApp = "music"
            updateTrackInfoMusic()
        }
        else if self.spotify.isRunning {
            selectApp = "spotify"
            updateTrackInfoSpotify()
        }
        else {
            selectApp = ""
            createMenuTitleStop()
        }
    }
    
    func updateTrackInfoSpotify() {
        if self.spotify.isRunning {
            let currentTrack = self.spotify.currentTrack!
            switch self.spotify.playerState! {
            case SpotifyEPlS.stopped:
                createMenuTitleStop()
                break
            case SpotifyEPlS.playing:
                createMenuTitlePlay(trackMenuArtist: String(currentTrack.artist!),
                                    trackMenuName: String(currentTrack.name!))
                break
            case SpotifyEPlS.paused:
                createMenuTitlePause(trackMenuArtist: String(currentTrack.artist!),
                                     trackMenuName: String(currentTrack.name!))
                break
            default:
                break
            }
        }
    }
    func updateTrackInfoMusic() {
        if self.music.isRunning {
            let currentTrack = self.music.currentTrack!
            switch self.music.playerState! {
            case MusicEPlS.stopped:
                createMenuTitleStop()
                break
            case MusicEPlS.playing:
                createMenuTitlePlay(trackMenuArtist: String(currentTrack.artist!),
                                    trackMenuName: String(currentTrack.name!))
                break
            case MusicEPlS.paused:
                createMenuTitlePause(trackMenuArtist: String(currentTrack.artist!),
                                     trackMenuName: String(currentTrack.name!))
                break
            default:
                break
            }
        }
    }
    
    func createMenuTitlePlay(trackMenuArtist:String,trackMenuName:String) {
        if trackMenuArtist != "" {
            trackMenuTitle = trackMenuArtist + String(": ") + trackMenuName
        } else {
            trackMenuTitle = trackMenuArtist + trackMenuName
        }
        trackMenuItem.title = trackMenuTitle
        if showTitleMenuItem.state == .on {
            statusItem.button!.title = trackMenuName
            statusItem.button!.imagePosition = NSControl.ImagePosition.imageLeft
        } else {
            statusItem.button!.title = ""
            statusItem.button!.imagePosition = NSControl.ImagePosition.imageOnly
        }
        statusItem.button!.appearsDisabled = false
        trackMenuItem.isHidden = false
        copyMenuItem.isHidden = false
        searchMenuItem.isHidden = false
        showTitleMenuItem.isHidden = false
        statusItem.button?.image = iconPlay
    }
    func createMenuTitlePause(trackMenuArtist:String,trackMenuName:String) {
        if trackMenuArtist != "" {
            trackMenuTitle = trackMenuArtist + String(": ") + trackMenuName
        } else {
            trackMenuTitle = trackMenuArtist + trackMenuName
        }
        if showTitleMenuItem.state == .on {
            statusItem.button!.title = trackMenuName
            statusItem.button!.imagePosition = NSControl.ImagePosition.imageLeft
        } else {
            statusItem.button!.title = ""
            statusItem.button!.imagePosition = NSControl.ImagePosition.imageOnly
        }
        trackMenuItem.title = trackMenuTitle
        statusItem.button!.appearsDisabled = true
        trackMenuItem.isHidden = false
        copyMenuItem.isHidden = false
        searchMenuItem.isHidden = false
        showTitleMenuItem.isHidden = false
        statusItem.button?.image = iconPause
    }
    
    func createMenuTitleStop() {
        statusItem.button!.title = ""
        statusItem.button!.appearsDisabled = false
        trackMenuItem.isHidden = true
        copyMenuItem.isHidden = true
        searchMenuItem.isHidden = true
        showTitleMenuItem.isHidden = true
        statusItem.button?.image = iconNone
    }
}
