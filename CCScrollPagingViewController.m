//
//  ViewController.m
//  网易新闻App
//
//  Created by demoncraz on 2017/1/24.
//  Copyright © 2017年 demoncraz. All rights reserved.
//

#import "CCScrollPagingViewController.h"


#define ScreenW [UIScreen mainScreen].bounds.size.width
#define ScreenH [UIScreen mainScreen].bounds.size.height
#define NavigationBar_H 64
//设置顶部标题栏的高度
#define TopViewH 35
//设置顶部最多展示几个按钮
#define TopButtonCount 5
#define TopButtonW 1.0 * ScreenW / TopButtonCount
//设置标题默认字体尺寸
#define DefaultFontSize 14
//设置标题栏的背景颜色
#define DefaultTitleViewColor [UIColor redColor];
//设置正常状态下的按钮颜色
#define DefaultButtonColorNormal ColorWithRBG(255, 255, 255, 1)
//设置选中状态下的按钮颜色
#define DefaultButtonColorSelected ColorWithRBG(0, 0, 0, 1)

//设置选中后放大的比例
static CGFloat const defaultZoomScale = 1.1;
//设置滚动时候是否有颜色渐变
static BOOL const isGradientEnabled = YES;

@interface CCScrollPagingViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *topScrollView;
@property (nonatomic, strong) UIScrollView *contentScrollView;
@property (nonatomic, strong) UIButton *selButton;
@property (nonatomic, strong) NSMutableArray<UIButton *> *topButtons;


@end

@implementation CCScrollPagingViewController

#pragma mark - lazy loading

-(NSMutableArray<UIButton *> *)topButtons {
    if (_topButtons == nil) {
        _topButtons = [NSMutableArray array];
    }
    return _topButtons;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupTitles];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
     //取消默认的inset
    self.automaticallyAdjustsScrollViewInsets = NO;
//    self.navigationItem.title = @"网易新闻";
    //1.set up top view
    [self setupTopLineView];
    //2.set up content view
    [self setupContentView];
    
}


#pragma mark - UIScrollViewDelegate


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    NSInteger index = scrollView.contentOffset.x / ScreenW;
    
    UIButton *button = self.topButtons[index];
    
    [self selectButon:button];
    
    [self setupOneViewController:index];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    
    NSInteger index = scrollView.contentOffset.x / ScreenW;
    UIButton *currentButton = self.topButtons[index];
    CGFloat relativeOffsetX = scrollView.contentOffset.x - ScreenW * index;
    CGFloat radius = fabs(1.0 * relativeOffsetX / ScreenW);
    //当前按钮颜色渐变
    if (isGradientEnabled) {
        UIColor *currentColor = [self getCurrentColorWithColor:DefaultButtonColorSelected anotherColor:DefaultButtonColorNormal gradientRadius:radius];
        
        [currentButton setTitleColor:currentColor forState:UIControlStateNormal];
        [currentButton setTitleColor:currentColor forState:UIControlStateSelected];
    }
    //当前按钮字体大小渐变


    CGFloat scale = defaultZoomScale - (defaultZoomScale - 1) * radius;
    currentButton.transform = CGAffineTransformMakeScale(scale, scale);
    
    NSInteger nextIndex = relativeOffsetX > 0 ? index + 1 : index - 1;
    
    if (nextIndex < 0 || nextIndex > self.topButtons.count - 1) {
        return;
    }
    
    UIButton *nextButton = self.topButtons[nextIndex];
    //下一个按钮颜色渐变
    if (isGradientEnabled) {
        UIColor *currentColor = [self getCurrentColorWithColor:DefaultButtonColorNormal anotherColor:DefaultButtonColorSelected gradientRadius:radius];
        [nextButton setTitleColor:currentColor forState:UIControlStateNormal];
        [nextButton setTitleColor:currentColor forState:UIControlStateSelected];
    }

    //下一个按钮字体大小渐变

    CGFloat nextScale = 1 + (defaultZoomScale - 1) * radius;
    nextButton.transform = CGAffineTransformMakeScale(nextScale, nextScale);
    
}




- (UIColor *)getCurrentColorWithColor:(UIColor *)color1 anotherColor:(UIColor *)color2 gradientRadius:(CGFloat)radius{
    const CGFloat *components1 = CGColorGetComponents(color1.CGColor);
    CGFloat red1 = components1[0];
    CGFloat green1 = components1[1];
    CGFloat blue1 = components1[2];
    
    const CGFloat *components2 = CGColorGetComponents(color2.CGColor);
    CGFloat red2 = components2[0];
    CGFloat green2 = components2[1];
    CGFloat blue2 = components2[2];
    
    CGFloat currentRed = red1 + (red2 - red1) * radius;
    CGFloat currentGreen = green1 + (green2 - green1) * radius;
    CGFloat currentBlue = blue1 + (blue2 - blue1) * radius;
    return [UIColor colorWithRed:currentRed green:currentGreen blue:currentBlue alpha:1];
    
}

