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
    
    public init?(utt: AVSpeechUtterance,delay: TimeInterval,index: NSInteger){
        self.utt = utt
        self.delay = delay
        self.index = index
    }
    
}
