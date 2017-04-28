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

enum PlayStutas {
    case ready
    case pause
    case playing
}

class ActionsManager: NSObject {

    private var speechStaus: String
    
    fileprivate var playStutas: PlayStutas
    
    public var actions: Array<SpeechAction>
    
    private var currentSpeechIndex:Int = 0
    
    private var flowManager = TTSpeechFlowManager()
    
    weak var delegate : ActionsManagerDelegate?
    
    public init?(actions: Array<SpeechAction>) {
        self.actions = actions
        self.speechStaus = SpeechTextElement.ready
        self.playStutas = PlayStutas.ready
    }
    
    public func begain(){
        
        assert(currentSpeechIndex <= actions.count, "数组为空或者越界")
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationExit), name: Notification.Name(rawValue:TTSpeechManager.speechStatus.exit), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(speechFlowManagerUpdate), name: NSNotification.Name(rawValue: TTSpeechManager.timerSecondUpdate), object: nil)
        
        self.playBackgroudAudio()
        
        let sa = actions[currentSpeechIndex]
        speechStaus = sa.ak.action.type
        flowManager.loadItemsWithDictionary(dic: sa.speech, time: sa.ak.action.time)
        flowManager.begain()
    }
    
    public func next(){

        switch speechStaus {
        case SpeechTextElement.rest:
            play()
        case SpeechTextElement.forceRest:
            play()
        default:
            print("出错了")
        }
    }
    
    private func play()  {
        playStutas = PlayStutas.playing
        currentSpeechIndex += 1
        let sa = actions[currentSpeechIndex]
        speechStaus = sa.ak.action.type
        self.flowManager.loadItemsWithDictionary(dic: sa.speech, time: sa.ak.action.time)
        flowManager.begain()
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
//        playStutas = PlayStutas.playing
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
            print("出错了")
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
        default:
            print("出错了")
        }
    }
}

extension ActionsManager{
    
    fileprivate func playBackgroudAudio()  {
        let path = Bundle.main.path(forResource: "BackGroundMusic", ofType: "mp3")
        do {
            try NBAudioBot.PlayerWithURL(URL.init(fileURLWithPath: path!), finish: { (sucess) in
                print("播放背景音乐成功")
            })
        } catch  {
            print(error.localizedDescription)
        }
    }
    
    fileprivate func stopBackgroudMusic() {
        NBAudioBot.stopPlay()
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


