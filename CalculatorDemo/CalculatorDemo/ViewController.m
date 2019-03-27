//
//  ViewController.m
//  CalculatorDemo
//
//  Created by zzcn77 on 2019/2/25.
//  Copyright © 2019 zzcn77. All rights reserved.
//

#import "ViewController.h"
#import "NumOpCell.h"
#import "UIView+Add.h"
#import "Caculate.h"
#import "CommonUtils.h"

@interface ViewController ()<UICollectionViewDelegate, UICollectionViewDataSource> {
    NSArray * buttonTitleArray;//cell item
    NSArray * beginChReplaceArray;//label显示为0时,是否替换掉0
    NSArray * berArray;//输入后自动加上(的运算符
    BOOL isDone;//是否计算过
    NSString * lastOperator;//上一个运算表达式
    BOOL curIsNega;//判断正负输入情况
    NSString * lastInputString;//记录最后输入的字符
    NSString * resultString;//计算结果记录
}
@property (strong, nonatomic)Caculate *calculator;
@property (nonatomic, strong)UILabel * resultLabel;//运算过程Label
@property (nonatomic, strong)UILabel * resLabel;//结果label
@property (nonatomic, strong)UICollectionView * collectionView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    buttonTitleArray = @[@"C", @"(", @")", @"÷", @"7", @"8", @"9", @"×", @"4", @"5", @"6", @"-", @"1", @"2", @"3", @"+", @"0", @".", @"+/-", @"=", @"ln", @"sin", @"cos", @"tan", @"√", @"sinh", @"cosh", @"tanh", @"^", @"arcsin", @"arccos", @"arctan"];
    
    berArray = @[@"sin", @"cos", @"tan", @"sinh", @"cosh", @"tanh", @"arcsin", @"arccos", @"arctan", @"ln"];
    beginChReplaceArray = @[@"sin", @"cos", @"tan", @"sinh", @"cosh", @"tanh", @"arcsin", @"arccos", @"arctan", @"ln", @"√", @"(", @"+/-"];
    self.calculator = [[Caculate alloc] init];
    isDone = NO;
    curIsNega = NO;
    resultString = @"";
    
    [self createSubViews];
}
/**
 初始化视图
 */
- (void)createSubViews {
    self.view.backgroundColor = [UIColor whiteColor];
    //展示结果label
    self.resultLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, self.view.width - 20, 60)];
    self.resultLabel.textAlignment = NSTextAlignmentRight;
    self.resultLabel.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:self.resultLabel];
    self.resultLabel.font = [UIFont systemFontOfSize:40];
    self.resultLabel.adjustsFontSizeToFitWidth = YES;
    self.resultLabel.minimumScaleFactor = 0.3;
    self.resultLabel.text = @"0";
    
    //展示结果label
    self.resLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, self.resultLabel.bottom, self.view.width - 20, 40)];
    self.resLabel.textAlignment = NSTextAlignmentRight;
    self.resLabel.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.resLabel];
    self.resLabel.font = [UIFont systemFontOfSize:20];
    self.resLabel.adjustsFontSizeToFitWidth = YES;
    self.resLabel.minimumScaleFactor = 0.3;
    self.resLabel.text = @"结果:0";
    
    
    //定义键盘
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat width = (self.view.width - 50)/4;
    layout.itemSize = CGSizeMake(width, width*2/3);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.resLabel.bottom + 10, self.view.width, self.view.height - self.resultLabel.bottom - 40) collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.collectionView];
    
    UINib * nib = [UINib nibWithNibName:@"NumOpCell" bundle:[NSBundle mainBundle]];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"cellId"];
}

