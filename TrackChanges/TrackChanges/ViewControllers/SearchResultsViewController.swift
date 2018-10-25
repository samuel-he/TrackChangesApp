
//
//  SearchResultsViewController.swift
//  TrackChanges
//
//  Created by Nolan Earl on 10/20/18.
//  Copyright © 2018 TrackChanges. All rights reserved.
//

import UIKit

class SearchResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var allButton: UIButton!
    @IBOutlet weak var songsButton: UIButton!
    @IBOutlet weak var albumsButton: UIButton!
    @IBOutlet weak var peopleButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Set tableView background color
        tableView.backgroundView = nil
        tableView.backgroundColor = UIColor.white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Change cancel button color
        let cancelButtonAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
        UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes , for: .normal)
    }
 
    /****
    *** Filters search results
    ****/
    
    @IBAction func switchTab(_ sender: UIButton) {
        switch sender.tag {
            
        case 1:
            allButton.setTitleColor(UIColor.black, for: .normal)
        case 2:
            songsButton.setTitleColor(UIColor.black, for: .normal)
        case 3:
            albumsButton.setTitleColor(UIColor.black, for: .normal)
        case 4:
            peopleButton.setTitleColor(UIColor.black, for: .normal)
        default:
            return
        }
    }
    
    /////
    // Go back to the previous screen
    /////
    
    @IBAction func previous(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: "SearchHeader") as! SearchResultsTitleTableViewCell
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Check which kind of cell was tapped
        if let cell = tableView.cellForRow(at: indexPath) as? PeopleSearchTableViewCell {
            // Go to person's profile
            self.performSegue(withIdentifier: "SearchResultsToProfile", sender: nil)
        } else if let cell = tableView.cellForRow(at: indexPath) as? SongSearchTableViewCell {
            print("Song")
        } else if let cell = tableView.cellForRow(at: indexPath) as? AlbumSearchTableViewCell {
            self.performSegue(withIdentifier: "SearchResultsToAlbum", sender: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
           let cell = tableView.dequeueReusableCell(withIdentifier: "PeopleCell", for: indexPath) as! PeopleSearchTableViewCell
            return cell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as! SongSearchTableViewCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumCell", for: indexPath) as! AlbumSearchTableViewCell
            return cell
        }
    }
    
    
    /*
 
        Handle Search Bar
 
    */
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        view.endEditing(true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
