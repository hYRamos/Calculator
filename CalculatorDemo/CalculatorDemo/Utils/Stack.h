//
//  Stack.h
//  CalculatorDemo
//
//  Created by zzcn77 on 2019/2/25.
//  Copyright © 2019 zzcn77. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Stack : NSObject

@property(nonatomic, readonly) NSString *Top;
@property(nonatomic) NSUInteger Stacksize;
@property(nonatomic, readonly) NSMutableArray *stackArray;
@property(nonatomic, readonly) NSString *popElement;

-(instancetype)initWithStacksize:(NSUInteger)Stacksize;

-(BOOL)push:(NSString *)element stack:(Stack *)stack;

-(NSString *)pop:(Stack *)stack;

-(NSString *)getTop:(Stack *)stack;

@end

NS_ASSUME_NONNULL_END
