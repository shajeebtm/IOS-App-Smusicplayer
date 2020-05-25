//
//  sMusicPlayer.swift
//  S music player
//
//  Created by Shajeeb T Muhammad on 2/10/19.
//  Copyright © 2019 Shajeeb T Muhammad. All rights reserved.
//


import UIKit
import MediaPlayer
import CoreData

var chosenCategoryName: String?
var chosenItemName: String?
var chosenSong: MPMediaItem?
var songsInItem: Int = 0
//var lastPlayedSongId: String?


let categoryItempSeparator = ":-:"
let lastPlayedIdentifier = "THELASTPLAYEDSONG"
let minimumCountForHistory: Int = 10
var loadedQueueSongIds = [MPMediaEntityPersistentID]()
// var isQueueReady: Bool = false


var musicPlayer = MPMusicPlayerController.systemMusicPlayer
let musicQuery = MPMediaQuery()

let dateFormatter = DateFormatter()


func dumpDB() -> Bool {
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .medium
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = appDelegate.persistentContainer.viewContext
    let fetchRequest = PlayHistory.fetchRequest() as NSFetchRequest<PlayHistory>
    
    let sortDescriptor1 = NSSortDescriptor(key: "playedAt", ascending: true)    // sort by playedAt date
    fetchRequest.sortDescriptors = [sortDescriptor1]

    
    print ("====== Start DB dump ========")
    do {
        let  fetchResults = try context.fetch(fetchRequest)
        if fetchResults.count > 0 {
            print ("OK found \(fetchResults.count) entried in DB")
            for history in fetchResults {
                let categoryAndItem = history.categoryAndItem!
                let totalSongs = history.totalSongs
                let songId = history.songId!
                let songIndex = history.songIndex
                //let playedAt = history.playedAt
                let playedAt = dateFormatter.string(from: history.playedAt! )
                print ("\(String(describing: categoryAndItem)) , \(totalSongs) , \(String(describing: songId)) , \(songIndex) , \(String(describing: playedAt))")
            }
        } else {
            print ("NO entry found  in DB")
            return false
        }
    } catch let error {
        print ("could not fetch because of \(error).")
        return false
    }
    
    print ("====== END  DB dump ========")

    return true
    
}

func updateDB(categoryAndItem: String) -> Bool {

    let categoryAndItem = categoryAndItem
    
    
    /*
    _ = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { timer in
        print("Short timer fired, proceed to update DB")
    }
    */
    
    let totalSongs = Int32(exactly: songsInItem)!
    let tempId = musicPlayer.nowPlayingItem?.persistentID
    //print ("func updateDB : tempId = \(String(describing: tempId))")
    // let s = tempId.map({String($0)})
    // let songId = s ?? ""
    let songId = tempId.map({String($0)}) ?? ""
    // let myUpper = songId.uppercased()
    // print ("Upper case of songId  = \(myUpper)")
    
    
    // let myUpper2 = songId.uppercased()
    // print ("Upper case of songId = \(myUpper2)")
    // let categoryAndItem = chosenCategoryName! + categoryItempSeparator + chosenItemName!
    let songIndex = Int32(exactly: musicPlayer.indexOfNowPlayingItem)!
    let playedAt = Date()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = appDelegate.persistentContainer.viewContext
    
    let fetchRequest = PlayHistory.fetchRequest() as NSFetchRequest<PlayHistory>
    fetchRequest.predicate = NSPredicate(format: "categoryAndItem = %@", categoryAndItem)
    if categoryAndItem.contains(lastPlayedIdentifier) {
        fetchRequest.predicate = NSPredicate(format: "categoryAndItem CONTAINS[cd] %@", lastPlayedIdentifier)
    }
    // request.predicate = NSPredicate (format: "cityName CONTAINS[cd] %@", searchString!)
    
    do {
        let fetchResults = try context.fetch(fetchRequest)
        if fetchResults.count > 0 {
            print ("OK found \(fetchResults.count) entried in DB , deleting")
            
            /*
            print ("Updating entry in DB with \(String(describing: categoryAndItem)) , \(String(describing: totalSongs)) , \(String(describing: songId)) , \(String(describing: songIndex)) , \(String(describing: playedAt))")
            fetchResults[0].songId = songId
            fetchResults[0].songIndex = songIndex + 1
            fetchResults[0].playedAt = playedAt
            fetchResults[0].totalSongs = totalSongs
            */
            context.delete(fetchResults[0])     // delete entry and create one
            
        } else {
            print ("NO entry found  in DB for \(categoryAndItem)")
        }
        
        // else {
            // print ("NO entry found  in DB for \(categoryAndItem)")
            print ("Creating entry in DB with : \(String(describing: categoryAndItem)) , \(String(describing: totalSongs)) , \(String(describing: songId)) , \(String(describing: songIndex)) , \(String(describing: playedAt))")
            let newHistory = PlayHistory(context: context)
            newHistory.categoryAndItem = categoryAndItem
            newHistory.songId = songId
            newHistory.songIndex = songIndex + 1
            newHistory.totalSongs = totalSongs
            newHistory.playedAt = playedAt
        // }
        do {
            try context.save()
        } catch let error {
            print ("could not save because of \(error).")
            return false
        }
        
    } catch let error {
        print ("could not fetch because of \(error).")
        return false
    }
    return true
}


