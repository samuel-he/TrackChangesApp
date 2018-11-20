# TrackChanges

[![Language: Swift 3.0](https://img.shields.io/badge/swift-3.0-orange.svg?style=flat)](https://developer.apple.com/swift) 
[![Language: Java 8.0](https://img.shields.io/badge/java-8.0-brown.svg?style=flat)](https://www.java.com/en/) 

*TrackChanges* is a social media platform that is built on top of a music app, allowing users to listen to their favorite music, and share music content with other users.

![TrackChanges logo](TrackChangesLogo.png =250x250)

## License

    Copyright [2018] [Track Changes]

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

## Progress after submitting Complete Code
What works:
-Users can currently login
-Users can add post
-Users can get feed
-Users can follow other users
-Users can unfollow other users
-Users can play songs from the Spotify API in the mini-player and now-playing
-Mini-player can pause, start, go to next track, and go to previous track
-Discover page fully works; retrieves new releases, recommendations, and explore new albums/songs from Spotify API
-User image from Spotify API displays correctly on all pages  
-Users can search for other albums, songs, and users; database is populated correctly
-Multi-threading functionality is working; multiple users can connect and server can handle multiple threads

What doesn't work:
-Guest functionality
-Unable to delete post
-Users are unable to like or unlike
-When you search for users, there is inconsistency with retrieving posts and followers/following from database
-When user shares a post, there is inconsistency with getting notifications of the posts that the users that they are following added