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
}

extension TTSpeechManager{
    open class func pause(){
        if ((shareManager.synThesizer) != nil  && (shareManager.synThesizer?.isSpeaking)!) {
            shareManager.synThesizer?.pauseSpeaking(at: AVSpeechBoundary.word)
        }
    }
    
    open class func contiue(){
        if ((shareManager.synThesizer) != nil  && (shareManager.synThesizer?.isPaused)!) {
            shareManager.synThesizer?.continueSpeaking()
        }
    }
    
    open class func stop(){
        if ((shareManager.synThesizer) != nil ){
            shareManager.synThesizer?.stopSpeaking(at: AVSpeechBoundary.immediate)
        }
        if (shareManager.currentWork != nil) {
            shareManager.currentWork?.cancel()
        }
        
    }
    
    open class func isSpeaking() -> Bool{
        
        return (shareManager.synThesizer != nil) && (shareManager.synThesizer?.isSpeaking)!
    }
}

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
        DispatchQueue.global(qos: .default).asyncAfter(deadline: DispatchTime.now()+timeInteger, execute: work)
    }
}

extension TTSpeechManager : AVSpeechSynthesizerDelegate{
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("speech begain",utterance.speechString)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: speechStatus.begain), object: nil)
    }
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: speechStatus.pause), object: nil)
    }
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        finish?(true)
        NotificationCenter.default.post(name: Notification.Name(rawValue: speechStatus.end), object: nil)
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
