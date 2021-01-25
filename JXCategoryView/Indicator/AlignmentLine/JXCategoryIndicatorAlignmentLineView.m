//
//  JXCategoryIndicatorAlignmentLineView.m
//  JXCategoryView
//
//  Created by jiaxin on 2019/7/20.
//  Copyright © 2019 jiaxin. All rights reserved.
//

#import "JXCategoryIndicatorAlignmentLineView.h"
#import "JXCategoryFactory.h"
#import "JXCategoryViewAnimator.h"

@interface JXCategoryIndicatorAlignmentLineView()
@property (nonatomic, strong) JXCategoryViewAnimator *animator;
@end

@implementation JXCategoryIndicatorAlignmentLineView

#pragma mark - Initialize

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _alignmentStyle = JXCategoryIndicatorAlignmentStyleCenter;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _alignmentStyle = JXCategoryIndicatorAlignmentStyleCenter;
    }
    return self;
}

#pragma mark - JXCategoryIndicatorProtocol

- (void)jx_refreshState:(JXCategoryIndicatorParamsModel *)model {
    self.backgroundColor = self.indicatorColor;
    self.layer.cornerRadius = [self indicatorCornerRadiusValue:model.selectedCellFrame];

    CGFloat selectedLineWidth = [self indicatorWidthValue:model.selectedCellFrame];
    CGFloat x = [self calculateXWithFrame:model.selectedCellFrame width:selectedLineWidth];
    CGFloat y = self.superview.bounds.size.height - [self indicatorHeightValue:model.selectedCellFrame] - self.verticalMargin;
    if (self.componentPosition == JXCategoryComponentPosition_Top) {
        y = self.verticalMargin;
    }
    self.frame = CGRectMake(x, y, selectedLineWidth, [self indicatorHeightValue:model.selectedCellFrame]);
}

- (void)jx_contentScrollViewDidScroll:(JXCategoryIndicatorParamsModel *)model {
    [self stopAnimator];
    
    CGRect rightCellFrame = model.rightCellFrame;
    CGRect leftCellFrame = model.leftCellFrame;
    CGFloat percent = model.percent;
    CGFloat targetWidth = [self indicatorWidthValue:leftCellFrame];
    
    CGFloat leftWidth = targetWidth;
    CGFloat rightWidth = [self indicatorWidthValue:rightCellFrame];
    CGFloat leftX = [self calculateXWithFrame:leftCellFrame width:leftWidth];
    CGFloat rightX = [self calculateXWithFrame:rightCellFrame width:rightWidth];
    
    CGFloat targetX = 0;
    if (self.lineStyle == JXCategoryIndicatorLineStyle_Normal) {
        targetX = [JXCategoryFactory interpolationFrom:leftX to:rightX percent:percent];
        if (self.indicatorWidth == JXCategoryViewAutomaticDimension) {
            targetWidth = [JXCategoryFactory interpolationFrom:leftWidth to:rightWidth percent:percent];
        }
    }else if (self.lineStyle == JXCategoryIndicatorLineStyle_Lengthen) {
        CGFloat maxWidth = rightX - leftX + rightWidth;
        // 前50%，只增加width；后50%，移动x并减小width
        if (percent <= 0.5) {
            targetX = leftX;
            targetWidth = [JXCategoryFactory interpolationFrom:leftWidth to:maxWidth percent:percent*2];
        }else {
            targetX = [JXCategoryFactory interpolationFrom:leftX to:rightX percent:(percent - 0.5)*2];
            targetWidth = [JXCategoryFactory interpolationFrom:maxWidth to:rightWidth percent:(percent - 0.5)*2];
        }
    }else if (self.lineStyle == JXCategoryIndicatorLineStyle_LengthenOffset) {
        //前50%,增加width，并少量移动x；后50%，少量移动x并减小width
        CGFloat offsetX = self.lineScrollOffsetX; // x的少量偏移量
        CGFloat maxWidth = rightX - leftX + rightWidth - offsetX*2;
        if (percent <= 0.5) {
            targetX = [JXCategoryFactory interpolationFrom:leftX to:leftX + offsetX percent:percent*2];
            targetWidth = [JXCategoryFactory interpolationFrom:leftWidth to:maxWidth percent:percent*2];
        }else {
            targetX = [JXCategoryFactory interpolationFrom:(leftX + offsetX) to:rightX percent:(percent - 0.5)*2];
            targetWidth = [JXCategoryFactory interpolationFrom:maxWidth to:rightWidth percent:(percent - 0.5)*2];
        }
    }

    //允许变动frame的情况：1、允许滚动；2、不允许滚动，但是已经通过手势滚动切换一页内容了；
    if (self.isScrollEnabled == YES || (self.isScrollEnabled == NO && percent == 0)) {
        CGRect frame = self.frame;
        frame.origin.x = targetX;
        frame.size.width = targetWidth;
        self.frame = frame;
    }
}

