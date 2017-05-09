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
    
    var allActions : [SportAction]?
    
    private override init() {
        super.init()
    }
}

extension ActionsHelper{
    func  loadJson(finish: @escaping (ActionsHelper) -> Void) {
        if (allActions != nil) {
            finish(self)
            return
        }
        DispatchQueue.global(qos: .default).async {
            
            let actions = SportResourceDeal.sportActions()
            DispatchQueue.main.async(execute: {
                self.allActions = actions
                finish(self)
            })
        }
    }
    
    func getActionWithId(id : NSNumber) -> SportAction{
        
        var result : SportAction?
        
        for sportsAction: SportAction in allActions! {
            if (sportsAction.id == id.intValue ) {
                result = sportsAction
                break
            }
        }
        return result!
    }
}
