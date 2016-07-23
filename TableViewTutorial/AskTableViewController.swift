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
    var compares = [Compare]()
    var queries = [Query]() // this is an array that will hold Asks and Compares
    var sortedQueries = [Query]()
    
    enum Shoes: String {
        case redReeboks
        case whiteConverse
        case violetVans
        case brownShiny
        case brownTooled
    }
    
    enum Jeans: String {
        case carmenJeansLight
        case carmenJeansDark
    }
    
    
    
    func loadSampleAsks() {
        
        //this is sloppy force unwrapping. Needs to be readdressed if this isn't temporary code:
        
        let photo1 = UIImage(named: "\(Shoes.redReeboks)")!
        let time1 = 0800
        let ask1 = Ask(title: "Red Reeboks", photo: photo1, timePosted: time1)
        ask1.askRating = 5.8

        let photo2 = UIImage(named: "\(Shoes.whiteConverse)")!
        let time2 = 0900
        let ask2 = Ask(title: "White Converse", photo: photo2, timePosted: time2)
        ask2.askRating = 2.5
        
        let photo3 = UIImage(named: "\(Shoes.violetVans)")!
        let time3 = 1730
        let ask3 = Ask(title: "Violet Vans", photo: photo3, timePosted: time3)
        ask3.askRating = 8.9
        
        asks += [ask1,ask2,ask3]  //+= just appends them, I believe
        print("Asks: \(asks)")
        queries.append(ask1)
        queries.append(ask2)
        queries.append(ask3)
    }
    
    func loadSampleCompares() {
        //this is sloppy force unwrapping. Needs to be readdressed if this isn't temporary code:
        
        //create a sample Jeans compare object
        let photo1 = UIImage(named: "\(Jeans.carmenJeansLight)")!
        let title1 = "Light Carmens"
        
        let photo2 = UIImage(named: "\(Jeans.carmenJeansDark)")!
        let title2 = "Dark Carmens"
        
        let time1 = 1200
        
        let compare1 = Compare(title1: title1, photo1: photo1, title2: title2, photo2: photo2, timePosted: time1)
        compare1.compareVotes1 = 10000
        compare1.compareVotes2 = 48000
        
        //create another sample Shoes compare object
        let photo1a = UIImage(named: "\(Shoes.brownShiny)")!
        let title1a = "Brown Shiny"

        let photo2a = UIImage(named: "\(Shoes.brownTooled)")!
        let title2a = "Brown Tooled"
        
        let time2 = 1405
        
        let compare2 = Compare(title1: title1a, photo1: photo1a, title2: title2a, photo2: photo2a, timePosted: time2)
        compare2.compareVotes1 = 6
        compare2.compareVotes2 = 6
        
        //compares = [compare1, compare2]
        queries.append(compare1)
        queries.append(compare2)

        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //load the sample data
        loadSampleAsks()
        loadSampleCompares()
        sortedQueries = queries.sort { $0.timePosted < $1.timePosted } //this line is going to have to appear somewhere later than ViewDidLoad
        
        //allows the row height to resize to fit the autolayout constraints
        tableView.rowHeight = UITableViewAutomaticDimension
        //it won't necessarily follow this, it's just an estimate that's required for the above line to work:
        tableView.estimatedRowHeight = 150
        
        
        //print("Queries: \(queries)")
        //print("SortedQueries: \(sortedQueries)")
        
        
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
        return sortedQueries.count
    }

    //I believe this is setting up the cell row in the table
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // here we build a single ask cell:
        if sortedQueries[indexPath.row].rowType == RowType.isSingle.rawValue {
            
            let cellIdentifier: String = "AskTableViewCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! AskTableViewCell
            let ask = sortedQueries[indexPath.row] as! Ask
        
            cell.titleLabel.text = ask.askTitle
            //cell.titleLabel.sizeToFit()
            cell.timeRemainingLabel.text = "\(ask.timePosted)" //will need to be updated to reflect time remaining
            cell.ratingLabel.text = "\(ask.askRating)"
            cell.photoImageView.image = ask.askPhoto

            return cell
            
        // here we build a dual compare cell:
        } else  if sortedQueries[indexPath.row].rowType == RowType.isDual.rawValue {
            
            let cellIdentifier: String = "CompareTableViewCell"
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! CompareTableViewCell
            let compare = sortedQueries[indexPath.row] as! Compare
            
            cell.image1.image = compare.comparePhoto1
            cell.image2.image = compare.comparePhoto2
            cell.title1Label.text = compare.compareTitle1
            cell.title2Label.text = compare.compareTitle2
            
            
            cell.scoreLabel.text = "\(compare.compareVotes1) to \(compare.compareVotes2)"
            //calculations need to be done to get time REMAINING vice time posted:
            cell.timeRemainingLabel.text = "Time Posted: \(compare.timePosted)"
            
            //set up the arrow image to point the right way:
            switch compare.winner {
            case CompareWinner.photo1Won.rawValue: cell.arrowImage.image = UIImage(named: "leftArrow")
            case CompareWinner.photo2Won.rawValue: cell.arrowImage.image = UIImage(named: "rightArrow")
            case CompareWinner.itsATie.rawValue: cell.arrowImage.image = UIImage(named: "shrug")
            default: cell.arrowImage.image = UIImage(named: "defaultPhoto")
                
            }
            
            return cell
        } else {
        //should there be error handling in here? This could be much prettier I think..
            let cell: UITableViewCell? = nil
            return cell!
    }
    
    // This was me fucking around with different ways to make it segue - it was actually just that rating label with some kind of latent naming issue.
    //override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //performSegueWithIdentifier ("showSingleAsk", sender: self)
        //presentViewController(Single Ask View Controller, animated: true, completion: nil)
        //self.navigationController?.pushViewController(singleAskViewController as! UIViewController, animated: true)
    //}
 

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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    // MARK: NEEDS TO BE UNCOMMENTED AND WORKED ON:
    
   
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // Get the new view controller using segue.destinationViewController.
        //if segue.identifier == "showSingleAsk" {
    
        if let indexPath = self.tableView.indexPathForSelectedRow {
            let passedQuery = sortedQueries[indexPath.row]
            if passedQuery.rowType == RowType.isSingle.rawValue {
                let controller = segue.destinationViewController as! AskViewController
                // Pass the selected object to the new view controller:
                controller.ask = passedQuery as! Ask
            } else if passedQuery.rowType == RowType.isDual.rawValue {
                let controller = segue.destinationViewController as! CompareViewController
                // Pass the selected object to the new view controller:
                controller.compare = passedQuery as! Compare
            }

        }
        
        /*
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let passedAsk = asks[indexPath.row]
                //print("rating in AskTableVC before passing is: \(passedAsk.askRating)")
                let controller = segue.destinationViewController as! AskViewController
                // Pass the selected object to the new view controller:
                controller.ask = passedAsk
            }
        //} */  //extranous bs
   
   
        }
 
    

}








}









