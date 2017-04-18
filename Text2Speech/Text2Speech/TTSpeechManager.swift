//
//  TTSpeechSynthesizer.swift
//  Text2Speech
//
//  Created by zhouyi on 2017/4/18.
//  Copyright © 2017年 NewBornTown, Inc. All rights reserved.
//

import UIKit
import AVFoundation

final public class TTSpeechManager: NSObject {
    
    fileprivate static let shareManager = TTSpeechManager()
    
    private override init() {
        super.init()
    }
    
    fileprivate var synThesizer : AVSpeechSynthesizer?
    fileprivate var voice : AVSpeechSynthesisVoice?
    fileprivate var uttrance : AVSpeechUtterance?
    
    //播放完成后的回调
    fileprivate var finish: ((Bool) -> Void)?
    //获取播放进度
    fileprivate var progress : ((String) -> Void)?
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
        if ((shareManager.synThesizer) != nil  && (shareManager.synThesizer?.isSpeaking)!) {
            shareManager.synThesizer?.stopSpeaking(at: AVSpeechBoundary.word)
        }
    }
}

extension TTSpeechManager{
    public class func SpeakWithUttrance( uttrance: AVSpeechUtterance, progress: @escaping (String) -> Void,finish: @escaping (Bool) -> Void) {
        if let syn = shareManager.synThesizer {
            syn.speak(uttrance)
        }else{
            let syn = AVSpeechSynthesizer()
            shareManager.synThesizer = syn
            shareManager.finish = finish
            shareManager.progress = progress
            syn.delegate = shareManager
            syn.speak(uttrance)
        }
    }
}

extension TTSpeechManager : AVSpeechSynthesizerDelegate{

    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("speech begain")
    }
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("speech end")
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
