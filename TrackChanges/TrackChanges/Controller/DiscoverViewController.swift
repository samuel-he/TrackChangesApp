//
//  DiscoverViewController.swift
//  TrackChanges
//
//  Created by Nolan Earl on 10/14/18.
//  Copyright © 2018 TrackChanges. All rights reserved.
//

import UIKit
import Starscream

var SearchResults = [String: Any]()
var TrackResults = [Track]()
var AlbumResults = [Album]()
var UserResults = [User]()

var DiscoverRecommendations = [Track]()
var DiscoverNewReleases = [Album]()

var SelectedAlbum = Album()

class DiscoverViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate, UISearchControllerDelegate, WebSocketDelegate {
    
    
    var miniPlayer: MiniPlayerViewController?
    
    @IBOutlet weak var tableView: UITableView!
    
    let search = UISearchController(searchResultsController: nil)

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        search.delegate = self
        search.searchBar.delegate = self
        self.navigationItem.searchController = search
        
        socket.delegate = self
        
        getNewReleases()
        getRecommendations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        socket.delegate = self
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DiscoverCell", for: indexPath) as! DiscoverTableViewCell
        // Title of each section
        if indexPath.row == 0 {
            cell.contentTitle.text = "New Releases"
            cell.collectionView.tag = 1
        } else if indexPath.row == 1 {
            cell.contentTitle.text = "Recommendations"
            cell.collectionView.tag = 2
        } else if indexPath.row == 2 {
            cell.contentTitle.text = "Explore"
            cell.collectionView.tag = 3
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 1 {
            return DiscoverNewReleases.count
        } else if collectionView.tag == 2 {
            return DiscoverRecommendations.count / 2
        } else if collectionView.tag == 3 {
            return DiscoverRecommendations.count / 2
        }
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiscoverContentCell", for: indexPath) as! DiscoverCollectionViewCell
        
        // Use correct list based on the collectionview
        if collectionView.tag == 1 {
            cell.artistName.text = DiscoverNewReleases[indexPath.row].artist.name
            
            cell.contentImage.contentMode = .scaleAspectFit
            let url = URL.init(string: DiscoverNewReleases[indexPath.row].image)!
            do {
                let data = try Data(contentsOf: url)
                cell.contentImage.image = UIImage.init(data: data)
            } catch {
                print(error.localizedDescription)
            }
            
            cell.contentTitle.text = DiscoverNewReleases[indexPath.row].name
        } else if collectionView.tag == 2 {
            cell.contentTitle.text = DiscoverRecommendations[indexPath.row].name
            
            cell.contentImage.contentMode = .scaleAspectFit
            let url = URL.init(string: DiscoverRecommendations[indexPath.row].album.image)!
            do {
                let data = try Data(contentsOf: url)
                cell.contentImage.image = UIImage.init(data: data)
            } catch {
                print(error.localizedDescription)
            }
            
            cell.artistName.text = DiscoverRecommendations[indexPath.row].album.artist.name
        } else if collectionView.tag == 3 {
            cell.contentTitle.text = DiscoverRecommendations[indexPath.row + DiscoverRecommendations.count / 2].name
            
            cell.contentImage.contentMode = .scaleAspectFit
            let url = URL.init(string: DiscoverRecommendations[indexPath.row + DiscoverRecommendations.count / 2].album.image)!
            do {
                let data = try Data(contentsOf: url)
                cell.contentImage.image = UIImage.init(data: data)
            } catch {
                print(error.localizedDescription)
            }
            
            cell.artistName.text = DiscoverRecommendations[indexPath.row + DiscoverRecommendations.count / 2].album.artist.name
        }
        return cell
    }
    
    /**
    * Function parses selected album json for its tracks
    ***/
    
