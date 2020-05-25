//
//  chooseList.swift
//  S music player
//
//  Created by Shajeeb T Muhammad on 2/8/19.
//  Copyright © 2019 Shajeeb T Muhammad. All rights reserved.
//

import UIKit
import MediaPlayer

class chooseList: UITableViewController {

    var lists = [String]()
    var displayLists = [String]()           // only for Playlist category
    var childParent: [String: String] = [:] // only for Playlist category
    // var activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
    let indicator:UIActivityIndicatorView = UIActivityIndicatorView  (style: UIActivityIndicatorView.Style.gray)
    let dispatchQueue = DispatchQueue(label: "Example Queue")

   
    override func loadView() {
        super.loadView()
        indicator.color = UIColor .magenta
        // indicator.frame = CGRectMake(0.0, 0.0, 10.0, 10.0)
        indicator.center = self.view.center
        tableView.backgroundView = indicator

        // self.view.addSubview(indicator)
        // indicator.bringSubviewToFront(self.view)
        // activityIndicatorView = UIActivityIndicatorView(style: .gray)
        // tableView.backgroundView = activityIndicatorView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Select " + "\(chosenCategoryName!)"
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // print ("Reached here with category : \(chosenCategoryName!)")
        // populateLists()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        indicator.startAnimating()
        tableView.separatorStyle = .none
        print ("Reached here with category : \(chosenCategoryName!)")
        
        dispatchQueue.async { Thread.sleep(forTimeInterval: 0.5)
                OperationQueue.main.addOperation() {
                    self.populateLists()            // populating list of items
                    self.indicator.stopAnimating()
                    self.tableView.separatorStyle = .singleLine
                    self.tableView.reloadData()
               }
            print ("out of OperationQueue now")
        }
        
        print ("out of displatchQueue now")

        // populateLists()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return lists.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "listIdentifier", for: indexPath)
        
        if chosenCategoryName == "Playlist" {
            cell.textLabel?.text = displayLists[indexPath.row]
        } else {
            cell.textLabel?.text = lists[indexPath.row]
        }
        
        return cell
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // your code
        print ("Good, you selected \(indexPath)")
        // let cell = tableView.dequeueReusableCell(withIdentifier: "listIdentifier", for: indexPath)
        
        chosenItemName = lists[indexPath.row]
        
        // cell.textLabel?.text = birthday.firstName + " " + birthday.lastName
        // cell.detailTextLabel?.text = dateFormatter.string(from: birthday.birthdate)
        
        
        // let secondViewController = self.?storyboard.instantiateViewControllerWithIdentifier("showSelectedBirthdays") as showSelectedBirthdays
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        // let secondController = storyboard.instantiateViewController(withIdentifier: "chooseSong") as! chooseSong
        let secondController = storyboard.instantiateViewController(withIdentifier: "resumeLast") as! resumeLast

        print ("calling next view")
        navigationController?.pushViewController(secondController, animated: true)
        
        // self.navigationController?.pushViewController(secondController, animated: true)
        // navigationController?.pushViewController(NewController(), animated: true)
        
    }
        
        
        
    func populateLists () {
        print ("will show lists soon for category = \(chosenCategoryName)")
        lists.removeAll()
        switch chosenCategoryName {
        case "Playlist":
            populatePlaylistLists()
        case "Composer":
            populateComposerLists()
        case "Singer":
            populateArtistLists()
        case "Lyricist":
            populateLyricistLists()
        default:
            print ("This option not yet available")
        }
        
        
    }
    