#pragma mark -- collection dataSouth delegate

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 10, 10);//分别为上、左、下、右
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return buttonTitleArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NumOpCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellId" forIndexPath:indexPath];
    cell.titleLabel.text = buttonTitleArray[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString * selelString = buttonTitleArray[indexPath.row];
    //归零
    if ([selelString isEqualToString:@"C"]) {
        self.resultLabel.text = @"0";
        self.resLabel.text = @"结果:0";
        self.calculator.input = [@"" mutableCopy];
        isDone = NO;
        lastInputString = @"";
        curIsNega = NO;
        resultString = @"";
        return;
    }
    
    //点击 = 进行计算
    if ([selelString isEqualToString:@"="]) {
        NSInteger left = [self.calculator.input componentsSeparatedByString:@"("].count - 1;
        NSInteger right = [self.calculator.input componentsSeparatedByString:@")"].count - 1;
        if (left > right && ![[self.calculator.input substringFromIndex:self.calculator.input.length-1] isEqualToString:@"("]) {//自动补全括号
            for (int i = 0; i < left - right; i++) {
                [self.calculator.input appendString:@")"];
                self.resultLabel.text = [NSString stringWithFormat:@"%@)", self.resultLabel.text];
            }
        }
        
        [self.calculator.input appendString:selelString];
        resultString = [self.calculator ExpressionCalculate:self.calculator.input];
        self.resLabel.text = [NSString stringWithFormat:@"结果: %@", resultString];
        //计算结束后将结果保存,以便进行连续运算
        lastInputString = @"";
        if ([[resultString substringFromIndex:resultString.length-1] isEqualToString:@"!"]) {
            self.calculator.input = [@"0" mutableCopy];
            resultString = @"0";
            isDone = YES;
            return;
        }
        //数据过大处理
        for (int i = 0; i < [resultString length]; i++) {
            char ch = [resultString characterAtIndex:i];
            NSString *temp = [NSString stringWithFormat:@"%c", ch];
            if ([temp isEqualToString:@"e"]) {
                self.calculator.input = [@"0" mutableCopy];
                resultString = @"0";
                isDone = YES;
                return;
            }
        }
        self.calculator.input = [resultString mutableCopy];
        if (resultString.floatValue < 0) {
            self.calculator.input =  [[resultString stringByReplacingOccurrencesOfString:@"-" withString:@"n"] mutableCopy];
        }
        isDone = YES;
        curIsNega = NO;
        return;
    }
    
    if (isDone) {//计算后转入下次运算
        self.resultLabel.text = resultString;
        isDone = NO;
    }
    
    //当前显示为0, 首次输入是否去掉0的情况处理
    if ([self.resultLabel.text isEqualToString:@"0"] && ![selelString isEqualToString:@")"]) {//当前显示为0时
        if ([CommonUtils inputShouldNumWithText:selelString] || [beginChReplaceArray containsObject:selelString]) {
            if ([selelString isEqualToString:@"+/-"]) {//正负单独处理
                [self.calculator.input appendString:@"n"];
                self.resultLabel.text = @"-";
                lastInputString = @"+/-";
                curIsNega = YES;
            }else {
                [self transformOperatorWithSeletString:selelString];
                if ([berArray containsObject:selelString]) {
                    selelString = [NSString stringWithFormat:@"%@(", selelString];
                }
                self.resultLabel.text = selelString;
            }
            NSLog(@"%@", self.calculator.input);
            return;
        }
    }else {
        //验证输入**********************
        if (![self isCanInputWith:selelString]) {
            return;
        }
    }
    
    if ([selelString isEqualToString:@"+/-"]) {
        if (![[self.calculator.input substringFromIndex:self.calculator.input.length - 1] isEqualToString:@"n"]) {
            curIsNega = NO;
        }
        if (!curIsNega) {//当前未输入负号
            [self.calculator.input appendString:@"n"];
            self.resultLabel.text = [NSString stringWithFormat:@"%@ -", self.resultLabel.text];
        }else {
            if ([self.calculator.input isEqualToString:@"n"]) {
                self.resultLabel.text = @"0";
                self.resLabel.text = @"结果:0";
                self.calculator.input = [@"" mutableCopy];
                isDone = NO;
                curIsNega = NO;
                return;
            }else {
                [self.calculator.input replaceCharactersInRange:NSMakeRange(self.calculator.input.length - 1, 1) withString:@""];
                NSLog(@"%@", self.resultLabel.text);
                self.resultLabel.text = [self.resultLabel.text stringByReplacingCharactersInRange:NSMakeRange(self.resultLabel.text.length - 2, 2) withString:@""];
            }
            
        }
        curIsNega = !curIsNega;
        return;
    }
    
    //对运算符的转换,显示仍为正常输入运算符,转换成字母进行算法处理
    [self transformOperatorWithSeletString:selelString];
    if ([berArray containsObject:selelString]) {
        selelString = [NSString stringWithFormat:@"%@(", selelString];
    }
    
    NSMutableString *originalString=[NSMutableString stringWithString:self.resultLabel.text];
    [originalString appendString:selelString];
    self.resultLabel.text=originalString;
    NSLog(@"%@", self.calculator.input);
}

