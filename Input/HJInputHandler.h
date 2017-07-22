//
//  HJInputHandler.h
//  IOSMaster
//
//  Created by HJ on 2017/7/22.
//  Copyright © 2017年 HJ. All rights reserved.
//

#import <Foundation/Foundation.h>

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

//异常回调
@property (nonatomic,copy) void(^errCallback)(HJInputHandlerInputErrorType errorType);

//返回清除样式的text
-(NSString *)removeFormateText;

@end


@interface UITextField (HJInputHandler)

@property (nonatomic,strong,readonly) HJInputHandler *hj_inputHandler;

//特殊样式显示属性
//@property (nonatomic,copy) NSString *hj_formateText;

@end

@interface UITextView (HJInputHandler)

@property (nonatomic,strong,readonly) HJInputHandler *hj_inputHandler;

//特殊样式显示属性
//@property (nonatomic,copy) NSString *hj_formateText;

@end


//输入字符样式 
@interface NSString (HJInputHandler)

-(NSString *)hj_showThousnad;
-(NSString *)hj_removeThousand;

-(NSString *)hj_showMobile;
-(NSString *)hj_removeMobile;

-(NSString *)hj_showBankBlank;
-(NSString *)hj_removeBankblank;

-(NSString *)hj_hideRealName;


@end
