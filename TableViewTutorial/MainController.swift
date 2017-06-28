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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSampleUsers()
        
        // These two methods load the dummy Questions and create containers for them with empty review collections.
        // As a result, any review created for these questions will be erased at this point.
        // What will not be erased however, are reviews created for questions created by the camera in the app.
        // Keep in mind, all of this is for testing and should be removed at beta.
        loadSampleAsks()
        loadSampleCompares()
        
        // clear the question queue
        assignedQuestions = []
        // front load the queue with any new questions that we created in the app
        for thisContainer in myUser.containerCollection {
            assignedQuestions.append(thisContainer.question)
        }
        // add the dummy questions to the end of the question queue to be reviewed
        for thisContainer in sampleContainers {
            assignedQuestions.append(thisContainer.question)
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        // hides the nav bar
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}

 
 