//对运算符的转换,显示仍为正常输入运算符,转换成字母进行算法处理
- (void)transformOperatorWithSeletString:(NSString *)selelString {
    lastInputString = selelString;
    if([selelString isEqualToString:@"×"]){
        [self.calculator.input appendString:@"*"];
    }else if([selelString isEqualToString:@"÷"]){
        [self.calculator.input appendString:@"/"];
    }else if([selelString isEqualToString:@"√"]){
        [self.calculator.input appendString:@"s"];
    }else if([selelString isEqualToString:@"sin"]){
        [self.calculator.input appendString:@"a("];
    }else if([selelString isEqualToString:@"cos"]){
        [self.calculator.input appendString:@"b("];
    }else if([selelString isEqualToString:@"tan"]){
        [self.calculator.input appendString:@"c("];
    }else if([selelString isEqualToString:@"sinh"]){
        [self.calculator.input appendString:@"d("];
    }else if([selelString isEqualToString:@"cosh"]){
        [self.calculator.input appendString:@"p("];
    }else if([selelString isEqualToString:@"tanh"]){
        [self.calculator.input appendString:@"f("];
    }else if([selelString isEqualToString:@"^"]){
        [self.calculator.input appendString:@"g"];
    }else if([selelString isEqualToString:@"arcsin"]){
        [self.calculator.input appendString:@"h("];
    }else if([selelString isEqualToString:@"arccos"]){
        [self.calculator.input appendString:@"i("];
    }else if([selelString isEqualToString:@"arctan"]){
        [self.calculator.input appendString:@"j("];
    }else if([selelString isEqualToString:@"ln"]){
        [self.calculator.input appendString:@"k("];
    }else{
        [self.calculator.input appendString:selelString];
    }
}


