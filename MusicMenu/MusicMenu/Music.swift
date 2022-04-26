//
//  Music.swift
//  MusicMenu
//

import AppKit
import ScriptingBridge

// MARK: MusicEPlS
@objc public enum MusicEPlS : AEKeyword {
    case stopped = 0x6b505353 /* 'kPSS' */
    case playing = 0x6b505350 /* 'kPSP' */
    case paused = 0x6b505370 /* 'kPSp' */
}

// MARK: MusicApplication
@objc public protocol MusicApplication: SBApplicationProtocol {
    @objc optional var currentTrack: MusicTrack { get } // The current playing track.
    @objc optional var playerState: MusicEPlS { get } // Is Spotify stopped, paused, or playing?
}
extension SBApplication: MusicApplication {}

// MARK: MusicTrack
@objc public protocol MusicTrack: SBObjectProtocol {
    @objc optional var artist: String { get } // The artist of the track.
    @objc optional var name: String { get } // The name of the track.
}
extension SBObject: MusicTrack {}
