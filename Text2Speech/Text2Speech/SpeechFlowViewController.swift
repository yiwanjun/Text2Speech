//
//  SpeechFlowViewController.swift
//  Text2Speech
//
//  Created by zhouyi on 2017/4/18.
//  Copyright © 2017年 NewBornTown, Inc. All rights reserved.
//

import UIKit
import AVFoundation

class SpeechFlowViewController: UIViewController {
    
    var flowManager :TTSpeechFlowManager = TTSpeechFlowManager()
    fileprivate var index : NSInteger?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        initItems()
    }
    
    func initItems()  {
        DispatchQueue.global(qos: .default).async(execute: {()-> Void in
            let plistPath = Bundle.main.path(forResource: "Sports", ofType: "plist")
            self.flowManager.loadConfigFileAndInitItems(path: plistPath!)
        })
    }
    
    @IBAction func speak(_ sender: Any) {
        self.flowManager.begain()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.flowManager.stop()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
