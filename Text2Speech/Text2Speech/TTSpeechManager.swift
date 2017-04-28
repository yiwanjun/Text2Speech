//
//  TTSpeechSynthesizer.swift
//  Text2Speech
//
//  Created by zhouyi on 2017/4/18.
//  Copyright © 2017年 NewBornTown, Inc. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation
import Dispatch

final public class TTSpeechManager: NSObject {
    
    fileprivate static let shareManager = TTSpeechManager()
    
    private override init() {
        super.init()
    }
    
    fileprivate var currentWork : DispatchWorkItem?
    fileprivate var synThesizer : AVSpeechSynthesizer?
    fileprivate var voice : AVSpeechSynthesisVoice?
    fileprivate var uttrance : AVSpeechUtterance?
    
    //播放完成后的回调
    fileprivate var finish: ((Bool) -> Void)?
    //获取播放进度
    fileprivate var progress : ((String) -> Void)?
    
    struct speechStatus {
        static let begain  = "kSynTheBegain"
        static let pause   = "kSynThePause"
        static let contiue = "KSynTheContiue"
        static let end     = "kSynTheEnd"
        static let exit    = "kSynTheExit"
    }
    static let timerSecondUpdate = "kTimerSecondUpdate"
}
//MARK: - Action
extension TTSpeechManager{
    open class func pause(){
        if let syn = shareManager.synThesizer ,syn.isSpeaking{
            syn.pauseSpeaking(at: AVSpeechBoundary.immediate)
        }
    }
    
    open class func contiue(){
        if let syn = shareManager.synThesizer,syn.isPaused{
            syn.continueSpeaking()
        }
    }
    
    open class func stop(){
        if let syn = shareManager.synThesizer{
            syn.stopSpeaking(at: AVSpeechBoundary.immediate)
        }
        
        if let work = shareManager.currentWork{
            work.cancel()
        }
    }
    
    open class func isSpeaking() -> Bool{
        guard let syn = shareManager.synThesizer else {
            return false
        }
        return syn.isSpeaking
    }
}
//MARK: - Speak
extension TTSpeechManager{
    
    public class func SpeakWithUttrance(uttrance: AVSpeechUtterance,progress: @escaping (String) -> Void,finish:@escaping (Bool) -> Void){
        SpeakWithUttrance(uttrance: uttrance, timeInteger: 0, progress: progress, finish: finish)
    }
    
    public class func SpeakWithUttrance( uttrance: AVSpeechUtterance, timeInteger: TimeInterval,progress: @escaping (String) -> Void,finish: @escaping (Bool) -> Void) {
        
        let work = DispatchWorkItem {
            if let syn = shareManager.synThesizer {
                syn.speak(uttrance)
                shareManager.finish = finish
            }else{
                let syn = AVSpeechSynthesizer()
                shareManager.synThesizer = syn
                shareManager.finish = finish
                shareManager.progress = progress
                syn.delegate = shareManager
                syn.speak(uttrance)
            }
        }
        shareManager.currentWork = work
        DispatchQueue.global(qos: .default).async(execute: work)
    }
    
    public class func SpeakAfterWithUttrance( uttrance: AVSpeechUtterance, timeInteger: TimeInterval,progress: @escaping (String) -> Void,finish: @escaping (Bool) -> Void) {
        
        let work = DispatchWorkItem {
            if let syn = shareManager.synThesizer {
                syn.speak(uttrance)
                shareManager.finish = finish
            }else{
                let syn = AVSpeechSynthesizer()
                shareManager.synThesizer = syn
                shareManager.finish = finish
                shareManager.progress = progress
                syn.delegate = shareManager
                syn.speak(uttrance)
            }
        }
        shareManager.currentWork = work
        DispatchQueue.global(qos: .default).asyncAfter(deadline: DispatchTime.now()+timeInteger, execute: work)
    }

}

   //MARK: - AVSpeechSynthesizerDelegate
extension TTSpeechManager : AVSpeechSynthesizerDelegate{
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("||==>speech text: ",utterance.speechString)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: speechStatus.begain), object: nil)
    }
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: speechStatus.pause), object: nil)
    }
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        //这里的 end 通知必须在前面，因为end通知发送会播放背景音乐，finish回调闭包内可能会停止播放背景音乐，细节去看闭包TTSpeechFlowManager具体实现
        NotificationCenter.default.post(name: Notification.Name(rawValue: speechStatus.end), object: nil)
        finish?(true)
    }
    //获取当前utterance的阅读进度
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        let text = utterance.speechString
        let start = text.index(text.startIndex, offsetBy: characterRange.location)
        let end = text.index(text.startIndex, offsetBy: characterRange.location + characterRange.length)
        let rang = start..<end
        progress?(text.substring(with: rang))
    }
}
