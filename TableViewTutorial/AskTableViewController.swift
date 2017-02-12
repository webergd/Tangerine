//
//  AskTableViewController.swift   //This file needs a better name
//  TableViewTutorial
//
//  Created by Wyatt Weber on 7/14/16.
//  Copyright © 2016 Freedom Electric. All rights reserved.
//

import UIKit

class AskTableViewController: UITableViewController {
    
    // MARK: Properties
    
    //var asks = [Ask]()
    //var compares = [Compare]()
    var queries: [Query] = mainArray // this is an array that will hold Asks and Compares
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
        
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        
        
        //this is sloppy force unwrapping. Needs to be readdressed if this isn't temporary code:
        //except it is most definitely temporary code
        
        let photo1 = UIImage(named: "\(Shoes.redReeboks)")!
        let time1 = formatter.date(from: "2016/08/09 00:01")! //force unwrap bc it's temp anyway
        let ask1 = Ask(title: "Red Reeboks", photo: photo1, timePosted: time1)
        let ask1SW = ask1.breakdown.straightWomen as! AskDemo
        let ask1GM = ask1.breakdown.gayMen as! AskDemo
        ask1SW.rating = 5
        ask1SW.numVotes = 1
        ask1GM.rating = 6
        ask1GM.numVotes = 10

        let photo2 = UIImage(named: "\(Shoes.whiteConverse)")!
        let time2 = formatter.date(from: "2016/08/09 00:11")!
        let ask2 = Ask(title: "White Converse", photo: photo2, timePosted: time2)
        let ask2GW = ask2.breakdown.gayWomen as! AskDemo
        ask2GW.rating = 6
        ask2GW.numVotes = 5
 
        let photo3 = UIImage(named: "\(Shoes.violetVans)")!
        let time3 = formatter.date(from: "2016/08/09 00:06")!
        let ask3 = Ask(title: "Violet Vans", photo: photo3, timePosted: time3)
        let ask3SM = ask3.breakdown.straightMen as! AskDemo
        ask3SM.rating = 9.8
        ask3SM.numVotes = 90
        
        //I think this is a pointless line of code:
        //asks += [ask1,ask2,ask3]  //+= just appends them, I believe
        //print("Asks: \(asks)")
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
        
        let time1 = formatter.date(from: "2016/08/09 00:04")!
        
        let compare1 = Compare(title1: title1, photo1: photo1, title2: title2, photo2: photo2, timePosted: time1)
        let compare1SW = compare1.breakdown.straightWomen as! CompareDemo
        let compare1SM = compare1.breakdown.straightMen as! CompareDemo
        let compare1GW = compare1.breakdown.gayWomen as! CompareDemo
        let compare1GM = compare1.breakdown.gayMen as! CompareDemo
        
        compare1SW.votesForOne = 10
        compare1SW.votesForTwo = 12
        compare1SM.votesForOne = 6
        compare1SM.votesForTwo = 33
        compare1GW.votesForOne = 3
        compare1GW.votesForTwo = 16
        compare1GM.votesForOne = 60
        compare1GM.votesForTwo = 77
        
        //create another sample Shoes compare object
        let photo1a = UIImage(named: "\(Shoes.brownShiny)")!
        let title1a = "Brown Shiny"

        let photo2a = UIImage(named: "\(Shoes.brownTooled)")!
        let title2a = "Brown Tooled"
        
        let time2 = formatter.date(from: "2016/08/09 00:08")!
        
        let compare2 = Compare(title1: title1a, photo1: photo1a, title2: title2a, photo2: photo2a, timePosted: time2)
        let compare2SW = compare2.breakdown.straightWomen as! CompareDemo
        let compare2SM = compare2.breakdown.straightMen as! CompareDemo
        
