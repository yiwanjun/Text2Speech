//
//  NBAudioBot.swift
//  Text2Speech
//
//  Created by zhouyi on 2017/4/18.
//  Copyright © 2017年 NewBornTown, Inc. All rights reserved.
//

import UIKit
import AVFoundation

class NBAudioBot: NSObject {
    
    fileprivate static let shareBot = NBAudioBot()
    override init() {
        super.init()
    }
    fileprivate var isExit = false
    fileprivate var audioPlayer : AVAudioPlayer?//播放背景音乐
    fileprivate var dingAudioPlayer : AVAudioPlayer?//用于播放 叮叮 声音
}

extension NBAudioBot{

    public class func PlayerWithURL(_ fileURL: URL ,finish: @escaping(Bool) -> Void) throws {

        NotificationCenter.default.addObserver(shareBot, selector: #selector(notificationBegin), name: Notification.Name(rawValue:TTSpeechManager.speechStatus.begin), object: nil)
        NotificationCenter.default.addObserver(shareBot, selector: #selector(notificationEnd), name: Notification.Name(rawValue:TTSpeechManager.speechStatus.end), object: nil)
        NotificationCenter.default.addObserver(shareBot, selector: #selector(notificationExit), name: Notification.Name(rawValue:TTSpeechManager.speechStatus.exit), object: nil)
        
        let seesion = AVAudioSession.sharedInstance()
        do {
            try seesion.setCategory(AVAudioSessionCategoryPlayback)
            try seesion.setActive(true)
        } catch let err {
            throw err
        }
        
        if let audioPlayer = shareBot.audioPlayer, audioPlayer.url == fileURL  {
            audioPlayer.play()
        }else{
            shareBot.audioPlayer?.stop()
            do {
                let player = try AVAudioPlayer(contentsOf: fileURL)
                player.numberOfLoops = 9999
                player.prepareToPlay()
                player.play()
                shareBot.audioPlayer = player
            } catch  {
                throw error
            }
        }
    }
    public class func contiuePlay(){
        if shareBot.isExit == true{
            return
        }
        if let player = shareBot.audioPlayer, player.prepareToPlay(){
            player.play()
            print("player contiue play")
        }
    }
    public class func pasuePlay(){
        if let player = shareBot.audioPlayer , player.isPlaying{
            player.pause()
            print("player pause")
        }
    }
    
    public class func stopPlay(){
        if let player = shareBot.audioPlayer{
            player.stop()
            print("player stop")
        }
    }
    public class func exitPlay(){
        stopPlay()
        shareBot.isExit = true
    }
}

extension NBAudioBot{
    open class func playDing( withURL fileURL: URL,loops: Int) throws{
        
        if let dingPlayer = shareBot.dingAudioPlayer , dingPlayer.url == fileURL{
            dingPlayer.play()
        }else{
            shareBot.dingAudioPlayer?.stop()
            do {
                let player = try AVAudioPlayer(contentsOf: fileURL)
                player.numberOfLoops = loops
                player.prepareToPlay()
                player.play()
                shareBot.dingAudioPlayer = player
                
            } catch  {
                throw error
            }
        }
    }
}

extension NBAudioBot{
    @objc func notificationBegin(){
        NBAudioBot.pasuePlay()
    }
    @objc func notificationEnd(){
        NBAudioBot.contiuePlay()
    }
    @objc func notificationExit(){
        NBAudioBot.stopPlay()
    }
}

