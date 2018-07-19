//
//  CustomScrollView.h
//  My
//
//  Created by mac on 2018/6/11.
//  Copyright © 2018年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomScrollView;
@protocol  CustomScrollViewDelegate <NSObject>
@optional
//点击图片回调方法
- (void)touchImageView:(CustomScrollView *)customView indexOfClickImageBtn:(NSInteger)imageBtnIndex;
@end

@interface CustomScrollView : UIView
//图片数组
@property (copy, nonatomic) NSArray *imageArray;
//pageControl的颜色和数量
@property (strong, nonatomic) UIColor *currentPageColor;
@property (strong, nonatomic) UIColor *pageColor;

//滚动方向
@property (assign, nonatomic, getter=isScrollDorectionPortrait) BOOL isScrollDorectionPortrait;

@property (weak, nonatomic) id <CustomScrollViewDelegate>delegate;




@end
