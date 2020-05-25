//
//  resumeLast.swift
//  S music player
//
//  Created by Shajeeb T Muhammad on 2/14/19.
//  Copyright © 2019 Shajeeb T Muhammad. All rights reserved.
//

import UIKit
import MediaPlayer
import CoreData

class resumeLast: UIViewController {

    @IBAction func anotherSongClicked(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondController = storyboard.instantiateViewController(withIdentifier: "chooseSong") as! chooseSong
        print ("calling next view from resmeLast")
        navigationController?.pushViewController(secondController, animated: true)
    }
    
    
    @IBOutlet weak var songCategoryItem: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var songAlbum: UILabel!
    @IBOutlet weak var songComposer: UILabel!
    @IBOutlet weak var songLyricist: UILabel!
    @IBOutlet weak var songYear: UILabel!
    @IBOutlet weak var songComment: UILabel!
    @IBOutlet weak var songPlayedAt: UILabel!
    
    @IBAction func playButton(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondController = storyboard.instantiateViewController(withIdentifier: "nowPlaying") as! nowPlaying
        
        print ("calling nowPlaying view")
        navigationController?.pushViewController(secondController, animated: true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // print ("View ill appear soon")
        if musicPlayer.playbackState == MPMusicPlaybackState.playing {
            musicPlayer.pause()
        }
        playButton.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print ("View appeared")
        if findLastPlayedCategoryItemSong() {
            if preloadQueueCommon(isMimic: false) {
                playButton.isHidden = false
            } else {
                print ("oho , queue didnt get loaded")
            }
        } else {
            print ("oho , could find last played song")
        }
        
    }
    
    func findLastPlayedCategoryItemSong() -> Bool{
  
        var toBeplayedID: String
        
        let categoryAndItem = chosenCategoryName! + ":-:" + chosenItemName!
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = PlayHistory.fetchRequest() as NSFetchRequest<PlayHistory>
        
        songCategoryItem.text = " " + chosenCategoryName! + " : " + chosenItemName!
        
        fetchRequest.predicate = NSPredicate(format: "categoryAndItem = %@", categoryAndItem)
        // fetchRequest.predicate = NSPredicate (format: "categoryAndItem CONTAINS[cd] %@", lastPlayedIdentifier)
        let sortDescriptor1 = NSSortDescriptor(key: "playedAt", ascending: true)    // sort by playedAt date
        fetchRequest.sortDescriptors = [sortDescriptor1]
        
        do {
            let  fetchResults = try context.fetch(fetchRequest)
            if fetchResults.count > 0 {
                print ("OK found \(fetchResults.count) entried in DB")
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
                    let title = myCollections![0].title ?? ""
                    let album = myCollections![0].albumTitle ?? ""
                    let composer = myCollections![0].composer ?? ""
                    let lyricist = myCollections![0].albumArtist ?? ""
                    let comment = myCollections![0].comments ?? ""
                    
                    
                    if let yearNumber: NSNumber = myCollections![0].value(forProperty: "year") as? NSNumber  {
                        if (yearNumber.isKind(of: NSNumber.self)) {
                            let year = yearNumber.intValue
                            let ytemp = "\(year)"
                            songYear.text =  " Year : " +  ytemp
                        }
                    } else {
                        songYear.text = " Year : "
                    }
                    
                    
                    
                    
                    let categoryAndItemOverall = lastInHistory.categoryAndItem
                    let category = categoryAndItemOverall!.components(separatedBy: categoryItempSeparator)[0]
                    let item = categoryAndItemOverall!.components(separatedBy: categoryItempSeparator)[1]
                    print ("Found : Title = \(title) , Album = \(album) , Category = \(category) , Item = \(item)")
                    
                    songTitle.text = " Title : " + title
                    songAlbum.text = " Album : " + album
                    songComposer.text = " Composer : " + composer
                    songLyricist.text = " Lyrics : " + lyricist
                    songComment.text = " Comment : " + comment
                    
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
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
