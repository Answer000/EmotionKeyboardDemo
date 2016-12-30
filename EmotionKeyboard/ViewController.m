//
//  ViewController.m
//  EmotionKeyboard
//
//  Created by 澳蜗科技 on 2016/12/29.
//  Copyright © 2016年 AnswerXu. All rights reserved.
//

#import "ViewController.h"
#import "SwiftModule-swift.h"

@interface ViewController ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *showLabel;
@property (weak, nonatomic) IBOutlet UIButton *clearBtn;
@property (nonatomic,strong) UIView *backgroundView;
@property (nonatomic,strong) UITextView *textView;
@property (nonatomic,strong) UIButton *leftView;
@property (nonatomic,strong) UIButton *sendBtn;
@property (nonatomic,strong) EmotionViewController *emotionVC;
@property (nonatomic,strong) UILabel *placeholderLable;
@property (nonatomic,assign) NSInteger textInputHeight;
@property (nonatomic,assign) NSInteger TextInputMaxHeight;
@property (nonatomic,assign) CGFloat keyboardHeight;
@property (nonatomic,assign) BOOL isKeyboardShow;
@property (nonatomic,assign) CGPoint originOffset;
@end

#define kSCREENWIDTH  [UIScreen mainScreen].bounds.size.width
#define kSCREENHEIGHT [UIScreen mainScreen].bounds.size.height
#define KNotificationCenter   [NSNotificationCenter defaultCenter]
#define TextViewMaxVisibleLine  4
@implementation ViewController
-(UIView *)backgroundView{
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, kSCREENHEIGHT - 49, kSCREENWIDTH, 49)];
        _backgroundView.backgroundColor = [UIColor colorWithWhite:0.953 alpha:1.000];
    }
    return _backgroundView;
}
-(UITextView *)textView{
    if (!_textView) {
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(35, 7, kSCREENWIDTH - 35 - 60, 35)];
        [_textView addSubview:self.placeholderLable];
        _textView.font = [UIFont systemFontOfSize:16];
        [self setTextViewMaxVisibleLine];
        _textView.layer.cornerRadius = 3;
        _textView.layer.borderWidth = 0.5;
        _textView.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
        _textView.textContainer.lineBreakMode = NSLineBreakByCharWrapping;
        _textView.textColor = [UIColor colorWithRed:0.239 green:0.239 blue:0.235 alpha:1.000];
        _textView.enablesReturnKeyAutomatically = YES;
        _textView.delegate = self;
        _textView.returnKeyType = UIReturnKeyDone;
    }
    return _textView;
}
-(UILabel *)placeholderLable{
    if (!_placeholderLable) {
        _placeholderLable = [[UILabel alloc] initWithFrame:CGRectMake(4, 0, self.textView.bounds.size.width, self.textView.bounds.size.height)];
        _placeholderLable.font = [UIFont systemFontOfSize:16];
        _placeholderLable.textColor = [UIColor colorWithRed:0.761 green:0.757 blue:0.745 alpha:1.000];
        _placeholderLable.text = @"评论";
    }
    return _placeholderLable;
}
-(EmotionViewController *)emotionVC{
    if (!_emotionVC) {
        _emotionVC = [[EmotionViewController alloc] initWithCallClosure:^(Emoji * emoji) {
            //获取传递的表情
            [self.textView insertEmojiToTextViewWithEmoji:emoji];
        }];
    }
    return _emotionVC;
}
-(UIButton *)leftView{
    if (!_leftView) {
        UIImage *leftImag = [UIImage imageNamed:@"compose_emoticonbutton_background"];
        _leftView = [UIButton buttonWithType:UIButtonTypeCustom];
        [_leftView setImage:leftImag forState:UIControlStateNormal];
        _leftView.center = CGPointMake(leftImag.size.width*0.5 + 5, CGRectGetMidY(self.textView.frame));
        _leftView.bounds = CGRectMake(0, 0, leftImag.size.width, leftImag.size.height);
        [_leftView setImage:[UIImage imageNamed:@"compose_keyboardbutton_background"] forState:UIControlStateSelected];
        [_leftView addTarget:self action:@selector(emotionAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftView;
}
-(UIButton *)sendBtn{
    if (!_sendBtn) {
        _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        [_sendBtn setTitleColor:[UIColor colorWithRed:0.129 green:0.677 blue:0.999 alpha:1.000] forState:UIControlStateNormal];
        _sendBtn.frame = CGRectMake(CGRectGetMaxX(self.textView.frame), CGRectGetMinY(self.leftView.frame), 50, 25);
        _sendBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_sendBtn addTarget:self action:@selector(sendAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendBtn;
}

#pragma mark-  事件监听
-(void)emotionAction:(UIButton *)sender{
    sender.selected = !sender.isSelected;
    //切换表情键盘，需先放弃第一响应者
    [self textViewResignFirstResponder];
    //若textView的inputView为nil,则显示默认键盘;不为nil则显示自定义键盘
    self.textView.inputView = self.textView.inputView ? nil : self.emotionVC.view;
    //将textView设置为第一响应者
    [self.textView becomeFirstResponder];
    if(_isKeyboardShow)[self.textView.delegate textViewDidChange:self.textView];
}
-(void)sendAction{
    self.showLabel.text = [NSString stringWithFormat:@"%@%@",self.showLabel.text.length > 0 ? self.showLabel.text : @"",self.textView.text];
    self.textView.text = nil;
    [self.textView.delegate textViewDidChange:self.textView];
    [self.textView resignFirstResponder];
    self.clearBtn.hidden = self.showLabel.text.length > 0 ? NO : YES;
}
- (IBAction)clearAction:(UIButton *)sender {
    self.showLabel.text = nil;
    sender.hidden = YES;
}

#pragma mark-  系统回调方法
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubviews];
    [self setupKeyboard];
}

#pragma mark-  设置UI
-(void)setupSubviews{
    [self.view addSubview:self.backgroundView];
    [self.backgroundView addSubview:self.leftView];
    [self.backgroundView addSubview:self.textView];
    [self.backgroundView addSubview:self.sendBtn];
}

#pragma mark-  添加观察者
-(void)setupKeyboard{
    [KNotificationCenter addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillShowNotification object:nil];
    [KNotificationCenter addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark-  监听键盘
-(void)keyboardWillChange:(NSNotification *)info{
    NSDictionary *userInfo = info.userInfo;
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _keyboardHeight = endFrame.size.height;
    [self keyboardWillChangeFrameAnimation:duration originY:(endFrame.origin.y - self.backgroundView.bounds.size.height)];
    self.isKeyboardShow = endFrame.origin.y > kSCREENHEIGHT ? NO : YES;
}
-(void)keyboardWillChangeFrameAnimation:(NSTimeInterval)duration originY:(CGFloat)originY{
    [UIView animateWithDuration:duration animations:^{
        self.backgroundView.frame = CGRectMake(0, originY, self.backgroundView.bounds.size.width, self.backgroundView.bounds.size.height);
    }];
}

#pragma mark-  UITextViewDelegate代理方法
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [self textViewResignFirstResponder];
        return NO;
    }
    return YES;
}

-(void)textViewDidChange:(UITextView *)textView{
    self.placeholderLable.text = textView.text.length > 0 ? nil : @"评论";
    [self changeBoundsWithTextView:textView];
}

-(void)changeBoundsWithTextView:(UITextView *)textView{
    //随着textView内容的变化，动态的修改textView的大小和位置
    _textInputHeight = ceilf([self.textView sizeThatFits:CGSizeMake(self.textView.bounds.size.width, MAXFLOAT)].height);
    self.textView.scrollEnabled = _textInputHeight > _TextInputMaxHeight && _TextInputMaxHeight > 0;
    if (self.textView.scrollEnabled) {
        CGRect b = self.textView.frame;
        b.size.height = 5 + _TextInputMaxHeight;
        self.textView.frame = b;
        
        CGRect f = self.backgroundView.frame;
        f.origin.y = kSCREENHEIGHT - _keyboardHeight - _TextInputMaxHeight - 10 - 8;
        f.size.height = _TextInputMaxHeight + 20;
        self.backgroundView.frame = f;
    }else{
        CGRect b = self.textView.frame;
        b.size.height = _textInputHeight;
        self.textView.frame = b;
        
        CGRect f = self.backgroundView.frame;
        f.origin.y = kSCREENHEIGHT - _keyboardHeight - _textInputHeight - 5.5 - 8;
        f.size.height = _textInputHeight + 15.5;
        self.backgroundView.frame = f;
    }
}

- (void)setTextViewMaxVisibleLine{
    _TextInputMaxHeight = ceil(self.textView.font.lineHeight * (TextViewMaxVisibleLine - 1) + self.textView.textContainerInset.top + self.textView.textContainerInset.bottom);
}
-(void)textViewResignFirstResponder{
    [self.textView resignFirstResponder];
}

#pragma mark-  开始触摸
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self textViewResignFirstResponder];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
