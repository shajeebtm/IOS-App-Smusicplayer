//
//  nowPlaying.swift
//  S music player
//
//  Created by Shajeeb T Muhammad on 2/9/19.
//  Copyright © 2019 Shajeeb T Muhammad. All rights reserved.
//

import UIKit
import CoreData
import MediaPlayer


class nowPlaying: UIViewController {

    var eventcounter: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // musicPlayer.prepareToPlay()
        // Do any additional setup after loading the view.
        self.title = "Now playing"
        
        NotificationCenter.default.addObserver(self, selector:#selector(updateNowPlayingInfo), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(movedToBackgrnd), name: UIApplication.didEnterBackgroundNotification, object: nil)
        // NotificationCenter.default.addObserver(self, selector:#selector(movedToForgrnd), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(updateNowPlayingInfo), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        print ("View appeared")
        
            
        if musicPlayer.playbackState == .playing {
           
                    let nowPlayingSongId = musicPlayer.nowPlayingItem?.persistentID
                    if nowPlayingSongId == 0 ||  nowPlayingSongId == nil {
                        print ("didnt get  nowPlayingSongId  = \(String(describing: nowPlayingSongId)) , returning")
                        return
                    }
                    if  (loadedQueueSongIds.contains(nowPlayingSongId!))  {
                        print ("Player is  playing , queue is same, not   changing pointer")
                    } else {
                        print ("current playing song is not in the queue, reloading")
                        if preloadQueueCommon(isMimic: false) {
                            musicPlayer.nowPlayingItem = chosenSong
                            musicPlayer.play()
                        }
                    }
            
            
        } else {
            print ("Player is not playing , \(musicPlayer.playbackState) hence changing pointer")
            musicPlayer.nowPlayingItem = chosenSong
            // updateNowPlayingInfo(_: self)
            musicPlayer.play()
        }
        
        songCategoryItem.text = " " + chosenCategoryName! + " : " + chosenItemName!
        updateNowPlayingInfo(self)
    }
    
    @IBOutlet weak var songCategoryItem: UILabel!
    @IBOutlet weak var songTitle: UILabel!
    
    @IBOutlet weak var songAlbum: UILabel!
    
    
    @IBOutlet weak var songComposer: UILabel!
    
    @IBOutlet weak var songSinger: UILabel!
    
    @IBOutlet weak var songLyricist: UILabel!
    
    @IBOutlet weak var songYear: UILabel!
    
