//
//  GlobalVariables.swift
//  TrackChanges
//
//  Created by Pavly Habashy on 11/20/18.
//  Copyright © 2018 TrackChanges. All rights reserved.
//

import Foundation
import Starscream

// TODO: Put all this in one file
protocol MiniPlayerDelegate: class {
    func expandSong(song: Track)
}

class PlayPauseButton: UIButton {
    var isPlaying = false
}

var AppRemote: SPTAppRemote {
    get {
        return AppDelegate.sharedInstance.appRemote
    }
}

var PlayerState: SPTAppRemotePlayerState?

var GuestUser = Bool()

let PlayURI = ""
let TrackIdentifier = ""
var socket: WebSocket!