func emptyDB() -> Bool {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = appDelegate.persistentContainer.viewContext
    let fetchRequest = PlayHistory.fetchRequest() as NSFetchRequest<PlayHistory>
    
    
   
    let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
    do {
        try context.execute(batchDeleteRequest)
        print ("Successfully emptied DB")
    }
    catch {
        print(error)
        return false
    }
    return true
    
    
}

func preloadQueueCommon(isMimic: Bool) -> Bool{
    let isMimic = isMimic
    print ("queue NOT  loaded, trying to load now with isMimic = \(isMimic) ")
    switch chosenCategoryName {
    case "Playlist":
        if preloadPlaylistSongs(isMimic: isMimic) { return true }
    case "Composer":
        if preloadComposerSongs(isMimic: isMimic) { return true }
    case "Singer":
        if preloadArtistSongs(isMimic: isMimic) { return true }
    case "Lyricist":
        if preloadLyricistSongs(isMimic: isMimic) { return true }
        
    default:
        print ("This option not yet available")
        return false
    }
    return false
}

func preloadPlaylistSongs(isMimic: Bool) -> Bool {
    let myPlaylistQuery = MPMediaQuery.playlists()
    let playlists = myPlaylistQuery.collections
    if (playlists != nil) {
        for playlist in playlists! {
            let playlistName = playlist.value(forProperty: MPMediaPlaylistPropertyName)! as? String
            if playlistName ==  chosenItemName {
                print ("Found required playlist : \(String(describing: playlistName))!")
                let songs = playlist.items
                
                for song in songs {
                    if song == chosenSong {
                        if !isMimic {
                            musicPlayer.setQueue(with: playlist)
                        }
                        songsInItem = playlist.count
                        trackLoadedQueue(loadedQueue: playlist)
                        return true
                    }
                }
                return false
            }
        }
    }
    return false
}

func preloadComposerSongs(isMimic: Bool) -> Bool {
    let myPlaylistQuery = MPMediaQuery.composers()
    let collections = myPlaylistQuery.collections
    if (collections != nil) {
        for collection in collections! {
            let songs = collection.items
            let composer = songs[0].composer!
            if composer ==  chosenItemName {    // check if required composer found
                print ("Found required composer : \(String(describing: composer))!")
                for song in songs {
                    if song == chosenSong {     // check if chosen song exists in composer
                        print ("found  needed song")
                        if !isMimic {
                            musicPlayer.setQueue(with: collection)
                        }
                        songsInItem = collection.count
                        trackLoadedQueue(loadedQueue: collection)
                        return true
                    }
                }
                print ("Couldnt find needed song")
                return false
            }
        }
    }
    print ("Couldnt find required composer")
    return false
}


func preloadArtistSongs(isMimic: Bool) -> Bool {
    let myPlaylistQuery = MPMediaQuery.artists()
    let collections = myPlaylistQuery.collections
    if (collections != nil) {
        for collection in collections! {
            let songs = collection.items
            let artist = songs[0].artist!
            if artist ==  chosenItemName {    // check if required composer found
                print ("Found required artist : \(String(describing: artist))!")
                for song in songs {
                    if song == chosenSong {     // check if chosen song exists in composer
                        print ("found  needed song")
                        if !isMimic {
                            musicPlayer.setQueue(with: collection)
                        }
                        songsInItem = collection.count
                        trackLoadedQueue(loadedQueue: collection)
                        return true
                    }
                }
                print ("Couldnt find needed song")
                return false
            }
        }
    }
    print ("Couldnt find required artist")
    return false
}

func preloadLyricistSongs(isMimic: Bool) -> Bool {
    let myPlaylistQuery = MPMediaQuery.songs()
    myPlaylistQuery.groupingType = MPMediaGrouping.albumArtist
    let predicate = MPMediaPropertyPredicate(value: chosenItemName, forProperty: MPMediaItemPropertyAlbumArtist)
    myPlaylistQuery.addFilterPredicate(predicate)       // adding filter to make it  faster
    let collections = myPlaylistQuery.collections
    if (collections != nil) {
        for collection in collections! {
            let songs = collection.items
            let artist = songs[0].albumArtist!
            if artist ==  chosenItemName {    // check if required composer found
                print ("Found required artist : \(String(describing: artist))!")
                for song in songs {
                    if song == chosenSong {     // check if chosen song exists in composer
                        print ("found  needed song")
                        if !isMimic {
                            musicPlayer.setQueue(with: collection)
                        }
                        songsInItem = collection.count
                        trackLoadedQueue(loadedQueue: collection)
                        return true
                    }
                }
                print ("Couldnt find needed song")
                return false
            }
        }
    }
    print ("Couldnt find required artist")
    return false
}

func trackLoadedQueue(loadedQueue: MPMediaItemCollection) {
    loadedQueueSongIds.removeAll()
    let loadedQueue = loadedQueue
    // let count = loadedQueue.count
    // print ("Loaded queue has \(count) items")
    let songs = loadedQueue.items
    
    for song in songs {
        let songId = song.persistentID
        // print ("ID = \(songId)")
        loadedQueueSongIds.append(songId)
    }
}
