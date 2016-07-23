//
//  DetailViewController.swift
//  TableViewTutorial
//
//  Created by Wyatt Weber on 7/12/16.
//  Copyright © 2016 Freedom Electric. All rights reserved.
//

import UIKit



class AskViewController: UIViewController {
    
    
    @IBOutlet weak var askRatingLabel: UILabel!
    @IBOutlet weak var askImageView: UIImageView!
    
    //@IBOutlet weak var detailDescriptionLabel: UILabel!
    
    //var detailText: String = ""
    //var ask: Ask = Ask(title: "blank", rating: 11, photo: UIImage(named: "defaultPhoto")! )
    
    var ask: Ask? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
     


    
    //askRatingLabel.text
    
    
    //OK, why the fuck is my ask object nil
    func configureView() {
        print("configuring view")
        //print("\(self.ask?.askRating)")
        // unwraps the ask that the tableView sent over:
        if let thisAsk = self.ask {
            // unwraps the ratingLabel from the IBOutlet
            if let thisLabel = self.askRatingLabel {
                print("passed rating is: \(thisAsk.askRating)")
                thisLabel.text = "\(thisAsk.askRating)"
            }
            // unwraps the imageView from the IBOutlet
            if let thisImageView = self.askImageView {
                thisImageView.image = thisAsk.askPhoto
            }
            
        } else {
            print("Looks like ask is nil")
        }
            
    }
    
        


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