        compare2SW.votesForOne = 100
        compare2SW.votesForTwo = 100
        compare2SM.votesForOne = 550
        compare2SM.votesForTwo = 550
        
        
        //compares = [compare1, compare2]
        queries.append(compare1)
        queries.append(compare2)

        
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //load the sample data
        loadSampleAsks()
        loadSampleCompares()
        sortedQueries = queries.sorted { $0.timePosted.timeIntervalSince1970 < $1.timePosted.timeIntervalSince1970 } //this line is going to have to appear somewhere later than ViewDidLoad
        
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
    
    
    // This happens when the main tableView is displayed again when navigating back to it from asks and compares
    override func viewDidAppear(_ animated: Bool) {
        // MARK: There is an issue here with 
        // the way that the table is reloading after we introduce
        // a cell from an ask that was made by the CameraViewController
        // It may have something to do with the way that we are 
        // loading up the queries array (local) from the main array (public)
        // ###################################################
        
        // This refreshes the time remaining labels in the cells every time we come back to the main tableView
        
      
        
        var index = 0
        for query in sortedQueries {
            let indexPath = IndexPath(row: index, section: 0)
            if query.rowType == RowType.isSingle.rawValue {
                // cellForRowAtIndexPath returns an optional cell so we use if let and then cast it as an optional ask cell
                // one of the times it returns nil is when the cell isn't visible
                if let cell = tableView.cellForRow(at: indexPath) as! AskTableViewCell? {
                    let ask = sortedQueries[indexPath.row] as! Ask
                    let timeRemaining = calcTimeRemaining(ask.timePosted)
                    cell.timeRemainingLabel.text = "\(timeRemaining)"
                }
            } else if query.rowType == RowType.isDual.rawValue {
                if let cell = tableView.cellForRow(at: indexPath) as! CompareTableViewCell? {
                    let compare = sortedQueries[indexPath.row] as! Compare
                    let timeRemaining = calcTimeRemaining(compare.timePosted)
                    cell.timeRemainingLabel.text = "\(timeRemaining)"
                }
            }
            index += 1
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        //return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return sortedQueries.count
    }


    //I believe this is setting up the cell row in the table
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // here we build a single ask cell:
        if sortedQueries[indexPath.row].rowType == RowType.isSingle.rawValue {
            
            let cellIdentifier: String = "AskTableViewCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! AskTableViewCell
            let ask = sortedQueries[indexPath.row] as! Ask
            print("indexPath.row= \(indexPath.row)")
            cell.titleLabel.text = ask.askTitle
            print("Cell title: \(cell.titleLabel.text)")
                
            print("Photo orientation is up? (in the ask itself): \(ask.askPhoto.imageOrientation == UIImageOrientation.up)")
            
            if let rowImage = cell.photoImageView.image {
                print("Photo orientation is up? (in the row): \(rowImage.imageOrientation == UIImageOrientation.up)")
            } else {
                print("row image was nil - unable to determine orientation")
            }
                
                
            // MARK: need to send value to the numVotesLabel
            cell.numVotesLabel.text = "(\(ask.numVotes) votes)"
            let timeRemaining = calcTimeRemaining(ask.timePosted)
            cell.timeRemainingLabel.text = "\(timeRemaining)"
            if ask.askRating > -1 {
                cell.ratingLabel.text = "\(ask.askRating.roundToPlaces(1))"
            } else {
                cell.ratingLabel.text = "?"
            }
            cell.photoImageView.image = ask.askPhoto

            return cell
            
        // here we build a dual compare cell:
        } else  if sortedQueries[indexPath.row].rowType == RowType.isDual.rawValue {
            
            let cellIdentifier: String = "CompareTableViewCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CompareTableViewCell
            let compare = sortedQueries[indexPath.row] as! Compare
            
            cell.image1.image = compare.comparePhoto1
            cell.image2.image = compare.comparePhoto2
            cell.title1Label.text = compare.compareTitle1
            cell.title2Label.text = compare.compareTitle2
            
            //need a method to change score label to thousands if too big (eg 45,700 to 45.7K)
            //this method can also be used on the number of reviews the user has given
            cell.scoreLabel.text = "\(compare.compareVotes1) to \(compare.compareVotes2)"
            //calculations need to be done to get time REMAINING vice time posted:
            let timeRemaining = calcTimeRemaining(compare.timePosted)
            cell.timeRemainingLabel.text = "Time Posted: \(timeRemaining)"
            
            //set up the arrow image to point the right way:
            switch compare.winner {
                case CompareWinner.photo1Won.rawValue:
                    cell.arrowImage.image = UIImage(named: "leftArrow")
                    cell.winnerOutline1.isHidden = false
                    cell.winnerOutline2.isHidden = true
                case CompareWinner.photo2Won.rawValue:
                    cell.arrowImage.image = UIImage(named: "rightArrow")
                    cell.winnerOutline1.isHidden = true
                    cell.winnerOutline2.isHidden = false
                case CompareWinner.itsATie.rawValue:
                    cell.arrowImage.image = UIImage(named: "shrug")
                    cell.winnerOutline1.isHidden = true // should I make them both false?
                    cell.winnerOutline2.isHidden = true // this might be too much orange shit everywhere
                default: cell.arrowImage.image = UIImage(named: "defaultPhoto")
                
            }
            
            return cell
        } else {
        //should there be error handling in here? This could be much prettier I think..
            let cell: UITableViewCell? = nil
            return cell!
        }
    }
    
    // This was me fucking around with different ways to make it segue - it was actually just that rating label with some kind of latent naming issue.
    //func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //print("didSelectRowAtIndexPath")
        
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

   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Get the new view controller using segue.destinationViewController.
        //if segue.identifier == "showAsk" {
        
        print("prepareForSegue")
    
        if let indexPath = self.tableView.indexPathForSelectedRow {
            let passedQuery = sortedQueries[indexPath.row]
            if passedQuery.rowType == RowType.isSingle.rawValue {
                let controller = segue.destination as! AskViewController
                // Pass the selected object to the new view controller:
                controller.ask = passedQuery as! Ask
            } else if passedQuery.rowType == RowType.isDual.rawValue {
                let controller = segue.destination as! CompareViewController
                // Pass the selected object to the new view controller:
                controller.compare = passedQuery as! Compare
            }

            }
        
        //}
        
 
 
            /*
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let passedAsk = asks[indexPath.row]
                //print("rating in AskTableVC before passing is: \(passedAsk.askRating)")
                let controller = segue.destinationViewController as! AskViewController
                // Pass the selected object to the new view controller:
                controller.ask = passedAsk
            }
        //} */   //extranous bs
   
   
}
}
 





















