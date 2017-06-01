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
    
    
    @IBOutlet var askTableView: UITableView!

    
    
    
    //var asks = [Ask]()
    //var compares = [Compare]()
    var containers: [Container] = questionCollection // this is an array that will hold Asks and Compares
    var sortedContainers = [Container]()
    
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
    
    
    /* to load dummy values for the new data model, I need dummy asks and compares, as well as sample reviews.
        I should be able to modfiy the loadSampleAsks and loadSampleCompares methods to work within the Container paradigm.
        At that point I then just need to create the sample reviews from scratch and then load them into the ReviewCollection for the specific Questions */
  
    // this is temporary code
    func loadSampleAsks() {
        
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        
        let photo1 = UIImage(named: "\(Shoes.redReeboks)")!
        let caption1 = Caption(text: "", yLocation: 0.0)
        let time1 = formatter.date(from: "2016/08/09 00:01")! //force unwrap bc it's temp anyway
        let ask1 = Ask(title: "Red Reeboks", photo: photo1, caption: caption1, timePosted: time1)
        let ask1SW = ask1.breakdown.straightWomen as! AskDemo
        let ask1GM = ask1.breakdown.gayMen as! AskDemo
        ask1SW.rating = 5
        ask1SW.numVotes = 1
        ask1GM.rating = 6
        ask1GM.numVotes = 10
        let container1 = Container(containerType: .ask, question: ask1, reviewCollection: ReviewCollection(type: .ask))

        let photo2 = UIImage(named: "\(Shoes.whiteConverse)")!
        let caption2 = Caption(text: "", yLocation: 0.0)
        let time2 = formatter.date(from: "2016/08/09 00:11")!
        let ask2 = Ask(title: "White Converse", photo: photo2,caption: caption2, timePosted: time2)
        let ask2GW = ask2.breakdown.gayWomen as! AskDemo
        ask2GW.rating = 6
        ask2GW.numVotes = 5
        let container2 = Container(containerType: .ask, question: ask2, reviewCollection: ReviewCollection(type: .ask))
 
        let photo3 = UIImage(named: "\(Shoes.violetVans)")!
        let caption3 = Caption(text: "", yLocation: 0.0)
        let time3 = formatter.date(from: "2016/08/09 00:06")!
        let ask3 = Ask(title: "Violet Vans", photo: photo3, caption: caption3, timePosted: time3)
        let ask3SM = ask3.breakdown.straightMen as! AskDemo
        ask3SM.rating = 9.8
        ask3SM.numVotes = 90
        let container3 = Container(containerType: .ask, question: ask3, reviewCollection: ReviewCollection(type: .ask))
        
        //I think this is a pointless line of code:
        //asks += [ask1,ask2,ask3]  //+= just appends them, I believe
        //print("Asks: \(asks)")
        containers.append(container1)
        containers.append(container2)
        containers.append(container3)
    }
    
    
    func loadSampleCompares() {
        
        //create a sample Jeans compare object
        let title1 = "Light Carmens"
        let photo1 = UIImage(named: "\(Jeans.carmenJeansLight)")!
        let caption1 = Caption(text: "", yLocation: 0.0)
        
        let title2 = "Dark Carmens"
        let photo2 = UIImage(named: "\(Jeans.carmenJeansDark)")!
        let caption2 = Caption(text: "", yLocation: 0.0)
        
        let time1 = formatter.date(from: "2016/08/09 00:04")!
        
        let compare1 = Compare(title1: title1, photo1: photo1, caption1: caption1, title2: title2, photo2: photo2, caption2: caption2, timePosted: time1)
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
        
        let container4 = Container(containerType: .compare, question: compare1, reviewCollection: ReviewCollection(type: .compare))
        
        
        //create another sample Shoes compare object
        
        let title1a = "Brown Shiny"
        let photo1a = UIImage(named: "\(Shoes.brownShiny)")!
        let caption1a = Caption(text: "", yLocation: 0.0)

        let title2a = "Brown Tooled"
        let photo2a = UIImage(named: "\(Shoes.brownTooled)")!
        let caption2a = Caption(text: "", yLocation: 0.0)
        
        let time2 = formatter.date(from: "2016/08/09 00:08")!
        
        let compare2 = Compare(title1: title1a, photo1: photo1a, caption1: caption1a, title2: title2a, photo2: photo2a, caption2: caption2a, timePosted: time2)
        let compare2SW = compare2.breakdown.straightWomen as! CompareDemo
        let compare2SM = compare2.breakdown.straightMen as! CompareDemo
        
        compare2SW.votesForOne = 100
        compare2SW.votesForTwo = 100
        compare2SM.votesForOne = 550
        compare2SM.votesForTwo = 550
        
        let container5 = Container(containerType: .compare, question: compare2, reviewCollection: ReviewCollection(type: .compare))
        

        
        containers.append(container4)
        containers.append(container5)


        
    }
    
    // requires loadSampleAsks() to be called first in order to work.
    func loadSampleAskReviews() {

        let askReview1 = AskReview(selection: .yes, strong: nil, userName: "Guido", reviewerDemo: .straightMan, reviewerAge: 37, comments: "raising eyebrows rapidly")
        
        let askReview2 = AskReview(selection: .yes, strong: .yes, userName: "Beast", reviewerDemo: .straightMan, reviewerAge: 32, comments: "I can dream a hell of a lot")
        
        let askReview3 = AskReview(selection: .no, strong: nil, userName: "Uncle Danny", reviewerDemo: .straightMan, reviewerAge: 69, comments: "Goooooooo")
        
        let askReview4 = AskReview(selection: .yes, strong: .yes, userName: "Melissa", reviewerDemo: .straightWoman, reviewerAge: 32, comments: "Go team WML")
        
        let askReview5 = AskReview(selection: .no, strong: nil, userName: "Zeenat", reviewerDemo: .straightWoman, reviewerAge: 29, comments: "I like beet juice")
        
        let askReview6 = AskReview(selection: .yes, strong: nil, userName: "Morgan", reviewerDemo: .gayWoman, reviewerAge: 26, comments: "Oregon is the best")
        
        let askReview7 = AskReview(selection: .yes, strong: nil, userName: "Ian", reviewerDemo: .gayMan, reviewerAge: 21, comments: "Wanna act something out silently?")
        
        // this loop adds all the reviews to each ask container since 0 through 2 are Asks 
        //  we only know this because we loaded 0 through 2 as asks
        for x in 0...2  {
            containers[x].reviewCollection.reviews.append(askReview1)
            containers[x].reviewCollection.reviews.append(askReview2)
            containers[x].reviewCollection.reviews.append(askReview3)
            containers[x].reviewCollection.reviews.append(askReview4)
            containers[x].reviewCollection.reviews.append(askReview5)
            containers[x].reviewCollection.reviews.append(askReview6)
            containers[x].reviewCollection.reviews.append(askReview7)
        }
        
        
    }
    
    // requires loadSampleCompares() to be called first in order to work.
    
    func loadSampleCompareReviews() {
        let compareReview1 = CompareReview(selection: .top, strongYes: false, strongNo: false, userName: "Guido", reviewerDemo: .straightMan, reviewerAge: 37, comments: "raising eyebrows rapidly")
        
        let compareReview2 = CompareReview(selection: .top, strongYes: false, strongNo: false, userName: "Beast", reviewerDemo: .straightMan, reviewerAge: 32, comments: "I can dream a hell of a lot")
        
        let compareReview3 = CompareReview(selection: .bottom, strongYes: true, strongNo: false, userName: "Uncle Danny", reviewerDemo: .straightMan, reviewerAge: 69, comments: "Gooooooo")
        
        let compareReview4 = CompareReview(selection: .top, strongYes: false, strongNo: false, userName: "Melissa", reviewerDemo: .straightWoman, reviewerAge: 32, comments: "Go team WML")
        
        let compareReview5 = CompareReview(selection: .bottom, strongYes: true, strongNo: false, userName: "Zeenat", reviewerDemo: .straightWoman, reviewerAge: 29, comments: "I like beet juice")
        
        let compareReview6 = CompareReview(selection: .bottom, strongYes: false, strongNo: false, userName: "Morgan", reviewerDemo: .gayWoman, reviewerAge: 26, comments: "Oregon is the best")
        
        let compareReview7 = CompareReview(selection: .bottom, strongYes: true, strongNo: false, userName: "Ian", reviewerDemo: .gayMan, reviewerAge: 21, comments: "Wanna act something out silently?")
        
        // this loop adds all the reviews to each compare container since 3 through 4 are Compares
        for x in 3...4  {
            containers[x].reviewCollection.reviews.append(compareReview1)
            containers[x].reviewCollection.reviews.append(compareReview2)
            containers[x].reviewCollection.reviews.append(compareReview3)
            containers[x].reviewCollection.reviews.append(compareReview4)
            containers[x].reviewCollection.reviews.append(compareReview5)
            containers[x].reviewCollection.reviews.append(compareReview6)
            containers[x].reviewCollection.reviews.append(compareReview7)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //load the sample data
        loadSampleAsks()
        loadSampleCompares()
        loadSampleAskReviews()
        loadSampleCompareReviews()
        sortedContainers = containers.sorted { $0.question.timePosted.timeIntervalSince1970 < $1.question.timePosted.timeIntervalSince1970 } //this line is going to have to appear somewhere later than ViewDidLoad
        
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
        // MARK: There is an issue here with 
        // the way that the table is reloading after we introduce
        // a cell from an ask that was made by the CameraViewController
        // It may have something to do with the way that we are 
        // loading up the questions array (local) from the main array (public)
        // ###################################################
        
        // This refreshes the time remaining labels in the cells every time we come back to the main tableView
        

        var index = 0
        for container in sortedContainers {
            let indexPath = IndexPath(row: index, section: 0)
            if container.containerType == .ask {
                // cellForRowAtIndexPath returns an optional cell so we use 'if let' and then cast it as an optional ask cell
                // one of the times it returns nil is when the cell isn't visible
                if let cell = tableView.cellForRow(at: indexPath) as! AskTableViewCell? {
                    let ask = sortedContainers[indexPath.row].question as! Ask
                    let timeRemaining = calcTimeRemaining(ask.timePosted)
                    cell.timeRemainingLabel.text = "\(timeRemaining)"
                }
            } else if container.containerType == .compare {
                if let cell = tableView.cellForRow(at: indexPath) as! CompareTableViewCell? {
                    let compare = sortedContainers[indexPath.row].question as! Compare
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
        return sortedContainers.count
    }


    //I believe this is setting up the cell row in the table, that's why it returns one cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // here we build a single ask cell:
        if sortedContainers[indexPath.row].containerType == .ask {
            
            let cellIdentifier: String = "AskTableViewCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! AskTableViewCell
            let ask = sortedContainers[indexPath.row].question as! Ask
            print("indexPath.row= \(indexPath.row)")
            cell.titleLabel.text = ask.askTitle
            print("Cell title: \(cell.titleLabel.text)")
            
            
            /*
            if let rowImage = cell.photoImageView.image {
                print("Photo orientation is up? (in the row): \(rowImage.imageOrientation == UIImageOrientation.up)")
            } else {
                print("row image was nil - unable to determine orientation")
            }
            */
                
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
        } else  if sortedContainers[indexPath.row].containerType == .compare {
            
            let cellIdentifier: String = "CompareTableViewCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CompareTableViewCell
            let compare = sortedContainers[indexPath.row].question as! Compare
            
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
 





















