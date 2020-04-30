//
//  ChatMessagesModel.swift
//  HIITList
//
//  Created by Ved on 30/10/17.
//  Copyright © 2017 Coldfin. All rights reserved.
//

import UIKit

class ChatMessagesModel: NSObject {
    var messageId = String()
    var sendby = String()
    var message = String()
    var Show: String = ""
    var blockedby: String = ""
    var timeStamp : Double = 0.0
    //var timeStamp2 : Double = 0.0
    var ViewFlag : Bool = false
    var SendRcvFlag = String()
}
