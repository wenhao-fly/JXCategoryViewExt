//
//  ViewController.m
//  Example
//
//  Created by gaokun on 2021/1/14.
//

#import "ViewController.h"
#import <JXCategoryViewExt/JXCategoryView.h>
#import "ListViewController.h"
#import <SDWebImage/SDWebImage.h>

#define HasAFNetworking (__has_include(<AFNetworking/AFNetworking.h>) || __has_include("AFNetworking.h"))
// 颜色
#define GKColorRGBA(r, g, b, a) [UIColor colorWithRed:(r / 255.0) green:(g / 255.0) blue:(b / 255.0) alpha:a]
#define GKColorRGB(r, g, b)     GKColorRGBA(r, g, b, 1.0)

@interface ViewController ()<JXCategoryListContainerViewDelegate, JXCategoryViewDelegate, JXCategoryTitleViewDataSource>

@property (nonatomic, strong) JXCategoryTitleView *titleView;

@property (nonatomic, strong) JXCategoryDotZoomView   *dotView;

@property (nonatomic, strong) JXCategorySubTitleImageView *subTitleView;

@property (nonatomic, strong) JXCategoryBadgeView *badgeView;

@property (nonatomic, strong) JXCategoryListContainerView *containerView;

@property (nonatomic, strong)JXCategoryTitleImageView *categoryView;

@property (nonatomic, strong)JXCategoryTitleImageView *categoryViewTop;

@property (nonatomic, strong)JXCategoryIndicatorLineView *lineViewTop;

@property (nonatomic, strong) NSArray *titles;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    self.categoryView.frame = CGRectMake(0, 100, self.view.bounds.size.width, 40);
    self.dotView.frame = CGRectMake(0, 140, self.view.bounds.size.width, 40);
    self.subTitleView.frame = CGRectMake(0, 180, self.view.bounds.size.width, 54);
    self.badgeView.frame = CGRectMake(0, 234, self.view.bounds.size.width, 40);
    self.categoryViewTop.frame = CGRectMake(0, 280, self.view.bounds.size.width, 40);
    self.containerView.frame = CGRectMake(0, 320, self.view.bounds.size.width, self.view.bounds.size.height - 320);
    
    [self.view addSubview:self.categoryView];
    [self.view addSubview:self.dotView];
    [self.view addSubview:self.subTitleView];
    [self.view addSubview:self.badgeView];
    [self.view addSubview:self.categoryViewTop];
    [self.view addSubview:self.containerView];
}

#pragma mark - JXCategoryTitleViewDataSource
- (NSInteger)numberOfTitleView:(JXCategoryTitleView *)titleView {
    return self.titles.count;
}

- (NSString *)titleView:(JXCategoryTitleView *)titleView titleForIndex:(NSInteger)index {
    return self.titles[index];
}

#pragma mark - JXCategoryListContainerViewDelegate
- (NSInteger)numberOfListsInlistContainerView:(JXCategoryListContainerView *)listContainerView {
    return self.titles.count;
}

- (id<JXCategoryListContentViewDelegate>)listContainerView:(JXCategoryListContainerView *)listContainerView initListForIndex:(NSInteger)index {
    ListViewController *listVC = [ListViewController new];
    return listVC;
}

#pragma mark - JXCategoryViewDelegate
- (void)categoryView:(JXCategoryBaseView *)categoryView didSelectedItemAtIndex:(NSInteger)index {
    NSLog(@"%zd", index);
}

