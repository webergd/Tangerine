//
//  AskTableViewController.swift   //This file needs a more accurate name -> it holds Asks and Compares
//  TableViewTutorial
//
//  Created by Wyatt Weber on 7/14/16.
//  Copyright © 2016 Freedom Electric. All rights reserved.
//

import UIKit

class AskTableViewController: UITableViewController {
    
    // MARK: Properties
    
    
    @IBOutlet var askTableView: UITableView!


    
    //var asks = [Ask]()
    //var compares = [Compare]()
    
    // In the actual implementation, the variable 'containers' is going to need to be pulled from the server
    // In this implementation I am just loading it with dummy reviews
    
    var containers: [Container] = localContainerCollection // this is an array that will hold Asks and Compares
    var sortedContainers = [Container]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //these four methods load the public array called sampleContainers with all the dummy values
        //loadSampleAsks()
        //loadSampleCompares()
        //loadSampleAskReviews()
        //loadSampleCompareReviews()
        // this appends the dummy values to this VC's containers property
        refreshContainers()
        refreshUserProfile()
        containers = localContainerCollection
        // the fact that this sorts the containers array by timestamp is the reason the dummy values are always at the top (they are the oldest)
        sortedContainers = containers.sorted { $0.question.containerID.timePosted.timeIntervalSince1970 < $1.question.containerID.timePosted.timeIntervalSince1970 } //this line is going to have to appear somewhere later than ViewDidLoad
        
        //allows the row height to resize to fit the autolayout constraints
        tableView.rowHeight = UITableViewAutomaticDimension
        //it won't necessarily follow this, it's just an estimate that's required for the above line to work:
        tableView.estimatedRowHeight = 150
        
