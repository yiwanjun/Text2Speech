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
    
    var indicator :NSInteger = 0//用于从items里获取对象的游标
    var musicPath :NSString?
    var maxTime : NSInteger?//最大时间
    var countor : NSInteger = 0//timer 计数器
    var currentItem : FlowItem?//当前的item
    var timer = Timer()
    fileprivate var itmes : NSMutableArray = NSMutableArray()
    override init() {
        super.init()
    }
}
//MARK: - Speech
extension TTSpeechFlowManager{
    public func loadConfigFileAndInitItems(path : String){
        let dicT: NSDictionary! = NSDictionary(contentsOfFile: path)
        for i in 0..<dicT.count{
            let dicM = dicT["t\(i)"] as![AnyHashable : Any]
            for j in 0..<dicM.count{
                let dicS = dicM["\(j)"] as! [AnyHashable:Any]
                let avVoice = AVSpeechSynthesisVoice(language: (dicS["local"] as! String))
                let uttrance = AVSpeechUtterance.init(string: (dicS["content"] as! String))
                let delay : NSNumber = dicS["delay"] as! NSNumber
                uttrance.rate *= 1
                uttrance.voice = avVoice
                
                let flowItem = FlowItem(utt: uttrance,delay: delay, index: i*j + j)
                self.itmes.add(flowItem!)
            }
        }
    }
    
    public func loadItemsWithDictionary(dic : Dictionary<AnyHashable, Any>,time: NSInteger){
        
        maxTime = time
        for i in 0..<dic.count{
            
            let dicM = dic["\(i)"] as![AnyHashable : Any]
            let avVoice = AVSpeechSynthesisVoice(language: (dicM["local"] as! String))
            let uttrance = AVSpeechUtterance(string: (dicM["content"] as! String))
            let delay = dicM["time"] as! NSNumber
            uttrance.rate *= 1
            uttrance.voice = avVoice
            
            let flowItem = FlowItem(utt: uttrance, delay: delay, index: i)
            self.itmes.add(flowItem!)
            
        }
    }
    
    private func loadFirstItem() -> FlowItem{
        let first = self.itmes.firstObject as! FlowItem
        self.indicator = first.index
        indicator += 1
        return first
    }
    private func loadNextItem() -> FlowItem?{
        
        if indicator >= itmes.count{
            return nil
        }
        let item =  itmes[indicator] as! FlowItem
        indicator += 1
        return item
    }
    public func begain(){
        if TTSpeechManager.isSpeaking(){
            return
        }
         timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    public func stop(){
        TTSpeechManager.stop()
        self.itmes.removeAllObjects()
    }
    
    @objc func timerAction(){
        print("timerAction")
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:TTSpeechManager.timerSecondUpdate), object: nil)
        if indicator == 0{
            speakWithUttrance(item: loadFirstItem())
            currentItem = loadNextItem()
            return
        }
        
        countor += 1
        
        let item = currentItem
        if item == nil{
            print("异常")
            timer.invalidate()
            return
        }
        
        if NSInteger((item?.delay)!) == countor{
            speakWithUttrance(item: item!)
            currentItem = loadNextItem()
          
        }else if NSInteger((item?.delay)!) == indicator - 1{
            timer.invalidate()
        }
    }
    public func speakWithUttrance(item: FlowItem) {
        
        TTSpeechManager.SpeakWithUttrance(uttrance: item.utt,timeInteger: item.delay, progress: {(progress) in
//            print(progress)
        }, finish: {[weak self]  finish  in
            if (self?.countor)! == (self?.maxTime)! - 1{//到达最大时间时退出
                self?.timer.invalidate()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: TTSpeechManager.speechStatus.exit), object: nil)
            }
        })
    }
}
//MARK: - Bcakgroud Music 
extension TTSpeechFlowManager{
    
    func playerAudio() throws {
        guard case let path as String = self.musicPath else {
            return
        }
        
        do {
            try NBAudioBot.PlayerWithURL(URL.init(fileURLWithPath: path), finish: { (sucess) in
                print("播放背景音乐成功")
            })
        } catch  {
            print(error.localizedDescription)
        }
    }
}
