//
//  SimulatedDatabase.swift
//  TableViewTutorial
//
//  Created by Wyatt Weber on 7/18/17.
//  Copyright © 2017 Freedom Electric. All rights reserved.
//

import Foundation
import UIKit

// creates a blank database: - we will tell it to load its values in the MainController
public var sd: SimulatedDatabase = SimulatedDatabase()

public class SimulatedDatabase {
    public var usersArray: [User] = []
    public var containersArray: [Container] = []
    
    public func loadDummyValues() {
        loadSampleUsers()
        loadSampleAsks()
        loadSampleAskReviews()
        loadSampleCompareReviews()
    }
    
    // Searches the containersArray for a specific userID and then returns a list of containerID's
    func getContainerIDs(username: String) -> [ContainerIdentification] {
        var arrayOfContainerIDsToReturn: [ContainerIdentification] = []
        for container in containersArray {
            if container.containerID.userID == username {
                arrayOfContainerIDsToReturn.append(container.containerID)
            }
        }
        return arrayOfContainerIDsToReturn
    }
    
    func refreshReviews(unuploadedRevs: [isAReview]) {
        for review in unuploadedRevs {
            add(review: review)
        }
    }
    
    func add(review: isAReview) {
        // find which container to add the review to
        let indexOfTargetContainer: Int = indexOf(containerID: review.reviewID.containerID, in: containersArray)
        containersArray[indexOfTargetContainer].reviewCollection.reviews.append(review)
    }
    
    // the actual database will probably use primary keys instead of indeces like an array so we will flex as required when ammending the code.
    func indexOf(containerID: ContainerIdentification, in array: [Container]) -> Int {
        // find userID's index in the array:
        var index: Int = 0
        for container in array {
            // This is nested so that only the userID will be checked first
            //  and if there's no match, it moves on.
            if container.containerID.userID == containerID.userID {
                if container.containerID.containerNumber == containerID.containerNumber {
                return index
            
                }
            }
            index += 1
        }
        print("containerID wasn't found in the containersArray")
        fatalError()
    }
    
    // this method takes a string of usernames to delete, a user who's friends they are, deletes the names from the user's list in the database, finds each of the users in the newly revised friend list, and adds them up into an array that it then returns to the user so that the localFriendCollection can be updated.
    func refreshFriends(of username: String, undeletedFrnds: [String]) -> [PublicInfo] {
        
        // First, delete the undeleted friends:
        let userIndex: Int = indexOfUser(userID: username, in: usersArray)
        var newFriendList: [String] = usersArray[userIndex].friendNames
        
        for friendName in undeletedFrnds {
            newFriendList = sd.delete(friend: friendName, from: newFriendList)
        }
        
        // Next, return an array of updated publicInfo profiles of Users that are still friends
        var friendCollectionToReturn: [PublicInfo] = []
        for friendName in newFriendList {
            let friendsUserIndex: Int = indexOfUser(userID: friendName, in: usersArray)
            friendCollectionToReturn.append(usersArray[friendsUserIndex].publicInfo)
        }
        return friendCollectionToReturn
    }
    

    func delete(friend toDelete: String, from friendList: [String]) -> [String] {
        var friendListToReturn: [String] = friendList
        var index: Int = 0 // this is just a counter for the loop
        for someUser in friendList {
            if toDelete == someUser {
                friendListToReturn.remove(at: index)
                return friendListToReturn
            }
            index += 1
        }
        print("unable to find friend name to delete in user's friend list")
        return friendListToReturn
    }
    
    func indexOfUser(userID: String, in array: [User])-> Int {
        // find userID's index in the array:
        var index: Int = 0
        for user in array {
            if user.publicInfo.userName == userID {
                return index
            }
            index += 1
        }
        print("myUser wasn't found in the usersArray, therefore the dummy containers couldn't be appended to it")
        fatalError()
    }

    
    
    /////////////////////////////////
    /////     DUMMY VALUES:    //////
    /////////////////////////////////

    // Not sure what this comment applies to now:
    // This is the same as the usersArray but we will use it for appending reviews because it is more "database like"
    // There is only one difference: myUser will also be a member of the dictionary
    //public var usersDictionary: [String:User] = [:]
    
