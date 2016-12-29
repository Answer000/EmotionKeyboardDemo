//
//  Emojis.swift
//  EmotionKeyBoard_swift
//
//  Created by 澳蜗科技 on 2016/11/28.
//  Copyright © 2016年 AnswerXu. All rights reserved.
//

import UIKit

class Emoji: NSObject{
    // MARK:- 自定义属性
    var chs : String? //普通表情对应的文字
    var code : String? { //emoji对应的code
        didSet{
            //校验nil值
            guard let code = code else {
                return
            }
            
            //1.创建扫描器
            let scanner = Scanner(string: code)
            //2.调用方法，扫描出code中的值
            var value : UInt32 = 0
            scanner.scanHexInt32(&value)
            //3.将value转成字符
            guard let unicode = UnicodeScalar(value) else {
                return
            }
            let char = Character(unicode)
            //4.将字符转换成字符串
            emojiCode = String(char)
        }
    }
    var png : String?{  //普通表情对应的图片名称
        didSet{
            guard let png = png else {
                return
            }
            pngPath = Bundle.main.bundlePath + "/Emoticons.bundle/" + png
        }
    }
    
    // MARK:- 数据处理
    var pngPath : String?
    var emojiCode : String?
    var isRemove : Bool = false //是否为删除按钮
    var isEmpty : Bool = false  //是否为空白按钮
    
    // MARK:- 自定义构造函数
    init(dict : [String : String]) {
        super.init()
        setValuesForKeys(dict)
    }
    override func setValue(_ value: Any?, forUndefinedKey key: String) {}
    override var description: String {
        return dictionaryWithValues(forKeys: ["emojiCode","chs","pngPath"]).description
    }
    
    init(isRemove : Bool) {
        self.isRemove = isRemove
    }
    
    init(isEmpty : Bool) {
        self.isEmpty = isEmpty
    }
    
    // MARK:- 实现归档协议方法:必须遵守NSCoding协议，实现代理方法
    ///归档方法
    func encodeWithCoder(aCoder : NSCoder){
        aCoder.encode(chs, forKey: "chs")
        aCoder.encode(code, forKey: "code")
        aCoder.encode(pngPath, forKey: "pngPath")
        aCoder.encode(emojiCode, forKey: "emojiCode")
        aCoder.encode(isRemove, forKey: "isRemove")
        aCoder.encode(isEmpty, forKey: "isEmpty")
    }
    ///解档方法
    required init?(coder aDecoder: NSCoder) {
        chs = aDecoder.decodeObject(forKey: "chs") as?String
        code = aDecoder.decodeObject(forKey: "code") as?String
        pngPath = aDecoder.decodeObject(forKey: "pngPath") as?String
        emojiCode = aDecoder.decodeObject(forKey: "emojiCode") as?String
        isRemove = (aDecoder.decodeObject(forKey: "isRemove") as?Bool)!
        isEmpty = (aDecoder.decodeObject(forKey: "isEmpty") as?Bool)!
    }
}
