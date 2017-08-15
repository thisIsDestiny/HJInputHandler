//
//  InputHandler.h
//  RedPage
//
//  Created by imac on 2017/6/23.
//  Copyright © 2017年 Shanjian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UITextField+HJExtension.h"
#import "UITextView+HJExtension.h"

//输入类型
typedef NS_ENUM(NSInteger,HJInputHandlerType){
    
    HJInputHandlerTypeNormal        = 0,//不做限制
    HJInputHandlerTypeMobile           ,//手机号（11位纯数字）
    HJInputHandlerTypeLetterOrNum      ,//字母或数字
    HJInputHandlerTypeID               ,//身份证（数字+xX）
    HJInputHandlerTypeBank             ,//最多21位(数字)
    HJInputHandlerTypePriceThousand    ,//显示千分位
};

//异常类型
typedef NS_ENUM(NSInteger,HJInputHandlerInputErrorType){
    
    HJInputHandlerInputErrorTypeNone            = 0,
    HJInputHandlerInputErrorTypeBeyondMax       = 1,//超长
    HJInputHandlerInputErrorTypeBelowMin        = 2,//过短
    HJInputHandlerInputErrorTypeNotLimitLength  = 3,//长度不符合
    HJInputHandlerInputErrorTypeNotLimitString  = 4 //输入字符不符合
};


@interface HJInputHandler : NSObject

//设置被监听对象
@property (nonatomic,weak) NSObject<UITextInput> *listener;

//限制输入字符(为空则不判断)
@property (nonatomic,copy)   NSString *limitLetters;

//最小长度
@property (nonatomic,strong) NSNumber *minLength;

//最大长度
@property (nonatomic,strong) NSNumber *maxLength;

//指定长度
@property (nonatomic,strong) NSNumber *limitLength;

//输入类型 -- (预配置 参数 及 特殊显示)
@property (nonatomic,assign) HJInputHandlerType inputType;

//输入异常回调
@property (nonatomic,copy) void(^errCallback)(HJInputHandlerInputErrorType errorType);

@property (nonatomic,copy) void(^didBeginEditBlock)();

@property (nonatomic,copy) void(^didEndEditBlock)();

@property (nonatomic,copy) void(^editChangedBlock)();


//返回清除样式的text
-(NSString *)removeFormateText;

@end


@interface UITextField (HJInputHandler)

@property (nonatomic,strong,readonly) HJInputHandler *hj_inputHandler;

@end

@interface UITextView (HJInputHandler)

@property (nonatomic,strong,readonly) HJInputHandler *hj_inputHandler;

@end

