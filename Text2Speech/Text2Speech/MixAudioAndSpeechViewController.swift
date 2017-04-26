//
//  MixAudioAndSpeechViewController.swift
//  Text2Speech
//
//  Created by zhouyi on 2017/4/18.
//  Copyright © 2017年 NewBornTown, Inc. All rights reserved.
//

import UIKit

class MixAudioAndSpeechViewController: UIViewController {
    
    var flowManager = TTSpeechFlowManager()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        initItems()
    }
    
    func initItems() {
        
        DispatchQueue.global(qos: .default).async(execute: {()-> Void in
            let plistPath = Bundle.main.path(forResource: "Sports", ofType: "plist")
            self.flowManager.loadConfigFileAndInitItems(path: plistPath!)
        })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NBAudioBot.stopPlay()
        self.flowManager.stop()
    }
    
    @IBAction func playMusic(_ sender: Any) {
        playerAudio()
        self.flowManager.begain()
    }
    
    @IBAction func pauseMusic(_ sender: Any) {
        NBAudioBot.pasuePlay()
    }
    
    @IBAction func stopMusic(_ sender: Any) {
        NBAudioBot.stopPlay()
    }

}
extension MixAudioAndSpeechViewController{
    
    func playerAudio()  {
        let path = Bundle.main.path(forResource: "BackGroundMusic", ofType: "mp3")
        
        do {
            try NBAudioBot.PlayerWithURL(URL.init(fileURLWithPath: path!), finish: { (sucess) in
                print("播放背景音乐成功")
            })
        } catch  {
            print(error.localizedDescription)
        }
    }
}
