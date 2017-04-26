//
//  FlowItem.swift
//  Text2Speech
//
//  Created by zhouyi on 2017/4/19.
//  Copyright © 2017年 NewBornTown, Inc. All rights reserved.
//

import UIKit
import AVFoundation
struct FlowItem {
    
    public var utt : AVSpeechUtterance
    public var delay : TimeInterval
    public var index : NSInteger
    public var content : String?
    
    public init?(utt: AVSpeechUtterance,delay: NSNumber,index: NSInteger){
        self.utt = utt
        self.delay = TimeInterval(delay)
        self.index = index
    }
}
