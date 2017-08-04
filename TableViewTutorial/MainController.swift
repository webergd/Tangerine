//
//  MainController.swift
//  TableViewTutorial
//
//  Created by Wyatt Weber on 7/12/16.
//  Copyright © 2016 Freedom Electric. All rights reserved.
//

import UIKit

class MainController: UIViewController {
    var loaded: Bool = false
    
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

        // clear the question queue so old ones don't just sit in it
        assignedQuestions = []
        
        // These two methods load the dummy Questions and create containers for them with empty review collections.
        // As a result, any review created for these questions will be erased at this point.
        // What will not be erased however, are reviews created for questions created by the camera in the app.
        // Keep in mind, all of this is for testing and should be removed at beta.
        
        // this ensures that the sample database itself only gets created once:
        if loaded == false {
            sd.loadDummyValues()
            print("all sample questions and reviews loaded")
            
            // call refresh / update methods
            
            loaded = true
            

        }
        
        loadAssignedQuestions()
        refreshEverything()
        
        // This really should be done at the point the asks and compares are created:
        // // front load the queue with any new questions that we created in the app
        //for thisContainer in myUser.containerCollection {
        //    assignedQuestions.append(thisContainer.question)
        //}
        
        // add the dummy questions to the end of the question queue to be reviewed
        //for thisContainer in sampleContainers {
        //    assignedQuestions.append(thisContainer.question)
        //}
        

        /*
        for container in myUser.containerCollection {
            print("\(container.containerID.userID), \(container.containerID.containerNumber)")
        }
        */
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("Number of elements in my containerCollection is now: \(localContainerCollection.count)")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        // hides the nav bar
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @IBAction func reviewOthersButtonTapped(_ sender: Any) {
        // sets the graphical view controller with the storyboard ID" comparePreviewViewController to nextVC
        if assignedQuestions[0].type == .ask {
            let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "reviewAskViewController") as! ReviewAskViewController
            self.navigationController?.pushViewController(nextVC, animated: true)
        } else if assignedQuestions[0].type == .compare {
            let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "reviewCompareViewController") as! ReviewCompareViewController
            self.navigationController?.pushViewController(nextVC, animated: true)
        } else {
            print("assignedQuestions array is null")
            fatalError()
        }
        // pushes askBreakdownViewController onto the nav stack
        
        
    }
    
    
}





