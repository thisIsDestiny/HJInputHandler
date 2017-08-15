//
//  NSString+HJExtension.m
//  OneLifeOneDoctor
//
//  Created by imac on 2017/8/11.
//  Copyright © 2017年 Shanjian. All rights reserved.
//

#import "NSString+HJExtension.h"

@implementation NSString (HJExtension)

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
