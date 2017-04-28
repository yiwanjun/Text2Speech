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

class UinitBySecondViewController: UIViewController,ActionsManagerDelegate {
    @IBOutlet weak var timeLabel: UILabel!
  
    var timer = Timer()
    var mycountor = 0
    var actionsManager: ActionsManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let actionsEx = [["actionId":2,"time":14],["actionId":1,"time":6],["actionId":3,"time":10]]
        
        ItemsGenerator(plan: actionsEx)?.gennerate(finish: {[weak self] (speechs)  in
            self?.actionsManager = ActionsManager(actions: speechs)
            self?.actionsManager?.delegate = self
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

