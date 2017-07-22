//
//  HJInputHandler.m
//  IOSMaster
//
//  Created by imac on 2017/7/22.
//  Copyright © 2017年 HJ. All rights reserved.
//

#import "HJInputHandler.h"
#import <objc/runtime.h>

static NSString *const kHJNumOrLetterLimited =  @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789\n";
static NSString *const kHJIDLimited          =  @"0123456789xX\n";
static NSString *const kHJMobileLimited      =  @"0123456789-";

@interface HJInputHandler ()

@property (nonatomic,copy) NSString *listenerShowKeyPath;


@end

@implementation HJInputHandler

#pragma mark - Register @{ClassName:@{PostName:Selector}}
+(NSDictionary<NSString *,NSDictionary<NSNotificationName ,NSString *> *> *)register_postName{
    
    return @{
             @"UITextField":@{UITextFieldTextDidBeginEditingNotification:@"inputDidBeginEditing:",
                              UITextFieldTextDidEndEditingNotification:@"inputDidEndEditing:",
                              UITextFieldTextDidChangeNotification:@"inputDidChange:",
                              },
             @"UITextView":@{UITextViewTextDidBeginEditingNotification:@"inputDidBeginEditing:",
                              UITextViewTextDidEndEditingNotification:@"inputDidEndEditing:",
                              UITextViewTextDidChangeNotification:@"inputDidChange:",
                              }
             };
}

+(NSDictionary<NSString *,NSString *> *)register_showText{
    
    return @{
             @"UITextField":@"text",
             @"UITextView":@"text"
             };
}

-(NSString *)listenerShowKeyPath{
    
    Class class = [_listener class];
    
    NSString *class_name = NSStringFromClass(class);
    
    return [[[self class] register_showText] objectForKey:class_name];
}

