//
//  AskReviewsTableViewController.swift
//  TableViewTutorial
//
//  Created by Wyatt Weber on 6/21/17.
//  Copyright © 2017 Freedom Electric. All rights reserved.
//

import UIKit

class AskReviewsTableViewController: UITableViewController {

    
    @IBOutlet var askReviewsTableView: UITableView!
    
    //var containers: [Container] = questionCollection // this is an array that will hold Asks and Compares
    
    var currentReviews = [AskReview]()
    
    //var container: Container // I still need to double check that this line doesn't reset container to nil after the previous VC sets it to a real value
    // (if it does, the best coa is probably to move this line to DataModels and make it public.
    
    
    
    var container: Container? {
        didSet {
            // Update the view.
            self.viewDidLoad()
        }
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */



//////////// AskTableViewController source code: //////////////

///////////////////////////////////////////////
//// There is a bunch of code in here that ////
////  I probably don't need.               ////
//// The next step is to filter that out   ////
////  and keep / modify what's important   ////
///////////////////////////////////////////////
    

    
    
    
    
    //var asks = [Ask]()
    //var compares = [Compare]()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        
        // I also need something that sorts the reviews by who they are from
        if let thisContainer = container {
        currentReviews = thisContainer.reviewCollection.reviews as! [AskReview]
        } else {
            print("container was nil")
        }
        
        
        //load the sample data
        //sortedContainers = containers.sorted { $0.question.timePosted.timeIntervalSince1970 < $1.question.timePosted.timeIntervalSince1970 } //this line is going to have to appear somewhere later than ViewDidLoad
        
        //allows the row height to resize to fit the autolayout constraints
        tableView.rowHeight = UITableViewAutomaticDimension
        //it won't necessarily follow this, it's just an estimate that's required for the above line to work:
        tableView.estimatedRowHeight = 150
        
        let swipeViewGesture = UISwipeGestureRecognizer(target: self, action: #selector(AskReviewsTableViewController.userSwiped))
        askReviewsTableView.addGestureRecognizer(swipeViewGesture)

        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    
    // This happens when the main tableView is displayed again when navigating back to it from asks and compares
    override func viewDidAppear(_ animated: Bool) {
        
        // I will only need this if I decide to add a timeCreated stamp to each review and then sort by it. As of now, the 
        //  fact that the reviews should already be roughly in order since they are naturally appended to the ReviewCollection
        //  chronologically as they are created should be good enough for my purposes.
        //  This method is pasted from AskTableViewController. Nothing in it has been modified yet.
        
        
        // This refreshes the time remaining labels in the cells every time we come back to the main tableView:
        
        var index = 0
        for _ in currentReviews {
            let indexPath = IndexPath(row: index, section: 0)

                // cellForRowAtIndexPath returns an optional cell so we use 'if let' and then cast it as an optional ask cell
                // one of the times it returns nil is when the cell isn't visible
            
            tableView.cellForRow(at: indexPath)

      
            index += 1
        } 
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        //return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return currentReviews.count
    }
    
    
    //I believe this is setting up the cell row in the table, that's why it returns one cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        print("cellforRowAt indexPath called")
        
        if let thisContainer = container {
            currentReviews = thisContainer.reviewCollection.reviews as! [AskReview]
        }  else {
            let cell: UITableViewCell? = nil
            return cell!
        }
            // here we build a single ask cell:
            
            
            /////////////////////////////////////
            /// There is some issue here      ///
            /// that is throwing an exception ///
            /// that seems to imply that the  ///
            /// prototype cell is not hooked  ///
            /// up correctly                  //
            /////////////////////////////////////
            
            
            /* Here is is:
            'NSInternalInconsistencyException', reason: 'unable to dequeue a cell with identifier AskReviewsTableViewCell - must register a nib or a class for the identifier or connect a prototype cell in a storyboard'
            */
            

        let cellIdentifier: String = "AskReviewsTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! AskReviewsTableViewCell
        let review = currentReviews[indexPath.row]
        // unwrap reviewing user's profile picture (it's optional)
        if let thisImage = review.reviewerInfo.profilePicture {
                cell.reviewerImageView.image = thisImage
        } else {
            cell.reviewerImageView.image = #imageLiteral(resourceName: "generic_user")
        }
        cell.reviewerNameLabel.text = review.reviewerName
        cell.reviewerAgeLabel.text = String(review.reviewerAge)
        
        cell.voteLabel.text = selectionToText(selection: review.selection)
        
        /* //replaced by the above line
        switch review.selection {
        case .yes: cell.voteLabel.text = "YES"
        case .no: cell.voteLabel.text = "NO"
        }
        */

        cell.strongExistsLabel.text = strongToText(strong: review.strong)
        
        /* //replaced by the above line
        if let strong = review.strong { // strong is an optional property
            switch strong {
            case .yes: cell.strongExistsLabel.text = "🔥"
            case .no: cell.strongExistsLabel.text = "❄️"
            }
        } else {
            cell.strongExistsLabel.text = ""
        }
        */
        
        switch review.comments {
        case "": cell.commentExistsLabel.text = ""
        default: cell.commentExistsLabel.text = "📋"
        }
            
        return cell


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
        
        
        // Pass the specific review's info, along with the required info from the container's ask
        
        /////// Uncomment this: //////////
        /*
        if let indexPath = self.tableView.indexPathForSelectedRow {
            let passedContainer = currentReviews[indexPath.row]
            if passedContainer.containerType == .ask {
                let controller = segue.destination as! AskViewController
                // Pass the selected object to the new view controller:
                controller.container = passedContainer as! Container // may not need the force casting
            } else if passedContainer.containerType == .compare {
                let controller = segue.destination as! CompareViewController
                // Pass the selected object to the new view controller:
                controller.container = passedContainer as! Container
            }
            
        }
        */
        
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

} // end of the class for this VC

























