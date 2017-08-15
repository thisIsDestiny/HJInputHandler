//
//  NSString+HJExtension.h
//  OneLifeOneDoctor
//
//  Created by imac on 2017/8/11.
//  Copyright © 2017年 Shanjian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HJExtension)

-(NSString *)hj_showThousnad;
-(NSString *)hj_removeThousand;

-(NSString *)hj_showMobile;
-(NSString *)hj_removeMobile;

-(NSString *)hj_showBankBlank;
-(NSString *)hj_removeBankblank;

-(NSString *)hj_hideRealName;

@end
