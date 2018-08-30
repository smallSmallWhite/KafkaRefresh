//
//  KafkaProgressiveRingIndicatorHeader.m
//  KafkaExample
//
//  Created by Sooyo on 2018/8/29.
//  Copyright © 2018年 Kinx. All rights reserved.
//

#import "KafkaProgressiveRingIndicatorHeader.h"

// 旋转一圈的默认时长
static const NSTimeInterval kDefaultSingleRunDuration = 0.8f;

// 默认的图标大小
static const CGFloat kDefaultIconSize = 40.f;

// 图标的下边距
static const CGFloat kIconBottomMargin = 0.f;

// 动画Key
static NSString * const kRotationAnimationKey = @"RotationAnimation";

// 文件名称
static NSString * const kIconImageFileName = @"RrereshIndicator";

@interface KafkaProgressiveRingIndicatorHeader ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, assign) CFTimeInterval layerPauseTime;

@end

@implementation KafkaProgressiveRingIndicatorHeader

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutUIComponents];
}

#pragma mark -
#pragma mark Private Functions
- (void)layoutUIComponents
{
    CGFloat xPos = (CGRectGetWidth(self.bounds) - kDefaultIconSize) / 2.f;
    CGFloat yPos = CGRectGetHeight(self.bounds) - kDefaultIconSize - kIconBottomMargin;
    
    _imageView.frame = CGRectMake(xPos, yPos, kDefaultIconSize, kDefaultIconSize);
}

- (void)prepareRingAnimation
{
    if ([_imageView.layer animationForKey:kRotationAnimationKey] == nil)
    {
        CABasicAnimation *rotationAnimation = [self rotationAnimationWithDuration:kDefaultSingleRunDuration];
        [_imageView.layer addAnimation:rotationAnimation forKey:kRotationAnimationKey];
        
        [self pauseRotationAnimation:YES];
    }
}

#pragma mark -
#pragma mark Override Functions
- (void)setupProperties
{
    [super setupProperties];
    
    _imageView = [[UIImageView alloc] init];
    _imageView.image = [UIImage imageNamed:@"RrereshIndicator"];
    
    self.endRefreshAnimationDuration = 0.3f;
    self.stretchOffsetYAxisThreshold = 1.8;
    
    [self prepareRingAnimation];
    [self addSubview:_imageView];
}

- (void)kafkaRefreshStateDidChange:(KafkaRefreshState)state
{
    [super kafkaRefreshStateDidChange:state];
    
    switch (state) {
        case KafkaRefreshStateRefreshing:
            [self pauseRotationAnimation:NO];
            break;
            
        case KafkaRefreshStateWillEndRefresh:
            [self pauseRotationAnimation:YES];
            break;
            
        default:
            break;
    }
}

- (void)kafkaDidScrollWithProgress:(CGFloat)progress max:(const CGFloat)max
{
    [self prepareRingAnimation];
    
    if (self.refreshState == KafkaRefreshStateScrolling || self.refreshState == KafkaRefreshStateReady)
    {
        [self updateRotationAnimationProgress:progress];
    }
}

#pragma mark -
#pragma mark Ring Animation
- (CABasicAnimation *)rotationAnimationWithDuration:(NSTimeInterval)duration
{
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    
    rotationAnimation.duration = duration;
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0];
    rotationAnimation.repeatCount = NSIntegerMax;
    rotationAnimation.cumulative = YES;

    return rotationAnimation;
}

- (void)pauseRotationAnimation:(BOOL)pause
{
    if (pause)
    {
        CFTimeInterval pauseTime = [_imageView.layer convertTime:CACurrentMediaTime() fromLayer:nil];
        _imageView.layer.speed = 0.f;
        _imageView.layer.timeOffset = pauseTime;
        _layerPauseTime = pauseTime;
    }
    else
    {
        CFTimeInterval pauseTime = _imageView.layer.timeOffset;
        
        _imageView.layer.beginTime = 0.0;
        _imageView.layer.timeOffset = 0.f;
        _imageView.layer.beginTime = [_imageView.layer convertTime:CACurrentMediaTime() fromLayer:nil] - pauseTime;
        _imageView.layer.speed = 1.f;
    }
}

- (void)updateRotationAnimationProgress:(CGFloat)progress
{
    _imageView.layer.timeOffset = _layerPauseTime + progress * kDefaultSingleRunDuration;
}

@end
