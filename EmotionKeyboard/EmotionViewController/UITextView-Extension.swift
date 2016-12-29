//
//  UITextView-Extension.swift
//  EmotionKeyBoard_swift
//
//  Created by 澳蜗科技 on 2016/11/30.
//  Copyright © 2016年 AnswerXu. All rights reserved.
//

import UIKit

extension UITextView {
    func getEmojiString() -> String {
        //创建属性字符串
        let attMStr = NSMutableAttributedString(attributedString: attributedText)
        //设置属性字符串的遍历范围(从头到尾)
        let range = NSMakeRange(0, attMStr.length)
        attMStr.enumerateAttributes(in: range, options: []) { (dict, range, _) in
            if let attachment = dict["NSAttachment"] as? EmojiTextAttachment {
                attMStr.replaceCharacters(in: range, with: attachment.chs!)
            }
        }
        return attMStr.string
    }
    
    func insertEmojiToTextView(emoji : Emoji) {
        //如果为空白表情，不插入
        if emoji.isEmpty {
            return
        }
        //如果为删除表情，不插入且做删除操作
        if emoji.isRemove {
            deleteBackward()
            return
        }
        //如果为emoji表情
        if emoji.emojiCode != nil {
            //1.获取光标位置
            let range = selectedTextRange
            replace(range!, withText: emoji.emojiCode!)
            return
        }
        //如果为图片表情:图文混排
        if emoji.pngPath != nil {
//            insertImageEmotion(emoji: emoji)
            let range = selectedTextRange
            replace(range!, withText: emoji.chs!)
            self.delegate?.textViewDidChange!(self)
        }
    }
    private func insertImageEmotion(emoji : Emoji) {
        
        //创建属性字符串
        let attImage = EmojiTextAttachment()
        attImage.chs = emoji.chs
        //设置插入的图片
        attImage.image = UIImage(contentsOfFile: emoji.pngPath!)
        //设置插入图片大小
        let font = self.font!
        attImage.bounds = CGRect(x: 0, y: -4, width: font.lineHeight, height: font.lineHeight)
        let attStr = NSAttributedString(attachment: attImage)
        //创建可变的属性字符串
        let attMStr = NSMutableAttributedString(attributedString: attributedText)
        //获取光标位置
        let range = selectedRange
        attMStr.replaceCharacters(in: range, with: attStr)
        
        //设置textView的属性字符串
        attributedText = attMStr
        //重置textView的字体，不然会变小
        self.font = font
        //将光标恢复到原来位置(会自动跑到最后位置)
        selectedRange = NSMakeRange(range.location + 1, 0)
    }
}

