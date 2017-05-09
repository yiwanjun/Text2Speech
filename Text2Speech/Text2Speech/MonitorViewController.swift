//
//  MonitorViewController.swift
//  Text2Speech
//
//  Created by zhouyi on 2017/4/18.
//  Copyright © 2017年 NewBornTown, Inc. All rights reserved.
//

import UIKit
import AVFoundation

class MonitorViewController: UIViewController {
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var currentTextLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func speak(_ sender: Any) {
        let content = "If you have multiple schemes that build different independent products (or the same product for different platforms) it is important to create one scheme that builds everything in your project and for all the platforms you need, including your unit test targets. "
        self.contentLabel.text = content
        DispatchQueue.global(qos: .default).async(execute: {()-> Void in
            let avVoice = AVSpeechSynthesisVoice.init(language: "en-US")
            let uttrance = AVSpeechUtterance.init(string: content)
            uttrance.rate *= 0.7
            uttrance.voice = avVoice
            TTSpeechManager.speakWithUttrance(uttrance: uttrance, progress: { (progress) in
                self.currentTextLabel.text = progress
            }, finish: { (isFinish) in
                print("speak end")
            })

        })
    }
    
    @IBAction func pause(_ sender: Any) {
        TTSpeechManager.pause()
    }
    
    @IBAction func contiue(_ sender: Any) {
        TTSpeechManager.contiue()
    }
    
    @IBAction func stop(_ sender: Any) {
        TTSpeechManager.stop()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        TTSpeechManager.stop()
    }

}