#pragma mark - Cycle
//set监听
-(void)setListener:(NSObject<UITextInput> *)listener{
    
    //清除对之前监听对象的监听
    if (_listener) {
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    
    _listener = listener;
    
    //设置监听
    if (_listener) {
        
        NSDictionary<NSString *,NSDictionary<NSNotificationName ,NSString *> *> *register_dic = [[self class] register_postName];
        
        for (NSString *class_name in register_dic) {
            
            if ([_listener isKindOfClass:NSClassFromString(class_name)]) {
                
                for (NSNotificationName post_name in register_dic[class_name].allKeys) {
                    
                    NSString *method = register_dic[class_name][post_name];
                    
                    [[NSNotificationCenter defaultCenter] addObserver:self
                                                             selector:NSSelectorFromString(method)
                                                                 name:post_name object:_listener];
                }
            }
        }
        
    }
    
}

-(void)setInputType:(HJInputHandlerType)inputType{
    
    _inputType = inputType;
    
    switch (inputType) {
        case HJInputHandlerTypeNormal:
            self.listener.keyboardType = UIKeyboardTypeDefault;
            self.limitLength = nil;
            self.limitLetters = nil;
            break;
        case HJInputHandlerTypeMobile:
            self.listener.keyboardType = UIKeyboardTypePhonePad;
            self.limitLength = @11;
            self.limitLetters = kHJMobileLimited;
            
            break;
        case HJInputHandlerTypeLetterOrNum:
            self.limitLetters = kHJNumOrLetterLimited;
            self.listener.keyboardType = UIKeyboardTypeDefault;
            break;
        case HJInputHandlerTypeID:
            self.limitLength = @18;
            self.limitLetters = kHJIDLimited;
            self.listener.keyboardType = UIKeyboardTypeDefault;
            break;
        case HJInputHandlerTypeBank:
            self.listener.keyboardType = UIKeyboardTypeNumberPad;
            self.limitLength = nil;
            self.minLength = @16;
            self.maxLength = @21;
            self.limitLetters = nil;
            break;
        case HJInputHandlerTypePriceThousand:
            self.listener.keyboardType = UIKeyboardTypeDecimalPad;
            self.limitLength = nil;
            self.limitLetters = nil;
            break;
        default:
            break;
    }
    
}

-(void)setLimitLength:(NSNumber *)limitLength{
    
    _limitLength = limitLength;
    _minLength = limitLength;
    _maxLength = limitLength;
}

-(void (^)(HJInputHandlerInputErrorType))errCallback{
    
    if (!_errCallback) {
        
        _errCallback = ^(HJInputHandlerInputErrorType errorType){
            
            
        };
    }
    return _errCallback;
}

-(void)dealloc{
    
    if (_listener) {
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

#pragma mark - Action
-(void)inputDidBeginEditing:(NSNotification *)noti{
    
    NSString *text;
    
    SEL sel_text = NSSelectorFromString(self.listenerShowKeyPath);
    
    if ([_listener respondsToSelector:sel_text]) {
        
        text = [_listener performSelector:sel_text];
    }
    
    text = [self removeFormate:text];
    
    [self formateListenerWith:text];
}

-(void)inputDidEndEditing:(NSNotification *)noti{
    
    NSString *text = [_listener valueForKey:self.listenerShowKeyPath];

    [self isOnRequired:text];
    [self formateListenerWith:[self formate:text]];
    
}

-(void)inputDidChange:(NSNotification *)noti{
    
    NSString *text = [_listener valueForKey:self.listenerShowKeyPath];
    
    if (text.length == 0) {
        
        return ;
    }
    
    NSString *string = [text substringWithRange:NSMakeRange(text.length - 1, 1)];
    
    //判断是否输入有效类型
    BOOL canReplace =   [self vertifyInputCurrent:string]
                        &&
                        [self isInMaxLength:text string:string];//是否超长
    
    if (canReplace == NO) {
        
        [self formateListenerWith: [text substringWithRange:NSMakeRange(0,text.length - 1)]];
    }
    
    //NSLog(@"%@ -- %@",[_listener valueForKey:@"text"],[_listener valueForKey:@"attributedText"]);
}

#pragma mark - Required
//判断是否符合输入要求
-(BOOL)vertifyInputCurrent:(NSString *)string{
    
    NSCharacterSet *cs;
    HJInputHandlerInputErrorType errorType = HJInputHandlerInputErrorTypeNone;
    
    if(self.limitLetters.length > 0)
    {
        cs = [[NSCharacterSet characterSetWithCharactersInString:self.limitLetters]invertedSet];
        errorType = HJInputHandlerInputErrorTypeNotLimitString;
    }
    
    if (cs)
    {
        //按cs分离出数组,数组按@""分离出字符串
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs]componentsJoinedByString:@""];
        
        BOOL canChange = [string isEqualToString:filtered];
        if (canChange == NO)
        {
            self.errCallback(errorType);
        }
        return canChange;
    }
    return YES;
}

//判断是否超过最大长度
-(BOOL)isInMaxLength:(NSString *)text string:(NSString *)string{
    
    if (self.maxLength != nil){
        
        NSString *noFormatText = text;
        
        BOOL canChange = noFormatText.length <= self.maxLength.integerValue;
        
        if ([string isEqualToString:@""])
        {
            canChange = noFormatText.length <= self.maxLength.integerValue;
        }
        
        if (canChange == NO)
        {
            self.errCallback(HJInputHandlerInputErrorTypeBeyondMax);
        }
        return canChange;
    }
    return YES;
}

//判断长度是否达标
-(void)isOnRequired:(NSString *)text{
    
    //先判断 是否 符合限制
    if (self.limitLength && text.length != self.limitLength.integerValue){
        
        self.errCallback(HJInputHandlerInputErrorTypeNotLimitLength);
        return;
    }
    
    //在判断 最小长度
    if (self.minLength && text.length < self.minLength.integerValue){
        
        self.errCallback(HJInputHandlerInputErrorTypeBelowMin);
        return;
    }
    
}

//判断是否应该添加空格 -- (已取消)
-(BOOL)isNeedBlank:(NSString *)text inputStr:(NSString *)string{
    
    if (self.inputType != HJInputHandlerTypeBank)
    {
        return YES;
    }
    
    
    if ([text hj_removeBankblank].length
        > self.maxLength.integerValue
        &&
        self.maxLength.integerValue > 0)
    {
        self.errCallback(HJInputHandlerInputErrorTypeBeyondMax);
        
        return NO;
    }
    else if (text.length % 5 == 0)
    {
        [self formate:[NSString stringWithFormat:@"%@ ",text]];
    }
    
    return YES;
}

//样式
-(void)formateListenerWith:(NSString *)text{
    
    //SEL sel_attr_text = NSSelectorFromString(@"setHj_formateText:");
    
    /*
    if ([_listener respondsToSelector:sel_attr_text]) {
        
        [_listener performSelector:sel_attr_text withObject:text];
    }
     */
    
    [_listener setValue:text forKey:self.listenerShowKeyPath];

}

#pragma mark - Formatter
-(NSString *)formate:(NSString *)text{
    
    NSString *formateStr = text;
    
    switch (self.inputType)
    {
        case HJInputHandlerTypePriceThousand:
            
            formateStr  = [text hj_showThousnad];
            break;
        case HJInputHandlerTypeBank:
            
            formateStr  = [text hj_showBankBlank];
            break;
        case HJInputHandlerTypeMobile:
            formateStr  = [text hj_showMobile];
            break;
        default:
            break;
    }
    
    return formateStr?:@"";
}

-(NSString *)removeFormate:(NSString *)text{
    
    NSString *removeFormateStr = text;
    
    switch (self.inputType)
    {
        case HJInputHandlerTypePriceThousand:
            removeFormateStr = [text hj_removeThousand];
            break;
        case HJInputHandlerTypeBank:
            removeFormateStr = [text hj_removeBankblank];
            break;
        case HJInputHandlerTypeMobile:
            removeFormateStr = [text hj_removeMobile];
            break;
        default:
            break;
    }
    
    return removeFormateStr;
}

//返回清除样式的text
-(NSString *)removeFormateText{
    
    return [self removeFormate:[_listener valueForKey:self.listenerShowKeyPath]];
}

@end

@implementation UITextField (HJInputHandler)

-(HJInputHandler *)hj_inputHandler{
    
    HJInputHandler *_inputHandler = objc_getAssociatedObject(self, _cmd);
    
    if (!_inputHandler) {
        
        _inputHandler = [HJInputHandler new];
        _inputHandler.listener = self;
        
        objc_setAssociatedObject(self, _cmd, _inputHandler, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return _inputHandler;
}

-(void)setHj_formateText:(NSString *)hj_formateText{
    
    objc_setAssociatedObject(self, @selector(hj_formateText), hj_formateText, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    NSMutableAttributedString *str =
    [[NSMutableAttributedString alloc]initWithString:hj_formateText?:@""
                                          attributes:@{
                                                       NSForegroundColorAttributeName:self.textColor,
                                                       NSFontAttributeName:self.font
                                                       }];
    
    self.attributedText = str;
}

-(NSString *)hj_formateText{
    
    return objc_getAssociatedObject(self, _cmd);
}

@end

@implementation UITextView (HJInputHandler)

-(HJInputHandler *)hj_inputHandler{
    
    HJInputHandler *_inputHandler = objc_getAssociatedObject(self, _cmd);
    
    if (!_inputHandler) {
        
        _inputHandler = [HJInputHandler new];
        _inputHandler.listener = self;
        
        objc_setAssociatedObject(self, _cmd, _inputHandler, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return _inputHandler;
}

-(void)setHj_formateText:(NSString *)hj_formateText{
    
    objc_setAssociatedObject(self, @selector(hj_formateText), hj_formateText, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    NSMutableAttributedString *str =
    [[NSMutableAttributedString alloc]initWithString:hj_formateText?:@""
                                          attributes:@{
                                                       NSForegroundColorAttributeName:self.textColor?:[UIColor blackColor],
                                                       NSFontAttributeName:self.font?:[UIFont systemFontOfSize:13]
                                                       }];
    
    self.attributedText = str;
}

-(NSString *)hj_formateText{
    
    return objc_getAssociatedObject(self, _cmd);
}

@end


@implementation NSString (HJInputHandler)

//  - 千分符
-(NSString *)hj_showThousnad{
    
    if(!self || [self floatValue] == 0)
    {
        return @"0.00";
    }
    else if([self floatValue] < 1)
    {
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setPositiveFormat:@",##0.00;"];
        return [numberFormatter stringFromNumber:[NSNumber numberWithDouble:[self doubleValue]]];
    }
    else
    {
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setPositiveFormat:@",###.00;"];
        return [numberFormatter stringFromNumber:[NSNumber numberWithDouble:[self doubleValue]]];
    }
}
-(NSString *)hj_removeThousand{
    
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    [formatter setPositiveFormat:@",##0.00;"];
    return [formatter numberFromString:self].stringValue;
}

//  - 手机号
-(NSString *)hj_showMobile{
    
    NSMutableString *str = [NSMutableString stringWithString:self];
    if (str.length >= 3)
    {
        [str insertString:@"-" atIndex:3];
        
    }
    if (str.length >= 8)
    {
        [str insertString:@"-" atIndex:8];
    }
    
    return str;
}
-(NSString *)hj_removeMobile{
    
    return [self stringByReplacingOccurrencesOfString:@"-" withString:@""];
}

//  - 银行卡空格显示
-(NSString *)hj_removeBankblank{
    
    return [self stringByReplacingOccurrencesOfString:@" " withString:@""];
}
-(NSString *)hj_showBankBlank{
    
    NSInteger count = self.length / 4;
    
    NSMutableString *str = [NSMutableString stringWithString:self];
    
    for (int i = 0; i < count; i ++) {
        
        NSInteger index = 4 * (i+1)  + i;
        
        [str insertString:@" " atIndex:index];
        
    }
    return str;
    
}

//  - 姓名隐藏
-(NSString *)hj_hideRealName{
    
    if (self.length == 2)
    {
        return [self stringByReplacingCharactersInRange:NSMakeRange(1, 1) withString:@"*"];
    }
    if (self.length >= 3)
    {
        NSMutableString *stars = [NSMutableString string];
        for (int i = 0; i < self.length - 2; i++)
        {
            [stars appendString:@"*"];
        }
        return [self stringByReplacingCharactersInRange:NSMakeRange(1, self.length - 2)
                                             withString:stars];
    }
    
    return self;
}

@end

