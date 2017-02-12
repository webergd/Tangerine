//
//  MainController.swift
//  TableViewTutorial
//
//  Created by Wyatt Weber on 7/12/16.
//  Copyright © 2016 Freedom Electric. All rights reserved.
//

import UIKit

class MainController: UIViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepareForSegue in MAIN controller called")
        justFinishedPicking = false // This lets the avCameraViewController call reloadCamera(() as soon as the view is loaded.
    }

}

 
 


