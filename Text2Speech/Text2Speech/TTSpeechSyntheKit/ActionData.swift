//
//  ActionData.swift
//  Text2Speech
//
//  Created by zhouyi on 2017/4/27.
//  Copyright © 2017年 NewBornTown, Inc. All rights reserved.
//

import UIKit

struct ActionData {

}

struct SpeechTextElement {
    static let ready = "ready"
    static let actionCount = "actionCount"
    static let forceRest = "forceRest"
    static let actionTimer = "actionTimer"
    static let end = "end"
    static let rest = "rest"
}

struct Action {
    var type: String//SpeechTextElement
    var time: Int //动作持续时长
    var text: Array<Any> //TTS文本
}

struct ActionAndKey {
    var action: Action
    var actionJsonObject : SportAction? //存储从allAction
    var key: Int //用来排序 ItemsGenerator line 86
}
struct SpeechAction {
    var ak: ActionAndKey
    var speech: Dictionary<String, Any>
}
