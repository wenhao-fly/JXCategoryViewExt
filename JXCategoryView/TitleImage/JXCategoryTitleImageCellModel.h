//
//  JXCategoryTitleImageCellModel.h
//  JXCategoryView
//
//  Created by jiaxin on 2018/8/8.
//  Copyright © 2018年 jiaxin. All rights reserved.
//

#import "JXCategoryTitleCellModel.h"

typedef NS_ENUM(NSUInteger, JXCategoryTitleImageType) {
    JXCategoryTitleImageType_TopImage = 0,
    JXCategoryTitleImageType_LeftImage,
    JXCategoryTitleImageType_BottomImage,
    JXCategoryTitleImageType_RightImage,
    JXCategoryTitleImageType_OnlyImage,
    JXCategoryTitleImageType_OnlyTitle,
};

@interface JXCategoryTitleImageCellModel : JXCategoryTitleCellModel

//add 添加了标签badge
@property (copy, nonatomic)NSString *badgeContent; //徽标
@property (strong, nonatomic)UIColor *badgeColor;
@property (strong, nonatomic)UIColor *badgeBgColor;

// 自定义imageView类
@property (nonatomic, strong) Class imageViewClass;

@property (nonatomic, assign) JXCategoryTitleImageType imageType;

@property (nonatomic, strong) id imageInfo;
@property (nonatomic, strong) id selectedImageInfo;
@property (nonatomic, copy) void(^loadImageBlock)(UIImageView *imageView, id info);

@property (nonatomic, copy) void(^loadImageCallback)(UIImageView *imageView, NSURL *imageURL);

@property (nonatomic, assign) CGSize imageSize;     //默认CGSizeMake(20, 20)

@property (nonatomic, assign) CGFloat titleImageSpacing;    //titleLabel和ImageView的间距，默认5

@property (nonatomic, assign, getter=isImageZoomEnabled) BOOL imageZoomEnabled;

@property (nonatomic, assign) CGFloat imageZoomScale;

@property (nonatomic, copy) NSString *imageName;    //加载bundle内的图片

@property (nonatomic, strong) NSURL *imageURL;      //图片URL

@property (nonatomic, copy) NSString *selectedImageName;

@property (nonatomic, strong) NSURL *selectedImageURL;

@end
