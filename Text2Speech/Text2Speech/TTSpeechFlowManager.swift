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
    var timer : PauseableTimer?
    
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
                let delay : Int = dicS["delay"] as! Int
                uttrance.rate *= 1
                uttrance.voice = avVoice
                
                let flowItem = FlowItem(utt: uttrance,delay: delay, index: i*j + j)
                self.itmes.add(flowItem!)
            }
        }
    }
    
    public func loadItemsWithDictionary(dic : Dictionary<AnyHashable, Any>,time: NSInteger){
        
        self.resetData()
        
        maxTime = time
        
        for i in 0..<dic.count{
            let dicM = dic["\(i)"] as![AnyHashable : Any]
            let json = JSON.init(dicM)
            let avVoice = AVSpeechSynthesisVoice(language: (json["local"].stringValue))
            let uttrance = AVSpeechUtterance(string: (json["content"].stringValue))
            let delay = json["time"].intValue
            uttrance.rate *= 1
            uttrance.voice = avVoice
            
            let flowItem = FlowItem(utt: uttrance, delay: delay, index: i)
            self.itmes.add(flowItem!)
        }
        
        
    }
    
    private func loadFirstItem() -> FlowItem{
        let first = self.itmes.firstObject as! FlowItem
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
        timer = PauseableTimer(timer: Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true))

    }
    
    public func stop(){
        TTSpeechManager.stop()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: TTSpeechManager.speechStatus.exit), object: nil)
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

        if indicator == 0{
            speakWithUttrance(item: loadFirstItem())
            NotificationCenter.default.post(name: NSNotification.Name(rawValue:TTSpeechManager.timerSecondUpdate), object: maxTime! - countor)
            currentItem = loadNextItem()
            return
        }
        
        let item = currentItem
        if item == nil{
            print("异常")
            timer?.invalidate()
            return
        }
        
        countor += 1
        //这个通知必须在这里重新post
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:TTSpeechManager.timerSecondUpdate), object: maxTime! - countor)
        
        if NSInteger((item?.delay)!) == countor{
            speakWithUttrance(item: item!)
            currentItem = loadNextItem()
          
        }else if NSInteger((item?.delay)!) == indicator - 1{
            timer?.invalidate()
        }
    }
    public func speakWithUttrance(item: FlowItem) {
        
        TTSpeechManager.SpeakWithUttrance(uttrance: item.utt,timeInteger: item.delay, progress: {(progress) in
//            print(progress)
        }, finish: {[weak self]  finish  in
            print("countor\(String(describing: self?.countor))")
            if let countor = self?.countor{
                if countor == (self?.maxTime)! - 1{//到达最大时间时退出
                    self?.resetData()
                    self?.postExitNotification()
                }
            }
        })
    }
    private  func postExitNotification(){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: TTSpeechManager.speechStatus.exit), object: nil)
    }
    
    private func resetData(){
        self.itmes.removeAllObjects()
        self.countor = 0
        self.indicator = 0
        self.timer?.invalidate()
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
