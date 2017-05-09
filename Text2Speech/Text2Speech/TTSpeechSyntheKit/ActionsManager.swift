//
//  ActionsManager.swift
//  Text2Speech
//
//  Created by zhouyi on 2017/4/26.
//  Copyright © 2017年 NewBornTown, Inc. All rights reserved.
//

import UIKit

protocol ActionsManagerDelegate : NSObjectProtocol {
    func actionsManagerTimerReadyUpdate(countor: NSInteger)
    func actionsManagerTimerCountIntrodctionUpdate(countor: NSInteger)
    func actionsManagerTimerCountUpdate(countor: NSInteger)
}

protocol ActionsManagerDataSource : NSObjectProtocol{
    func actionManagerCurrentSpeechAction(speechAction: SpeechAction)
}

enum PlayStutas {
    case ready
    case pause
    case playing
}

class ActionsManager: NSObject {

    fileprivate var speechStaus: String
    
    fileprivate var playStutas: PlayStutas
    
    public var actions: Array<SpeechAction>
    
    fileprivate var currentSpeechIndex:Int = 0
    
    fileprivate var flowManager = TTSpeechFlowManager()
    
    weak var delegate : ActionsManagerDelegate?
    
    weak var datasource : ActionsManagerDataSource?
    
    public init?(actions: Array<SpeechAction>) {
        self.actions = actions
        self.speechStaus = SpeechTextElement.ready
        self.playStutas = PlayStutas.ready
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public func begin(){
        
        assert(currentSpeechIndex <= actions.count, "数组为空或者越界")
        NotificationCenter.default.addObserver(self, selector: #selector(notificationExit), name: Notification.Name(rawValue:TTSpeechManager.speechStatus.exit), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(speechFlowManagerUpdate), name: NSNotification.Name(rawValue: TTSpeechManager.timerSecondUpdate), object: nil)
        
        self.playBackgroudAudio()
        
        playCommon()
    }
    
    public func next(){

        switch speechStaus {
        case SpeechTextElement.rest:
            play()
        case SpeechTextElement.ready:
            play()
        default:
            print("出错了")
        }
    }
    
    private func play()  {
        playStutas = PlayStutas.playing
        currentSpeechIndex += 1
        playCommon()
    }

    public func finishOne(){

        switch speechStaus {
        case SpeechTextElement.actionCount:
            play()
        case SpeechTextElement.actionTimer:
            play()
        default:
            print("出错了")
        }
    }
    
    public func stop(){
        flowManager.stop()
        stopBackgroudMusic()
    }
    
    public func pause(){
        playStutas = PlayStutas.pause
        flowManager.pause()
        pauseBackgroufMusic()
    }
    
    public func contiue(){
        playStutas = PlayStutas.playing
        flowManager.flowContinue()
        continueBackgroudMusic()
    }
    
    @objc func notificationExit(){

        switch speechStaus {
        case SpeechTextElement.ready:
            play()
        case SpeechTextElement.forceRest:
            play()
        case SpeechTextElement.actionTimer:
            play()
        default:
            print("do nothing")
        }
    }
    
    @objc func speechFlowManagerUpdate(notification:Notification) {
        let second = notification.object as! NSInteger
        switch speechStaus {
        case SpeechTextElement.ready:
            self.delegate?.actionsManagerTimerReadyUpdate(countor: second)
        case SpeechTextElement.forceRest:
            delegate?.actionsManagerTimerCountIntrodctionUpdate(countor: second)
        case SpeechTextElement.actionTimer:
            delegate?.actionsManagerTimerCountUpdate(countor: second)
            playDaDaAudio()
        default:
            print("do nothing")
        }
    }
}

extension ActionsManager{
    
    fileprivate func playCommon(){
        
        //完成训练时的 叮叮
        if currentSpeechIndex == actions.count - 1  {
            playDingAudio()
        }
        
        let sa = actions[currentSpeechIndex]
        speechStaus = sa.ak.action.type
        self.flowManager.loadItemsWithDictionary(dic: sa.speech, time: sa.ak.action.time)
        flowManager.begin()

        datasource?.actionManagerCurrentSpeechAction(speechAction: sa)
    }
}

extension ActionsManager{
    
    fileprivate func playBackgroudAudio()  {
        guard let path = soundPath(withSource: "sound/BackGroundMusic", type: "mp3") else {
            return
        }
        do {
            try NBAudioBot.PlayerWithURL(URL(fileURLWithPath: path), finish: { (sucess) in
                print("播放背景音乐成功")
            })
        } catch  {
            print(error.localizedDescription)
        }
    }
    
    fileprivate func playDingAudio(){
        guard let path = soundPath(withSource: "sound/ding", type: "mp3") else {
            return
        }
        do {
            try NBAudioBot.playDing(withURL: URL(fileURLWithPath: path), loops: 0)
        } catch  {
            print(error.localizedDescription)
        }
    }
    
    //计时运动的时候卡妙声音
    fileprivate func playDaDaAudio(){
        print("playDaDaAudio sound/td_di")
        guard let path = soundPath(withSource: "sound/ding", type: "wav") else {
            return
        }
        do {
            try NBAudioBot.playDing(withURL: URL(fileURLWithPath: path), loops: 0)
        } catch  {
            print(error.localizedDescription)
        }
    }
    
    private func soundPath( withSource name: String, type: String) -> String?{
        var path : String?
        
        if let bundlePath = Bundle.main.path(forResource: "SportResource", ofType: "bundle") {
            let sportsBundle = Bundle(path: bundlePath)
            path = sportsBundle?.path(forResource: name, ofType: type)
        }
        assert((path != nil), "path error")
        return path
    }
    fileprivate func stopBackgroudMusic() {
        NBAudioBot.exitPlay()
    }
    
    fileprivate func pauseBackgroufMusic(){
        NBAudioBot.pasuePlay()
    }
    
    fileprivate func continueBackgroudMusic(){
        if playStutas == PlayStutas.playing {
            NBAudioBot.contiuePlay()
        }
        
    }
}


