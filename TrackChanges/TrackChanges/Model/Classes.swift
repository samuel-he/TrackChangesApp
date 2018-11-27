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
    var imageURL: URL?
    var artist: String
    var image: UIImage?
    
    init() {
        self.name = ""
        self.uri = ""
        self.album = Album()
        self.id = ""
        self.artist = ""
    }

    init(name: String, uri: String, album: Album, id: String,  image: URL, artist: String) {
        self.name = name
        self.uri = uri
        self.album = album
        self.id = id
        self.imageURL = image
        self.artist = artist
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
    var user: User
    var id: String
    var type: String
    
    var trackId: String?
    var albumId: String?
    var track = Track()
    var album = Album()
    
    init() {
        message = ""
        timestamp = ""
        user = User()
        id = ""
        type = ""
    }

    /*
    init(message: String, trackId: String) {
        self.message = message
        self.timestamp = String(Date.timeIntervalSinceReferenceDate)
        self.trackId = trackId
    }
    
    init(message: String, albumId: String) {
        self.message = message
        self.timestamp = String(NSDate().timeIntervalSince1970)
        self.albumId = albumId
    }
    
    init(message: String) {
        self.message = message
        self.timestamp = String(NSDate().timeIntervalSince1970)
    }
    */
}

class User {
    var displayName: String
    var username: String
    var imageUrl: String
    
    var image: UIImage?
    var firstName: String?
    var lastName: String?
    var following: [User]?
    var followers: [User]?
    var posts = [Post]() 
    
    init() {
        self.displayName = ""
        self.username = ""
        self.imageUrl = ""
        following = [User]()
        followers = [User]()
    }
    
    init(displayName: String, username: String, imageUrl: String) {
        self.displayName = displayName
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

extension Post: Equatable {
    static func == (lhs: Post, rhs: Post) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Post: Comparable {
    static func > (lhs: Post, rhs: Post) -> Bool {
        return lhs.id > rhs.id
    }
    
    static func < (lhs: Post, rhs: Post) -> Bool {
        return lhs.id < rhs.id
    }
}