        let swipeViewGesture = UISwipeGestureRecognizer(target: self, action: #selector(AskTableViewController.userSwiped))
        askTableView.addGestureRecognizer(swipeViewGesture)
        
        
        //print("Questions: \(questions)")
        print("SortedContainers: \(sortedContainers)")
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    
    // This happens when the main tableView is displayed again when navigating back to it from asks and compares
    override func viewDidAppear(_ animated: Bool) {

        
        // This refreshes the time remaining labels in the cells every time we come back to the main tableView:
        
        // It seems like we might want to call viewDidLoad() here to make sure the cells are as up to date as possible....
        
        var index = 0
        for container in sortedContainers {
            let indexPath = IndexPath(row: index, section: 0)
            if container.containerType == .ask {
                
                //print("first reviewer's username is: \(container.reviewCollection.reviews[0].reviewerName)")
                
                // cellForRowAtIndexPath returns an optional cell so we use 'if let' and then cast it as an optional ask cell
                // one of the times it returns nil is when the cell isn't visible
                if let cell = tableView.cellForRow(at: indexPath) as! AskTableViewCell? {
                    let ask = sortedContainers[indexPath.row].question as! Ask
                    let timeRemaining = calcTimeRemaining(ask.containerID.timePosted)
                    cell.timeRemainingLabel.text = "\(timeRemaining)"
                }
            } else if container.containerType == .compare {
                if let cell = tableView.cellForRow(at: indexPath) as! CompareTableViewCell? {
                    let compare = sortedContainers[indexPath.row].question as! Compare
                    let timeRemaining = calcTimeRemaining(compare.containerID.timePosted)
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
        return sortedContainers.count
    }


    //I believe this is setting up the cell row in the table, that's why it returns one cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let container = sortedContainers[indexPath.row]
        let reviewCollection = container.reviewCollection
        let isLocked: Bool = container.isLocked()
        
        // here we build a single ask cell:
        if container.containerType == .ask {
            let cellIdentifier: String = "AskTableViewCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! AskTableViewCell
            let ask = container.question as! Ask
            let targetDemoDataSet = pullConsolidatedData(from: container, filteredBy: .targetDemo) as! ConsolidatedAskDataSet
            print("indexPath.row= \(indexPath.row)")
            cell.titleLabel.text = ask.askTitle
            //print("Cell title: \(cell.titleLabel.text)")
            
            let timeRemaining = calcTimeRemaining(ask.containerID.timePosted)
            cell.timeRemainingLabel.text = "\(timeRemaining)"
            
            if reviewCollection.reviews.count > 0 {
                cell.numVotesLabel.text = "\(reviewCollection.reviews.count) votes"
                if isLocked == true {
                    cell.ratingLabel.text = "🗝"
                } else {
                    cell.ratingLabel.text = "\(targetDemoDataSet.percentYes)%"
                }
            } else {
                cell.numVotesLabel.text = "No Votes Yet"
                if isLocked == true {
                    cell.ratingLabel.text = "🗝"
                } else {
                    cell.ratingLabel.text = "?"
                }
            }

            cell.photoImageView.image = ask.askPhoto

            return cell
            
        // here we build a dual compare cell:
        } else  if container.containerType == .compare {
            
            let cellIdentifier: String = "CompareTableViewCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CompareTableViewCell
            let compare = container.question as! Compare
            let targetDemoDataSet = pullConsolidatedData(from: container, filteredBy: .targetDemo) as! ConsolidatedCompareDataSet
            cell.image1.image = compare.comparePhoto1
            cell.image2.image = compare.comparePhoto2
            cell.title1Label.text = compare.compareTitle1
            cell.title2Label.text = compare.compareTitle2
            
            //need a method to change score label to thousands if too big (eg 45,700 to 45.7K)
            //this method can also be used on the number of reviews the user has given
            
            if reviewCollection.reviews.count > 0 {
                // we don't have a numVotes label for compare cell yet but we need one
                //cell.numVotesLabel.text = "\(reviewCollection.reviews.count) votes)"
                if isLocked == true {
                    cell.scoreLabel.text = "🗝"
                } else {
                    cell.scoreLabel.text = "\(targetDemoDataSet.percentTop)% to \(targetDemoDataSet.percentBottom)%"
                }
            } else {
                //cell.numVotesLabel.text = "No Votes Yet"
                if isLocked == true {
                    cell.scoreLabel.text = "🗝"
                } else {
                    cell.scoreLabel.text = "? to ?"
                }
            }
            
            //cell.scoreLabel.text = "\(compare.compareVotes1) to \(compare.compareVotes2)"
            //calculations need to be done to get time REMAINING vice time posted:
            let timeRemaining = calcTimeRemaining(compare.containerID.timePosted)
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
    
    func userSwiped() {
        print("user swiped**********")
        self.navigationController?.popViewController(animated: true)
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Get the new view controller using segue.destinationViewController.
        //if segue.identifier == "showAsk" {
        
        print("prepareForSegue")
    
        if let indexPath = self.tableView.indexPathForSelectedRow {
            let passedContainer = sortedContainers[indexPath.row]

            if passedContainer.isLocked() == true {
                print("selected container is locked")
                return
                
                // we need a way to actually cock block the segue, not just the data being passed
            }
 
            
            if passedContainer.containerType == .ask {
                let controller = segue.destination as! AskViewController
                // Pass the selected object to the new view controller:
                controller.container = passedContainer
            } else if passedContainer.containerType == .compare {
                let controller = segue.destination as! CompareViewController
                // Pass the selected object to the new view controller:
                controller.container = passedContainer 
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        print("shouldperformSegue called")
        
        guard let indexPath = self.tableView.indexPathForSelectedRow else {
            print("no Question value exists for cell selected")
            return false
        }
        
        let passedContainer = sortedContainers[indexPath.row]
        
        
        if let ident = identifier {
            if ident == "tableViewToAskVCSegue" || ident == "tableViewToCompareVCSegue" {
                if passedContainer.isLocked() == true {
                    tableView.deselectRow(at: indexPath, animated: true)
                    return false
                } else {
                    return true
                }
            }
        }
        return true
    }
}
 





















