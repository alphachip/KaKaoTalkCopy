//
//  NotificationModel.swift
//  KaKaoTalkCopy
//
//  Created by dindon on 2020/06/25.
//  Copyright © 2020 Alphachip. All rights reserved.
//

import ObjectMapper

@objcMembers
class NotificationModel: Mappable {
    public var to: String?
    public var notification: Notification = Notification()
    
    init() {}
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        to <- map["to"]
        notification <- map["notification"]
    }
    
    class Notification: Mappable {
        public var title: String?
        public var text: String?
        
        init() {}
        required init?(map: Map) {}
        
        func mapping(map: Map) {
            title <- map["title"]
            text <- map["text"]
        }
    }
}

//{ "notification": {
//    "title": "KR vs Other",
//    "text": "5 to 1"
//    },
//    "to": "user_token_id"
//}
