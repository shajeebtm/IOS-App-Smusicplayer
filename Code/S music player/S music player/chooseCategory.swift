//
//  ViewController.swift
//  S music player
//
//  Created by Shajeeb T Muhammad on 2/8/19.
//  Copyright © 2019 Shajeeb T Muhammad. All rights reserved.
//

import UIKit
import MediaPlayer
import CoreData

/*
var chosenCategoryName: String?
var chosenItemName: String?
var chosenItemID: String?
var chosenSong: MPMediaItem?
var musicPlayer = MPMusicPlayerController.systemMusicPlayer
*/

class chooseCategory: UIViewController {
    
    @IBAction func chosePlaylist(_ sender: UIButton) {
        chosenCategoryName = "Playlist"
        gotoItems()
    }
    
    @IBAction func chosePlaylistIcon(_ sender: UIButton) {
        chosenCategoryName = "Playlist"
        gotoItems()
    }
    
    @IBAction func choseComposer(_ sender: UIButton) {
        chosenCategoryName = "Composer"
        gotoItems()
    }
    
    @IBAction func choseComposerIcon(_ sender: UIButton) {
        chosenCategoryName = "Composer"
        gotoItems()
    }
    
    
    @IBAction func choseSinger(_ sender: UIButton) {
        chosenCategoryName = "Singer"
        gotoItems()
    }
    
    @IBAction func choseSingerIcon(_ sender: UIButton) {
        chosenCategoryName = "Singer"
        gotoItems()
    }
    
    @IBAction func choseLyricist(_ sender: UIButton) {
        chosenCategoryName = "Lyricist"
        gotoItems()
    }
    
    @IBAction func choseLyricistIcon(_ sender: UIButton) {
        chosenCategoryName = "Lyricist"
        gotoItems()
    }
    
    @IBAction func gotoHistory(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondController = storyboard.instantiateViewController(withIdentifier: "viewEditHistory") as! viewEditHistory
        print ("calling  viewEditHistory view from chooseCategory")
        navigationController?.pushViewController(secondController, animated: true)
    }
    
    @IBOutlet weak var songTitle: UILabel!
    
    @IBOutlet weak var songAlbum: UILabel!
    
    @IBOutlet weak var songCategory: UILabel!
    
    @IBOutlet weak var songPlayedAt: UILabel!
    
    @IBOutlet weak var playButton: UIButton!
    