    @IBOutlet weak var songComment: UILabel!
    
    
    @IBAction func returnToCategory(_ sender: UIButton) {
        // if musicPlayer.playbackState == MPMusicPlaybackState.playing {
            // musicPlayer.pause()
        // }
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func playPressed(_ sender: UIButton) {
        musicPlayer.play()
    }
    @IBAction func pausePressed(_ sender: UIButton) {
        musicPlayer.pause()
    }
    @IBAction func nextPressed(_ sender: UIButton) {
        musicPlayer.skipToNextItem()
    }
    @IBAction func prevPressed(_ sender: UIButton) {
        musicPlayer.skipToPreviousItem()
    }
    @IBAction func stopPressed(_ sender: UIButton) {
        musicPlayer.stop()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc func movedToBackgrnd() {

        print("Sad, I am in background now")
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
                return
            }
        if musicPlayer.playbackState == .playing {
            musicPlayer.stop()
        }
    }
    
    @objc func updateNowPlayingInfo(_:AnyObject){
        
        eventcounter = eventcounter + 1
        
        let nowPlayingSongId = musicPlayer.nowPlayingItem?.persistentID
        if nowPlayingSongId == 0 ||  nowPlayingSongId == nil {
            print ("didnt get  nowPlayingSongId  = \(String(describing: nowPlayingSongId)) , returning")
            return
        }
        
        let newtitle = musicPlayer.nowPlayingItem?.title ?? ""
        
        print ("eventcounter = \(eventcounter)")
        print ("nowPlayingSongId = \(String(describing: nowPlayingSongId)), newtitle = \(newtitle)")
        
        if  !(loadedQueueSongIds.contains(nowPlayingSongId!))  {
            
            print ("Load oaded queue is changed,  stopping now")
            if musicPlayer.playbackState == .playing {
                musicPlayer.stop()
            }
            self.navigationController?.popToRootViewController(animated: true)
            return
            
            
        }
        
        
        print ("Still loaded queue is being played")
        
        chosenSong = musicPlayer.nowPlayingItem
        
        print ("Playing item changed : Updating info now")
        let title = musicPlayer.nowPlayingItem?.title ?? ""
        let album = musicPlayer.nowPlayingItem?.albumTitle ?? ""
        let composer = musicPlayer.nowPlayingItem?.composer ?? ""
        let lyricist = musicPlayer.nowPlayingItem?.albumArtist ?? ""
        let singer = musicPlayer.nowPlayingItem?.artist ?? ""
        let comment = musicPlayer.nowPlayingItem?.comments ?? ""
        
        let songIndex = Int32(exactly: musicPlayer.indexOfNowPlayingItem + 1)
        let totalSongs = Int32(exactly: songsInItem)

        
        // let year = musicPlayer.nowPlayingItem?.releaseDate
        
        if let yearNumber: NSNumber = musicPlayer.nowPlayingItem?.value(forProperty: "year") as? NSNumber  {
            if (yearNumber.isKind(of: NSNumber.self)) {
                let year = yearNumber.intValue
                let ytemp = "\(year)"
                songYear.text =  " Year : " +  ytemp
            }
        } else {
            songYear.text = " Year : "
        }
       
        songTitle.text = " Song : " + title
        songAlbum.text = " Album : " + album
        songComposer.text = " Composer : " + composer
        songLyricist.text = " Lyricist : " + lyricist
        songSinger.text = " Singer : " + singer
        // songComment.text = "  Comment : " + comment
        
        let songOfTotal: String = " [" + String (describing: songIndex!)  + "/" + String (describing: totalSongs!) + "]"
        songComment.text = songOfTotal + ", Comment : " + comment
        
        print ("label updated")
    
        if songsInItem > minimumCountForHistory {    // update individual history conditionally
            let categoryAndItem1 = chosenCategoryName! + categoryItempSeparator + chosenItemName!
            if !updateDB(categoryAndItem: categoryAndItem1) {  print ("Failed to update DB") }
        } else {
             print ("lesser songs , so no DB update for individual item")
        }
        
        let categoryAndItem2 = lastPlayedIdentifier + categoryItempSeparator + chosenCategoryName! + categoryItempSeparator + chosenItemName!
        if !updateDB(categoryAndItem: categoryAndItem2) {  print ("Failed to update DB") }
        
        // if !dumpDB() {  print ("Failed to dump DB") }
        
        
    }
    
    /*
    
    func updateDB () {
        // let fixedId = song.persistentID
        // let totalSongs = Int32(exactly: 22)
        // let songId = String(describing: chosenSong?.persistentID)
        
       
        let totalSongs = Int32(exactly: songsInItem)
        let tempId = musicPlayer.nowPlayingItem?.persistentID
        // let s = tempId.map({String($0)})
        // let songId = s ?? ""
        let songId = tempId.map({String($0)}) ?? ""
        // let myUpper = songId.uppercased()
        // print ("Upper case of songId  = \(myUpper)")
        
        
        let myUpper2 = songId.uppercased()
        print ("Upper case of songId = \(myUpper2)")
        let categoryAndItem = chosenCategoryName! + ":-:" + chosenItemName!
        let songIndex = Int32(exactly: musicPlayer.indexOfNowPlayingItem)
        let playedAt = Date()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = PlayHistory.fetchRequest() as NSFetchRequest<PlayHistory>
        fetchRequest.predicate = NSPredicate(format: "categoryAndItem = %@", categoryAndItem)
        // request.predicate = NSPredicate (format: "cityName CONTAINS[cd] %@", searchString!)
        
        do {
            let fetchResults = try context.fetch(fetchRequest)
            if fetchResults.count > 0 {
                print ("OK found \(fetchResults.count) entried in DB")
                print ("Updating entry in DB with \(String(describing: categoryAndItem)) , \(String(describing: totalSongs)) , \(String(describing: songId)) , \(String(describing: songIndex)) , \(String(describing: playedAt))")
                fetchResults[0].songId = songId
                fetchResults[0].songIndex = (songIndex)!
                fetchResults[0].playedAt = playedAt
                fetchResults[0].totalSongs = totalSongs!
                
                
            } else {
                print ("NO entry found  in DB for \(categoryAndItem)")
                print ("Creating entry in DB with : \(String(describing: categoryAndItem)) , \(String(describing: totalSongs)) , \(String(describing: songId)) , \(String(describing: songIndex)) , \(String(describing: playedAt))")
                let newHistory = PlayHistory(context: context)
                newHistory.categoryAndItem = categoryAndItem
                newHistory.songId = songId
                newHistory.songIndex = (songIndex)!
                newHistory.totalSongs = totalSongs!
                newHistory.playedAt = playedAt
            }
            do {
                    try context.save()
            } catch let error {
                    print ("could not save because of \(error).")
            }
            
        } catch let error {
            print ("could not fetch because of \(error).")
        }
        
        }
    
    
     */
    
}
