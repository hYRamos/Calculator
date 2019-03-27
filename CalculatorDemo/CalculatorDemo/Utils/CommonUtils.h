//
//  CommonUtils.h
//  CalculatorDemo
//
//  Created by zzcn77 on 2019/2/25.
//  Copyright © 2019 zzcn77. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CommonUtils : NSObject

//纯数字
+ (BOOL)inputShouldNumWithText:(NSString *)inputString;

+ (NSString *)getNumberFromStr:(NSString *)str;
/**
 特殊运算符运算结果处理

 @param content 数字
 @param operatorr 运算符
 @return 运算结果
 */
+ (double)mathSpecilOperatorWithValue:(double)content withOperator:(NSString *)operatorr;
@end

NS_ASSUME_NONNULL_END
