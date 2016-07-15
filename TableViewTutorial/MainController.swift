//
//  MainController.swift
//  TableViewTutorial
//
//  Created by Wyatt Weber on 7/12/16.
//  Copyright © 2016 Freedom Electric. All rights reserved.
//

import UIKit

class MainController: UIViewController {
    


}

class Ask {
    let askPhoto: UIImage
    var askTitle: String
    var askRating: Double
    
    init(title: String, rating: Double, photo: UIImage) {
        askTitle = title
        askRating = rating
        askPhoto = photo
    }
}
