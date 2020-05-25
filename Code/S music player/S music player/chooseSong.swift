//
//  chooseSong.swift
//  S music player
//
//  Created by Shajeeb T Muhammad on 2/9/19.
//  Copyright © 2019 Shajeeb T Muhammad. All rights reserved.
//

import UIKit
import MediaPlayer

class chooseSong: UITableViewController {

    var songsToplay = [MPMediaItem]()
    var songstitle = [String]()
    var songsalbum = [String]()
    
    @IBOutlet weak var itemName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Select song from \(chosenCategoryName!)"
        
        // itemName.text = chosenItemName
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        populateSongs()
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return songstitle.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "songIdentifier", for: indexPath)
        cell.textLabel?.text = songstitle[indexPath.row]
        cell.detailTextLabel?.text = songsalbum[indexPath.row]

        // Configure the cell...

        return cell
    }
   

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
        chosenSong = songsToplay[indexPath.row]
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondController = storyboard.instantiateViewController(withIdentifier: "nowPlaying") as! nowPlaying
        
        print ("calling nowPlaying view")
        navigationController?.pushViewController(secondController, animated: true)
        
        // self.navigationController?.pushViewController(secondController, animated: true)
        // navigationController?.pushViewController(NewController(), animated: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // super.viewWillAppear(Bool)
        print ("View ill appear soon")
        if musicPlayer.playbackState == MPMusicPlaybackState.playing {
            musicPlayer.pause()
        }
    }
    
    
    func populateSongs () {
        print ("will show lists soon for item = \(String(describing: chosenItemName))")
        songsToplay.removeAll()
        songstitle.removeAll()
        songsalbum.removeAll()
        
        switch chosenCategoryName {
        case "Playlist":
            populatePlaylistSongs()
        case "Composer":
            populateComposerSongs()
        
        case "Singer":
            populateArtistSongs()
        
        case "Lyricist":
            populateLyricistSongs()
        
        default:
            print ("This option not yet available")
        }
        itemName.text = "\(chosenItemName!) (\(songstitle.count) songs)"
    }
    
    
    func populatePlaylistSongs () {
        let myPlaylistQuery = MPMediaQuery.playlists()
        let playlists = myPlaylistQuery.collections
        if (playlists != nil) {
            for playlist in playlists! {
                let playlistName = playlist.value(forProperty: MPMediaPlaylistPropertyName)! as? String
                if playlistName ==  chosenItemName {
                    print ("Found required playlist : \(String(describing: playlistName))!")
                    let songs = playlist.items
                    for song in songs {
                        songsToplay.append(song)
                        
                        let mytitle = song.value(forProperty: MPMediaItemPropertyTitle) as! String
                        let myalbum = song.value(forProperty: MPMediaItemPropertyAlbumTitle) as! String
                        // if (myalbum == "" ) {
                            //myalbum = "NO ALBUM"
                        //}
                        songstitle.append(mytitle )
                        songsalbum.append(myalbum)
                        // print ("\(mytitle) belongs to \(myalbum)" )
                    }
                    if musicPlayer.playbackState == .playing {
                        musicPlayer.stop()
                    }
                    musicPlayer.setQueue(with:playlist) // load new playlist
                    songsInItem = songstitle.count
                    trackLoadedQueue(loadedQueue: playlist)
                }
            }
        }
    }
    
    func populateComposerSongs () {
        
        let myPlaylistQuery = MPMediaQuery.composers()
        let collections = myPlaylistQuery.collections
        if (collections != nil) {
            for collection in collections! {
                let songs = collection.items
                let composer = songs[0].composer    // reading only first
                if composer ==  chosenItemName {
                    print ("Found required composer : \(String(describing: composer))!")

                    for song in songs {
                        songsToplay.append(song)
                        
                        let mytitle = song.value(forProperty: MPMediaItemPropertyTitle) as! String
                        let myalbum = song.value(forProperty: MPMediaItemPropertyAlbumTitle) as! String
                        // if (myalbum == "" ) {
                        //myalbum = "NO ALBUM"
                        //}
                        songstitle.append(mytitle )
                        songsalbum.append(myalbum)
                        // print ("\(mytitle) belongs to \(myalbum)" )
                    }
                    if musicPlayer.playbackState == .playing {
                        musicPlayer.stop()
                    }
                    musicPlayer.setQueue(with: collection) // load new playlist
                    songsInItem = songstitle.count
                    trackLoadedQueue(loadedQueue: collection)
                }
            }
        }
    }

    func populateArtistSongs () {
        
        let myPlaylistQuery = MPMediaQuery.artists()
        // MPMediaItemPropertyArtist
        let predicate = MPMediaPropertyPredicate(value: chosenItemName, forProperty: MPMediaItemPropertyArtist)
        myPlaylistQuery.addFilterPredicate(predicate)       // adding filter to make it  faster
        let collections = myPlaylistQuery.collections
        if (collections != nil) {
            for collection in collections! {
                let songs = collection.items
                let artist = songs[0].artist    // reading only first
                if artist ==  chosenItemName {
                    print ("Found required artists : \(String(describing: artist))!")
                    
                    for song in songs {
                        songsToplay.append(song)
                        
                        let mytitle = song.value(forProperty: MPMediaItemPropertyTitle) as! String
                        let myalbum = song.value(forProperty: MPMediaItemPropertyAlbumTitle) as! String
                        // if (myalbum == "" ) {
                        //myalbum = "NO ALBUM"
                        //}
                        songstitle.append(mytitle )
                        songsalbum.append(myalbum)
                        // print ("\(mytitle) belongs to \(myalbum)" )
                    }
                    if musicPlayer.playbackState == .playing {
                        musicPlayer.stop()
                    }
                    musicPlayer.setQueue(with: collection) // load new playlist
                    songsInItem = songstitle.count
                    trackLoadedQueue(loadedQueue: collection)
                }
            }
        }
    }
    
    
    func populateLyricistSongs () {
        let myPlaylistQuery = MPMediaQuery.songs()
        myPlaylistQuery.groupingType = MPMediaGrouping.albumArtist
        let predicate = MPMediaPropertyPredicate(value: chosenItemName, forProperty: MPMediaItemPropertyAlbumArtist)
        myPlaylistQuery.addFilterPredicate(predicate)       // adding filter to make it  faster
        let collections = myPlaylistQuery.collections
        print ("populateLyricistSongs : found \(String(describing: collections?.count)) items in query result")
        if (collections != nil) {
            for collection in collections! {
                let songs = collection.items
                let artist = songs[0].albumArtist    // reading only first
                if artist ==  chosenItemName {
                    print ("Found required artists : \(String(describing: artist))!")
                    
                    for song in songs {
                        songsToplay.append(song)
                        
                        let mytitle = song.value(forProperty: MPMediaItemPropertyTitle) as! String
                        let myalbum = song.value(forProperty: MPMediaItemPropertyAlbumTitle) as! String
                        // if (myalbum == "" ) {
                        //myalbum = "NO ALBUM"
                        //}
                        songstitle.append(mytitle )
                        songsalbum.append(myalbum)
                        // print ("\(mytitle) belongs to \(myalbum)" )
                    }
                    if musicPlayer.playbackState == .playing {
                        musicPlayer.stop()
                    }
                    musicPlayer.setQueue(with: collection) // load new playlist
                    songsInItem = songstitle.count
                    trackLoadedQueue(loadedQueue: collection)
                }
            }
        }
    }
    
}