    func loadSampleUsers(){
        
        let genericTargetDemo: TargetDemo = TargetDemo(minAge: 0, maxAge: 100, straightWomenPreferred: true, straightMenPreferred: true, gayWomenPreferred: true, gayMenPreferred: true)
        
        let user1: User = User(password: "123", emailAddress: "yut@yut.com",
                               publicInfo: PublicInfo(userName: "guido", displayName: "Guido", profilePicture: #imageLiteral(resourceName: "guido"), age: 37, orientation: .straightMan, signUpDate: Date(), reviewsRated: 10, reviewerScore: 4.8), targetDemo: genericTargetDemo, containerCollection: [])
        let user2: User = User(password: "123", emailAddress: "yut@yut.com",
                               publicInfo: PublicInfo(userName: "beast", displayName: "Beast", profilePicture: #imageLiteral(resourceName: "beast"), age: 32, orientation: .straightMan, signUpDate: Date(), reviewsRated: 10, reviewerScore: 3.3), targetDemo: genericTargetDemo, containerCollection: [])
        let user3: User = User(password: "123", emailAddress: "yut@yut.com",
                               publicInfo: PublicInfo(userName: "uncleDanny", displayName: "Uncle Danny", profilePicture: nil, age: 69, orientation: .straightMan, signUpDate: Date(), reviewsRated: 10, reviewerScore: 1.0), targetDemo: genericTargetDemo, containerCollection: [])
        let user4: User = User(password: "123", emailAddress: "yut@yut.com",
                               publicInfo: PublicInfo(userName: "melissa", displayName: "Melissa", profilePicture: #imageLiteral(resourceName: "melissa"), age: 32, orientation: .straightWoman, signUpDate: Date(), reviewsRated: 10, reviewerScore: 4.0), targetDemo: genericTargetDemo, containerCollection: [])
        let user5: User = User(password: "123", emailAddress: "yut@yut.com",
                               publicInfo: PublicInfo(userName: "zeenat", displayName: "Zeenat", profilePicture: #imageLiteral(resourceName: "zeenat"), age: 29, orientation: .straightWoman, signUpDate: Date(), reviewsRated: 10, reviewerScore: 2.2), targetDemo: genericTargetDemo, containerCollection: [])
        let user6: User = User(password: "123", emailAddress: "yut@yut.com",
                               publicInfo: PublicInfo(userName: "morgan", displayName: "Morgan", profilePicture: #imageLiteral(resourceName: "morgan"), age: 26, orientation: .gayWoman, signUpDate: Date(), reviewsRated: 10, reviewerScore: 2.9), targetDemo: genericTargetDemo, containerCollection: [])
        let user7: User = User(password: "123", emailAddress: "yut@yut.com",
                               publicInfo: PublicInfo(userName: "ian", displayName: "Ian", profilePicture: #imageLiteral(resourceName: "ian"), age: 21, orientation: .gayMan, signUpDate: Date(), reviewsRated: 10, reviewerScore: 1.2), targetDemo: genericTargetDemo, containerCollection: [])
        let user8: User = User(password: "123", emailAddress: "yut@yut.com",
                               publicInfo: PublicInfo(userName: "countryBear", displayName: "Country Bear", profilePicture: nil, age: 33, orientation: .straightMan, signUpDate: Date(), reviewsRated: 10, reviewerScore: 3.8), targetDemo: genericTargetDemo, containerCollection: [])
        let user9: User = User(password: "123", emailAddress: "yut@yut.com",
                               publicInfo: PublicInfo(userName: "bob", displayName: "Bob", profilePicture: nil, age: 23, orientation: .gayMan, signUpDate: Date(), reviewsRated: 10, reviewerScore: 2.6), targetDemo: genericTargetDemo, containerCollection: [])
        
        // I put the reviewers in an array to avoid having to explicitly declare each user at the class level.
        // This way I just declared an empty (but not nil) array at the class level and then add to it within this method.
        usersArray.append(user1)
        usersArray.append(user2)
        usersArray.append(user3)
        usersArray.append(user4)
        usersArray.append(user5)
        usersArray.append(user6)
        usersArray.append(user7)
        usersArray.append(user8)
        usersArray.append(user9)
        
        
        // dummy value as usual, we will keep friendsArray though.
        friendsArray = usersArray
        
        // this will need to be data pulled from the user's profile in the database, and stored locally:
        let myPublicInfo: PublicInfo = PublicInfo(userName: "wyatt", displayName: "Wyatt", profilePicture: #imageLiteral(resourceName: "wyatt"), age: 33, orientation: .straightMan, signUpDate: Date(), reviewsRated: 0, reviewerScore: 5.0)
        let myUser: User = User(password: "", emailAddress: "kabar3@gmail.com", publicInfo: myPublicInfo, targetDemo: myTargetDemo, containerCollection: [])
        
        // appended later because I am not my own friend
        usersArray.append(myUser)
        
        
        /*
         for user in usersArray {
         usersDictionary.updateValue(user, forKey: user.publicInfo.userName)
         }
         
         usersDictionary.updateValue(myUser, forKey: myUser.publicInfo.userName)
         */
        
    }
    
    /* to load dummy values for the new data model, I need dummy asks and compares, as well as sample reviews.
     I should be able to modfiy the loadSampleAsks and loadSampleCompares methods to work within the Container paradigm.
     At that point I then just need to create the sample reviews from scratch and then load them into the ReviewCollection for the specific Questions - DONE */

    // this has been replaced with sd.containersArray //used that way outside of the class
    //public var sampleContainers: [Container] = []
    
    // These dictionaries will simulate the online database:
    
    
    public func loadSampleAsks() {
        
        sampleContainers = [] // this clears out sampleContainers so that each time this method runs, more copies of the same containers aren't appended to it
        
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        
        let photo1 = #imageLiteral(resourceName: "redReeboks")
        let caption1 = Caption(text: "", yLocation: 0.0)
        let time1 = formatter.date(from: "2016/08/09 00:01")! //force unwrap bc it's temp anyway
        let ask1 = Ask(title: "Red Reeboks", photo: photo1, caption: caption1, timePosted: time1)
        let ask1SW = ask1.breakdown.straightWomen as! AskDemo
        let ask1GM = ask1.breakdown.gayMen as! AskDemo
        ask1SW.rating = 5
        ask1SW.numVotes = 1
        ask1GM.rating = 6
        ask1GM.numVotes = 10
        
        let container1 = Container(question: ask1)
        
        let photo2 = #imageLiteral(resourceName: "whiteConverse")
        let caption2 = Caption(text: "", yLocation: 0.0)
        let time2 = formatter.date(from: "2016/08/09 00:11")!
        let ask2 = Ask(title: "White Converse", photo: photo2,caption: caption2, timePosted: time2)
        let ask2GW = ask2.breakdown.gayWomen as! AskDemo
        ask2GW.rating = 6
        ask2GW.numVotes = 5
        let container2 = Container(question: ask2)
        
        let photo3 = #imageLiteral(resourceName: "violetVans")
        let caption3 = Caption(text: "", yLocation: 0.0)
        let time3 = formatter.date(from: "2016/08/09 00:06")!
        let ask3 = Ask(title: "Violet Vans", photo: photo3, caption: caption3, timePosted: time3)
        let ask3SM = ask3.breakdown.straightMen as! AskDemo
        ask3SM.rating = 9.8
        ask3SM.numVotes = 90
        let container3 = Container(question: ask3)
        
        //I think this is a pointless line of code:
        //asks += [ask1,ask2,ask3]  //+= just appends them, I believe
        //print("Asks: \(asks)")
        containersArray.append(container1)
        containersArray.append(container2)
        containersArray.append(container3)
    }
    
    
    public func loadSampleCompares() {
        
        //create a sample Jeans compare object
        let title1 = "Light Carmens"
        let photo1 = #imageLiteral(resourceName: "carmenJeansLight")
        let caption1 = Caption(text: "", yLocation: 0.0)
        
        let title2 = "Dark Carmens"
        let photo2 = #imageLiteral(resourceName: "carmenJeansDark")
        let caption2 = Caption(text: "", yLocation: 0.0)
        
        let time1 = formatter.date(from: "2016/08/09 00:04")!
        
        let compare1 = Compare(title1: title1, photo1: photo1, caption1: caption1, title2: title2, photo2: photo2, caption2: caption2, timePosted: time1)
        let compare1SW = compare1.breakdown.straightWomen as! CompareDemo
        let compare1SM = compare1.breakdown.straightMen as! CompareDemo
        let compare1GW = compare1.breakdown.gayWomen as! CompareDemo
        let compare1GM = compare1.breakdown.gayMen as! CompareDemo
        
        compare1SW.votesForOne = 10
        compare1SW.votesForTwo = 12
        compare1SM.votesForOne = 6
        compare1SM.votesForTwo = 33
        compare1GW.votesForOne = 3
        compare1GW.votesForTwo = 16
        compare1GM.votesForOne = 60
        compare1GM.votesForTwo = 77
        
        let container4 = Container(question: compare1)
        
        
        //create another sample Shoes compare object
        
        let title1a = "Brown Shiny"
        let photo1a = #imageLiteral(resourceName: "brownShiny")
        let caption1a = Caption(text: "", yLocation: 0.0)
        
        let title2a = "Brown Tooled"
        let photo2a = #imageLiteral(resourceName: "brownTooled")
        let caption2a = Caption(text: "", yLocation: 0.0)
        
        let time2 = formatter.date(from: "2016/08/09 00:08")!
        
        let compare2 = Compare(title1: title1a, photo1: photo1a, caption1: caption1a, title2: title2a, photo2: photo2a, caption2: caption2a, timePosted: time2)
        let compare2SW = compare2.breakdown.straightWomen as! CompareDemo
        let compare2SM = compare2.breakdown.straightMen as! CompareDemo
        
        compare2SW.votesForOne = 100
        compare2SW.votesForTwo = 100
        compare2SM.votesForOne = 550
        compare2SM.votesForTwo = 550
        
        let container5 = Container(question: compare2)
        
        
        
        containersArray.append(container4)
        containersArray.append(container5)
        
    }
    
    
    
    // requires loadSampleAsks() to be called first in order to work.
    public func loadSampleAskReviews() {
        
        loadSampleUsers() // this ensures that the reviewersArray values are not nil
        
        let askReview1 = AskReview(selection: .no, strong: nil, reviewerInfo: usersArray[0].publicInfo, comments: "raising eyebrows rapidly")
        
        let askReview2 = AskReview(selection: .no, strong: nil, reviewerInfo: usersArray[1].publicInfo, comments: "I can dream a hell of a lot")
        
        let askReview3 = AskReview(selection: .no, strong: nil, reviewerInfo: usersArray[2].publicInfo, comments: "Goooooooo")
        
        let askReview4 = AskReview(selection: .no, strong: .yes, reviewerInfo: usersArray[3].publicInfo, comments: "Go team WML")
        
        let askReview5 = AskReview(selection: .no, strong: nil, reviewerInfo: usersArray[4].publicInfo, comments: "I like beet juice")
        
        let askReview6 = AskReview(selection: .no, strong: nil, reviewerInfo: usersArray[5].publicInfo, comments: "Oregon is the best")
        
        let askReview7 = AskReview(selection: .no, strong: nil, reviewerInfo: usersArray[6].publicInfo, comments: "Wanna act something out silently?")
        
        let askReview8 = AskReview(selection: .yes, strong: nil, reviewerInfo: usersArray[7].publicInfo, comments: "You suck at preflighting")
        
        let askReview9 = AskReview(selection: .yes, strong: .yes, reviewerInfo: usersArray[8].publicInfo, comments: "My name is Bob?")
        
        // this loop adds all the reviews to each ask container since 0 through 2 are Asks
        //  we only know this because we loaded 0 through 2 as asks
        for x in 0...2  {
            containersArray[x].reviewCollection.reviews.append(askReview1)
            containersArray[x].reviewCollection.reviews.append(askReview2)
            containersArray[x].reviewCollection.reviews.append(askReview3)
            containersArray[x].reviewCollection.reviews.append(askReview4)
            containersArray[x].reviewCollection.reviews.append(askReview5)
            containersArray[x].reviewCollection.reviews.append(askReview6)
            containersArray[x].reviewCollection.reviews.append(askReview7)
            containersArray[x].reviewCollection.reviews.append(askReview8)
            containersArray[x].reviewCollection.reviews.append(askReview9)
        }
        
        
    }
    
    // requires loadSampleCompares() to be called first in order to work.
    
    public func loadSampleCompareReviews() {
        let compareReview1 = CompareReview(selection: .bottom, strongYes: true, strongNo: false, reviewerInfo: usersArray[0].publicInfo, comments: "raising eyebrows rapidly")
        
        let compareReview2 = CompareReview(selection: .top, strongYes: true, strongNo: false, reviewerInfo: usersArray[1].publicInfo, comments: "I can dream a hell of a lot")
        
        let compareReview3 = CompareReview(selection: .top, strongYes: true, strongNo: false, reviewerInfo: usersArray[2].publicInfo, comments: "Gooooooo")
        
        let compareReview4 = CompareReview(selection: .top, strongYes: true, strongNo: false, reviewerInfo: usersArray[3].publicInfo, comments: "Go team WML")
        
        let compareReview5 = CompareReview(selection: .top, strongYes: true, strongNo: false, reviewerInfo: usersArray[4].publicInfo, comments: "I like beet juice")
        
        let compareReview6 = CompareReview(selection: .top, strongYes: true, strongNo: false, reviewerInfo: usersArray[5].publicInfo, comments: "Oregon is the best")
        
        let compareReview7 = CompareReview(selection: .top, strongYes: true, strongNo: false, reviewerInfo: usersArray[6].publicInfo, comments: "Wanna act something out silently?")
        
        // this loop adds all the reviews to each compare container since 3 through 4 are Compares
        for x in 3...4  {
            containersArray[x].reviewCollection.reviews.append(compareReview1)
            containersArray[x].reviewCollection.reviews.append(compareReview2)
            containersArray[x].reviewCollection.reviews.append(compareReview3)
            containersArray[x].reviewCollection.reviews.append(compareReview4)
            containersArray[x].reviewCollection.reviews.append(compareReview5)
            containersArray[x].reviewCollection.reviews.append(compareReview6)
            containersArray[x].reviewCollection.reviews.append(compareReview7)
        }
        
        let thisIndex: Int = myUserIndex()
        
        // this loads the sample containers into the myUser that is in the usersArray
        // All of this as usual is dummy stuff that needs to be deleted on beta
        usersArray[thisIndex].containerCollection = sampleContainers // this needs to be switched to containerID's instead of containers
        
        
    }

}
