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
    let prepare = "ready to go"
    let go = "go"
    let startWith = "start with "
    let begin:String = "do the exercise"
    let next:String = "next"
    let half:String = "half the time"
    let rest:String = "take a rest"
    let local:String = "en-US"
    let seconds:String = " seconds"
    let congratulations:String = "congratulations"
    
    public init?(plan:Array<Dictionary<String,Any>>){
        self.plans = plan
    }
    
    public func gennerate(finish: @escaping (Array<SpeechAction>) -> Void) {
        
        ActionsHelper.shareHelper.loadJson { (helper) in
            //添加预备开始
            //actions.time 0表示整套动作完成
            var actions : Array<ActionAndKey> = Array()
            
            if let first = self.plans.first {
                let actionJson : SportAction = helper.getActionWithId(id: first["actionId"] as! NSNumber)
                let startWithName = self.startWith.appending(actionJson.name)
                
                let ready : Action = Action(type: SpeechTextElement.ready, time: 10, text: [self.prepare,startWithName,"3","2","1"])
                actions.append(ActionAndKey(action: ready,actionJsonObject: actionJson, key: 0))
            }
            //遍历今天计划的动作，从json文件中获取到的
            for i in 0..<self.plans.count{
                let plan = self.plans[i]
                let actionId = plan["actionId"]
                let time = plan["time"] as! Int
                
                let actionJson : SportAction = helper.getActionWithId(id: actionId! as! NSNumber)
                let unit = actionJson.unit
                var content: Action
                
                if unit == "s" {
                    //计时动作之前加一个强制休息
                    if i != 0{//如果是第一个动作不需要休息
                        //time = 10000表示一直等待
                        let rest: Action = Action(type: SpeechTextElement.forceRest, time: 7, text: [self.begin,String(time)+(self.seconds),"3","2","1",self.go])
                        actions.append(ActionAndKey(action: rest, actionJsonObject: actionJson, key: 10+10*i))
                    }
                    
                    //计时动作
                    content = Action(type: SpeechTextElement.actionTimer, time: time, text: ["","3","2","1"])
                    actions.append(ActionAndKey(action: content,actionJsonObject: actionJson, key: 10 + 10*i + 1))
                    
                }else{
                    //记次动作
                    content = Action(type: SpeechTextElement.actionCount, time: 10000, text: [self.begin,time,actionJson.name])
                    actions.append(ActionAndKey(action: content,actionJsonObject: actionJson, key: 10 + 10*i))
                    //记次动作的后面加普通的休息
                }
                
                if i+1 < self.plans.count{
                    //获取下一个动作
                    let next = self.plans[i+1]
                    let actionId = next["actionId"]
                    let actionJson: SportAction = helper.getActionWithId(id: actionId! as! NSNumber)
                    //当下一个动作不是计时的时候才加普通的休息
                    let rest: Action = Action(type: SpeechTextElement.rest, time: 10, text: [self.rest,self.next,actionJson.name])
                    actions.append(ActionAndKey(action: rest,actionJsonObject: actionJson, key: 10+10*i+2))
                }
            }
            //完成所有动作
            let action = Action(type:SpeechTextElement.end,time:1,text:[self.congratulations])
            actions.append(ActionAndKey(action: action,actionJsonObject: nil, key: 9999))
            
            //按照设置key升序排列，都是数字类型的字符串
            let result = actions.sorted(by: { (ak0: ActionAndKey, ak1: ActionAndKey) -> Bool in
                return ak0.key < ak1.key
            })
            
            finish(self.speechsAllTextsWithContent(content: result))
        }
    }
}

extension ItemsGenerator{
    
