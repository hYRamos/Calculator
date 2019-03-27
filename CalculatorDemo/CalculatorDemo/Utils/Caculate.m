//
//  Caculate.m
//  CalculatorDemo
//
//  Created by zzcn77 on 2019/2/25.
//  Copyright © 2019 zzcn77. All rights reserved.
//

#import "Caculate.h"
#import "CommonUtils.h"
@interface Caculate () {
    BOOL isNan;
}

@property (nonatomic, strong) NSMutableArray *arrayToCalculate;
@property (nonatomic, strong)NSMutableArray *arrayForOperator;

@property (nonatomic, strong) Stack *optr;
@property (nonatomic, strong) Stack *opnd;
@property (nonatomic) NSUInteger optrSize;
@property (nonatomic) NSUInteger opndSize;

@end

@implementation Caculate

-(void)clearAll {
    self.input = nil;
}

//override getter:如果不这样做有可能得到一个空的对象
-(NSMutableString *)input {
    if (!_input) {
        _input = [[NSMutableString alloc]init];
    }
    return _input;
}

-(void)delNumber {
    long length = self.input.length - 1;
    if (length >= 0) {
        [self.input deleteCharactersInRange:NSMakeRange(length, 1)];//只删除一个
    }
}

//特殊运算符,取数字栈顶时只需取出栈顶一个数字
+ (NSArray *)spelOperator {
    return @[@"s", @"a", @"b", @"c", @"d", @"p", @"f", @"h", @"i", @"j", @"j", @"k", @"n"];
}


+(NSArray *)validOperator {
    return @[@"+", @"-", @"*", @"/", @"(", @")", @"=", @"s", @"a", @"b", @"c", @"d", @"p", @"f", @"g", @"h", @"i", @"j", @"k", @"n"];
}

+(NSDictionary *)inStackPriority {
    return @{@"(":@1, @"*":@5, @"/":@5, @"+":@3, @"-":@3, @")":@800000, @"=":@0, @"s":@6, @"a":@70, @"b":@70, @"c":@70, @"d":@70, @"p":@70, @"f":@70, @"g":@6, @"h":@70, @"i":@70, @"j":@70, @"k":@70, @"n":@6 };
}

+(NSDictionary *)outStackPriority {
    return @{@"(":@800000, @"*":@4, @"/":@4, @"+":@2, @"-":@2, @")":@1, @"=":@0, @"s":@7, @"a":@60, @"b":@60, @"c":@60, @"d":@60, @"p":@60, @"f":@60, @"g":@7, @"h":@60, @"i":@60, @"j":@60, @"k":@60, @"n":@7};
}

-(BOOL)isOperator:(NSString *)ch {
    if ([[Caculate validOperator] containsObject:ch]) {
        return YES;
    }else
        return NO;
}

-(BOOL)isNumberic:(NSString *)ch {
    NSCharacterSet* Digits = [NSCharacterSet decimalDigitCharacterSet];
    NSString *value = [ch stringByTrimmingCharactersInSet:Digits];
    NSLog(@"nonDigits:value:%@", value);
    
    if ([value length]!= 0) {//value为ch中除数字之外的字符
        if (!([value isEqualToString:@"."] ^ [value isEqualToString:@"n"] )) {//value中包含.或者-可能为小数或者负数//^ [value isEqualToString:@"-"]
            NSLog(@"isNumberic Error!");
            return NO;
        }
        if ([value isEqualToString:@"n"]) {
            NSString *theLast = [ch substringFromIndex:[ch length]-1];
            if ([theLast isEqualToString:@"n"]) {
                return NO;
            }
            return YES;
        }
        
    }
    return YES;
}

-(BOOL)isBracket:(NSString *)ch {
    if ([ch isEqualToString:@"("] || [ch isEqualToString:@")"]) {
        return YES;
    }
    return NO;
}

