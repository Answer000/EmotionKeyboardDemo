//
//  EmojiPackage.swift
//  EmotionKeyBoard_swift
//
//  Created by 澳蜗科技 on 2016/11/28.
//  Copyright © 2016年 AnswerXu. All rights reserved.
//

import UIKit

class EmojiPackage: NSObject {
    
    // MARK:- 自定义属性
    var emojis : [Emoji] = [Emoji]()
    
    // MARK:- 重写构造函数
    init(id : String) {
        super.init()
        if id == "" {
            addEmptyEmotion(isRecently: true)
            return
        }
        
        //拼接路径
        guard let path = Bundle.main.path(forResource: "\(id)/info.plist", ofType: nil, inDirectory: "Emoticons.bundle") else {
            return
        }
        guard let pics = NSArray(contentsOfFile: path) as? [[String : String]] else {
            return
        }
        var index = 0
        for var emoji in pics {
            if let png = emoji["png"] {
                emoji["png"] = id + "/" + png
            }
            emojis.append(Emoji(dict: emoji))
            index += 1
            
            if index == 20 {
                emojis.append(Emoji(isRemove : true))
                index = 0
            }
        }
        //添加空白表情和删除表情
        addEmptyEmotion(isRecently: false)
    }
    
    //添加空白表情
    fileprivate func addEmptyEmotion(isRecently : Bool) {
        let count = emojis.count % 21
        if count == 0 && !isRecently {
            return
        }
        for _ in count..<20 {
            //添加空白表情
            emojis.append(Emoji(isEmpty: true))
        }
        //添加删除表情
        emojis.append(Emoji(isRemove: true))
    }
}
