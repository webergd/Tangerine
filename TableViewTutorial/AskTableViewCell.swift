//
//  AskTableViewCell.swift
//  TableViewTutorial
//
//  Created by Wyatt Weber on 7/14/16.
//  Copyright © 2016 Freedom Electric. All rights reserved.
//

import UIKit

class AskTableViewCell: UITableViewCell {
    
    // MARK: Properties
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var numVotesLabel: UILabel!


    /*
    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        print("preparedForSegue called in AskTableViewCell")
        
        
        /*  HAving this shit in here is 
            experimental. I don't think I'm supposed to utilize 
            prepareForSegue from the 'Cell' class
        // Get the new view controller using segue.destinationViewController.
        if segue.identifier == "showAsk" {
            
            print("prepareForSegue")
            
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
            
        } */
    
    
    
        } */
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

    
    
}





