    func parseAlbum(json: [String: Any], selectedAlbum: Album) {
        var albumTracks = [Track]()
        
        if let items = json["items"] as? [[String: Any]] {
            for item in items {
                
                var trackInAlbum = Track()
                
                //  Get track
                if let trackName = item["name"] as? String {
                    trackInAlbum.name = trackName
                }
                if let trackUri = item["uri"] as? String {
                    trackInAlbum.uri = trackUri
                }
                if let trackId = item["id"] as? String {
                    trackInAlbum.id = trackId
                }
                // Add the track to the list of album tracks
                albumTracks.append(trackInAlbum)
            }
        }
    
        // Add the tracks to the selected album
        SelectedAlbum.tracks = albumTracks
        
        for track in SelectedAlbum.tracks {
            track.album = SelectedAlbum
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Create selected album for next screen
        if collectionView.tag == 1 {
            SelectedAlbum = DiscoverNewReleases[indexPath.row]
        } else if collectionView.tag == 2 {
            SelectedAlbum = DiscoverRecommendations[indexPath.row].album
        } else {
            SelectedAlbum = DiscoverRecommendations[indexPath.row + DiscoverRecommendations.count / 2].album
        }
        
        // MAKE API CALL FOR ALBUM TRACKS
        
        // Request accecssToken
        let client = "4bebf0c82b774aaa99764eb7c5c58cc4:3be8d087faf841ea805d6d9842c0cbf0"
        let base64 = client.data(using: String.Encoding.utf8)?.base64EncodedString() ?? ""
        
        let tokenUrl = "https://accounts.spotify.com/api/token"
        var albumUrl = "https://api.spotify.com/v1/albums/"
        
        // Request access token to make search requests
        var tokenRequest = URLRequest(url: URL.init(string: tokenUrl)!)
        tokenRequest.addValue("Basic \(base64)", forHTTPHeaderField: "Authorization")
        tokenRequest.httpBody = "grant_type=client_credentials".data(using: .utf8)
        tokenRequest.httpMethod = "POST"
        
        var accessToken = String()
        
        URLSession.shared.dataTask(with: tokenRequest) { (data, response, error) in
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        accessToken = (json["access_token"] as? String)!
                        
                        // Make request to get tracks for SelectedAlbum
                        albumUrl += SelectedAlbum.id
                        albumUrl += "/tracks"
                        
                        var albumRequest = URLRequest(url: URL.init(string: albumUrl)!)
                        albumRequest.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                        
                        URLSession.shared.dataTask(with: albumRequest) { (data, response, error) in
                            if let data = data {
                                do {
                                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                        self.parseAlbum(json: json, selectedAlbum: SelectedAlbum)
                                        
                                        DispatchQueue.main.async {
                                            self.performSegue(withIdentifier: "DiscoverToAlbum", sender: nil)
                                        }
                                        
                                    }
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                            }.resume()
                        
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }.resume()
    }
    
    // MARK: Search bar functionality
    
    /**
     * Function to parse track json from Spotify
     **/
    
    func parseTracks(json: [String: Any]) {
        if let tracks = json["tracks"] as? [String: Any] {
            if let items = tracks["items"] as? [[String: Any]] {
                
                for track in items {
                    
                    var trackResult = Track()
                    
                    // Get track info
                    if let uri = track["uri"] as? String {
                        trackResult.uri = uri
                    }
                    if let name = track["name"] as? String {
                        trackResult.name = name
                    }
                    
                    if let trackId = track["id"] as? String {
                        trackResult.id = trackId
                    }
                    
                    var albumForTrack = Album()
                    
                    var artistForAlbum = Artist()
                    
                    // Get the artist of the track
                    if let album = track["album"] as? [String: Any] {
                        if let albumName = album["name"] as? String {
                            albumForTrack.name = albumName
                        }
                        if let albumUri = album["uri"] as? String {
                            albumForTrack.uri = albumUri
                        }
                        
                        if let albumId = album["id"] as? String {
                            albumForTrack.id = albumId
                        }
                        
                        if let artists = album["artists"] as? [[String: Any]] {
                            // Get artist name
                            if let artistName = artists[0]["name"] as? String {
                                artistForAlbum.name = artistName
                            }
                            // Get artist uri
                            if let artistUri = artists[0]["uri"] as? String {
                                artistForAlbum.uri = artistUri
                            }
                            // Get artist id
                            if let artistId = artists[0]["id"] as? String {
                                artistForAlbum.id = artistId
                            }
                        }
                        
                        albumForTrack.artist = artistForAlbum
 
                        // Get album cover
                        if let images = album["images"] as? [[String: Any]] {
                            if let url = images[0]["url"] as? String {
                                albumForTrack.image = url
                            }
                        }
                    }
                    
                    // Add album to track
                    trackResult.album = albumForTrack
                    
                    // Add results to track results
                    TrackResults.append(trackResult)
    
                }
            }
        }
    }
    
    /**
     * Function to parse album json from Spotify
     **/
    
    func parseAlbums(json: [String: Any]) {
        if let albums = json["albums"] as? [String: Any] {
            if let items = albums["items"] as? [[String: Any]] {
                for album in items {
                    
                    var albumResult = Album()
                    
                    if let uri = album["uri"] as? String {
                        albumResult.uri = uri
                    }
                    if let name = album["name"] as? String {
                        albumResult.name = name
                    }
                    
                    if let albumId = album["id"] as? String {
                        albumResult.id = albumId
                    }
                    
                    var artistForAlbum = Artist()
                    
                    if let artists = album["artists"] as? [[String: Any]] {
                        if let artistName = artists[0]["name"] as? String {
                            artistForAlbum.name = artistName
                        }
                        if let artistUri = artists[0]["uri"] as? String {
                            artistForAlbum.uri = artistUri
                        }
                        
                        if let artistId = artists[0]["id"] as? String {
                            artistForAlbum.id = artistId
                        }
                    }
                    
                    // Add artist to the album
                    albumResult.artist = artistForAlbum
                    
                    if let images = album["images"] as? [[String: Any]] {
                        if let url = images[0]["url"] as? String {
                            albumResult.image = url
                        }
                    }
                
                    
                    AlbumResults.append(albumResult)
                }
            }
        }
    }
    
    /**
    * Function to parse new release json from Spotify
    **/
    
    func parseNewReleases(json: [String: Any]) {
        if let albums = json["albums"] as? [String: Any] {
            if let items = albums["items"] as? [[String: Any]] {
                for album in items {
                    
                    var albumResult = Album()
                    
                    if let uri = album["uri"] as? String {
                        albumResult.uri = uri
                    }
                    if let name = album["name"] as? String {
                        albumResult.name = name
                    }
                    
                    if let albumId = album["id"] as? String {
                        albumResult.id = albumId
                    }
                    
                    var artistForAlbum = Artist()
                    
                    if let artists = album["artists"] as? [[String: Any]] {
                        if let artistName = artists[0]["name"] as? String {
                            artistForAlbum.name = artistName
                        }
                        if let artistUri = artists[0]["uri"] as? String {
                            artistForAlbum.uri = artistUri
                        }
                        
                        if let artistId = artists[0]["id"] as? String {
                            artistForAlbum.id = artistId
                        }
                    }
                    
                    // Add the artist to the album
                    albumResult.artist = artistForAlbum
                    
                    if let images = album["images"] as? [[String: Any]] {
                        if let url = images[0]["url"] as? String {
                            albumResult.image = url
                        }
                    }
                    
                    
                    DiscoverNewReleases.append(albumResult)
                }
            }
            
            DispatchQueue.main.async {
                let cell = self.tableView.cellForRow(at: IndexPath.init(row: 1, section: 0)) as? DiscoverTableViewCell
                cell?.collectionView.reloadData()
            }
            
            DispatchQueue.main.async {
                let cell = self.tableView.cellForRow(at: IndexPath.init(row: 2, section: 0)) as? DiscoverTableViewCell
                cell?.collectionView.reloadData()
            }
        }
        
        DispatchQueue.main.async {
            let cell = self.tableView.cellForRow(at: IndexPath.init(row: 0, section: 0)) as! DiscoverTableViewCell
            cell.collectionView.reloadData()
        }
        
    }
    
    /**
     * Function to parse recommendation json from Spotify
     **/
    
    func parseRecommendations(json: [String: Any]) {
        if let tracks = json["tracks"] as? [[String: Any]] {
            for track in tracks {
                
                // The recommendation result
                var trackResult = Track()
                
                if let trackUri = track["uri"] as? String {
                    trackResult.uri = trackUri
                }
                
                if let trackName = track["name"] as? String {
                    trackResult.name = trackName
                }
                
                if let trackId = track["id"] as? String {
                    trackResult.id = trackId
                }
                // Album for the track
                var albumForTrack = Album()
                // Artist for the album/track
                var artistForAlbum = Artist()
                
                if let album = track["album"] as? [String: Any] {
                    if let albumName = album["name"] as? String {
                        albumForTrack.name = albumName
                    }
                    if let albumUri = album["uri"] as? String {
                        albumForTrack.uri = albumUri
                    }
    
                    if let albumId = album["id"] as? String {
                        albumForTrack.id = albumId
                    }
                    
                    if let artists = album["artists"] as? [[String: Any]] {
                        if let artistName = artists[0]["name"] as? String {
                            artistForAlbum.name = artistName
                        }
                        if let artistUri = artists[0]["uri"] as? String {
                            artistForAlbum.uri = artistUri
                        }
                        
                        if let artistId = artists[0]["id"] as? String {
                            artistForAlbum.id = artistId
                        }
                    }
                    
                    albumForTrack.artist = artistForAlbum
                    
                    if let images = album["images"] as? [[String: Any]] {
                        if let url = images[0]["url"] as? String {
                            albumForTrack.image = url
                        }
                    }
                    
                    trackResult.album = albumForTrack
                }
                
                // Add result to results list
                DiscoverRecommendations.append(trackResult)
            }
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    var tokenUrl = "https://accounts.spotify.com/api/token"
    // Base url for spotify search
    var searchUrl = "https://api.spotify.com/v1/search?q="
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Clear search results
        TrackResults.removeAll()
        AlbumResults.removeAll()
        UserResults.removeAll()
        SearchResults.removeAll()
        
        tokenUrl = "https://accounts.spotify.com/api/token"
        searchUrl = "https://api.spotify.com/v1/search?q="
        
        
        // Send request to database to search for users
        
        let json:NSMutableDictionary = NSMutableDictionary()
        
        json.setValue("search_users", forKey: "request")
        json.setValue(self.search.searchBar.text, forKey: "search_term")
        
        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions())
        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        
        print(jsonString)
        
        socket.write(data: jsonData)

        // Request accecssToken
        let client = "4bebf0c82b774aaa99764eb7c5c58cc4:3be8d087faf841ea805d6d9842c0cbf0"
        let base64 = client.data(using: String.Encoding.utf8)?.base64EncodedString() ?? ""
        
        
        // Request access token to make search requests
        var tokenRequest = URLRequest(url: URL.init(string: tokenUrl)!)
        tokenRequest.addValue("Basic \(base64)", forHTTPHeaderField: "Authorization")
        tokenRequest.httpBody = "grant_type=client_credentials".data(using: .utf8)
        tokenRequest.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: tokenRequest) { (data, response, error) in
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        let accessToken = (json["access_token"] as? String)!
                        
                        // MARK: SEARCH
                        
                        DispatchQueue.main.async {
                            // Get search parameter
                            self.searchUrl += self.search.searchBar.text!
                            self.searchUrl += "&type=album,artist,track"
                            self.searchUrl += "&limit=10"
                            self.searchUrl = self.searchUrl.replacingOccurrences(of: " ", with: "%20")
                            
                            var searchRequest = URLRequest(url: URL.init(string: self.searchUrl)!)
                            
                            searchRequest.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                            
                            URLSession.shared.dataTask(with: searchRequest) { (data, response, error) in
                                if let data = data {
                                    do {
                                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                            self.parseTracks(json: json)
                                            self.parseAlbums(json: json)
                                            
                                            DispatchQueue.main.async {
                                                self.performSegue(withIdentifier: "Search", sender: self)
                                            }
                                        }
                                    } catch {
                                        print(error.localizedDescription)
                                    }
                                }
                            }.resume()
                        }
                        
                        
                        
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }.resume()
        
    }
    
    
    // MARK: WebSocket Delegate functions
    func websocketDidConnect(socket: WebSocketClient) {
        
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        if let e = error as? WSError {
            print("websocket is disconnected: \(e.message)")
        } else if let e = error {
            print("websocket is disconnected: \(e.localizedDescription)")
        } else {
            print("websocket disconnected")
        }
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("Received text: \(text)")
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("Received data: \(data.count)")
        let jsonString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
        print(jsonString)
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            let jsonString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
            print(jsonString)
            if json["response"] as? String == "search_results" {
                let userResults = json["search_results"] as! [[String: Any]]
                for user in userResults {
                    var userResult = User()
                    userResult.imageUrl = user["user_imageurl"] as! String
                    userResult.username = user["user_id"] as! String
                    userResult.displayName = user["user_displayname"] as! String
                    
                    UserResults.append(userResult)
                }
            }
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: Spotify Browse to populate discover
    
    var newReleaseUrl = "https://api.spotify.com/v1/browse/new-releases"
    var releaseAccessToken = ""
    
    func getNewReleases() {
        
        let client = "4bebf0c82b774aaa99764eb7c5c58cc4:3be8d087faf841ea805d6d9842c0cbf0"
        let base64 = client.data(using: String.Encoding.utf8)?.base64EncodedString() ?? ""
        
        var tokenRequest = URLRequest(url: URL.init(string: tokenUrl)!)
        tokenRequest.addValue("Basic \(base64)", forHTTPHeaderField: "Authorization")
        tokenRequest.httpBody = "grant_type=client_credentials".data(using: .utf8)
        tokenRequest.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: tokenRequest) { (data, response, error) in
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        self.releaseAccessToken = (json["access_token"] as? String)!
                        
                        // MARK: CALL FOR NEW RELEASES
                        
                        DispatchQueue.main.async {
                            var newReleaseRequest = URLRequest(url: URL.init(string: self.newReleaseUrl)!)
                            newReleaseRequest.addValue("Bearer \(self.releaseAccessToken)", forHTTPHeaderField: "Authorization")
                            URLSession.shared.dataTask(with: newReleaseRequest) { (data, response, error) in
                                if let data = data {
                                    do {
                                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                            self.parseNewReleases(json: json)
                                        }
                                    } catch {
                                        print(error.localizedDescription)
                                    }
                                }
                            }.resume()
                        }
                        
                        
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }.resume()
    }
    
    var recommendationsUrl = "https://api.spotify.com/v1/recommendations?limit=25&seed_genres=alternative,hip-hop,rock,r-n-b,electronic"
    
    func getRecommendations() {
        let client = "4bebf0c82b774aaa99764eb7c5c58cc4:3be8d087faf841ea805d6d9842c0cbf0"
        let base64 = client.data(using: String.Encoding.utf8)?.base64EncodedString() ?? ""
        
        var tokenRequest = URLRequest(url: URL.init(string: tokenUrl)!)
        tokenRequest.addValue("Basic \(base64)", forHTTPHeaderField: "Authorization")
        tokenRequest.httpBody = "grant_type=client_credentials".data(using: .utf8)
        tokenRequest.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: tokenRequest) { (data, response, error) in
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        
                        let recommendationsAccessToken = (json["access_token"] as? String)!
                        
                        
                        DispatchQueue.main.async {
                            var recommendationsRequest = URLRequest(url: URL.init(string: self.recommendationsUrl)!)
                            recommendationsRequest.addValue("Bearer \(recommendationsAccessToken)", forHTTPHeaderField: "Authorization")
                            
                            URLSession.shared.dataTask(with: recommendationsRequest) { (data, response, error) in
                                if let data = data {
                                    do {
                                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                            self.parseRecommendations(json: json)
                                        }
                                    } catch {
                                        print(error.localizedDescription)
                                    }
                                }
                            }.resume()
                        }
                        
                        
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }.resume()
    }
}
