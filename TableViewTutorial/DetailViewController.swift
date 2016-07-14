//
//  DetailViewController.swift
//  TableViewTutorial
//
//  Created by Wyatt Weber on 7/12/16.
//  Copyright © 2016 Freedom Electric. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    //@IBOutlet weak var detailDescriptionLabel: UILabel!
    
    var detailText: String = ""
    @IBOutlet weak var detailViewLabel: UILabel!
    

    
    func configureView() {

        detailViewLabel.text = detailText
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