-(BOOL)isLeftBracket:(NSString *)ch {
    if ([ch isEqualToString:@"("]) {
        return YES;
    }
    return NO;
}

-(BOOL)isRightBracket:(NSString *)ch {
    if ([ch isEqualToString:@")"]) {
        return YES;
    }
    return NO;
}

//判断是否为整数
-(BOOL)isInteger:(NSString *)content {
    if (![self isNumberic:content]) {
        NSLog(@"content has operator.");
        return NO;
    }
    //判断时,把负数符号n转成-以便比较
    int intContent = [[content stringByReplacingOccurrencesOfString:@"n" withString:@"-"] intValue];
    double doubleContent = [[content stringByReplacingOccurrencesOfString:@"n" withString:@"-"] doubleValue];
    if ((doubleContent - intContent == 0))
        return YES;
    else
        return NO;
}

//判断是否为有效输入
-(BOOL)isValidInput:(NSString *)ch {
    NSUInteger length = [ch length];
    NSUInteger lcount = 0, rcount = 0;
    
    for (int i = 0; i < length; i++) {
        char c = [ch characterAtIndex:i];
        NSString *iStr = [NSString stringWithFormat:@"%c", c];
        
        if (![self isOperator:iStr])
            //不考虑数字
            continue;
        else if([self isBracket:iStr]){
            if ([self isLeftBracket:iStr])
                lcount++;
            if([self isRightBracket:iStr])
                rcount++;
        }else{
            //istr既不是数字也不是括号
            int j = i + 1;
            if (j < length) {
                char nextc = [ch characterAtIndex:j];
                NSString *jStr = [NSString stringWithFormat:@"%c", nextc];
                if ([self isOperator:jStr]) {
                    if ([[Caculate spelOperator] containsObject:jStr]) {//判断+-*/等运算符后面可以跟特殊运算符
                        continue;
                    }
                    if (![self isBracket:jStr])
                        return NO;
                }
            }
        }
    }//for结束
    
    if (lcount != rcount) {
        return NO;
    }
    
    return YES;
}

-(NSString *)comparePriority:(NSString *)inOptr outOptr:(NSString *)outOptr {
    NSDictionary *inStackPriority = [Caculate inStackPriority];
    NSDictionary *outStackPriority = [Caculate outStackPriority];
    
    NSString *inPriority = inStackPriority[inOptr];
    NSString *outPriority = outStackPriority[outOptr];
    
    NSInteger isp = [inPriority integerValue];
    NSInteger icp = [outPriority integerValue];
    
    NSLog(@"栈外 %@ 优先级:%@ 栈内 %@ 优先级:%@", outOptr, outPriority, inOptr, inPriority);
    
    if (isp > icp)
        return @">";
    else if (isp < icp)
        return @"<";
    else
        return @"=";
}


-(double)calculate:(double)opnd1 opnd2:(double)opnd2 optr:(NSString *)optr {
    NSArray *items = @[@"+", @"-", @"*", @"/", @"g"];
    int item = (int)[items indexOfObject:optr];
    switch (item) {
        case 0:
            return (opnd1 + opnd2);
            break;
        case 1:
            return (opnd1 - opnd2);
            break;
        case 2:
            return (opnd1 * opnd2);
            break;
        case 3:
            if (opnd2 == 0) {
                NSLog(@"除法，除数为0");
                return 0;
                break;
            }
            return (opnd1 / opnd2);
            break;
        case 4:
            return (pow(opnd1, opnd2));//求次方
            break;
        default:
            NSLog(@"calculate default case");
            return 0;
            break;
    }
}

-(NSMutableArray *)clearWhitespace:(NSMutableArray *)inputArray {
    NSMutableArray * tempArray = [NSMutableArray array];//必须初始化，否则数组存不上东西
    for (int i = 0; i < inputArray.count; i++) {
        if (![inputArray[i] isEqualToString:@""]) {
            [tempArray addObject:inputArray[i]];
        }
    }
    return tempArray;
}