- (BOOL)isCanInputWith:(NSString *)input {
    

    NSString * old = self.resultLabel.text;
    NSString *theLast = [old substringFromIndex:[old length]-1];
    NSLog(@"old = %@, theLast = %@, input =%@ ", old, theLast, input);
    if ([input isEqualToString:@")"]) {
        NSInteger left = [old componentsSeparatedByString:@"("].count - 1;
        NSInteger right = [old componentsSeparatedByString:@")"].count - 1;
        if (left <= right) {
            return NO;
        }
    }
    
    if ([self.calculator isNumberic:old]) {//当前输入是纯数字
        if ([self.calculator isInteger:old]) {//当前输入是整数
            if ([@[@")", @"÷", @"7", @"8", @"9", @"×", @"4", @"5", @"6", @"-", @"1", @"2", @"3", @"+", @"0", @".", @"^"] containsObject:input]) {
                if ([theLast isEqualToString:@"-"] && [input isEqualToString:@"-"]) {
                    return NO;
                }
                return YES;
            }else {
                return NO;
            }
        }else {
            if ([@[@")", @"÷", @"7", @"8", @"9", @"×", @"4", @"5", @"6", @"-", @"1", @"2", @"3", @"+", @"0", @"^"] containsObject:input]) {
                return YES;
            }else {
                return NO;
            }
        }
    }else {
        
        if ([theLast isEqualToString:@"."]) {//最后一位为.
            if ([@[@"7", @"8", @"9", @"4", @"5", @"6", @"1", @"2", @"3", @"0", @"+", @"-", @"×", @"÷", @"^"] containsObject:input]) {
                return YES;
            }else {
                return NO;
            }
        }
        
        if ([@[@"7", @"8", @"9", @"4", @"5", @"6", @"1", @"2", @"3", @"0", @"."] containsObject:theLast]) {//当后面是数字的情况
            NSArray *numArr = [self getNumberWithString:old];
            NSLog(@"numArr = %@", numArr);
            if ([numArr containsObject:@"."] && [input isEqualToString:@"."]) {
                return NO;
            }else {
                if ([@[@"7", @"8", @"9", @"4", @"5", @"6", @"1", @"2", @"3", @"0", @".", @"+", @"-", @"×", @"÷", @"^"] containsObject:input]) {
                    return YES;
                }else if ([input isEqualToString:@")"]) {
                    NSInteger left = [old componentsSeparatedByString:@"("].count - 1;
                    NSInteger right = [old componentsSeparatedByString:@")"].count - 1;
                    if (left <= right) {
                        return NO;
                    }
                } else {
                    return NO;
                }
            }
        }
        if ([theLast isEqualToString:@"("]) {//左括号
            if ([@[@"(", @"7", @"8", @"9", @"4", @"5", @"6", @"1", @"2", @"3", @"0", @"sin", @"cos", @"tan", @"√", @"sinh", @"cosh", @"tanh", @"arcsin", @"arccos", @"arctan", @"ln", @"+/-"] containsObject:input]) {
                return YES;
            }else {
                return NO;
            }
        }
        
        if ([theLast isEqualToString:@")"]) {//右括号时,判断左右括号数量是否相等
            if ([@[@"+", @"-", @"×", @"÷", @"^"] containsObject:input]) {
                return YES;
            }else if ([input isEqualToString:@")"]) {//判断左右括号数量是否相等
                NSInteger left = [old componentsSeparatedByString:@"("].count - 1;
                NSInteger right = [old componentsSeparatedByString:@")"].count - 1;
                if (left > right) {
                    return YES;
                }else {
                    return NO;
                }
            }else {
                return NO;
            }
        }
        
        if ([theLast isEqualToString:@")"]) {//右括号
            if ([@[@"+", @"-", @"×", @"÷", @"^"] containsObject:input]) {
                return YES;
            }else {
                return NO;
            }
        }
        
        if ([@[@"+", @"-", @"×", @"÷", @"^"] containsObject:theLast]) {//最后一位是 +-*/^时,不可再继续输入该运算符
            if (![@[@"+", @"-", @"×", @"÷", @"^"] containsObject:input]) {
                return YES;
            }else {
                return NO;
            }
        }
        
        if ([theLast isEqualToString:@"√"]) {//√
            if ([@[@"(", @"7", @"8", @"9", @"4", @"5", @"6", @"1", @"2", @"3", @"0", @"sin", @"cos", @"tan", @"√", @"sinh", @"cosh", @"tanh", @"arcsin", @"arccos", @"arctan", @"ln"] containsObject:input]) {
                return YES;
            }else {
                return NO;
            }
        }
    }
    return YES;
}

//获取表达式末位数字
- (NSArray *)getNumberWithString:(NSString *)old {
    NSMutableArray * numArr = [@[] mutableCopy];
    for (int i = 0; i < old.length; i++) {
        char c = [old characterAtIndex:i];
        NSString *iStr = [NSString stringWithFormat:@"%c", c];
        if ([@[@"7", @"8", @"9", @"4", @"5", @"6", @"1", @"2", @"3", @"0", @"."] containsObject:iStr]) {
            [numArr addObject:iStr];
        }else {
            [numArr removeAllObjects];
        }
    }
    return numArr;
}


@end