    @IBAction func playClicked(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondController = storyboard.instantiateViewController(withIdentifier: "nowPlaying") as! nowPlaying
        print ("calling nowPlaying view from chooseCategory")
        navigationController?.pushViewController(secondController, animated: true)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
     
        songTitle.text = "Title  : "
        // if !emptyDB () {print ("Unable to empty DB")}
        if !dumpDB () {print ("DB dump failed")}
        // getlastPlayedSong ()
        
        // NotificationCenter.default.addObserver(self, selector:#selector(movedToForgrnd), name: UIApplication.didBecomeActiveNotification, object: nil)
    
    }

    
    override func viewWillAppear(_ animated: Bool) {
        // super.viewWillAppear(Bool)
    print ("View ill appear soon")
       // removed on 03/04/2019
        /*
        if musicPlayer.playbackState == .playing {
            musicPlayer.pause()
        }
        */
        playButton.isHidden = true
    
 }
 
    
    override func viewDidAppear(_ animated: Bool) {
        print ("View appeared")
        if findLastPlayedAnySong() {
            if musicPlayer.playbackState == .playing {
                if preloadQueueCommon(isMimic: true) {      //not loading Queue, only populating other parameters
                    print ("Mimiced , didnt really load queue")
                    let nowPlayingSongId = musicPlayer.nowPlayingItem?.persistentID
                    print ("nowPlayingSongId = \(String(describing: nowPlayingSongId))")
                    if loadedQueueSongIds.contains(nowPlayingSongId!) {
                        print ("Still loaded queue is being played")
                        let songTitle = musicPlayer.nowPlayingItem?.title
                        let alertMessage = chosenCategoryName! + ":" + chosenItemName! + ":" + songTitle!
                        let alert = UIAlertController(title: "Resume currenly playing", message: alertMessage, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler:{action in
                            print ("OK will resume")
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let secondController = storyboard.instantiateViewController(withIdentifier: "nowPlaying") as! nowPlaying
                            print ("calling nowPlaying view from chooseCategory")
                            self.navigationController?.pushViewController(secondController, animated: true)
                        }))
                        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: {action in      // decided to cancel
                            //print ("Ok fine, ")
                            if preloadQueueCommon(isMimic: false) {     //loading Queue & populating other parameters
                                musicPlayer.pause()
                                print ("NOT mimiced , really loaded queue")
                                self.playButton.isHidden = false
                            }
                        }))
                        self.present(alert, animated: true, completion: nil)
                        // playButton.isHidden = false
                    }else {         // means some other queue is being played
                        musicPlayer.pause() // it is already playing so can be paused
                        if preloadQueueCommon(isMimic: false) {     //loading Queue & populating other parameters
                            print ("NOT mimiced , really loaded queue")
                            playButton.isHidden = false
                        }
                    }
                }
            } else {
                if preloadQueueCommon(isMimic: false) {     //loading Queue & populating other parameters
                    print ("NOT mimiced , really loaded queue")
                    playButton.isHidden = false
                }
            }
            
            
        } else {
            print ("oho , could find last played song")
        }

    }
 
    
    func gotoItems () {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondController = storyboard.instantiateViewController(withIdentifier: "chooseList") as! chooseList
        
        // secondController.detailText = "Name = \(firstName)  \(lastName)\nDate = \(String (describing: birthdate))\nID = \(birthIdentifier)"
        
        print ("calling next view")
        navigationController?.pushViewController(secondController, animated: true)
        
    }
    
    func findLastPlayedAnySong() -> Bool{
        /*
        if (chosenSong != nil){     // already I know about the last played song, mostly coming from other views
            songTitle.text = "Title : " + (chosenSong?.title!)!
            songAlbum.text = "Album : " + (chosenSong?.albumTitle!)!
            songCategory.text = chosenCategoryName! + " : " + chosenItemName!
            songPlayedAt.text =  "Last : " + dateFormatter.string(from: Date() )
            return true
        }
        */
        
        var toBeplayedID: String
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = PlayHistory.fetchRequest() as NSFetchRequest<PlayHistory>
        
        // fetchRequest.predicate = NSPredicate(format: "categoryAndItem = %@", categoryAndItem)
        fetchRequest.predicate = NSPredicate (format: "categoryAndItem CONTAINS[cd] %@", lastPlayedIdentifier)
        let sortDescriptor1 = NSSortDescriptor(key: "playedAt", ascending: true)    // sort by playedAt date
        fetchRequest.sortDescriptors = [sortDescriptor1]
        
        do {
            let  fetchResults = try context.fetch(fetchRequest)
            if fetchResults.count > 0 {
                print ("OK found \(fetchResults.count) entries in DB")
                // toBeplayedID = fetchResults[fetchResults.count-1].songId? as String
                let lastInHistory = fetchResults[fetchResults.count-1]
                toBeplayedID =  lastInHistory.songId ?? ""
                let playedAt = lastInHistory.playedAt
                let songIndex = lastInHistory.songIndex
                let totalSongs = lastInHistory.totalSongs
                print ("ID of last played Songs = \(String(describing: toBeplayedID))")
                
                let predicate = MPMediaPropertyPredicate(value: toBeplayedID, forProperty: MPMediaItemPropertyPersistentID)
                musicQuery.addFilterPredicate(predicate)
                let myCollections = musicQuery.items
                
                musicQuery.removeFilterPredicate(predicate) // clearing filters for next time operation
                
                
                if (myCollections?.count)! > 0 {
                    let count = myCollections!.count
                    print ("Found the last played song : \(String(describing: count)) , ID = \(toBeplayedID)")
                    let title = myCollections![0].title!
                    let album = myCollections![0].albumTitle!
                    let categoryAndItemOverall = lastInHistory.categoryAndItem
                    let category = categoryAndItemOverall!.components(separatedBy: categoryItempSeparator)[1]
                    let item = categoryAndItemOverall!.components(separatedBy: categoryItempSeparator)[2]
                    print ("Found : Title = \(title) , Album = \(album) , Category = \(category) , Item = \(item)")
                    songTitle.text = " Title : " + title
                    songAlbum.text = " Album : " + album
                    songCategory.text = " " + category + " : " + item
                    // songPlayedAt.text =  "Last : " + dateFormatter.string(from: playedAt! )
                    let songOfTotal: String = " [" + String (describing: songIndex)  + "/" + String (describing: totalSongs) + "]"
                    songPlayedAt.text = songOfTotal + " : " + dateFormatter.string(from: playedAt! )
                    chosenSong = myCollections![0]          // setting Global value for chosenSong
                    chosenItemName = item                   // setting Global value for chosenItemName
                    chosenCategoryName = category           // setting Global value for chosenCategoryName
                    
                } else {
                    print ("I couldnt find the song with ID : \(toBeplayedID)")
                    return false
                }
            } else {
                print ("NO entry found  in DB")
                return false
            }
        } catch let error {
            print ("could not fetch because of \(error).")
            return false
        }
        // chosenSong =
        return true
        
    }
    
    
    @objc func movedToForgrnd() {
        
        print("Great I am active now")
        _ = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { timer in
            print("Short timer fired!")
        }
        let nowPlayingSongId = musicPlayer.nowPlayingItem?.persistentID
        
        print ("nowPlayingSongId = \(String(describing: nowPlayingSongId))")
        if loadedQueueSongIds.contains(nowPlayingSongId!) {
            print ("Still loaded queue is being played")
            if musicPlayer.playbackState == .playing {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let secondController = storyboard.instantiateViewController(withIdentifier: "nowPlaying") as! nowPlaying
                print ("calling nowPlaying view from movedToForgrnd:chooseCategory  ")
                navigationController?.pushViewController(secondController, animated: true) // so that it will update history records
            } else {
              return
            }
        }
        if musicPlayer.playbackState == .playing {
            musicPlayer.stop()
        }
    }
  
   
    /*
    func getlastPlayedSong (){
        
        var toBeplayedID: String
    
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = PlayHistory.fetchRequest() as NSFetchRequest<PlayHistory>
        let sortDescriptor1 = NSSortDescriptor(key: "playedAt", ascending: true)    // sort by playedAt date
        fetchRequest.sortDescriptors = [sortDescriptor1]
        
        do {
            let  fetchResults = try context.fetch(fetchRequest)
            if fetchResults.count > 0 {
                print ("OK found \(fetchResults.count) entried in DB")
                // toBeplayedID = fetchResults[fetchResults.count-1].songId? as String
                let lastInHistory = fetchResults[fetchResults.count-1]
                toBeplayedID =  lastInHistory.songId ?? ""
                
                // toBeplayedID = "6012215651297255000"
                print ("ID of last played Songs = \(String(describing: toBeplayedID))")

                let predicate = MPMediaPropertyPredicate(value: toBeplayedID, forProperty: MPMediaItemPropertyPersistentID)
                musicQuery.addFilterPredicate(predicate)
                let myCollections = musicQuery.items
                
                musicQuery.removeFilterPredicate(predicate) // clearing filters for next time operation
              
                
                if (myCollections?.count)! > 0 {
                    let count = myCollections!.count
                    print ("Found the last played song : \(String(describing: count)) , ID = \(toBeplayedID)")
                    let title = myCollections![0].title!
                    let album = myCollections![0].albumTitle!
                    let categoryAndItem = lastInHistory.categoryAndItem
                    let category = categoryAndItem!.components(separatedBy: categoryItempSeparator)[0]
                    let item = categoryAndItem!.components(separatedBy: categoryItempSeparator)[1]
                    print ("Found : Title = \(title) , Album = \(album) , Category = \(category) , Item = \(item)")
                    songTitle.text = "Title : " + title
                } else {
                    print ("I couldnt find the song with ID : \(toBeplayedID)")
                }
            } else {
                print ("NO entry found  in DB")
            }
        } catch let error {
            print ("could not fetch because of \(error).")
        }
 
     
        // let newID = Int64(toBeplayedID)
        /*
        let myPlaylistQuery = MPMediaQuery.songs()
        let predicate = MPMediaPropertyPredicate(value: interestedPlaylist, forProperty: MPMediaPlaylistPropertyName)
        query.addFilterPredicate(predicate)
        
        let collections = myPlaylistQuery.collections
        */
    }

    */
}

