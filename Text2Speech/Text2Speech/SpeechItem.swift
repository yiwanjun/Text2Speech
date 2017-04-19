//
//  SpeechItem.swift
//  Text2Speech
//
//  Created by zhouyi on 2017/4/18.
//  Copyright © 2017年 NewBornTown, Inc. All rights reserved.
//

import UIKit

struct SpeechItem {
    public var name : String
    public var content : String
    public var delay : Float
    public var local : String
    
    public init?(json: NSDictionary){
        guard let name      = json["name"] as? String,
              let content   = json["content"] as? String,
              let delay     = json["delay"] as? Float,
              let local     = json["local"] as? String else {return nil}
        self.name = name
        self.content = content
        self.delay = delay
        self.local = local
    }
}
