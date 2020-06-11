//
//  ChatModel.swift
//  KaKaoTalkCopy
//
//  Created by dindon on 2020/06/10.
//  Copyright © 2020 Alphachip. All rights reserved.
//

import ObjectMapper

@objcMembers
class ChatModel: Mappable {
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        users <- map["users"]
        comments <- map["comments"]
    }
    
    public var users: Dictionary<String,Bool> = [:] //채팅방 참여 유저
    public var comments: Dictionary<String,Comment> = [:] //대화 내용
    
    public class Comment: Mappable {
        public var uid: String?
        public var message: String?
        
        public required init?(map: Map) {

        }
        
        public func mapping(map: Map) {
            uid <- map["uid"]
            message <- map["message"]
        }
    }
}