    func populatePlaylistLists () {
        let myPlaylistQuery = MPMediaQuery.playlists()
        let playlists = myPlaylistQuery.collections
        if (playlists != nil) {
            for playlist in playlists! {
                let playlistName = playlist.value(forProperty: MPMediaPlaylistPropertyName)! as! String
                // let attributes = playlist.value(forProperty: MPMediaPlaylistPropertyPlaylistAttributes)
                let songs = playlist.items
                let isFolder = playlist.value(forProperty: "isFolder")!
                let myId = playlist.value(forProperty: MPMediaPlaylistPropertyPersistentID)!
                let myTempParentId = playlist.value(forProperty: "parentPersistentID") as! NSNumber
                let myParentId = String (describing: myTempParentId)
                // let myParentId = myParentIdtemp
                // print ("\(playlistName) contains \(songs.count) songs, attributes = \(attributes)")
                
                /*
                if (String(describing: "isFolder") == "0") {
                    let myParentId = playlist.value(forProperty: "parentPersistentID")!
                    print ("\(String(describing: playlistName)) contains \(songs.count) songs, isFolder = \(String(describing: isFolder))")
                }
                */
                
                let isPlaylistFolder = String (describing: isFolder)
                
                // childParent.updateValue(myParentId as Any, forKey: playlistName)
                
                childParent[playlistName]=String (describing: myParentId)  // populating dictionary
                childParent[String (describing: myId)] = playlistName
                // childParent[myId] = myParentId
                
                if isPlaylistFolder.contains("0") {     // this playlist is not a folder
                    print ("\(String(describing: playlistName)) contains \(songs.count) songs, isFolder = \(String(describing: isPlaylistFolder)) , myId = \(String(describing: myId)) , parent = \(myParentId)")
                    if (songs.count > 0) {
                        lists.append(playlistName)
                    }
                } else {    // skip playlist folders
                    print ("FOLDER : \(String(describing: playlistName)) contains \(songs.count) songs, isFolder = \(String(describing: isPlaylistFolder)) , myId = \(String(describing: myId)) , parent = \(myParentId)")
                }
                
                
            }
            /*
            print ("lets check what is inside childParent")
            
            for key in childParent.keys {
                print ("\(key) --> \(String(describing: childParent[key]))")
            }
 
            
            print ("")
            print ("Starting tree mapping for ALL ")
            print ("")
            
            */
           
            for f in lists {    // lists contains only non-folder playlists
                // print ("Starting tree mapping with \(f)")
                var mykey = f
                var myres = f
                var isOddCounter: Bool = true
                
                while (mykey != "0" ) {
                    // print ("Prev mykey = \(mykey)")
                    if childParent[mykey] != nil  {
                        mykey = String (describing:  childParent[mykey]!)
                    } else {
                        mykey = "0"
                        isOddCounter = true
                    }
                    // print ("New mykey = \(mykey)")
                    if isOddCounter {
                        isOddCounter = false
                    } else {
                        // myres = mykey + "/" + myres
                        myres = myres  + "/" + mykey
                        isOddCounter = true
                    }
                }
                print (myres)
                displayLists.append(myres)
            }
 
          
           
            
        }
        
    }
    
    func populateComposerLists () {
        let myPlaylistQuery = MPMediaQuery.composers()
        let collections = myPlaylistQuery.collections
        var counter = 0
        if (collections != nil) {
            for collection in collections! {
                counter += 1
                let songs = collection.items
                let composer = songs[0].composer    // reading only first songs's composer name
                let count = songs.count
                // print ("Composer = \(composer) , songs = \(count)")
                if (songs.count > 0) {
                    lists.append(composer!)
                }
                /*
                for song in songs {
                    let myTitle = song.title
                    let myAlbum = song.albumTitle
                    let myComposer = song.composer
                    print ("Album = \(myAlbum) , Title = \(myTitle) , Composer = \(myComposer)")
                }
                */
                
            }
        }
        print ("Total of \(counter) composers")
        
    }
    
    
    
    func populateArtistLists () {
        let myPlaylistQuery = MPMediaQuery.artists()
        let collections = myPlaylistQuery.collections
        var counter = 0
        if (collections != nil) {
            for collection in collections! {
                counter += 1
                let songs = collection.items
                let artist = songs[0].artist    // reading only first songs's composer name
                let count = songs.count
                // print ("Composer = \(artist) , songs = \(count)")
                if (songs.count > 0) {
                    lists.append(artist!)
                }

            }
        }
        print ("Total of \(counter) artists")

        
    }
    
    func populateLyricistLists () {
        let myPlaylistQuery = MPMediaQuery.songs()
        myPlaylistQuery.groupingType = MPMediaGrouping.albumArtist
        let collections = myPlaylistQuery.collections
        var counter = 0
        if (collections != nil) {
            for collection in collections! {
                counter += 1
                let songs = collection.items
                let lyricist = songs[0].albumArtist    // reading only first songs's composer name
                if (lyricist != nil) {
                    let count = songs.count
                    // print ("Lyricist = \(lyricist) , songs = \(count)")
                    if (songs.count > 0) {
                        lists.append(lyricist!)
                    }
                }
            }
        }
        print ("Total of \(counter) lyricists")
        
        
    }
    
}
