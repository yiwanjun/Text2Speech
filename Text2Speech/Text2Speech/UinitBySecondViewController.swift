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
class UinitBySecondViewController: UIViewController {
    @IBOutlet weak var timeLabel: UILabel!
  
    var timer = Timer()
    var countor = 0
    var flowManager = TTSpeechFlowManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let actionsEx = [["actionId":0,"time":8],["actionId":2,"time":14],["actionId":1,"time":6],["actionId":3,"time":10]]
        
        
        ItemsGenerator(plan: actionsEx)?.gennerate(finish: {[weak self] (dics)  in
            
             self?.flowManager.loadItemsWithDictionary(dic: dics, time: 10)
        })
        
     
    }

    
    @IBAction func begain(_ sender: Any) {
        
        flowManager.begain()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
