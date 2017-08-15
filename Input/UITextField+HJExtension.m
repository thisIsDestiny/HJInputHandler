//
//  UITextField+HJExtension.m
//  OneLifeOneDoctor
//
//  Created by imac on 2017/8/11.
//  Copyright © 2017年 Shanjian. All rights reserved.
//

#import "UITextField+HJExtension.h"

@implementation UITextField (HJExtension)

-(NSRange )hj_selectedRange{
    
    UITextPosition* beginning = self.beginningOfDocument;
    UITextRange* selectedRange = self.selectedTextRange;
    UITextPosition* selectionStart = selectedRange.start;
    UITextPosition* selectionEnd = selectedRange.end;
    NSInteger location = [self offsetFromPosition:beginning toPosition:selectionStart];
    NSInteger length = [self offsetFromPosition:selectionStart toPosition:selectionEnd];
    
    return NSMakeRange(location, length);
}

-(NSRange )hj_markedRange{
    
    UITextPosition* beginning = self.beginningOfDocument;
    UITextRange* selectedRange = self.markedTextRange;
    UITextPosition* selectionStart = selectedRange.start;
    UITextPosition* selectionEnd = selectedRange.end;
    NSInteger location = [self offsetFromPosition:beginning toPosition:selectionStart];
    NSInteger length = [self offsetFromPosition:selectionStart toPosition:selectionEnd];
    
    return NSMakeRange(location, length);
}

@end
