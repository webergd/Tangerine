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
        currentCompare.isAsk = true // This lets CameraViewController know to treat the image and associated information as part of a new Ask until the user taps the addCompareButton
        
        clearOutCurrentCompare()
        /*
        currentCompare.imageCurrentlyBeingEdited = .image1
        currentCompare.imageBeingEdited1 = nil
        currentCompare.imageBeingEdited2 = nil
        whatToCreate = .ask
        */
    }

}

 
 


