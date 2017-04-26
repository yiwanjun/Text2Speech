//
//  ItemGenerator.swift
//  Text2Speech
//
//  Created by zhouyi on 2017/4/25.
//  Copyright © 2017年 NewBornTown, Inc. All rights reserved.
//

import UIKit

class ItemsGenerator: NSObject {
    var plans:Array<Dictionary<String,Any>>?
    let prepare = "Ready to go"
    let startWith = "start with "
    let begain:String = "do the exercise"
    let next:String = "nexy"
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
        
        if let first = self.plans?.first {
            let action = helper.getActionWithId(id: String(describing: first["actionId"]))
            let startWithName = self.startWith.appending(action["name"] as! String)
            let ready = [self.prepare,startWithName,"3","2","1"]
            actions.append(ready)
        }
        
        var i = 0
        for plan in self.plans!{
            let actionId = plan["id"]
            let time = plan["time"] as! String
            
            let action = helper.getActionWithId(id: actionId! as! String)
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
        
        let dic = self.getItemsWithContent(contentArray: actions)
        finish(dic as! Dictionary<String, AnyObject>)
     
        }
    }
    
    private func getItemsWithContent(contentArray: Array<Any>) -> NSDictionary {
        let time = 10
        let dic = NSMutableDictionary()
        for i in 0..<contentArray.count {
            switch i {
            case 0:
                let contentDic = ["local":self.local,"content":contentArray[i],"time":0] as NSDictionary;
                dic.setObject(contentDic, forKey: String("\(i)")! as NSCopying)
            case 1:
                let contentDic = ["local":self.local,"content":contentArray[i],"time":2] as NSDictionary;
                dic.setObject(contentDic, forKey: String("\(i)")! as NSCopying)
            case 2:
                let contentDic = ["local":self.local,"content":contentArray[i],"time":time/2] as NSDictionary
                dic.setObject(contentDic, forKey: String("\(i)")! as NSCopying)
            case 3:
                let contentDic = ["local":self.local,"content":contentArray[i],"time":time - 3] as NSDictionary;
                dic.setObject(contentDic, forKey: String("\(i)")! as NSCopying)
            case 4:
                let contentDic = ["local":self.local,"content":contentArray[i],"time":time - 2] as NSDictionary;
                dic.setObject(contentDic, forKey: String("\(i)")! as NSCopying)
            case 5:
                let contentDic = ["local":self.local,"content":contentArray[i],"time":time - 1] as NSDictionary;
                dic.setObject(contentDic, forKey: String("\(i)")! as NSCopying)
                
            default: break
                
            }
        }
        
        return dic
    }
    
}
