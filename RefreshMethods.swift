//
//  RefreshMethods.swift
//  TableViewTutorial
//
//  Created by Wyatt Weber on 7/19/17.
//  Copyright © 2017 Freedom Electric. All rights reserved.
//

import Foundation
import UIKit

/////////////////////////////////////////////////////////////////////
//                  REFRESH METHODS                                //
//                                                                 //
//  It still remains to be seen whether these methods will be      //
//   members of the database, or exist in the app.                 //
//  Since they are looping methods, it would be preferable for     //
//   them to exist on the server level




// we need methods to merge lists in case the user modified anything from a different device. Keep in mind, something deleted from another device should be deleted from the local file, not replaced in the database file.

// we need to pull some values that would normally be pushed, only becuase this is a simulation. We will only pull them once though.

// so there are 3 types of data merges:
// 1. Delete Merge:
//    This is when during the refresh, items missing from the local but present in the db are deleted, while items present in the local but missing in the db are added.
// 2.

// we also need a method (that really should be in the database) that returns containers belonging to a specific username
//   the question is: do we search for the specific container ID's or for all of that username...I'm thinking username, because some might be up there that we don't have in the local file.. hmm
// Or here's another thing, do we do all the manipulation to the database containerCollection (which is comprised only of ContainerID's) and then use that information to add or delete from the database?

// I think we want to do everything with containerID's with the exception of new containers to upload or new containers to download. This way there is minimal data upload/download usage.

public func refreshContainers() ->[Container] {
    
    // download the list of all of myUser's containerID's on the database:
    var databaseContainers = sd.getContainerIDs(username: localMyUser.publicInfo.userName)
    
    localContainerCollection = sd.refreshContainers(/*needs parameters*/)
    
    // 1. delete the containtersToDelete in the sd.containers array
    //    then clear out the undeletedContainers array
    // 2. upload the containers that haven't been uploaded yet
    //    then clear out the unuploadedContainers array
    // 3.
}

public func refreshReviews() {
    sd.refreshReviews(unuploadedRevs: unuploadedReviews)
}

public func refreshFriends() {
    localFriendCollection = sd.refreshFriends(of: localMyUser.publicInfo.userName, undeletedFrnds: undeletedFriends)
}

// deletes the objects in array one from array two
public func delete(objects: [AnyObject], from onlineArray: [AnyObject])->[AnyObject] {
    
}

