#pragma mark - Private
- (UIImage *)changeImageWithImage:(UIImage *)image color:(UIColor *)color {
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    CGContextClipToMask(context, rect, image.CGImage);
    [color setFill];
    CGContextFillRect(context, rect);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - 懒加载
- (JXCategoryTitleView *)titleView {
    if (!_titleView) {
        _titleView = [[JXCategoryTitleView alloc] init];
//        _titleView.cellBackgroundSelectedColor = UIColor.grayColor;
//        _titleView.cellBackgroundUnselectedColor = UIColor.blueColor;
//        _titleView.cellBackgroundColorGradientEnabled = YES;
        
//        _titleView.titleFont = [UIFont systemFontOfSize:15];
//        _titleView.titleSelectedFont = [UIFont boldSystemFontOfSize:18];
//        _titleView.titleLabelZoomEnabled = YES;
        
        _titleView.titleFont = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
        _titleView.titleSelectedFont = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
        _titleView.titleLabelZoomEnabled = YES;
        _titleView.titleLabelZoomScale = 1.25;
        _titleView.titleLabelStrokeWidthEnabled = YES;
        _titleView.titleLabelVerticalOffset = -10;
        _titleView.backgroundColor = UIColor.grayColor;
        
        _titleView.titleDataSource = self;
//        _titleView.titles = @[@"你的", @"我的", @"他的", @"你的", @"我的", @"他的", @"你的", @"我的", @"他的"];
//        _titleView.selectItemOnScrollHalf = YES;
        _titleView.delegate = self;
        _titleView.selectedAnimationEnabled = YES;
        
//        JXCategoryIndicatorBackgroundView *indicator = [JXCategoryIndicatorBackgroundView new];
//        indicator.indicatorCornerRadius = 4;
//        indicator.indicatorWidthIncrement = 20;
//        _titleView.indicators = @[indicator];
        
        _titleView.listContainer = self.containerView;
    }
    return _titleView;
}

- (JXCategorySubTitleImageView *)subTitleView {
    if (!_subTitleView) {
        _subTitleView = [[JXCategorySubTitleImageView alloc] init];
        _subTitleView.titles = @[@"热点", @"种草", @"本地", @"放映厅", @"直播"];
        _subTitleView.subTitles = @[@"热点资讯", @"潮流好物", @"同城关注", @"宅家必看", @"大V在线"];
        _subTitleView.titleFont = [UIFont boldSystemFontOfSize:15];
        _subTitleView.titleSelectedFont = [UIFont boldSystemFontOfSize:15];
        _subTitleView.titleColor = UIColor.blackColor;
        _subTitleView.titleSelectedColor = GKColorRGB(243, 136, 68);
        _subTitleView.titleLabelVerticalOffset = -10;
        _subTitleView.subTitleFont = [UIFont systemFontOfSize:11];
        _subTitleView.subTitleSelectedFont = [UIFont systemFontOfSize:11];
        _subTitleView.subTitleColor = [UIColor grayColor];
        _subTitleView.subTitleSelectedColor = [UIColor whiteColor];
        _subTitleView.subTitleWithTitlePositionMargin = 3;
        _subTitleView.cellSpacing = 0;
        _subTitleView.cellWidthIncrement = 16;
//        _subTitleView.imageViewClass = [SDAnimatedImageView class];
        _subTitleView.imageSize = CGSizeMake(12, 12);
        _subTitleView.imageTypes = @[@(JXCategorySubTitleImageType_None), @(JXCategorySubTitleImageType_Left), @(JXCategorySubTitleImageType_None), @(JXCategorySubTitleImageType_Left), @(JXCategorySubTitleImageType_Left)];
        _subTitleView.imageInfoArray = @[@"", @"zhongcao", @"", @"fangying", @"gif"];
        _subTitleView.selectedImageInfoArray = @[@"", @"zhongcao", @"", @"fangying", @"gif"];
        _subTitleView.subTitleInCenterX = NO;
        
        __weak __typeof(self) weakSelf = self;
        _subTitleView.loadImageBlock = ^(UIImageView *imageView, id info) {
            __strong __typeof(weakSelf) self = weakSelf;
            NSString *name = (NSString *)info;
            if (name.length > 0) {
                if ([name isEqualToString:@"gif"]) {
//                    [imageView sd_setImageWithURL:[NSURL URLWithString:@"https://upload-images.jianshu.io/upload_images/1598505-b6817cad3c9fa37c.gif?imageMogr2/auto-orient/strip"]];
                    NSMutableArray *images = [NSMutableArray new];
                    for (NSInteger i = 0; i < 4; i++) {
                        NSString *imageName = [NSString stringWithFormat:@"cm2_list_icn_loading%zd", i + 1];

                        UIImage *img = [self changeImageWithImage:[UIImage imageNamed:imageName] color:UIColor.redColor];

                        [images addObject:img];
                    }

                    for (NSInteger i = 4; i > 0; i--) {
                        NSString *imageName = [NSString stringWithFormat:@"cm2_list_icn_loading%zd", i];

                        UIImage *img = [self changeImageWithImage:[UIImage imageNamed:imageName] color:UIColor.redColor];

                        [images addObject:img];
                    }

                    imageView.animationImages = images;
                    imageView.animationDuration = 0.75;
                    [imageView startAnimating];
                }else {
                    imageView.image = [UIImage imageNamed:name];
                }
            }
        };
        _subTitleView.ignoreImageWidth = YES;
//        _subTitleView.indicators = @[self.lineView];
        _subTitleView.listContainer = self.containerView;
        
        JXCategoryIndicatorLineView *lineView = [[JXCategoryIndicatorLineView alloc] init];
        lineView.indicatorHeight = 16;
        lineView.verticalMargin = 10;
        lineView.indicatorWidthIncrement = 0;
        lineView.lineScrollOffsetX = _subTitleView.titleImageSpacing + _subTitleView.imageSize.width;
        lineView.indicatorColor = GKColorRGB(243, 136, 68);;
        lineView.lineStyle = JXCategoryIndicatorLineStyle_Lengthen;
        _subTitleView.indicators = @[lineView];
    }
    return _subTitleView;
}

- (JXCategoryDotZoomView *)dotView {
    if (!_dotView) {
        _dotView = [[JXCategoryDotZoomView alloc] init];
        _dotView.titles = @[@"你好", @"我好", @"他好", @"你好", @"我好"];
        
        _dotView.titleFont = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
        _dotView.titleSelectedFont = [UIFont fontWithName:@"PingFangSC-Medium" size:20];
        _dotView.titleLabelZoomEnabled = YES;
        _dotView.titleLabelZoomScale = 1.25;
        _dotView.dotOffset = CGPointMake(3, 3);
        _dotView.dotStyle = JXCategoryDotStyle_Hollow;
        _dotView.hollowWH = 6.0f;
        
        _dotView.listContainer = self.containerView;
    }
    return _dotView;
}

- (JXCategoryBadgeView *)badgeView {
    if (!_badgeView) {
        _badgeView = [[JXCategoryBadgeView alloc] init];
        _badgeView.titles = @[@"你好", @"我好", @"他好", @"大家好"];
        _badgeView.badgeTypes = @[@(JXCategoryBadgeType_Number), @(JXCategoryBadgeType_Text), @(JXCategoryBadgeType_Dot), @(JXCategoryBadgeType_Text)];
        _badgeView.badges = @[@"100", @"直播", @"1", @"0"];
        _badgeView.shouldMakeRoundWhenSingleNumber = YES;
        
        _badgeView.badgeStringFormatterBlock = ^NSString * _Nonnull(JXCategoryBadgeType badgeType, id  _Nonnull badge) {
            if (badgeType == JXCategoryBadgeType_Number) {
                NSInteger count = [badge integerValue];
                return count > 99 ? @"99+" : badge;
            }
            return badge;
        };
        
        _badgeView.badgeStyleBlock = ^(NSInteger index, UILabel * _Nonnull badgeLabel) {
            if (index == 1) {
                badgeLabel.backgroundColor = UIColor.blackColor;
                badgeLabel.textColor = UIColor.brownColor;
            }else if (index == 2) {
                badgeLabel.backgroundColor = UIColor.blueColor;
            }
        };
        
        _badgeView.listContainer = self.containerView;
    }
    return _badgeView;
}

- (JXCategoryListContainerView *)containerView {
    if (!_containerView) {
        _containerView = [[JXCategoryListContainerView alloc] initWithType:JXCategoryListContainerType_CollectionView delegate:self];
    }
    return _containerView;
}

- (JXCategoryTitleImageView *)categoryView {
    if (!_categoryView) {
        _categoryView = [JXCategoryTitleImageView new];
        _categoryView.delegate              = self;
        _categoryView.backgroundColor       = [UIColor clearColor];
        _categoryView.titleFont             = [UIFont systemFontOfSize:16.0f];
        _categoryView.titleSelectedFont     = [UIFont boldSystemFontOfSize:20.0f];
        _categoryView.imageSize             = CGSizeMake(46.0f, 28.0f);
        _categoryView.imageZoomEnabled      = YES;  // 图片缩放
        _categoryView.imageZoomScale        = 1.3;  // 图片缩放程度
        _categoryView.titleLabelZoomEnabled = YES;  // 标题缩放
        _categoryView.titleLabelZoomScale   = 1.3;  // 标题缩放程度
        _categoryView.contentScrollViewClickTransitionAnimationEnabled = NO;
        _categoryView.titleLabelAnchorPointStyle = JXCategoryTitleLabelAnchorPointStyleCenter;
        _categoryView.cellSpacing = 30;
        _categoryView.contentEdgeInsetLeft = 15;
        _categoryView.listContainer = self.containerView;
        
        _categoryView.titles = @[@"你好", @"我好", @"他好", @"大家好"];
        _categoryView.imageURLs = nil;
        _categoryView.selectedImageURLs = nil;
        _categoryView.imageTypes = nil;
        _categoryView.badgeContents = @[@"你好", @"", @"", @"大家好"];
        
        // 刷新内容
        [self.containerView reloadData];
    }
    return _categoryView;
}

- (NSArray *)titles {
    return @[@"你的", @"我的", @"他的", @"你的", @"我的"];
}


- (JXCategoryTitleImageView *)categoryViewTop {
    if (!_categoryViewTop) {
        _categoryViewTop = [JXCategoryTitleImageView new];
        _categoryViewTop.delegate              = self;
        _categoryViewTop.backgroundColor       = [UIColor clearColor];
        _categoryViewTop.titleFont             = [UIFont systemFontOfSize:16.0f];
        _categoryViewTop.titleSelectedFont     = [UIFont systemFontOfSize:20.0f];
        _categoryViewTop.titleColor            = UIColor.blackColor;
        _categoryViewTop.titleSelectedColor    = UIColor.blueColor;
        _categoryViewTop.imageSize             = CGSizeMake(0.0f, 28.0f);
        _categoryViewTop.imageZoomEnabled      = YES;  // 图片缩放
        _categoryViewTop.imageZoomScale        = 1.3;  // 图片缩放程度
        _categoryViewTop.titleLabelZoomEnabled = YES;  // 标题缩放 为YES时titleSelectedFont失效，以titleFont为准。
        _categoryViewTop.titleLabelZoomScale   = 1.3;  // 标题缩放程度
        _categoryViewTop.contentScrollViewClickTransitionAnimationEnabled = NO;
        _categoryViewTop.titleLabelAnchorPointStyle = JXCategoryTitleLabelAnchorPointStyleCenter;
        _categoryViewTop.cellSpacing = 10;
        _categoryViewTop.contentEdgeInsetLeft = 15;
        
        _categoryViewTop.titles = @[@"你好", @"我好", @"他好", @"大家好"];
        
        _categoryViewTop.indicators    = @[self.lineViewTop];
        
        _categoryViewTop.listContainer = self.containerView;
    }
    return _categoryViewTop;
}

- (JXCategoryIndicatorLineView *)lineViewTop {
    if (!_lineViewTop) {
        _lineViewTop = [JXCategoryIndicatorLineView new];
        _lineViewTop.indicatorWidth     = 20;
        _lineViewTop.indicatorHeight    = 4;
        _lineViewTop.indicatorColor     = UIColor.redColor;
        _lineViewTop.lineStyle          = JXCategoryIndicatorLineStyle_Lengthen;
    }
    return _lineViewTop;
}

@end
