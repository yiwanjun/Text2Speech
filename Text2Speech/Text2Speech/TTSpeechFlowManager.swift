//
//  TTSpeechFlowManager.swift
//  Text2Speech
//
//  Created by zhouyi on 2017/4/19.
//  Copyright © 2017年 NewBornTown, Inc. All rights reserved.
//

import UIKit
import AVFoundation

class TTSpeechFlowManager: NSObject {
    
    var indicator :NSInteger = 0
    fileprivate var itmes : NSMutableArray = NSMutableArray()
    override init() {
        super.init()
    }
}

extension TTSpeechFlowManager{
    public func loadConfigFileAndinitItems(path : String){
        let dicT: NSDictionary! = NSDictionary(contentsOfFile: path)
        for i in 0..<dicT.count{
            let dicM = dicT["t\(i)"] as![AnyHashable : Any]
            for j in 0..<dicM.count{
                let dicS = dicM["\(j)"] as! [AnyHashable:Any]
                let avVoice = AVSpeechSynthesisVoice(language: (dicS["local"] as! String))
                let uttrance = AVSpeechUtterance.init(string: (dicS["content"] as! String))
                let delay : TimeInterval = TimeInterval((dicS["delay"] as? Float)!)
                uttrance.rate *= 1
                uttrance.voice = avVoice
                
                let flowItem = FlowItem(utt: uttrance,delay: delay, index: i*j + j)
                self.itmes.add(flowItem!)
            }
        }
    }
    
    private func loadFirstItem() -> FlowItem{
        let first = self.itmes.firstObject as! FlowItem
        self.indicator = first.index
        return first
    }
    private func loadNextItem() -> FlowItem?{
        self.indicator += 1
        if self.indicator >= self.itmes.count{
            return nil
        }
        let item =  self.itmes[self.indicator] as! FlowItem
        return item
    }
    public func begain(){
        
        speakWithUttrance(item: loadFirstItem())
    }
    public func stop(){
        TTSpeechManager.stop()
        self.itmes.removeAllObjects()
    }

    public func speakWithUttrance(item: FlowItem) {
        
        TTSpeechManager.SpeakWithUttrance(uttrance: item.utt,timeInteger: item.delay, progress: {(progress) in
//            print(progress)
        }, finish: { (finish)  in
            let item = self.loadNextItem()
            if (item != nil){
                self.speakWithUttrance(item: item!)
            }else{
                
            }
        })
    }
}
