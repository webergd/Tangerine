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
    var usersArray: [User] = []
    var containersArray: [Container] = []
    var friendshipsArray: [Friendship] = []
    
    func loadDummyValues() {
        loadSampleUsers()
        loadSampleAsks()
        loadSampleAskReviews()
        loadSampleCompareReviews()
    }
    
    func refreshContainers(for username: String, undeletedContainers: [ContainerIdentification], unuploadedContainers: [Container]) -> [Container] {
        // deletes the undeletedContainers from containersArray
        for containerID in undeletedContainers {
            delete(containerID: containerID)
        }
        // adds the unuploadedContainers to the containersArray
        for container in unuploadedContainers {
            upload(container: container)
        }
        // sends the updated containers in containersArray (that belong to the specific user) back down to the app
        return getContainers(for: username)
    }
    
    func delete(containerID: ContainerIdentification) {
        containersArray.remove(at: index(of: containerID))
    }
    
    func upload(container: Container) {
        let locationIndex = index(of: container.containerID)
        if locationIndex == -1 {
        // this means the container doesn't already exist in the array
            containersArray.append(container)
        }
        // otherwise do nothing because the container is already uploaded
        
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
    
    // this method takes a string of usernames to delete, a user who's friends they are, deletes the names from the user's list in the database, finds each of the users in the newly revised friend list, and adds them up into an array that it then returns to the user so that the localFriendCollection can be updated. It also uolod an array of friends who the user has accepted a re
    
    // uploads:
    //  username
    //  undeletedFriends
    //  newlyAcceptedFriends
    // downloads:
    //  friends
    //  friends I have requested (but haven't accepted me yet)
    //  friends who requested me (but I haven't accepted yet)
    func refreshFriends(of myUsername: String, undeletedFriends: [String], newlyAcceptedFriends: [String], requestedFriends: [String]) -> ([PublicInfo],[PublicInfo],[PublicInfo]) {
        
        
        // These are used to intitally sort the users into. The names lists are then used to pull the users' PublicInfo from the database.
        var friendsNames: [String] = []
        var iRequestedNames: [String] = []
        var requestedMeNames: [String] = []
        
        // These are the actual arrays this method will return:
        var friends: [PublicInfo] = []
        var iRequested: [PublicInfo] = []
        var requestedMe: [PublicInfo] = []
        
        // friends' names in a friendship with myUser when myUser is in the given position:
        // For example, if myUser's username appears in the user1 column of a friendship, we append the other person's name in that friendship 
        //  (which is the username in the user2 column of the friendship) to the user2s array.
        var user2s: [String] = []
        var user1s: [String] = []
        
        // create primary keys for myUser%friend and friend%myUser
        // (these are the lines of the friendship database that need to be deleted
        /*
        var deleteKeysAsUser1: [String] = []
        var deleteKeysAsUser2: [String] = []
        
        for friendName in undeletedFriends {
            deleteKeysAsUser1.append(username + "%" + friendName)
            deleteKeysAsUser2.append(friendName + "%" + username)
        }
         */
        
        

        
        
        // The result of this code block is to do two things:
        // 1. Remove friendships from the database whose friendshipID's we specified in the two 'deleteKeysAsUser' arrays
        // 2. Fill the myUserAsUser arrays with friends' usernames that appear in a friendship of the opposing position
        // This will allow us to work only within these arrays for the rest of the logic in this method so that we don't have to search the whole database again.
        // We end up with two arrays of strings of friends' names. The two arrays should be mostly redundant except for those cases in which one side
        //  or the other has not yet accepted the friendship.
        // If someone's name ends up in the user2s array but not the user1s, that means myUser has requested them but they have not yet accepted
        // The reverse is true for someone's name in the user1s array. It means that person has requested to be friends with myUser
        //  but myUser has not accepted them yet. We will use this to return our triple of three arrays of PublicInfo's by using the usernames
        //  to pull the users' publicinfo properties from the users array.
        var index: Int = 0
        for friendship in friendshipsArray {
            // check the user1 column to see if it is myUser
            if friendship.user1 == myUsername {
                // see if the other person's name in this friendship is in the 'to delete' list. If it is, delete it and return true.
                if deleteFriendshipIfDesired(otherFriendName: friendship.user2, friendsToDelete: undeletedFriends, index: index) == false {
                    // If it returned false, that means the user wasn't in the 'to delete' list, so we'll keep them and append their name to our list
                    user2s.append(friendship.user2)
                }
            }
            // now check the user2 column to see if myUser is there instead
            if friendship.user2 == myUsername {
                for friendName in newlyAcceptedFriends {
                    if friendName == friendship.user1 {
                        // we know that there is only one half of the friendship created so far, the one where otherUser is in user1 and myUser is in user2
                        // The purposed of this is to create that other half:
                        friendshipsArray.append(Friendship(user1: myUsername, user2: friendName))
                        // There is a potential for something to get messed up and to create a redundant second friendship half. Which would end up looking like I requested them, even though the friends database says we are already friends also.
                        // We will need something in the database routine cleanup procedures to check for redundant friendshipID's and delete one of them.
                        user2s.append(friendship.user2) // this will allow us to know locally that this user is now our accepted friend.
                    }
                }
                // since myUser is in the user2 column, once again, check to see if the name in the user1 column was on my delete list and delete as required.
                if deleteFriendshipIfDesired(otherFriendName: friendship.user1, friendsToDelete: undeletedFriends, index: index) == false {
                    // once again, if the username in position 1 of the friendship wasn't on the delete list, now append that name to the other array where we
                    //  are keeping track of friendships in which myUser is in the second position (instead of the previous if statement where we're
                    //  concerned with cases in which myUser is in the first position)
                    user1s.append(friendship.user1)
                }
                
            }
            index += 1

        }


        
        // sort the two arrays of friends' usernames in ascending order
        // If we sort the user1s and user2s arrays alphbetically, this will probably be more efficient.
        user1s = user1s.sorted { $0 < $1 }
        user2s = user2s.sorted { $0 < $1 }
        
        // The next step is to use for loops and if statements to determine which values will go into the 3 arrays we are returning.
        
        // If a username appears on both lists, the user is friends with myUser
        // If a username appears only on the user1s list, the user has requested myUser but has not yet been accepted
        // If a username appears only on the user2s list, myUser has requested that person but the other person hasn't accepted it yet.
        
        // Populate the lists of usernames for each of the 3 catgories:
        for username in user1s {
            if user2s.contains(username) {
                // It's a two-way friendship because the name appears on both lists, therefore the are friends.
                friendsNames.append(username)
                // This allows us to end up with only the names in the user2s list that don't also appear in the user1s lists:
                if let indexInUser2s: Int = user2s.index(of: username) {
                    user2s.remove(at: indexInUser2s)
                }
            } else {
                // The name only appears in user1s, therefore myUser has not accepted this person yet
                requestedMeNames.append(username)
            }
        }
        iRequestedNames = user2s
        
        for requestedFriend in requestedFriends {
            // If this is the first time the request has appeared, add the half-friendship (i.e. request) to the friendship table in the database
            if !iRequestedNames.contains(requestedFriend) {
                friendshipsArray.append(Friendship(user1: myUsername, user2: requestedFriend))
                iRequestedNames.append(requestedFriend) // append it becuase this element was not added in the first sweep
            }
            // otherwise, leave it be.
            // The previous loops have already identified the request and
        }
        

        // Sort the arrays of usernames by their display names:
        friendsNames = sortUsersByDisplayName(listOfUsernames: friendsNames)
        iRequestedNames = sortUsersByDisplayName(listOfUsernames: iRequestedNames)
        requestedMeNames = sortUsersByDisplayName(listOfUsernames: requestedMeNames)

        // Populate the arrays of PublicInfo's to return by searching the usersArray (which will be a table in the real database):
        for user in usersArray {
            let username = user.publicInfo.userName
            
            if friendsNames.contains(username) {
                friends.append(user.publicInfo)
                
            } else if requestedMeNames.contains(username) {
                requestedMe.append(user.publicInfo)
                
            } else if iRequestedNames.contains(username) {
                iRequested.append(user.publicInfo)
            }
        }

        return (friends, iRequested, requestedMe)
        
        
        // At some point we will need a way to hide requests from other users that we never plan to accept. The decision to be made at that point
        //  is whether to delete the half-friendship (i.e. request) out of the system entirely (which will let the requesting user know that
        //  the requested user rejected them since they will no longer show a pending request for them, or to simply store the request as hidden so that
        //  the user who requested the friendship still sees it as pending, but the other user who never plans on accepting the request doesn't
        //  have to keep looking at it. I think this second approach would use more data. I'd rather just delete the request out of the system.
        // The downside to this would be that the rejected user might send another request to the user who rejected them, which could
        //  get really annoying if they keep doing it. Most likely I should allow users to add to a blockedUsers array for themselves
        //  which will prevent other users from even searching for them.
        // The least memory-using solution is this:
        //  If a user denies a friendship, give them the option to add that person to a "don't search for me" list.
        //  This can be implemented later. For now, we'll let them send unlimited friend requests.
        
        
    }
    
    func sortUsersByDisplayName(listOfUsernames: [String]) -> [String] {
        var listOfPublicInfos: [PublicInfo] = []
        
        for user in usersArray {
            let usersPublicInfo = user.publicInfo
            listOfPublicInfos.append(usersPublicInfo)
        }

        let sortedPublicInfos = listOfPublicInfos.sorted {
            // this still needs to be tested
            return $0.userName < $1.userName
        }

        var sortedUsernames: [String] = []
        for pubInfo in sortedPublicInfos {
            sortedUsernames.append(pubInfo.userName)
        }
        
        return sortedUsernames
    }
    

    
    // we need a way to not crash when trying to delete a one sided friendship (like a request that we no longer want to have out there)
    
    // returns true if the friendship was deleted
    func deleteFriendshipIfDesired(otherFriendName: String, friendsToDelete: [String], index: Int) -> Bool {
        for friendName in friendsToDelete {
            if friendName == otherFriendName {
                friendshipsArray.remove(at: index)
                return true // true means we deleted this half of the friendship
            }
        }
        return false
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
        
        // we also need to delete myUser's name from the deleted friend's friendlist
        
        
        // My only worry is a situation where I delete a friendship
        //  but the system mistakenly only deletes one half, and now the
        //  other half is out floating in space.
        // Maybe the database itself can have a periodic cleaning fuction
        //  that checks for those and removes them.
        // Also, if only one half exists, but it not pending, then it means that the other half was deleted and therefore the remaining half should also be deleted. We can locate these in the get freind names function also.
        
        
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
    
    func index(of containerID: ContainerIdentification) -> Int {
        var index: Int = 0
        for container in containersArray {
            if container.containerID.userID == containerID.userID {
                if container.containerID.timePosted == containerID.timePosted {
                    return index
                }
            }
            index += 1
        }
        print("Index of container not found. Container not present in the array.")
        return -1
    }
    
    // Searches the containersArray for a specific userID and then returns a list of CONTAINER-ID's:
    func getContainerIDs(for username: String) -> [ContainerIdentification] {
        var arrayOfContainerIDsToReturn: [ContainerIdentification] = []
        for container in containersArray {
            if container.containerID.userID == username {
                arrayOfContainerIDsToReturn.append(container.containerID)
            }
        }
        return arrayOfContainerIDsToReturn
    }
    
    // Searches the containersArray for a specific userID and then returns a list of CONTAINERS:
    func getContainers(for username: String) -> [Container] {
        var arrayOfContainersToReturn: [Container] = []
        for container in containersArray {
            if container.containerID.userID == username {
                arrayOfContainersToReturn.append(container)
            }
        }
        return arrayOfContainersToReturn
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
        
        let genericFriendNameList1: [String] = ["wyatt","guido","beast","uncleDanny","melissa"]
        let genericFriendNameList2: [String] = ["wyatt", "zeenat", "morgan","ian","countryBear","bob"]
        
        let user1: User = User(password: "123", emailAddress: "yut@yut.com",
                               publicInfo: PublicInfo(userName: "guido", displayName: "Guido", profilePicture: #imageLiteral(resourceName: "guido"), age: 37, orientation: .straightMan, signUpDate: Date(), reviewsRated: 10, reviewerScore: 4.8), targetDemo: genericTargetDemo, containerIDCollection: [], friendNames: genericFriendNameList2)
        let user2: User = User(password: "123", emailAddress: "yut@yut.com",
                               publicInfo: PublicInfo(userName: "beast", displayName: "Beast", profilePicture: #imageLiteral(resourceName: "beast"), age: 32, orientation: .straightMan, signUpDate: Date(), reviewsRated: 10, reviewerScore: 3.3), targetDemo: genericTargetDemo, containerIDCollection: [], friendNames: genericFriendNameList2)
        let user3: User = User(password: "123", emailAddress: "yut@yut.com",
                               publicInfo: PublicInfo(userName: "uncleDanny", displayName: "Uncle Danny", profilePicture: nil, age: 69, orientation: .straightMan, signUpDate: Date(), reviewsRated: 10, reviewerScore: 1.0), targetDemo: genericTargetDemo, containerIDCollection: [], friendNames: genericFriendNameList2)
        let user4: User = User(password: "123", emailAddress: "yut@yut.com",
                               publicInfo: PublicInfo(userName: "melissa", displayName: "Melissa", profilePicture: #imageLiteral(resourceName: "melissa"), age: 32, orientation: .straightWoman, signUpDate: Date(), reviewsRated: 10, reviewerScore: 4.0), targetDemo: genericTargetDemo, containerIDCollection: [], friendNames: genericFriendNameList2)
        let user5: User = User(password: "123", emailAddress: "yut@yut.com",
                               publicInfo: PublicInfo(userName: "zeenat", displayName: "Zeenat", profilePicture: #imageLiteral(resourceName: "zeenat"), age: 29, orientation: .straightWoman, signUpDate: Date(), reviewsRated: 10, reviewerScore: 2.2), targetDemo: genericTargetDemo, containerIDCollection: [], friendNames: genericFriendNameList1)
        let user6: User = User(password: "123", emailAddress: "yut@yut.com",
                               publicInfo: PublicInfo(userName: "morgan", displayName: "Morgan", profilePicture: #imageLiteral(resourceName: "morgan"), age: 26, orientation: .gayWoman, signUpDate: Date(), reviewsRated: 10, reviewerScore: 2.9), targetDemo: genericTargetDemo, containerIDCollection: [], friendNames: genericFriendNameList1)
        let user7: User = User(password: "123", emailAddress: "yut@yut.com",
                               publicInfo: PublicInfo(userName: "ian", displayName: "Ian", profilePicture: #imageLiteral(resourceName: "ian"), age: 21, orientation: .gayMan, signUpDate: Date(), reviewsRated: 10, reviewerScore: 1.2), targetDemo: genericTargetDemo, containerIDCollection: [], friendNames: genericFriendNameList1)
        let user8: User = User(password: "123", emailAddress: "yut@yut.com",
                               publicInfo: PublicInfo(userName: "countryBear", displayName: "Country Bear", profilePicture: nil, age: 33, orientation: .straightMan, signUpDate: Date(), reviewsRated: 10, reviewerScore: 3.8), targetDemo: genericTargetDemo, containerIDCollection: [], friendNames: genericFriendNameList1)
        let user9: User = User(password: "123", emailAddress: "yut@yut.com",
                               publicInfo: PublicInfo(userName: "bob", displayName: "Bob", profilePicture: nil, age: 23, orientation: .gayMan, signUpDate: Date(), reviewsRated: 10, reviewerScore: 2.6), targetDemo: genericTargetDemo, containerIDCollection: [], friendNames: genericFriendNameList1)
        
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
        let myUser: User = User(password: "", emailAddress: "kabar3@gmail.com", publicInfo: myPublicInfo, targetDemo: myTargetDemo, containerIDCollection: [], friendNames: ["guido","beast","melissa", "zeenat", "morgan","ian","countryBear"])
        
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
        
        containersArray = [] // this clears out the database so that each time this method runs, more copies of the same containers aren't appended to it
        
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        
        let photo1 = #imageLiteral(resourceName: "redReeboks")
        let caption1 = Caption(text: "", yLocation: 0.0)
        let time1 = formatter.date(from: "2016/08/09 00:01")! //force unwrap bc it's temp anyway
        let ask1 = Ask(title: "Red Reeboks", photo: photo1, caption: caption1)
        let ask1SW = ask1.breakdown.straightWomen as! AskDemo
        let ask1GM = ask1.breakdown.gayMen as! AskDemo
        ask1SW.rating = 5
        ask1SW.numVotes = 1
        ask1GM.rating = 6
        ask1GM.numVotes = 10
        
        let container1 = Container(question: ask1)
        
        let photo2 = #imageLiteral(resourceName: "whiteConverse")
        let caption2 = Caption(text: "", yLocation: 0.0)
        //let time2 = formatter.date(from: "2016/08/09 00:11")! // if this becomes an issue, we could create a secondary initializer for Asks and Compares that involves taking in a timePosted value to pass into the ContainerID rather than creating one on the spot
        let ask2 = Ask(title: "White Converse", photo: photo2,caption: caption2)
        let ask2GW = ask2.breakdown.gayWomen as! AskDemo
        ask2GW.rating = 6
        ask2GW.numVotes = 5
        let container2 = Container(question: ask2)
        
        let photo3 = #imageLiteral(resourceName: "violetVans")
        let caption3 = Caption(text: "", yLocation: 0.0)
        //let time3 = formatter.date(from: "2016/08/09 00:06")!
        let ask3 = Ask(title: "Violet Vans", photo: photo3, caption: caption3)
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
        
        let compare1 = Compare(title1: title1, photo1: photo1, caption1: caption1, title2: title2, photo2: photo2, caption2: caption2)
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
        
        let compare2 = Compare(title1: title1a, photo1: photo1a, caption1: caption1a, title2: title2a, photo2: photo2a, caption2: caption2a)
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
        
        
        ///////////////////////////////////////////////////////////////////////////////////////////////
        //    START HERE:
        //
        //
        //  Just start moving through the code to all errors and adjust them to work with the database. 
        //  Database methods should now be fully functional unless I forgot something.
        //  In which case, just scroll back up and create the functionality.
        //
        ///////////////////////////////////////////////////////////////////////////////////////////////
        
        
        
        
        
        
        
        
        let askReview1 = AskReview(selection: .no, strong: nil, comments: "raising eyebrows rapidly", reviewerInfo: usersArray[0].publicInfo)
        
        let askReview2 = AskReview(selection: .no, strong: nil, comments: "I can dream a hell of a lot", reviewerInfo: usersArray[1].publicInfo)
        
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
