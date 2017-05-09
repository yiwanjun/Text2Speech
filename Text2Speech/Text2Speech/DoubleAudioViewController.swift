//
//  DoubleAudioViewController.swift
//  Text2Speech
//
//  Created by zhouyi on 2017/5/3.
//  Copyright © 2017年 NewBornTown, Inc. All rights reserved.
//

import UIKit

class DoubleAudioViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        playBackgroudAudio()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func play(_ sender: Any) {
        playDingAudio()
        
    }
    fileprivate func playBackgroudAudio()  {
        let path = soundPath(withSource: "BackGroundMusic", type: "mp3")
        
        do {
            try NBAudioBot.PlayerWithURL(URL.init(fileURLWithPath: path), finish: { (sucess) in
                print("播放背景音乐成功")
            })
        } catch  {
            print(error.localizedDescription)
        }
    }
    
    fileprivate func playDingAudio(){
        let path = soundPath(withSource: "ding", type: "mp3")
        do {
            try NBAudioBot.playDing(withURL: URL(fileURLWithPath: path), loops: 0)
        } catch  {
            print(error.localizedDescription)
        }
    }
    
    //计时运动的时候卡妙声音
    fileprivate func playDaDaAudio(){
        let path = soundPath(withSource: "td_di", type: "mp3")
        do {
            try NBAudioBot.playDing(withURL: URL(fileURLWithPath: path), loops: 0)
        } catch  {
            print(error.localizedDescription)
        }
    }
    
    private func soundPath( withSource name: String, type: String) -> String{
        var path : String?
        
        if let temp = Bundle.main.path(forResource: name, ofType: type) {
            path = temp
        }
        return path!
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
