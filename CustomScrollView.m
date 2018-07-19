//
//  CustomScrollView.m
//  My
//
//  Created by mac on 2018/6/11.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "CustomScrollView.h"



static const int imageBtnCount = 3;



@interface CustomScrollView() <UIScrollViewDelegate>
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (weak, nonatomic)  NSTimer *timer;

////是否竖向滚动
//@property (nonatomic, assign, getter=isScrollDorectionPortrait) BOOL scrollDorectionPortrait;

@end


@implementation CustomScrollView

- (void)setImageArray:(NSArray *)imageArray {
    _imageArray = imageArray;
    //pageControl的页数就是图片的个数
    self.pageControl.numberOfPages  = imageArray.count;
    //默认一开始显示的
    self.pageControl.currentPage = 0;
    //设置图片显示内容
    [self setContent];
    //设置定时器
    [self startTimer];
}


- (instancetype)initWithFrame:(CGRect)frame  {
    
    if (self = [super initWithFrame:frame]) {
        //创建滚动视图
        UIScrollView *scrollView = [[UIScrollView alloc]init];
        scrollView.delegate = self;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        //分页
        scrollView.pagingEnabled = YES;
        scrollView.bounces = YES;
        [self addSubview:scrollView];
        self.scrollView = scrollView;
        //添加点击事件
        for (int i = 0; i < imageBtnCount; i++) {
            UIButton *imageBtn = [[UIButton alloc]init];
            //将一个个点击事件添加到滚动视图上
            [scrollView addSubview:imageBtn];
        }
        //添加pageControl
        UIPageControl *pageControl = [[UIPageControl alloc]init];
        [self addSubview:pageControl];
        self.pageControl = pageControl;
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    //设置scrollView的frame
    self.scrollView.frame = self.bounds;
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    //设置contentSize，不同方向contentSize不一致
    if (self.isScrollDorectionPortrait) {
        self.scrollView.contentSize = CGSizeMake(width, height * imageBtnCount);
    }else {
        self.scrollView.contentSize = CGSizeMake(width  * imageBtnCount, height);
    }
    //设置三张图片的内容
    for (int i = 0; i < imageBtnCount; i ++ ) {
        UIButton *imageBtn = self.scrollView.subviews[i];
        [imageBtn addTarget:self action:@selector(imageClick:) forControlEvents:UIControlEventTouchUpInside];
        if (self.isScrollDorectionPortrait) {
            imageBtn.frame = CGRectMake(0, i * height, width, height);
        }else {
            imageBtn.frame = CGRectMake(i * width, 0, width , height);
        }
    }
    
    //设置contentOffSet,显示最中间的图片
    if (self.isScrollDorectionPortrait) {
        self.scrollView.contentOffset = CGPointMake(0, height);
    }else {
        self.scrollView.contentOffset = CGPointMake(width, 0);
    }
    
    //设置pageControl
    CGFloat pageW = 100;
    CGFloat pageH = 20;
    CGFloat pageX = width - pageW;
    CGFloat pageY = height - pageH;
    self.pageControl.frame = CGRectMake(pageX, pageY, pageW, pageH);
}

//设置pageControl的CurrentPageColor
- (void)setCurrentPageColor:(UIColor *)currentPageColor {
    _currentPageColor = currentPageColor;
    self.pageControl.currentPageIndicatorTintColor = currentPageColor;
}

//设置pageControl的pageColor
- (void)setPageColor:(UIColor *)pageColor {
    _pageColor = pageColor;
    self.pageControl.pageIndicatorTintColor = pageColor;
}

- (void)setContent {
    for (int i = 0; i < self.scrollView.subviews.count; i++) {
        UIButton *imageBtn = self.scrollView.subviews[i];
        NSInteger index = self.pageControl.currentPage;
        //第一个Button隐藏在当前显示的左侧，第三个隐藏在当前显示的右侧
        if (i == 0) {
            index --;
        }else if(i == 2) {
            index ++;
        }
        //当index为0时，再往右侧拖动，左侧显示第三张图
        if (index < 0) {
            index = self.pageControl.numberOfPages - 1;
        }else if (index == self.pageControl.numberOfPages) {
            index = 0;
        }
        
        imageBtn.tag = index;
        //根据索引为imageBtn设置图片
        [imageBtn setBackgroundImage:self.imageArray[index] forState:UIControlStateNormal];
        [imageBtn setBackgroundImage:self.imageArray[index] forState:UIControlStateHighlighted];

    }
    
}

- (void)updateContent {
    CGFloat width = self.bounds.size.width;
    CGFloat heigt = self.bounds.size.height;
    [self setContent];
    //唯一跟设置显示内容不同的就是重新设置偏移量，让它永远用中间的按钮显示图片,滑动之后就偷偷的把偏移位置设置回去，这样就实现了永远用中间的按钮显示图片
    if (self.isScrollDorectionPortrait) {
        self.scrollView.contentOffset = CGPointMake(0, heigt);
    }else {
        self.scrollView.contentOffset = CGPointMake(width, 0);
    }
}

#pragma mark --BtnAction
- (void)imageClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(touchImageView:indexOfClickImageBtn:)]) {
        [self.delegate touchImageView:self indexOfClickImageBtn:sender.tag];
    }
}

#pragma mark  --ScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //拖动的时候，哪张图片最靠中间，也就是偏移量最小，就滑到哪页
    //用来设置当前页
    NSInteger page = 0;
    //用来拿最小偏移量
    CGFloat minDistance = MAXFLOAT;
    //遍历三个imageView,看那个图片偏移最小，也就是最靠中间
    for (int i = 0; i < self.scrollView.subviews.count; i++) {
        UIButton *imageBtn = self.scrollView.subviews[i];
        CGFloat distance = 0;
        if (self.isScrollDorectionPortrait) {
            distance = ABS(imageBtn.frame.origin.y - scrollView.contentOffset.y);
        } else {
            distance = ABS(imageBtn.frame.origin.x - scrollView.contentOffset.x);
        }
        if (distance < minDistance) {
            minDistance = distance;
            page = imageBtn.tag;
        }
    }
    self.pageControl.currentPage = page;
}

//开始拖拽的时候停止计时器
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self stopTimer];
}

//结束拖拽的时候开始定时器
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self startTimer];
}

//scroll滚动动画结束的时候更新image内容
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self updateContent];
}

//结束拖拽的时候更新image内容
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self updateContent];
}

#pragma mark --StartNSTimer
- (void)startTimer {
    NSTimer  *timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(changeNextImage) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop]addTimer:timer forMode:NSRunLoopCommonModes];
    self.timer  = timer;
}

//停止计时器
- (void)stopTimer {
    //结束计时
    [self.timer invalidate];
    //计时器被系统强引用，必须手动释放
    self.timer = nil;
}

//通过改变contentOffset * 2换到下一张图片
- (void)changeNextImage {
    CGFloat height = self.bounds.size.height;
    CGFloat width = self.bounds.size.width;
    if (self.isScrollDorectionPortrait) {
        [self.scrollView setContentOffset:CGPointMake(0, 2 * height) animated:YES];
    } else {
        [self.scrollView setContentOffset:CGPointMake(2 * width, 0) animated:YES];
    }
}

@end
