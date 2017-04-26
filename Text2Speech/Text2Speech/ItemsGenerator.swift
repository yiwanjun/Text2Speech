//
//  ItemGenerator.swift
//  Text2Speech
//
//  Created by zhouyi on 2017/4/25.
//  Copyright © 2017年 NewBornTown, Inc. All rights reserved.
//

import UIKit

class ItemsGenerator: NSObject {
    var plans:Array<Dictionary<String,Any>>
    let prepare = "Ready to go"
    let startWith = "start with "
    let begain:String = "do the exercise"
    let next:String = "next"
    let half:String = "half the time"
    let rest:String = "take a rest"
    let local:String = "en-US"
    let finish:String = "congratulations"
    
    
    public init?(plan:Array<Dictionary<String,Any>>){
        self.plans = plan
    }
    
    public func gennerate(finish: @escaping (Dictionary<String, AnyObject>) -> Void) {

       ActionsHelper.shareHelper.loadJson { (helper) in
        //ready
        var actions = Array<Any>()
        
        if let first = self.plans.first {
            let action = helper.getActionWithId(id: first["actionId"] as! NSNumber)
            let startWithName = self.startWith.appending(action["name"] as! String)
            let ready = [self.prepare,startWithName,"3","2","1"]
            actions.append(ready)
        }
        
        var i = 0
        for plan in self.plans{
            let actionId = plan["actionId"]
            let time = plan["time"] as! NSNumber
            
            let action = helper.getActionWithId(id: actionId! as! NSNumber)
            let unit = action["unit"] as! String
            var contentArray = Array<Any>()
            
            if unit == "s" {
                contentArray = [self.begain,action["name"] as! String,self.half,"3","2","1",self.next];
                
            }else{
                contentArray = [self.begain,time,action["name"] as! String]
            }
            actions.append(contentArray)
            i += 1
        }
        
//        let dic = self.getItemsWithContent(contentArray: actions)
//        finish(dic as! Dictionary<String, AnyObject>)
     
        }
    }
    
//    private func speechsTextsWithContent(contentArray: Array<Any>) -> [String:AnyObject]{
//        
//    }
    
}

extension ItemsGenerator{
    //预备开始
    private func readyItemsWithContent(contentArray: Array<Any>,time: Int) -> NSDictionary {
        
        let dic = NSMutableDictionary()
        
        for i in 0..<contentArray.count {
            switch i {
            case 0:
                dic.addEntries(from: speechTextWithAction(content: contentArray[i], index: i, time: 0))
            case 1:
                dic.addEntries(from: speechTextWithAction(content: contentArray[i], index: i, time: 2))
            case 2:
                dic.addEntries(from: speechTextWithAction(content: contentArray[i], index: i, time: 4))
            case 3:
                dic.addEntries(from: speechTextWithAction(content: contentArray[i], index: i, time: time - 3))
            case 4:
                dic.addEntries(from: speechTextWithAction(content: contentArray[i], index: i, time: time - 2 ))
            case 5:
                dic.addEntries(from: speechTextWithAction(content: contentArray[i], index: i, time: time - 1))
            default: break
                
            }
        }
        
        return dic
    }
    
    //计次动作
    private func countItemsWithContent(contentArray: Array<Any>,time: Int) -> NSDictionary {
        
        let dic = NSMutableDictionary()
        
        for i in 0..<contentArray.count {
            switch i {
            case 0:
                dic.addEntries(from: speechTextWithAction(content: contentArray[i], index: i, time: 0))
            case 1:
                dic.addEntries(from: speechTextWithAction(content: contentArray[i], index: i, time: 2))
            case 2:
                dic.addEntries(from: speechTextWithAction(content: contentArray[i], index: i, time: 4))
            default: break
                
            }
        }
        return dic
    }
    
    //计时动作
    private func timerItemsWithContent(contentArray: Array<Any>,time: Int) -> NSDictionary {
        
        let dic = NSMutableDictionary()
        
        for i in 0..<contentArray.count {
            switch i {
            case 0:
                dic.addEntries(from: speechTextWithAction(content: contentArray[i], index: i, time: 0))
            case 1:
                dic.addEntries(from: speechTextWithAction(content: contentArray[i], index: i, time: 2))
            case 2:
                dic.addEntries(from: speechTextWithAction(content: contentArray[i], index: i, time: 2))
            case 3:
                dic.addEntries(from: speechTextWithAction(content: contentArray[i], index: i, time: time/2))
            case 4:
                dic.addEntries(from: speechTextWithAction(content: contentArray[i], index: i, time: time - 3))
            case 5:
                dic.addEntries(from: speechTextWithAction(content: contentArray[i], index: i, time: time - 2 ))
            case 6:
                dic.addEntries(from: speechTextWithAction(content: contentArray[i], index: i, time: time - 1))
            default: break
                
            }
        }
        
        return dic
    }
    
    //休息
    private func restItemsWithContent(contentArray: Array<Any>,time: Int) -> NSDictionary {
        
        let dic = NSMutableDictionary()
        
        for i in 0..<contentArray.count {
            switch i {
            case 0:
                dic.addEntries(from: speechTextWithAction(content: contentArray[i], index: i, time: 0))
            case 1:
                dic.addEntries(from: speechTextWithAction(content: contentArray[i], index: i, time: 2))
            case 2:
                dic.addEntries(from: speechTextWithAction(content: contentArray[i], index: i, time: 4))
            default: break
                
            }
        }
        return dic
    }
    
    //强制休息
    private func forceRestItemsWithContent(contentArray: Array<Any>,time: Int) -> NSDictionary {
        
        let dic = NSMutableDictionary()
        
        for i in 0..<contentArray.count {
            switch i {
            case 0:
                dic.addEntries(from: speechTextWithAction(content: contentArray[i], index: i, time: 0))
            case 1:
                dic.addEntries(from: speechTextWithAction(content: contentArray[i], index: i, time: 2))
            case 2:
                dic.addEntries(from: speechTextWithAction(content: contentArray[i], index: i, time: 4))
            case 3:
                dic.addEntries(from: speechTextWithAction(content: contentArray[i], index: i, time: time - 5))
            case 4:
                dic.addEntries(from: speechTextWithAction(content: contentArray[i], index: i, time: time - 4))
            case 5:
                dic.addEntries(from: speechTextWithAction(content: contentArray[i], index: i, time: time - 3))
            case 6:
                dic.addEntries(from: speechTextWithAction(content: contentArray[i], index: i, time: time - 2))
            case 7:
                dic.addEntries(from: speechTextWithAction(content: contentArray[i], index: i, time: time - 1))
            default: break
                
            }
        }
        
        return dic
    }
    
    //结束
    private func endItemsWithContent(contentArray: Array<Any>,time: Int) -> NSDictionary {
        
        let dic = NSMutableDictionary()
        
        for i in 0..<contentArray.count {
            switch i {
            case 0:
                dic.addEntries(from: speechTextWithAction(content: contentArray[i], index: i, time: 0))
            case 1:
                dic.addEntries(from: speechTextWithAction(content: contentArray[i], index: i, time: 2))
            case 2:
                dic.addEntries(from: speechTextWithAction(content: contentArray[i], index: i, time: 6))
            default: break
                
            }
        }
        return dic
    }
    
    private func speechTextWithAction(content: Any,index: Int,time: Int) -> [String:AnyObject]{
        
        let contentDic = ["local":self.local,"content":content,"time":time - 1] as NSDictionary;
        return [String(index) : contentDic]
    }
}
