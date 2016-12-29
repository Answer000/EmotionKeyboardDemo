//
//  EmotionViewController.swift
//  EmotionKeyBoard_swift
//
//  Created by 澳蜗科技 on 2016/11/28.
//  Copyright © 2016年 AnswerXu. All rights reserved.
//

import UIKit

private let screen_width  = UIScreen.main.bounds.width
private let screen_heigth = UIScreen.main.bounds.height
private let itemWH        = screen_width / 7
private let emojiCell     = "emojiCell"

class EmotionViewController: UIViewController {

    // MARK:- 自定义属性
    fileprivate var emojiCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: EmojiCollectionViewLayout())
    fileprivate var emojiToolBar = UIToolbar()
    fileprivate lazy var emojiManager = EmojiManager()
    //传递表情给外界的闭包
    fileprivate var callClosure : (_ emoji : Emoji)->()
    //回调属性
    var callBackEmoji : ((_ emoji : Emoji) -> ())?
    //存储最近表情的Plist文件路径
    var emotionPath : String {
        let emotionPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        return (emotionPath as NSString).appendingPathComponent("emotion.plist")
    }
    
    var emojis : [Emoji]?
 
    // MARK:- 系统回调方法
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK:- 重写构造函数
    init(callClosure : @escaping (_ emoji : Emoji)->()) {
        self.callClosure = callClosure
        //必须实现方法
        super.init(nibName: nil, bundle: nil)
    }
    // MARK:- 重写构造函数必须实现的方法
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
// MARK:- 设置UI
extension EmotionViewController {
    fileprivate func setupUI() {
        view.addSubview(emojiCollectionView)
        view.addSubview(emojiToolBar);
        
        emojiCollectionView.backgroundColor = UIColor.red
        
        emojiCollectionView.translatesAutoresizingMaskIntoConstraints = false;
        emojiToolBar.translatesAutoresizingMaskIntoConstraints = false;
        let views = ["toolBar":emojiToolBar,"collectionView":emojiCollectionView] as [String : UIView]
        var cons = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[collectionView]-0-|", options: [], metrics: nil, views: views)
        cons += NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[collectionView]-0-[toolBar(49)]-0-|", options: [.alignAllLeft,.alignAllRight], metrics: nil, views: views)
        view.addConstraints(cons)
        
        //设置collectionView
        setupCollectionView()
        //设置toolBar
        setupToolBar()
    }
    
    fileprivate func setupToolBar() {
        let titles = ["最近","默认","Emoji","浪小花"];
        var tempItems = [UIBarButtonItem]()
        for i in 0 ..< titles.count {
            let item = UIBarButtonItem(title: titles[i], style: .plain, target: self, action: #selector(EmotionViewController.itemClick(item:)))
            item.tag = i + 1000
            tempItems.append(item)
            tempItems.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        }
        // 3.设置toolBar的items数组
        tempItems.removeLast()
        emojiToolBar.items = tempItems
        emojiToolBar.tintColor = UIColor.orange
    }
    
    fileprivate func setupCollectionView() {
        //注册cell
        emojiCollectionView.register(EmotionCollectionViewCell.self, forCellWithReuseIdentifier: emojiCell)
        //设置代理
        emojiCollectionView.dataSource = self
        emojiCollectionView.delegate = self
        //设置背景色
        emojiCollectionView.backgroundColor = UIColor.clear
    }
}

// MARK:- 事件监听
extension EmotionViewController {
    @objc fileprivate func itemClick(item : UIBarButtonItem) {
        let section = item.tag - 1000
        let defaultSelectCell = IndexPath(row: 0, section: section)
        self.emojiCollectionView.selectItem(at: defaultSelectCell, animated: true, scrollPosition: UICollectionViewScrollPosition.left)
    }
}

// MARK:- collectionView代理方法
extension EmotionViewController : UICollectionViewDataSource ,UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return emojiManager.emojiPackage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojiManager.emojiPackage[section].emojis.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emojiCell, for: indexPath) as! EmotionCollectionViewCell
        cell.emoji = emojiManager.emojiPackage[indexPath.section].emojis[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //获取点击的表情
        let emoji = emojiManager.emojiPackage[indexPath.section].emojis[indexPath.item]
        //插入表情
        insertEmotion(emoji: emoji)
        //将表情回调到控制器
        callClosure(emoji)
    }
    // MARK:- 插入表情方法
    fileprivate func insertEmotion(emoji : Emoji) {
        //空白表情或删除表情不需要插入
        if emoji.isRemove || emoji.isEmpty {
            return
        }
        //判断该表情是否已存在
        if (emojiManager.emojiPackage.first?.emojis.contains(emoji))!{
            //如果已经存在,先获取该表情下标值
            let index = emojiManager.emojiPackage.first?.emojis.index(of: emoji)
            //根据下标值删除该表情
            emojiManager.emojiPackage.first?.emojis.remove(at: index!)
        }else{
            //如果不存在，将最后一个表情删除
            emojiManager.emojiPackage.first?.emojis.remove(at: 19)
        }
        //将表情插入到第一个
        emojiManager.emojiPackage.first?.emojis.insert(emoji, at: 0)
    }
}

// MARK:- 自定义布局
class EmojiCollectionViewLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        itemSize = CGSize(width: itemWH, height: itemWH)
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        scrollDirection = .horizontal
        //设置属性
        collectionView!.showsVerticalScrollIndicator = false
        collectionView!.showsHorizontalScrollIndicator = false
        collectionView!.isPagingEnabled = true
        let insetMargin = (collectionView!.bounds.height - 3 * itemWH) / 2
        collectionView?.contentInset = UIEdgeInsets(top: insetMargin, left: 0, bottom: insetMargin, right: 0)
    }
}
