//
//  AskTableViewController.swift
//  TableViewTutorial
//
//  Created by Wyatt Weber on 7/14/16.
//  Copyright © 2016 Freedom Electric. All rights reserved.
//

import UIKit

class AskTableViewController: UITableViewController {
    
    // MARK: Properties
    
    var asks = [Ask]()
    
    enum Shoes: String {
        case redReeboks
        case whiteConverse
        case violetVans
    }
    
    
    
    func loadSampleAsks() {
        
        //this is sloppy force unwrapping. Needs to be readdressed if this isn't temporary code:
        
        let photo1 = UIImage(named: "\(Shoes.redReeboks)")!
        let ask1 = Ask(title: "Red Reeboks", rating: 5.5,photo: photo1)

        let photo2 = UIImage(named: "\(Shoes.whiteConverse)")!
        let ask2 = Ask(title: "White Converse", rating: 5.5, photo: photo2)
        
        let photo3 = UIImage(named: "\(Shoes.violetVans)")!
        let ask3 = Ask(title: "Violet Vans", rating: 5.5, photo: photo3)
        
        asks += [ask1,ask2,ask3]
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //load the sample data
        loadSampleAsks()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        //return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return asks.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier: String = "AskTableViewCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! AskTableViewCell
        
        let ask = asks[indexPath.row]
        
        cell.titleLabel.text = ask.askTitle
        cell.ratingLabel.text = "\(ask.askRating)"
        cell.photoImageView.image = ask.askPhoto

        return cell
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
