//
//  ProfilepicModel.swift
//  ClassPath
//
//  Created by Coldfin on 05/03/18.
//  Copyright © 2018 Coldfin. All rights reserved.
//

import UIKit

class ProfilepicModel{
    var ProfilePic: String?
    
    init(ProfilePic: String?){
        self.ProfilePic = ProfilePic
    }
    
}

class UsersData {
    
    var Uid: String?
    var Fname: String?
    var Lname: String?
    var Email: String?
    var City: String?
    var Password: String?
    
    
    init(Uid: String?, Fname: String?, Lname: String?, Email: String?, City: String?, Password: String?){
        self.Uid = Uid
        self.Fname = Fname
        self.Lname = Lname
        self.Email = Email
        self.City = City
        self.Password = Password
    }
}

class UserReviewModel{
    var reviewId = ""
    var Uid = ""
    var Stars:CGFloat = 0.0
    var timeframe = ""
    var reviewed_date = ""
    var listName = ""
    var ProfilePic = ""
    var UserName = ""
}