-(NSString *)ExpressionCalculate:(NSString *)inputString {
    NSLog(@"inputstring = %@", inputString);
    if (![self isValidInput:inputString]) {
        NSLog(@"Exp.calculating, invalid input!");
        return @"输入错误!";
    }
    
    //从输入的字符串中提取运算符
    self.arrayForOperator = [NSMutableArray array];//必须初始化，否则数组存不上东西
    self.arrayToCalculate = [NSMutableArray array];
    
    for (int i = 0; i < [inputString length]; i++) {
        char ch = [inputString characterAtIndex:i];
        NSString *temp = [NSString stringWithFormat:@"%c", ch];
        if ([[Caculate validOperator] containsObject:temp]) {
            [self.arrayForOperator addObject:temp];
        }
    }
    
    NSArray *tempArray = [inputString componentsSeparatedByCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"(+-*/%=)sabcdpfghijkn"]];
    self.arrayToCalculate = [NSMutableArray arrayWithArray:tempArray];
    self.arrayToCalculate = [self clearWhitespace:self.arrayToCalculate];
    NSLog(@"self.arrayToCalculate2 = %@", self.arrayToCalculate);
    
    //检查是否包含非法字符
    for (NSString *ch in self.arrayToCalculate) {
        if (![self isNumberic:ch]) {
            NSLog(@"ch isn't numberic!");
            return @"输入错误!";
        }
    }
    
    self.optrSize = self.arrayForOperator.count;
    self.opndSize = self.arrayToCalculate.count;
    
    NSLog(@"arrayToCalculate:%@", self.arrayToCalculate);
    NSLog(@"arrayForOperator:%@", self.arrayForOperator);
    
    //表达式计算
    
    //初始化两个栈
    self.optr = [[Stack alloc] initWithStacksize:self.optrSize];
    [self.optr push:@"=" stack:self.optr];
    self.opnd = [[Stack alloc] initWithStacksize:self.opndSize];
    
    NSLog(@"optr: %@", self.optr.stackArray);
    NSLog(@"opnd: %@", self.opnd.stackArray);
    
    
    NSString *bracket;//接收括号
    NSString *theta;//存放计算符号
    NSString *a, *b;//存放操作数
    
    isNan = NO;
    
    for (int i = 0; i < [inputString length]; i++) {
        
        char ch = [inputString characterAtIndex:i];
        NSString *str = [NSString stringWithFormat:@"%c", ch];
        
        if (([str isEqualToString:@"="]) && ([[self.optr getTop:self.optr] isEqualToString:@"="]) ) {
            break;
        }else{
            
            if (![self isOperator:str]) {
                NSLog(@"%@ 不是运算符", str);
                if ([str isEqualToString:@"m"]) {
                    continue;
                }
                int j = i+1;
                NSLog(@"j = %d", j);
                if (j < [inputString length]) {
                    NSLog(@"j < %d", (int)[inputString length]);
                    char nextch = [inputString characterAtIndex:j];
                    NSString *nextStr = [NSString stringWithFormat:@"%c", nextch];
                    NSLog(@"nextStr:%@", nextStr);
                    if (![self isOperator:nextStr]){//下一个字符仍然是数字
                        NSLog(@"下一个字符仍为数字");
                        continue;
                    }
                    else{
                        NSLog(@"下一个字符不是数字");
                        [self.opnd push:[self.arrayToCalculate firstObject] stack:self.opnd];
                        [self.arrayToCalculate removeObjectAtIndex:0];
                    }
                }else{
                    [self.opnd push:[self.arrayToCalculate firstObject] stack:self.opnd];
                    [self.arrayToCalculate removeObjectAtIndex:0];
                }
                NSLog(@"opnd:%@", self.opnd.stackArray);
                NSLog(@"optr:%@", self.optr.stackArray);
                
            }else{
                
                NSLog(@"%@ 是运算符", str);
                NSLog(@"opnd: %@", self.opnd.stackArray);
                NSLog(@"optr: %@", self.optr.stackArray);
                
                
                //判断优先级
                NSString *priority = [self comparePriority:[self.optr getTop:self.optr] outOptr:str];
                NSArray *items = @[@"<", @"=", @">"];
                int item = (int)[items indexOfObject:priority];
                NSLog(@"%d", i);
                switch (item) {
                    case 0: {   //栈顶元素优先级低
                        if([self.optr push:str stack:self.optr]) {
                            NSLog(@"栈顶元素优先级低,将 %@ 压入栈", str);
                            NSLog(@"after compute, opnd is:%@", self.opnd.stackArray);
                            NSLog(@"after compute, optr is:%@", self.optr.stackArray);
                        } else {
                            NSLog(@"push failed.");
                        }
                        break;
                    }
                    case 1: {    //脱括号并接收下一元素
                        bracket = [self.optr pop:self.optr];
                        NSLog(@"%@ 和 %@ 优先级相等，脱括号并接收下一元素", str, bracket);
                        NSLog(@"after compute, opnd is:%@", self.opnd.stackArray);
                        NSLog(@"after compute, optr is:%@", self.optr.stackArray);
                        break;
                    }
                    case 2: {   //退栈并将运算结果入栈
                        --i;//栈外运算符的优先级小于栈顶元素，弹出当前栈顶元素，保留当前栈外元素
                        theta = [self.optr pop:self.optr];
                        if ([[Caculate spelOperator] containsObject:theta]) {//只需取出一个数字栈的情况
                            a = [self.opnd pop:self.opnd];
                            NSLog(@"计算%@ %@ %@", a, theta, b);
                            if ([a isEqualToString:@"90"] && [theta isEqualToString:@"c"])  {
                                isNan = YES;
                                break;
                            }
                            
                            double resulta=[CommonUtils mathSpecilOperatorWithValue:[a doubleValue] withOperator:theta];
                            if (isnan(resulta)) {
                                isNan = YES;
                                break;
                            }
                            
                            NSNumber *num = [[NSNumber alloc] initWithDouble:resulta];
                            NSString *result = [num stringValue];
                            [self.opnd push:result stack:self.opnd];
                        }else {
                            b = [self.opnd pop:self.opnd];
                            a = [self.opnd pop:self.opnd];
                            NSLog(@"计算%@ %@ %@", a, theta, b);
                            
                            double da = [a doubleValue];
                            NSLog(@"a = %@, da = %f", a, da);
                            double db = [b doubleValue];
                            if ([theta isEqualToString:@"/"] && db == 0) {
                                isNan = YES;
                                break;
                            }
                            if (da == 0 && db == 0 && [theta isEqualToString:@"g"]) {
                                isNan = YES;
                                break;
                            }
                            
                            double res;
                            res = [self calculate:da opnd2:db optr:theta];
                            
                            NSNumber *num = [[NSNumber alloc] initWithDouble:res];
                            NSString *result = [num stringValue];
                            [self.opnd push:result stack:self.opnd];
                        }
                        
                        NSLog(@"after compute, opnd is:%@", self.opnd.stackArray);
                        NSLog(@"after compute, optr is:%@", self.optr.stackArray);
                        break;
                    }
                    default:
                        NSLog(@"default case");
                        break;
                }
            }
        }
    }    //for
    if (isNan) {
        isNan = NO;
        return @"不是数字!";
    }
    
    NSString *expResult = [self.opnd getTop:self.opnd];
    if ([expResult isEqualToString:@"inf"]) {
        return @"数据过大";
    }
    if ([self isInteger:expResult]) {
        NSLog(@"result is integer.");
        int temp = [expResult intValue];
        NSNumber *num = [[NSNumber alloc] initWithInt:temp];
        return [num stringValue];
    }
    return expResult;
}
@end
