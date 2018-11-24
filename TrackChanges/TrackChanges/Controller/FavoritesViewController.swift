//
//  FavoritesViewController.swift
//  TrackChanges
//
//  Created by Nolan Earl on 11/4/18.
//  Copyright © 2018 TrackChanges. All rights reserved.
//

import UIKit
import Starscream

var FavoritesDisplayCategory = Int()

class FavoritesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, WebSocketDelegate {
    func websocketDidConnect(socket: WebSocketClient) {
        
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("In Favorites")
    }
    

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var nowPlayingImage: UIImageView!
    @IBOutlet weak var nowPlayingTitle: UILabel!
    @IBOutlet weak var nowPlayingArtist: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        socket.delegate = self
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
    
    override func viewWillAppear(_ animated: Bool) {
        socket.delegate = self
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoritesCell", for: indexPath) as! FavoritesTableViewCell
        if indexPath.row == 0 {
            cell.categoryTitle.text = "Songs"
            cell.cellImage.image = UIImage(named: "song")
            
        } else if indexPath.row == 1 {
            cell.categoryTitle.text = "Albums"
            cell.cellImage.image = UIImage(named: "album")
        } else {
            cell.categoryTitle.text = "Shared"
            cell.cellImage.image = UIImage(named: "shared")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Set the category for the next screen
        FavoritesDisplayCategory = indexPath.row
        // Go to the display list
        self.performSegue(withIdentifier: "FavoritesToList", sender: nil)
    }
}
