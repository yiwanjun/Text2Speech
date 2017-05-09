//
//  SportResource.swift
//  SoloFitness
//
//  Created by Maynard on 2017/4/27.
//  Copyright © 2017年 赤子城. All rights reserved.
//

import Foundation
import SwiftyJSON

struct SportIntroduce {
    
    let name: String
    let introduce: String
    
}

struct SportAction {
    
    let id: Int
    let name: String
    let unit: String
    let imagePath: String
    let videoPath: String
    let coach: String
}

struct SportResourceDeal {
    
    //获取动作列表
    static func sportActions() ->[SportAction] {
        if let file = self.sportResourceBundle()?.path(forResource: "json/td_allactions", ofType: "json") {
            if let data = try? Data(contentsOf: URL(fileURLWithPath: file)) {
                let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
                let json = JSON(jsonObject).arrayValue
                let array = json.map({ (json) -> SportAction in
                    return SportAction(
                        id: json["id"].intValue,
                        name: json["name"].stringValue,
                        unit: json["unit"].stringValue,
                        imagePath: json["imagePath"].stringValue,
                        videoPath: json["VideoPath"].stringValue,
                        coach: json["coach"].stringValue
                    )
                })
                return array
            }
        }
        return []
    }
    
    //通过图片路径获取所有图片
    static func imageArray(path: String) -> [UIImage] {
        let bundle = self.sportResourceBundle()
        if let array = bundle?.paths(forResourcesOfType: "png", inDirectory: path) {
            return array.filter({ (imagePath) -> Bool in
                return !imagePath.hasSuffix("icon.png")
            }).flatMap({ (imagePath) -> UIImage in
                UIImage(contentsOfFile: imagePath)!
            })
        }
        return []
    }
    
    //通过路径获取icon 图片
    static func imageIcon(path: String) -> UIImage? {
        let bundle = self.sportResourceBundle()
        if let array = bundle?.paths(forResourcesOfType: "png", inDirectory: path) {
            return array.filter({ (imagePath) -> Bool in
                return imagePath.hasSuffix("icon.png")
            }).flatMap({ (imagePath) -> UIImage in
                UIImage(contentsOfFile: imagePath)!
            }).first
        }
        return nil
    }

    
    //获取资源包bundle
    static func sportResourceBundle() -> Bundle? {
        if let bundlePath = Bundle.main.path(forResource: "SportResource", ofType: "bundle") {
            let bundle = Bundle(path: bundlePath)
            return bundle
        }
        return nil
    }
    
}
