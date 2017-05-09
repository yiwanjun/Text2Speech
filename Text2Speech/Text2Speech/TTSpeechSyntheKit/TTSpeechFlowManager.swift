//
//  TTSpeechFlowManager.swift
//  Text2Speech
//
//  Created by zhouyi on 2017/4/19.
//  Copyright © 2017年 NewBornTown, Inc. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftyJSON

class TTSpeechFlowManager: NSObject {
    
    fileprivate var indicator :NSInteger = 0//用于从items里获取对象的游标
    fileprivate var maxTime : NSInteger?//最大时间
    fileprivate var countor : NSInteger = 0//timer 计数器
    fileprivate var timer : PauseableTimer?
    fileprivate var itmes : NSMutableArray = NSMutableArray()
}

//MARK: - Load
extension TTSpeechFlowManager{
    public func loadConfigFileAndInitItems(path : String){
        let dicT: NSDictionary! = NSDictionary(contentsOfFile: path)
        for i in 0..<dicT.count{
            let dicM = dicT["t\(i)"] as![AnyHashable : Any]
            for j in 0..<dicM.count{
                let dicS = dicM["\(j)"] as! [AnyHashable:Any]
                let avVoice = AVSpeechSynthesisVoice(language: (dicS["local"] as! String))
                let uttrance = AVSpeechUtterance(string: (dicS["content"] as! String))
                let delay : Int = dicS["delay"] as! Int
                uttrance.rate *= 1
                uttrance.voice = avVoice
                
                let flowItem = FlowItem(utt: uttrance,delay: delay, index: i*j + j)
                self.itmes.add(flowItem!)
            }
        }
    }
    
    public func loadItemsWithDictionary(dic : Dictionary<AnyHashable, Any>,time: NSInteger){
        //重新初始化，确保新的items正常
        self.resetData()
        maxTime = time
        
        for i in 0..<dic.count{
            let dicM = dic["\(i)"] as![AnyHashable : Any]
            let json = JSON(dicM)
            let avVoice = AVSpeechSynthesisVoice(language: (json["local"].stringValue))
            let uttrance = AVSpeechUtterance(string: (json["content"].stringValue))
            let delay = json["time"].intValue
            uttrance.rate *= 1
            uttrance.voice = avVoice
            
            let flowItem = FlowItem(utt: uttrance, delay: delay, index: i)
            self.itmes.add(flowItem!)
        }
    }
}

//MARK: - Controll
extension TTSpeechFlowManager{

    public func begin(){
        assert(itmes.count > 0, "初始化数据错误,可能是操作过于频繁")
        timer = PauseableTimer(timer: Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true))
    }
    
    public func stop(){
        TTSpeechManager.stop()
        timer?.invalidate()
        resetData()
    }
    
    public func pause(){
        TTSpeechManager.pause()
        timer?.pause()
    }
    
    public func flowContinue(){
        TTSpeechManager.contiue()
        timer?.resume()
    }
    
    @objc func timerAction(){
         //已经退出,而且重置所有数据了
        if itmes.count == 0 { return }
        
        guard let item = loadNextItem() else {
            DPrint("currectItem is nil !")
            return
        }
        //这个通知必须在这里重新post
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:TTSpeechManager.timerSecondUpdate), object: maxTime! - countor)
        
        if NSInteger(item.delay) == countor{
            speakWithUttrance(item: item)
            indicator += 1 //数组游标当播放一个完成后才加1
        }
        //timer计数器每次都加1
        countor += 1
    }
    
    public func speakWithUttrance(item: FlowItem) {
        
        TTSpeechManager.speakWithUttrance(uttrance: item.utt,timeInteger: item.delay, progress: {(progress) in
            //            DPrint(progress)
        }, finish: {[weak self]  finish  in
            DPrint("countor : \(String(describing: self?.countor))")
            if let countor = self?.countor{
                if countor == (self?.maxTime)! - 1{//到达最大时间时退出
                    self?.resetData()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: TTSpeechManager.speechStatus.exit), object: nil)
                }
            }
        })
    }
}

//MARK: - private
extension TTSpeechFlowManager{

    fileprivate func loadNextItem() -> FlowItem?{
        if indicator >= itmes.count{
            return nil
        }
        let item =  itmes[indicator] as? FlowItem
        return item
    }
    
    fileprivate func resetData(){
        self.itmes.removeAllObjects()
        self.countor = 0
        self.indicator = 0
        self.timer?.invalidate()
        TTSpeechManager.stop()
    }
}

