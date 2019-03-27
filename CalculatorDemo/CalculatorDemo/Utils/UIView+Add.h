//
//  UIView+Add.h
//  CalculatorDemo
//
//  Created by zzcn77 on 2019/2/25.
//  Copyright © 2019 zzcn77. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Add)
- (id) initWithParent:(UIView *)parent;
+ (id) viewWithParent:(UIView *)parent;
-(void)removeAllSubViews;



// Position of the top-left corner in superview's coordinates
@property CGPoint position;
@property CGFloat x;
@property CGFloat y;
@property CGFloat top;
@property CGFloat bottom;
@property CGFloat left;
@property CGFloat right;


// makes hiding more logical
@property BOOL    visible;


// Setting size keeps the position (top-left corner) constant
@property CGSize size;
@property CGFloat width;
@property CGFloat height;

@end

@interface UIImageView (MFAdditions)

- (void) setImageWithName:(NSString *)name;
@end

NS_ASSUME_NONNULL_END
