 //
//  Message.swift
//  ChatApplication
//
//  Created by Yash on 10/8/19.
//  Copyright © 2019 Yash. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    @objc var fromId: String? //The uid of the users that has sent this message
    @objc var text: String?
    @objc var timeStamp:NSNumber?
    @objc var toId: String? //The uid of the users that is the recipient of this message
    @objc var imageURL: String?
    //The dimensions of the image
    @objc var imageWidth: NSNumber?
    @objc var imageHeight: NSNumber?
    //The confidence of the image classifier for the two classes
    var porn: Double?
    var non_porn: Double?
    
    init(dictionary: [String: AnyObject]) {
        super.init()
        //Use the dictionary values to initialise the properties
        fromId = dictionary["fromId"] as? String
        text = dictionary["text"] as? String
        timeStamp = dictionary["timeStamp"] as? NSNumber
        toId = dictionary["toId"] as? String
        imageURL = dictionary["imageURL"] as? String
        imageWidth = dictionary["imageWidth"] as? NSNumber
        imageHeight = dictionary["imageHeight"] as? NSNumber
        porn = dictionary["porn"] as? Double
        non_porn = dictionary["non_porn"] as? Double
    }
    
    func chatPartnerID() -> String? {
        //Show the uid of the other chat user (chat partner) as opposed to the logged in user
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId
    }
    
    func isMessageFromLocalUser() -> Bool {
        //Returns true if the user that sent te message is the local users else returns false
        if Auth.auth().currentUser?.uid == fromId {
            return true
        } else {
            return false
        }
    }
}
