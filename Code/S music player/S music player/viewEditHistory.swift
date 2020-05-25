//
//  viewEditHistory.swift
//  S music player
//
//  Created by Shajeeb T Muhammad on 2/24/19.
//  Copyright © 2019 Shajeeb T Muhammad. All rights reserved.
//

import UIKit
import MediaPlayer
import CoreData

class viewEditHistory: UITableViewController {

    var histories = [PlayHistory]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = PlayHistory.fetchRequest() as NSFetchRequest<PlayHistory>
        let sortDescriptor1 = NSSortDescriptor(key: "playedAt", ascending: false)    // sort by playedAt date
        fetchRequest.sortDescriptors = [sortDescriptor1]
        
        do {
            histories = try context.fetch(fetchRequest)
        } catch let error {
            print ("could not fetch because of \(error).")
        }
        histories.remove(at: 0) // to remove the latest item 'lastPlayedIdentifier'
        tableView.reloadData()
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return histories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyIdentifier", for: indexPath)
        let history = histories[indexPath.row]
        let playedAt = history.playedAt
        let songIndex = history.songIndex
        let totalSongs = history.totalSongs
        let categoryAndItemOverall = history.categoryAndItem
        let category = categoryAndItemOverall!.components(separatedBy: categoryItempSeparator)[0]
        let item = categoryAndItemOverall!.components(separatedBy: categoryItempSeparator)[1]
        let songOfTotal: String = " [" + String (describing: songIndex)  + "/" + String (describing: totalSongs) + "]"
        cell.textLabel?.text = category + " : " + item
        cell.detailTextLabel?.text = songOfTotal + " : " + dateFormatter.string(from: playedAt! )
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print ("Good, you selected \(indexPath)")
        // let cell = tableView.dequeueReusableCell(withIdentifier: "historyIdentifier", for: indexPath)
        let currentCell = tableView.cellForRow(at: indexPath)!
        let categoryAndItemOverall = currentCell.textLabel?.text
        chosenCategoryName  = categoryAndItemOverall!.components(separatedBy: " : ")[0]
        chosenItemName = categoryAndItemOverall!.components(separatedBy: " : ")[1]
        print ("you are interested in -> \(String(describing: chosenCategoryName)) , \(String(describing: chosenItemName))")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondController = storyboard.instantiateViewController(withIdentifier: "resumeLast") as! resumeLast
        print ("calling next view")
        navigationController?.pushViewController(secondController, animated: true)
        
    
        
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // print ("we will try to delete row at \(indexPath.row)")
            let currentCell = tableView.cellForRow(at: indexPath)!
            let categoryAndItemOverall = currentCell.textLabel?.text
            let playerAt = currentCell.detailTextLabel?.text
    
            let alertMessage = categoryAndItemOverall! + "\n" + playerAt!
            let alert = UIAlertController(title: "Delete entry from history", message: alertMessage, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Delete", style: .default, handler:{action in      // decided to delete
                //print ("Ok fine, will delete this time")
                if self.histories.count > indexPath.row {
                    let history = self.histories[indexPath.row]
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    let context = appDelegate.persistentContainer.viewContext
                    context.delete(history)
                    self.histories.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    do {
                        try context.save()
                    }catch let error {
                        print ("could not save after dletion: because of \(error).")
                    }
                }
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {action in      // decided to cancel
                //print ("Ok fine, no delete this time")
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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

}
