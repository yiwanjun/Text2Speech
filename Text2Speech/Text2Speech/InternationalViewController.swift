//
//  InternationalViewController.swift
//  Text2Speech
//
//  Created by zhouyi on 2017/4/18.
//  Copyright © 2017年 NewBornTown, Inc. All rights reserved.
//

import UIKit
import AVFoundation

class InternationalViewController: UIViewController {
    
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func speak(_ sender: Any) {
        let plistPath = Bundle.main.path(forResource: "Language", ofType: "plist")
        let dicM: NSDictionary! = NSDictionary.init(contentsOfFile: plistPath!)
        DispatchQueue.global(qos: .default).async(execute: {()-> Void in
            for i in 0..<dicM.count{
                let dicS = dicM["\(i)"] as! [AnyHashable:Any]
                let avVoice = AVSpeechSynthesisVoice.init(language: (dicS["local"] as! String))
                let uttrance = AVSpeechUtterance.init(string: (dicS["content"] as! String))
                uttrance.rate *= 1
                uttrance.voice = avVoice

                TTSpeechManager.speakWithUttrance(uttrance: uttrance, progress: {(progress) in
                    print(progress)
                }, finish: { (finish) in
                    print("end \(dicS)",dicS)
                })
                DispatchQueue.main.async {
                    self.languageLabel.text = dicS["local"] as? String
                    self.contentLabel.text = dicS["content"] as? String
                }
                Thread.sleep(forTimeInterval: 3)
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        TTSpeechManager.stop()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
