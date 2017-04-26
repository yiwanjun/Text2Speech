//
//  ActionsHelper.swift
//  Text2Speech
//
//  Created by zhouyi on 2017/4/25.
//  Copyright © 2017年 NewBornTown, Inc. All rights reserved.
//

import UIKit
import Foundation

final public class ActionsHelper: NSObject {
    
    open static let shareHelper = ActionsHelper()
    
    private override init() {
        super.init()
    }
    
    var allActions : Array<Dictionary<String, AnyObject>>?

}

extension ActionsHelper{
    func  loadJson(finish: @escaping (ActionsHelper) -> Void) {
        if (allActions != nil) {
            finish(self)
            return
        }
        
        DispatchQueue.global(qos: .default).async { 
            let path =  Bundle.main.path(forResource: "td_allactions", ofType: "json")
            let data =  NSData(contentsOfFile: path!)
            do {
                if let messages = try JSONSerialization.jsonObject(with: data! as Data, options: JSONSerialization.ReadingOptions.allowFragments) as? [[String: AnyObject]]{
                    DispatchQueue.main.async(execute: { 
                        self.allActions = messages as Array<Dictionary>
                        finish(self)
                    })
                }
            } catch let error as NSError {
                print(error.description)
            }
        }
    }
    
    func getActionWithId(id : NSNumber) -> Dictionary<String, AnyObject>{
        
        var result : Dictionary<String, AnyObject>?
        
        for dic: Dictionary in allActions! {
            if (dic["id"] as! NSNumber == id ) {
                 result = dic
                 break
            }
        }
        return result!
    }
}
