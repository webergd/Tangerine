//
//  ViewController.swift
//  TableViewTutorial
//
//  Created by Wyatt Weber on 7/12/16.
//  Copyright © 2016 Freedom Electric. All rights reserved.
//

import UIKit


//since we conform to these protocols we have to implement 3 methods:
/*
numberOfSectionsInTableView:
tableView:numberOfRowsInSection:
tableView:cellForRowAtIndexPath: 
 */
class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    
    //this is my attempt at connecting the label in the 
    //detail view to the "button" that is each row:
    
    
    let swiftBlogs = ["Ray", "Hipster", "Developer Tips"]
    let textCellIdentifier = "TableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //we only have one section in this table so fuck it we just return one
    //obviously we can compute it if we want though
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    //this gets us the number of rows in the table
    //since we're using an array, we just use the number of items in the array
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return swiftBlogs.count
    }
    
    //this method loads the rows in the table with the strings in the array
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //this has something to do with what happens to cells when they go off the screen
        let cell = tableView.dequeueReusableCellWithIdentifier(textCellIdentifier, forIndexPath: indexPath)
        
        let row = indexPath.row
        cell.textLabel?.text = swiftBlogs[row]
        
        return cell
    }
    
    //when someone taps the row:
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)//this just takes the highlight off the tapped row
        let row = indexPath.row //this is just an Int representing the row number

    }
    
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        //use the text in the selected row to set the label on the detail view:
        if segue.identifier == "displayDetailView" {
                if let indexPath = self.tableView.indexPathForSelectedRow {
                    let controller: DetailViewController = segue.destinationViewController as! DetailViewController
                    controller.detailText = swiftBlogs[indexPath.row]

            }

            
            }
        

    
    }
    
    


}















