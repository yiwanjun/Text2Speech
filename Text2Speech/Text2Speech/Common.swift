//
//  Common.swift
//  Text2Speech
//
//  Created by zhouyi on 2017/5/9.
//  Copyright © 2017年 NewBornTown, Inc. All rights reserved.
//


public func DPrint(_ message:Any...,file:String = #file,row:Int = #line){
    #if DEBUG
        if let filename = (file as String).components(separatedBy: "/").last {
            print("[\(String(describing: filename))-\(row)]:\(message)")
        }
    #endif
}
