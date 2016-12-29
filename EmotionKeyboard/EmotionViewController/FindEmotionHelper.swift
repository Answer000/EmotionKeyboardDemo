//
//  FindEmotionHelper.swift
//  MyWB
//
//  Created by 澳蜗科技 on 16/10/24.
//  Copyright © 2016年 澳蜗科技. All rights reserved.
//

import UIKit

class FindEmotionHelper: NSObject {
    static var shareInstance : FindEmotionHelper = FindEmotionHelper()
    fileprivate lazy var manager : EmojiManager = EmojiManager()
    
    func findEmotion(string : String? ,font : UIFont) -> NSAttributedString?{
        guard let string = string else {
            return nil
        }
        //创建匹配规则
        let pattern = "\\[.*?\\]"
        //创建正则表达式对象
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return nil
        }
        //开始匹配
        let results = regex.matches(in: string, options: [], range: NSRange(location: 0, length: string.characters.count))
        //获取结果
        let attMStr = NSMutableAttributedString(string: string)
        for (_ ,result) in results.enumerated().reversed() {
            let chs = (string as NSString).substring(with: result.range)
            guard let pngPath = findEmotionPngpath(chs: chs) else {
                return nil
            }
            let attachment = NSTextAttachment()
            attachment.image = UIImage(contentsOfFile: pngPath)
            attachment.bounds = CGRect(x: 0, y: -4, width: font.lineHeight, height: font.lineHeight)
            let attrImageStr = NSAttributedString(attachment: attachment)
            
            attMStr.replaceCharacters(in: result.range, with: attrImageStr)
        }
        return attMStr
    }
    //查找图片路径
    fileprivate func findEmotionPngpath(chs : String) -> String?{
        for packges in manager.emojiPackage {
            for emojis in packges.emojis {
                if emojis.chs == chs {
                    return emojis.pngPath
                }
            }
        }
        return nil
    }
}
