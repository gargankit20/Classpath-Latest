//
//  conversationModel.swift
//  CoolMatch
//
//  Created by ved on 30/11/16.
//  Copyright © 2016 ved. All rights reserved.
//

import UIKit

class conversationModel: NSObject {
    var UserId : String!
    var UserName : String!
    var Unread : String = "0"
    var chatID : String!
    var oponentPic = ""
    var lastMessage : String = ""
    var lastmsgTime : Double = 0
    var date_Time : String = ""
    var listingId :String = ""
}
