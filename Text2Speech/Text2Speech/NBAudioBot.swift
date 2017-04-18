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
    
    fileprivate var audioPlayer : AVAudioPlayer?
}

extension NBAudioBot{
    public class func PlayerWithURL(_ fileURL: URL ,finish: @escaping(Bool) -> Void) throws {
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
            shareBot.audioPlayer?.pause()
            do {
                let player = try AVAudioPlayer(contentsOf: fileURL)
                shareBot.audioPlayer = player
                player.delegate = shareBot
                player.prepareToPlay()
                player.play()
            } catch  {
                throw error
            }
        }
    }
    public class func pasuePlay(){
       shareBot.audioPlayer?.pause()
    }
    
    public class func stopPlay(){
        shareBot.audioPlayer?.stop()
    }
}

extension NBAudioBot : AVAudioPlayerDelegate{
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("播放完成")
    }
    public func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("audio plyer error : \(String(describing: error))",error.debugDescription)
    }
    
}

