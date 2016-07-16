//
//  DetailViewController.swift
//  TableViewTutorial
//
//  Created by Wyatt Weber on 7/12/16.
//  Copyright © 2016 Freedom Electric. All rights reserved.
//

import UIKit



class singleAskViewController: UIViewController {
    
    //@IBOutlet weak var detailDescriptionLabel: UILabel!
    
    var detailText: String = ""
    var ask: Ask = Ask(title: "blank", rating: 11, photo: UIImage(named: "defaultPhoto")! )
    
    /*var detailItem: Ask? {
        didSet {
            // Update the view.
            self.configureView()
        }
     */

    @IBOutlet weak var askRatingLabel: UILabel!
    @IBOutlet weak var askImageView: UIImageView!
    
    func configureView() {
        
        askImageView.image = ask.askPhoto
        
        //askRatingLabel.text = "0.0" //"\(ask.askRating)"
        
        /*if let ratingString: String = "\(ask.askRating)" {
            askRatingLabel.text = ratingString
        } */
        
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

