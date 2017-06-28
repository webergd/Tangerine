//
//  FriendsReviewsTableViewController.swift
//  TableViewTutorial
//
//  Created by Wyatt Weber on 6/24/17.
//  Copyright © 2017 Freedom Electric. All rights reserved.
//

import UIKit

class FriendsTableViewController: UITableViewController {

    
    @IBOutlet var friendsTableView: UITableView!

    ///////////////////////////////////////////
    // To populate this table of friends, we //
    //  need an array of users who are our   //
    //  friends. Eventually, there also needs//
    //  to be a way that this array is       //
    //  compared against the online database //
    //  and updated as appropriate.          //
    // For now, friends is a dummy array that//
    //  lives in dataModels.swift            //
    ///////////////////////////////////////////


    


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

    
    override func viewDidLoad() {
        super.viewDidLoad()

        //allows the row height to resize to fit the autolayout constraints
        tableView.rowHeight = UITableViewAutomaticDimension
        //it won't necessarily follow this, it's just an estimate that's required for the above line to work:
        tableView.estimatedRowHeight = 150
        
        let swipeViewGesture = UISwipeGestureRecognizer(target: self, action: #selector(FriendsTableViewController.userSwiped))
        friendsTableView.addGestureRecognizer(swipeViewGesture)

        
        
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
        /*
        var index = 0
        for _ in currentReviews {
            let indexPath = IndexPath(row: index, section: 0)

                // cellForRowAtIndexPath returns an optional cell so we use 'if let' and then cast it as an optional ask cell
                // one of the times it returns nil is when the cell isn't visible
            
            tableView.cellForRow(at: indexPath)

      
            index += 1
        } 
        */
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        //return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return friendsArray.count
    }
    
    
    //I believe this is setting up the cell row in the table, that's why it returns one cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cellIdentifier: String = "FriendsTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! FriendsTableViewCell
        let friend = friendsArray[indexPath.row]
        
        cell.friendImageView.image = returnProfilePic(image: friend.publicInfo.profilePicture)

        
        cell.friendNameLabel.text = friend.publicInfo.displayName
        cell.friendAgeLabel.text = String(friend.publicInfo.age)
        cell.friendRatingLabel.text = reviewerRatingToTangerines(rating: friend.publicInfo.reviewerScore)
        
        // Don't color code friends by demo. We should know thier demo.
        // And if we don't, then it's because they don't want us to know and that's thier private prerogative.
        //cell.cellBackgroundView.backgroundColor = demoSpecificColor(userDemo: friend.publicInfo.orientation)

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

        //This needs to be switched over once the friend detail VC is built:

        if let indexPath = self.tableView.indexPathForSelectedRow {
            
            let passedFriend = friendsArray[indexPath.row]
            
            let controller = segue.destination as! FriendDetailsViewController
            // Pass the selected review to the next view controller:
            controller.friend = passedFriend

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

} // end of the class for this VC

























