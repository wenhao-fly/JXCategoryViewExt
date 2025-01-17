//
//  JXCategoryImageCell.m
//  JXCategoryView
//
//  Created by jiaxin on 2018/8/8.
//  Copyright © 2018年 jiaxin. All rights reserved.
//

#import "JXCategoryTitleImageCell.h"
#import "JXCategoryTitleImageCellModel.h"

@interface JXCategoryTitleImageCell()
@property (nonatomic, strong) id currentImageInfo;
@property (nonatomic, strong) NSString *currentImageName;
@property (nonatomic, strong) NSURL *currentImageURL;
@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, strong) NSLayoutConstraint *imageViewWidthConstraint;
@property (nonatomic, strong) NSLayoutConstraint *imageViewHeightConstraint;
@end

@implementation JXCategoryTitleImageCell

- (void)prepareForReuse {
    [super prepareForReuse];

    self.currentImageInfo = nil;
    self.currentImageName = nil;
    self.currentImageURL = nil;
    
    self.badgeLabel.text = nil;
}

- (void)initializeViews {
    [super initializeViews];

    [self.titleLabel removeFromSuperview];

    [self initialImageViewWithClass:UIImageView.class];

    _stackView = [[UIStackView alloc] init];
    self.stackView.alignment = UIStackViewAlignmentCenter;
    [self.contentView addSubview:self.stackView];
    self.stackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.stackView.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor].active = YES;
    [self.stackView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor].active = YES;
    
    self.badgeLabel = [[UILabel alloc] init];
    self.badgeLabel.textAlignment = NSTextAlignmentCenter;
    self.badgeLabel.layer.masksToBounds = YES;
    self.badgeLabel.layer.cornerRadius = 6.5;
    self.badgeLabel.font = [UIFont systemFontOfSize:9];
    [self.contentView addSubview:self.badgeLabel];
}

- (void)initialImageViewWithClass:(Class)cls {
    _imageView = [[cls alloc] init];
    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageViewWidthConstraint = [self.imageView.widthAnchor constraintEqualToConstant:0];
    self.imageViewWidthConstraint.active = YES;
    self.imageViewHeightConstraint = [self.imageView.heightAnchor constraintEqualToConstant:0];
    self.imageViewHeightConstraint.active = YES;
}

