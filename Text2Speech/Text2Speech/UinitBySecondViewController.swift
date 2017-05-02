//
//  UinitBySecondViewController.swift
//  Text2Speech
//
//  Created by zhouyi on 2017/4/25.
//  Copyright © 2017年 NewBornTown, Inc. All rights reserved.
//

import UIKit
import Foundation
import Dispatch

class UinitBySecondViewController: UIViewController,ActionsManagerDelegate,ActionsManagerDataSource {
    @IBOutlet weak var timeLabel: UILabel!
  
    @IBOutlet weak var mixButton: UIButton!
    
    var timer = Timer()
    var mycountor = 0
    var actionsManager: ActionsManager?
    var mySpeechAction : SpeechAction?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let actionsEx = [["actionId":2,"time":14],["actionId":1,"time":6],["actionId":3,"time":10]]
        
        ItemsGenerator(plan: actionsEx)?.gennerate(finish: {[weak self] (speechs)  in
            self?.actionsManager = ActionsManager(actions: speechs)
            self?.actionsManager?.delegate = self
            self?.actionsManager?.datasource = self
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        actionsManager?.stop()
    }
    
    @IBAction func begain(_ sender: Any) {
        actionsManager?.begain()
    }
    
    @IBAction func finishOne(_ sender: Any) {
        actionsManager?.finishOne()
        
    }
    @IBAction func playNext(_ sender: Any) {
        
        actionsManager?.next()
    }
    
    @IBAction func pause(_ sender: Any) {
        actionsManager?.pause()
    }
    
    @IBAction func contiue(_ sender: Any) {
        actionsManager?.contiue()
    }
    

    @IBAction func mixButtonAction(_ sender: UIButton) {
        
  
        guard let sa = mySpeechAction else {
            actionsManager?.begain()
            return
        }
        
        switch sa.ak.action.type {
        case SpeechTextElement.ready:
            playNext(sender)
        case SpeechTextElement.actionCount:
            finishOne(sender)
        case SpeechTextElement.actionTimer:
            if sender.isSelected == true{
                contiue(sender)
                sender.titleLabel?.text = "播放中"
                sender.isSelected = false
            }else{
                pause(sender)
                sender.titleLabel?.text = "暂停中"
                sender.isSelected = true
            }
        case SpeechTextElement.rest:
            playNext(sender)
        case SpeechTextElement.forceRest:
            playNext(sender)
        default:
            actionsManager?.begain()
        }
    }
    
    
    func actionsManagerTimerReadyUpdate(countor: NSInteger) {
        print("预备 ", countor)
        timeLabel.text = "预备 " + String( countor)
    }
    
    func actionsManagerTimerCountIntrodctionUpdate(countor: NSInteger) {
        timeLabel.text = "计时动作预备开始 " + String(countor)
    }
    
    func actionsManagerTimerCountUpdate(countor: NSInteger) {
        timeLabel.text = "计时动作 " + String(countor)
    }
    
    func actionManagerCurrentSpeechAction(speechAction: SpeechAction) {
        mySpeechAction = speechAction
        print(speechAction)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

