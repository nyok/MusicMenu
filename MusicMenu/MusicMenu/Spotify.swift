//
//  Spotify.swift
//  MusicMenu
//

import AppKit
import ScriptingBridge

// MARK: SpotifyEPlS
@objc public enum SpotifyEPlS : AEKeyword {
    case stopped = 0x6b505353 /* 'kPSS' */
    case playing = 0x6b505350 /* 'kPSP' */
    case paused = 0x6b505370 /* 'kPSp' */
}

// MARK: SpotifyApplication
@objc public protocol SpotifyApplication: SBApplicationProtocol {
    @objc optional var currentTrack: SpotifyTrack { get } // The current playing track.
    @objc optional var playerState: SpotifyEPlS { get } // Is Spotify stopped, paused, or playing?
}
extension SBApplication: SpotifyApplication {}

// MARK: SpotifyTrack
@objc public protocol SpotifyTrack: SBObjectProtocol {
    @objc optional var artist: String { get } // The artist of the track.
    @objc optional var name: String { get } // The name of the track.
}
extension SBObject: SpotifyTrack {}