- (void)jx_selectedCell:(JXCategoryIndicatorParamsModel *)model {
    CGRect targetIndicatorFrame = self.frame;
    CGFloat targetIndicatorWidth = [self indicatorWidthValue:model.selectedCellFrame];
    targetIndicatorFrame.origin.x = [self calculateXWithFrame:model.selectedCellFrame width:targetIndicatorWidth];
    targetIndicatorFrame.size.width = targetIndicatorWidth;
    if (self.isScrollEnabled) {
        if (self.scrollStyle == JXCategoryIndicatorScrollStyleSameAsUserScroll && (model.selectedType == JXCategoryCellSelectedTypeClick | model.selectedType == JXCategoryCellSelectedTypeCode)) {
            [self stopAnimator];
            CGFloat leftX = 0;
            CGFloat rightX = 0;
            CGFloat leftWidth = 0;
            CGFloat rightWidth = 0;
            BOOL isNeedReversePercent = NO;
            if (self.frame.origin.x > model.selectedCellFrame.origin.x) {
                leftWidth = [self indicatorWidthValue:model.selectedCellFrame];
                rightWidth = self.frame.size.width;
                leftX = model.selectedCellFrame.origin.x + (model.selectedCellFrame.size.width - leftWidth)/2;
                rightX = self.frame.origin.x;
                isNeedReversePercent = YES;
            }else {
                leftWidth = self.frame.size.width;
                rightWidth = [self indicatorWidthValue:model.selectedCellFrame];
                leftX = self.frame.origin.x;
                rightX = model.selectedCellFrame.origin.x + (model.selectedCellFrame.size.width - rightWidth)/2;
            }
            __weak typeof(self) weakSelf = self;
            if (self.lineStyle == JXCategoryIndicatorLineStyle_Normal) {
                [UIView animateWithDuration:self.scrollAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    self.frame = targetIndicatorFrame;
                } completion:nil];
            }else if (self.lineStyle == JXCategoryIndicatorLineStyle_Lengthen) {
                CGFloat maxWidth = rightX - leftX + rightWidth;
                // 前50%，只增加width；后50%，移动x并减小width
                self.animator = [[JXCategoryViewAnimator alloc] init];
                self.animator.progressCallback = ^(CGFloat percent) {
                    if (isNeedReversePercent) {
                        percent = 1 - percent;
                    }
                    CGFloat targetX = 0;
                    CGFloat targetWidth = 0;
                    if (percent <= 0.5) {
                        targetX = leftX;
                        targetWidth = [JXCategoryFactory interpolationFrom:leftWidth to:maxWidth percent:percent*2];
                    }else {
                        targetX = [JXCategoryFactory interpolationFrom:leftX to:rightX percent:(percent - 0.5)*2];
                        targetWidth = [JXCategoryFactory interpolationFrom:maxWidth to:rightWidth percent:(percent - 0.5)*2];
                    }
                    CGRect toFrame = weakSelf.frame;
                    toFrame.origin.x = targetX;
                    toFrame.size.width = targetWidth;
                    weakSelf.frame = toFrame;
                };
                [self.animator start];
            }else if (self.lineStyle == JXCategoryIndicatorLineStyle_LengthenOffset) {
                //前50%,增加width，并少量移动x；后50%，少量移动x并减小width
                CGFloat offsetX = self.lineScrollOffsetX; // x的少量偏移量
                CGFloat maxWidth = rightX - leftX + rightWidth - offsetX*2;
                self.animator = [[JXCategoryViewAnimator alloc] init];
                self.animator.progressCallback = ^(CGFloat percent) {
                    if (isNeedReversePercent) {
                        percent = 1 - percent;
                    }
                    CGFloat targetX = 0;
                    CGFloat targetWidth = 0;
                    if (percent <= 0.5) {
                        targetX = [JXCategoryFactory interpolationFrom:leftX to:leftX + offsetX percent:percent*2];
                        targetWidth = [JXCategoryFactory interpolationFrom:leftWidth to:maxWidth percent:percent*2];
                    }else {
                        targetX = [JXCategoryFactory interpolationFrom:(leftX + offsetX) to:rightX percent:(percent - 0.5)*2];
                        targetWidth = [JXCategoryFactory interpolationFrom:maxWidth to:rightWidth percent:(percent - 0.5)*2];
                    }
                    CGRect toFrame = weakSelf.frame;
                    toFrame.origin.x = targetX;
                    toFrame.size.width = targetWidth;
                    weakSelf.frame = toFrame;
                };
                [self.animator start];
            }
        }else if (self.scrollStyle == JXCategoryIndicatorScrollStyleSimple) {
            [UIView animateWithDuration:self.scrollAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.frame = targetIndicatorFrame;
            } completion:nil];
        }
    }else {
        self.frame = targetIndicatorFrame;
    }
}

- (CGFloat)calculateXWithFrame:(CGRect)frame width:(CGFloat)width {
    CGFloat originX = 0;
    if (self.alignmentStyle == JXCategoryIndicatorAlignmentStyleLeading) {
        originX = frame.origin.x;
    }else if (self.alignmentStyle == JXCategoryIndicatorAlignmentStyleCenter) {
        originX = frame.origin.x + (frame.size.width - width)/2;
    }else if (self.alignmentStyle == JXCategoryIndicatorAlignmentStyleTrailing) {
        originX = frame.origin.x + frame.size.width - width;
    }
    return originX;
}

- (void)stopAnimator {
    if (self.animator.isExecuting) {
        [self.animator invalid];
        self.animator = nil;
    }
}

@end
