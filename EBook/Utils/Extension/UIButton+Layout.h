//
//  UIButton+Layout.h
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, UIButtonLayoutType) {
    UIButtonLayoutImageLeft,
    UIButtonLayoutImageRight,
    UIButtonLayoutImageTop,
    UIButtonLayoutImageBottom,
};

@interface UIButton (Layout)

- (void)setImageLayout:(UIButtonLayoutType)type space:(CGFloat)space;

/**
 titleLabel是否自适应宽度
 */
@property (assign, nonatomic) BOOL isSizeToFit;

@end

NS_ASSUME_NONNULL_END
