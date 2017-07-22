# HJInputHandler

![image](https://github.com/thisIsDestiny/HJInputHandler/blob/master/Input/HJInputHandlerV1.0.gif)

(1)Method:

SetInputType

textView.hj_inputHandler.inputType =  HJInputHandlerTypeLetterOrNum;

textField.hj_inputHandler.inputType =  HJInputHandlerTypeMobile;

(2)limit

限制输入字符(为空则不判断)

@property (nonatomic,copy)   NSString *limitLetters;

最小长度

@property (nonatomic,strong) NSNumber *minLength;

最大长度

@property (nonatomic,strong) NSNumber *maxLength;

指定长度

@property (nonatomic,strong) NSNumber *limitLength;


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

(3)实现原理 获取控件通知
现在支持 UITextField\UITextView[注册通知]
//设置被监听对象
@property (nonatomic,weak) NSObject<UITextInput> *listener;

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

(4)注册 显示 keyPath
+(NSDictionary<NSString *,NSString *> *)register_showText{
    
    return @{
             @"UITextField":@"text",
             @"UITextView":@"text"
             };
}


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