#pragma mark - 设置标题及按钮
- (void)setupTitles {
    NSInteger count = self.childViewControllers.count;
    //设置顶部按钮
    
    for (int i = 0; i < count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat buttonX = i * TopButtonW;
        button.frame = CGRectMake(buttonX, 0, TopButtonW, TopViewH);
        button.tag = i;
        
        //取出每个button对应的VC的标题
        UIViewController *vc = self.childViewControllers[i];
        
        [button setTitle:vc.title forState:UIControlStateNormal];
        [button setTitleColor:DefaultButtonColorNormal forState:UIControlStateNormal];
        [button setTitleColor:DefaultButtonColorSelected forState:UIControlStateSelected];
        button.titleLabel.font = [UIFont systemFontOfSize:DefaultFontSize];
        [button addTarget:self action:@selector(topButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        //添加到按钮数组中
        [self.topButtons addObject:button];
        
        //默认选中第一个按钮
        if (i == 0) {
            [self topButtonClick:button];
        }
        
        [self.topScrollView addSubview:button];
    }
    
    self.topScrollView.contentSize = CGSizeMake(count * TopButtonW, TopViewH);
    self.topScrollView.showsHorizontalScrollIndicator = NO;
    self.topScrollView.bounces = NO;
    
    
    self.contentScrollView.contentSize = CGSizeMake(self.childViewControllers.count * ScreenW, self.contentScrollView.frame.size.height);
    
}


#pragma mark - 按钮点击事件
- (void)topButtonClick:(UIButton *)button {
    
    NSInteger i = button.tag;
    
    [self selectButon:button];
    
    CGFloat x = i * ScreenW;
    self.contentScrollView.contentOffset = CGPointMake(x, 0);
    
    //把对应的vc添加上去
    [self setupOneViewController:i];

}


#pragma mark - 选中顶部栏中的按钮
- (void)selectButon:(UIButton *)button {
    //取消原来的选中
    self.selButton.selected = NO;
    self.selButton.transform = CGAffineTransformIdentity;
    //选中点击的按钮
    button.selected = YES;
    button.transform = CGAffineTransformMakeScale(defaultZoomScale, defaultZoomScale);
    
    self.selButton = button;
    
    //滚动结束后如果选中的不是前两个按钮或者最后两个按钮，就将改按钮在顶部栏居中
    [self setButtonToCenter:button];
}

#pragma mark - 标题居中
- (void)setButtonToCenter:(UIButton *)button {
    //滚动结束后如果选中的不是前两个按钮或者最后两个按钮，就将改按钮在顶部栏居中
    
    CGFloat offsetX = button.center.x - ScreenW * 0.5;
    
    if (offsetX < 0) {
        offsetX = 0;
    }
    CGFloat maxOffsetX = self.topScrollView.contentSize.width - ScreenW;
    if (offsetX > maxOffsetX) {
        offsetX = maxOffsetX;
    }
    [self.topScrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    
}

#pragma mark - 设置顶部栏
- (void)setupTopLineView {
    
    UIScrollView *topScrollView = [[UIScrollView alloc] init];
    CGFloat topScrollView_y = 0;
    
    topScrollView.backgroundColor = DefaultTitleViewColor;
    topScrollView.frame = CGRectMake(0, topScrollView_y, ScreenW, TopViewH);
    [self.view addSubview:topScrollView];
    self.topScrollView = topScrollView;
    
    
}

#pragma mark - 设置内容试图
- (void)setupContentView {
    UIScrollView *contentScrollView = [[UIScrollView alloc] init];
    contentScrollView.frame = CGRectMake(0, CGRectGetMaxY(self.topScrollView.frame), ScreenW, ScreenH - NavigationBar_H - self.topScrollView.frame.size.height);
    contentScrollView.backgroundColor = [UIColor blueColor];
    
    [self.view addSubview:contentScrollView];
    self.contentScrollView = contentScrollView;
    self.contentScrollView.showsHorizontalScrollIndicator = NO;
    self.contentScrollView.pagingEnabled = YES;
    self.contentScrollView.delegate = self;
}

#pragma mark - 设置一个子控制器
- (void)setupOneViewController:(NSInteger)index {
    UIViewController *vc = self.childViewControllers[index];
    if (vc.view.superview) {//如果已经添加了，就不用再次添加
        return;
    }
    vc.view.frame = CGRectMake(index * ScreenW, 0, ScreenW, self.contentScrollView.frame.size.height);
    [self.contentScrollView addSubview:vc.view];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
