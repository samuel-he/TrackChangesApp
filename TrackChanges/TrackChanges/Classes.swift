//
//  Classes.swift
//  TrackChanges
//
//  Created by Nolan Earl on 11/12/18.
//  Copyright © 2018 TrackChanges. All rights reserved.
//

import Foundation

class Album {
    var name: String
    var uri: String
    var artist: Artist
    var image: String
    var id: String
    var tracks = [Track]()
    
    init() {
        self.name = ""
        self.uri = ""
        self.artist = Artist()
        self.image = ""
        self.id = ""
    }
    
    init(name: String, uri: String, artist: Artist, image: String, id: String) {
        self.name = name
        self.uri = uri
        self.artist = artist
        self.image = image
        self.id = id
    }
}

class Track {
    var name: String
    var uri: String
    var album: Album
    var id: String
    
    init() {
        self.name = ""
        self.uri = ""
        self.album = Album()
        self.id = ""
    }

    init(name: String, uri: String, album: Album, id: String) {
        self.name = name
        self.uri = uri
        self.album = album
        self.id = id
    }

}

class Artist {
    var name: String
    var uri: String
    var id: String
    
    init() {
        self.name = ""
        self.uri = ""
        self.id = ""
    }

    init(name: String, uri: String, id: String) {
        self.name = name
        self.uri = uri
        self.id = id 
    }
}

class Post {
    var message: String
    var timestamp: String
    var track: Track?
    var album: Album?

    init(message: String, track: Track) {
        self.message = message
        self.timestamp = String(Date.timeIntervalSinceReferenceDate)
        self.track = track
    }
    
    init(message: String, album: Album) {
        self.message = message
        self.timestamp = String(Date.timeIntervalSinceReferenceDate)
        self.album = album
    }
    
    init(message: String) {
        self.message = message
        self.timestamp = String(Date.timeIntervalSinceReferenceDate)
    }
}

class User {
    var firstName: String
    var lastName: String
    var username: String
    var imageUrl: String
    var following = [User]()
    var followers = [User]()
    
    init() {
        self.firstName = ""
        self.lastName = ""
        self.username = ""
        self.imageUrl = ""
    }
    
    init(firstName: String, lastName: String, username: String, imageUrl: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.username = username
        self.imageUrl = imageUrl
    }
}

class Feed {
    var posts: [Post]
    
    init() {
        self.posts = [Post]()
    }
    
    init(posts: [Post]) {
        self.posts = posts 
    }
    
    func addPost(post: Post) {
        posts.append(post) 
    }
}



