//
//  EmotionCollectionViewCell.swift
//  EmotionKeyBoard_swift
//
//  Created by 澳蜗科技 on 2016/11/28.
//  Copyright © 2016年 AnswerXu. All rights reserved.
//

import UIKit

class EmotionCollectionViewCell: UICollectionViewCell {
    var emoji : Emoji? {
        didSet{
            guard let emoji = emoji else {
                return
            }
            emojiBtn.setImage(UIImage(contentsOfFile: emoji.pngPath ?? ""), for: .normal)
            emojiBtn.setTitle(emoji.emojiCode, for: .normal)
            if emoji.isRemove {
                emojiBtn.setImage(UIImage(named: "compose_emotion_delete"), for: .normal)
            }
        }
    }
    fileprivate lazy var emojiBtn : UIButton = UIButton(type: UIButtonType.custom)
    override init(frame : CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension EmotionCollectionViewCell {
    fileprivate func setupUI() {
        //设置emojiBtn的属性
        contentView.addSubview(emojiBtn)
        emojiBtn.frame = contentView.bounds
        emojiBtn.titleLabel?.font = UIFont.systemFont(ofSize: 32)
        emojiBtn.isUserInteractionEnabled = false
    }
}