- (void)reloadData:(JXCategoryBaseCellModel *)cellModel {
    [super reloadData:cellModel];

    JXCategoryTitleImageCellModel *myCellModel = (JXCategoryTitleImageCellModel *)cellModel;
    if (myCellModel.imageViewClass) {
        [self initialImageViewWithClass:myCellModel.imageViewClass];
    }
    
    self.titleLabel.hidden = NO;
    self.imageView.hidden = NO;
    [self.stackView removeArrangedSubview:self.titleLabel];
    [self.stackView removeArrangedSubview:self.imageView];
    CGSize imageSize = myCellModel.imageSize;
    self.imageViewWidthConstraint.constant = imageSize.width;
    self.imageViewHeightConstraint.constant = imageSize.height;
    self.stackView.spacing = myCellModel.titleImageSpacing;
    
    switch (myCellModel.imageType) {
        case JXCategoryTitleImageType_TopImage: {
            self.stackView.axis = UILayoutConstraintAxisVertical;
            [self.stackView addArrangedSubview:self.imageView];
            [self.stackView addArrangedSubview:self.titleLabel];
            break;
        }
        case JXCategoryTitleImageType_LeftImage: {
            self.stackView.axis = UILayoutConstraintAxisHorizontal;
            [self.stackView addArrangedSubview:self.imageView];
            [self.stackView addArrangedSubview:self.titleLabel];
            break;
        }
        case JXCategoryTitleImageType_BottomImage: {
            self.stackView.axis = UILayoutConstraintAxisVertical;
            [self.stackView addArrangedSubview:self.titleLabel];
            [self.stackView addArrangedSubview:self.imageView];
            break;
        }
        case JXCategoryTitleImageType_RightImage: {
            self.stackView.axis = UILayoutConstraintAxisHorizontal;
            [self.stackView addArrangedSubview:self.titleLabel];
            [self.stackView addArrangedSubview:self.imageView];
            break;
        }
        case JXCategoryTitleImageType_OnlyImage: {
            self.titleLabel.hidden = YES;
            [self.stackView addArrangedSubview:self.imageView];
            break;
        }
        case JXCategoryTitleImageType_OnlyTitle: {
            self.imageView.hidden = YES;
            [self.stackView addArrangedSubview:self.titleLabel];
            break;
        }
    }

    //因为`- (void)reloadData:(JXCategoryBaseCellModel *)cellModel`方法会回调多次，尤其是左右滚动的时候会调用无数次，如果每次都触发图片加载，会非常消耗性能。所以只会在图片发生了变化的时候，才进行图片加载。
    if (myCellModel.loadImageBlock != nil) {
        id currentImageInfo = myCellModel.imageInfo;
        if (myCellModel.isSelected) {
            currentImageInfo = myCellModel.selectedImageInfo;
        }
        if (currentImageInfo && [currentImageInfo isKindOfClass:[NSString class]] && ![currentImageInfo isEqualToString:self.currentImageInfo]) {
            self.currentImageInfo = currentImageInfo;
            myCellModel.loadImageBlock(self.imageView, currentImageInfo);
        }else if (currentImageInfo && currentImageInfo != self.currentImageInfo) {
            self.currentImageInfo = currentImageInfo;
            myCellModel.loadImageBlock(self.imageView, currentImageInfo);
        }
    }else {
        NSString *currentImageName;
        NSURL *currentImageURL;
        if (myCellModel.imageName) {
            currentImageName = myCellModel.imageName;
        } else if (myCellModel.imageURL) {
            currentImageURL = myCellModel.imageURL;
        }
        if (myCellModel.isSelected) {
            if (myCellModel.selectedImageName) {
                currentImageName = myCellModel.selectedImageName;
            } else if (myCellModel.selectedImageURL) {
                currentImageURL = myCellModel.selectedImageURL;
            }
        }
        if (currentImageName.length > 0 && ![currentImageName isEqualToString:self.currentImageName]) {
            self.currentImageName = currentImageName;
            self.imageView.image = [UIImage imageNamed:currentImageName];
        } else if (currentImageURL && ![currentImageURL.absoluteString isEqualToString:self.currentImageURL.absoluteString]) {
            self.currentImageURL = currentImageURL;
            if (myCellModel.loadImageCallback) {
                myCellModel.loadImageCallback(self.imageView, currentImageURL);
            }
        }
    }
    
    if (myCellModel.isImageZoomEnabled) {
        self.imageView.transform = CGAffineTransformMakeScale(myCellModel.imageZoomScale, myCellModel.imageZoomScale);
    } else {
        self.imageView.transform = CGAffineTransformIdentity;
    }
    
    if(myCellModel.badgeContent.length > 0) {
        self.badgeLabel.textColor = myCellModel.badgeColor;
        self.badgeLabel.backgroundColor = myCellModel.badgeBgColor;
        self.badgeLabel.text = myCellModel.badgeContent;
        CGFloat width =  [self widthWithFont:[UIFont systemFontOfSize:9] constrainedToHeight:13 withStr:myCellModel.badgeContent];
        self.badgeLabel.frame = CGRectMake(cellModel.cellWidth - 5 , 2, width + 8, 13);
        self.badgeLabel.hidden = false;
    }else {
        self.badgeLabel.hidden = true;
    }
    
    
}

- (CGFloat)widthWithFont:(UIFont *)font constrainedToHeight:(CGFloat)height withStr:(NSString *)str
{
    UIFont *textFont = font ? font : [UIFont systemFontOfSize:[UIFont systemFontSize]];
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName: textFont,
                                 NSParagraphStyleAttributeName: paragraph};
    CGSize textSize = [str boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height)
                                         options:(NSStringDrawingUsesLineFragmentOrigin |
                                                  NSStringDrawingTruncatesLastVisibleLine)
                                      attributes:attributes
                                         context:nil].size;
    return ceil(textSize.width);
}

@end