    fileprivate func speechsAllTextsWithContent(content: Array<Any>) -> Array<SpeechAction>{
        var  speechs = Array<SpeechAction>()
        
        for i in 0..<content.count{
            
            let ak: ActionAndKey = content[i] as! ActionAndKey
        
            let type:String = ak.action.type
            let time:Int = ak.action.time
            let text:Array<Any> = ak.action.text
            switch type {
            case SpeechTextElement.ready:
                speechs.append(SpeechAction(ak: ak, speech: readyItemsWithContent(contentArray: text, time: time) as! Dictionary<String, Any>))
            case SpeechTextElement.actionCount:
                speechs.append(SpeechAction(ak: ak, speech: countItemsWithContent(contentArray: text, time: time) as! Dictionary<String, Any>))
            case SpeechTextElement.actionTimer:
                 speechs.append(SpeechAction(ak: ak, speech: timerItemsWithContent(contentArray: text, time: time) as! Dictionary<String, Any>))
            case SpeechTextElement.rest:
                 speechs.append(SpeechAction(ak: ak, speech: restItemsWithContent(contentArray: text, time: time) as! Dictionary<String, Any>))
            case SpeechTextElement.forceRest:
                 speechs.append(SpeechAction(ak: ak, speech: forceRestItemsWithContent(contentArray: text, time: time) as! Dictionary<String, Any>))
            default://end
                 speechs.append(SpeechAction(ak: ak, speech: endItemsWithContent(contentArray: text, time: time) as! Dictionary<String, Any>))
            }
        }
        return speechs
    }
    
    //预备开始
    fileprivate func readyItemsWithContent(contentArray: Array<Any>,time: Int) -> NSDictionary {
        
        let dic = NSMutableDictionary()
        
        for i in 0..<contentArray.count {
            switch i {
            case 0:
                dic.addEntries(from: speechTextWithAction(content: contentArray[i], index: i, time: 0))
            case 1:
                dic.addEntries(from: speechTextWithAction(content: contentArray[i], index: i, time: 2))
            case 2:
                dic.addEntries(from: speechTextWithAction(content: contentArray[i], index: i, time: time - 3))
            case 3:
                dic.addEntries(from: speechTextWithAction(content: contentArray[i], index: i, time: time - 2 ))
            case 4:
                dic.addEntries(from: speechTextWithAction(content: contentArray[i], index: i, time: time - 1))
            default: break
                
            }
        }
        return dic
    }
    
    //计次动作
    fileprivate func countItemsWithContent(contentArray: Array<Any>,time: Int) -> NSDictionary {
        
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
    fileprivate func timerItemsWithContent(contentArray: Array<Any>,time: Int) -> NSDictionary {
        
        let dic = NSMutableDictionary()
        
        for i in 0..<contentArray.count {
            switch i {
            case 0:
                dic.addEntries(from: speechTextWithAction(content: contentArray[i], index: i, time: 0))
            case 1:
                dic.addEntries(from: speechTextWithAction(content: contentArray[i], index: i, time: time - 3))
            case 2:
                dic.addEntries(from: speechTextWithAction(content: contentArray[i], index: i, time: time - 2 ))
            case 3:
                dic.addEntries(from: speechTextWithAction(content: contentArray[i], index: i, time: time - 1))
            default: break
                
            }
        }
        return dic
    }
    
    //休息
    fileprivate func restItemsWithContent(contentArray: Array<Any>,time: Int) -> NSDictionary {
        
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
    fileprivate func forceRestItemsWithContent(contentArray: Array<Any>,time: Int) -> NSDictionary {
        
        let dic = NSMutableDictionary()
        
        for i in 0..<contentArray.count {
            switch i {
            case 0:
                dic.addEntries(from: speechTextWithAction(content: contentArray[i], index: i, time: 0))
            case 1:
                dic.addEntries(from: speechTextWithAction(content: contentArray[i], index: i, time: 2))
            case 2:
                dic.addEntries(from: speechTextWithAction(content: contentArray[i], index: i, time: time - 4))
            case 3:
                dic.addEntries(from: speechTextWithAction(content: contentArray[i], index: i, time: time - 3))
            case 4:
                dic.addEntries(from: speechTextWithAction(content: contentArray[i], index: i, time: time - 2))
            case 5:
                dic.addEntries(from: speechTextWithAction(content: contentArray[i], index: i, time: time - 1))
            default: break
                
            }
        }
        return dic
    }
    
    //结束
    fileprivate func endItemsWithContent(contentArray: Array<Any>,time: Int) -> NSDictionary {
        
        let dic = NSMutableDictionary()
        
        for i in 0..<contentArray.count {
            switch i {
            case 0:
                dic.addEntries(from: speechTextWithAction(content: contentArray[i], index: i, time: 0))
            default: break
                
            }
        }
        return dic
    }
    
    fileprivate func speechTextWithAction(content: Any,index: Int,time: Int) -> [String:AnyObject]{
        let contentDic = ["local":self.local,"content":content,"time":time] as NSDictionary;
        return [String(index) : contentDic]
    }
}
