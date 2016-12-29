//
//  EmojiManager.swift
//  EmotionKeyBoard_swift
//
//  Created by 澳蜗科技 on 2016/11/28.
//  Copyright © 2016年 AnswerXu. All rights reserved.
//

import UIKit

class EmojiManager{
    
    // MARK:- 自定义属性
    var emojiPackage : [EmojiPackage] = [EmojiPackage]()
    
    // MARK:- 自定义构造函数
    init() {
        //最近
        emojiPackage.append(EmojiPackage(id: ""))
        //默认
        emojiPackage.append(EmojiPackage(id: "com.sina.default"))
        //emoji
        emojiPackage.append(EmojiPackage(id: "com.apple.emoji"))
        //浪小花
        emojiPackage.append(EmojiPackage(id: "com.sina.lxh"))
    }

}
