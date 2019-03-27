//
//  CommonUtils.m
//  CalculatorDemo
//
//  Created by zzcn77 on 2019/2/25.
//  Copyright © 2019 zzcn77. All rights reserved.
//

#import "CommonUtils.h"
#import <math.h>

@implementation CommonUtils
//纯数字
+ (BOOL)inputShouldNumWithText:(NSString *)inputString {
    if (inputString.length == 0) return NO;
    NSString *regex =@"[0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [pred evaluateWithObject:inputString];
}

+(NSString *)reviseString:(NSNumber *)number {
    //直接传入精度丢失有问题的Double类型
    double conversionValue = [number doubleValue];
    NSString *doubleString = [NSString stringWithFormat:@"%lf", conversionValue];
    NSDecimalNumber *decNumber = [NSDecimalNumber decimalNumberWithString:doubleString];
    return [decNumber stringValue];
}

+ (NSString *)getNumberFromStr:(NSString *)str {
    NSMutableCharacterSet *set = [[NSMutableCharacterSet alloc] init];
    //    NSCharacterSet *nonDigitCharacterSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    [set formUnionWithCharacterSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
    [set formUnionWithCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];//小数
    return[[str componentsSeparatedByCharactersInSet:set] componentsJoinedByString:@""];
    
}

+ (double)mathSpecilOperatorWithValue:(double)content withOperator:(NSString *)operatorr {
    if ([operatorr isEqualToString:@"a"]) {
        return sin(M_PI/(180/content));
    }else if ([operatorr isEqualToString:@"b"]) {
        return cos(M_PI/(180/content));
    }else if ([operatorr isEqualToString:@"c"]) {
        return tan(M_PI/(180/content));
    }else if ([operatorr isEqualToString:@"d"]) {
        return sinh(content);
    }else if ([operatorr isEqualToString:@"p"]) {
        return cosh(content);
    }else if ([operatorr isEqualToString:@"f"]) {
        return tanh(content);
    }else if ([operatorr isEqualToString:@"h"]) {
        return asin(content);
    }else if ([operatorr isEqualToString:@"i"]) {
        return acos(content);
    }else if ([operatorr isEqualToString:@"j"]) {
        return atan(content);
    }else if ([operatorr isEqualToString:@"k"]) {
        return log(content);
    }else if ([operatorr isEqualToString:@"s"]) {
        return sqrt(content);
    }else if ([operatorr isEqualToString:@"n"]) {
        return -content;
    }
    return 0;
}

@end
