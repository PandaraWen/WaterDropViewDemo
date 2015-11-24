//
//  WaterDropView.m
//  WaterDropViewDemo
//
//  Created by Pandara on 15/11/23.
//  Copyright © 2015年 Pandara. All rights reserved.
//

#import "WaterDropView.h"

#define test 0

#define TOPWATERDROP_W 10.0f
#define TOPWATERDROP_ASSISTANCE_W 13.0f

#define TOPWATER_R 12 //上面的水宽度
#define TOPWATER_Y 0
#define TOPWATER_BROKEN_H 15.0f

#define BOTTOMWATERDROP_ASSISTANCE_W 10.0f
#define BOTTOMWATERDROP_ASSISTANCE_CENTER_INIT CGPointMake(self.frame.size.width / 2.0f, self.frame.size.height - BOTTOMWATER_H - BOTTOMWATER_BROKEN_H)

#define BOTTOMWATER_H 60.0f
#define BOTTOMWATER_R 25 //下水面宽度
#define BOTTOMWATER_BROKEN_H 30.0f

#define WAVE_W 30
#define WAVE_CONTROL_H 3.0f
#define WAVE_MOVE_DISTANCE 35.0f

#define COLLISION_BOUNDARY_ID_FLOOR @"floor"
#define COLLISION_BOUNDARY_ID_BOTTOMWATER @"bottomwater"

@interface WaterDropView() <UICollisionBehaviorDelegate> {
}

@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) UIGravityBehavior *gravityBehavior;
@property (strong, nonatomic) UICollisionBehavior *collisionBehavior;

//top water
@property (strong, nonatomic) CAShapeLayer *topWaterLayer;
@property (strong, nonatomic) UIView *topWaterDrop;
@property (strong, nonatomic) UIView *topWaterDropAssistance;   //上面的水平复时的辅助 view

@property (strong, nonatomic) UIDynamicItemBehavior *topWaterDropBehavior;

@property (strong, nonatomic) CADisplayLink *topWaterDropFallDisplayLink;
@property (strong, nonatomic) CADisplayLink *topWaterDropBackDisplayLink;

//bottom water
@property (strong, nonatomic) CAShapeLayer *bottomWaterLayer;
@property (strong, nonatomic) UIView *bottomWaterDropAssistance;
@property (strong, nonatomic) UIDynamicItemBehavior *bottomWaterDropAssistanceBehavior;

@property (strong, nonatomic) CADisplayLink *bottomWaterDropJumpDisplayLink;
@property (strong, nonatomic) CADisplayLink *bottomWaterDropBackDisplayLink;

@end

@implementation WaterDropView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self setupDynamic];
        
        [self setupBottomWater];
        
        [self setupTopWater];
    }
    
    return self;
}

- (void)setupDynamic
{
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
    
    //gravity
    self.gravityBehavior = [[UIGravityBehavior alloc] init];
    [self.animator addBehavior:self.gravityBehavior];
    
    //collision
    self.collisionBehavior = [[UICollisionBehavior alloc] init];
    self.collisionBehavior.collisionMode = UICollisionBehaviorModeEverything;
    self.collisionBehavior.collisionDelegate = self;
    [self.collisionBehavior addBoundaryWithIdentifier:COLLISION_BOUNDARY_ID_FLOOR fromPoint:CGPointMake(0, self.frame.size.height) toPoint:CGPointMake(self.frame.size.width, self.frame.size.height)];
    [self.animator addBehavior:self.collisionBehavior];
}

- (void)setupTopWater
{
    self.topWaterLayer = [CAShapeLayer layer];
    self.topWaterLayer.frame = CGRectMake(0, 0, self.frame.size.width, 0);
    self.topWaterLayer.backgroundColor = [UIColor whiteColor].CGColor;
    self.topWaterLayer.fillColor = [UIColor whiteColor].CGColor;
    self.topWaterLayer.strokeColor = [UIColor clearColor].CGColor;
    [self.layer addSublayer:self.topWaterLayer];
    
    self.topWaterDrop = [[UIView alloc] initWithFrame:CGRectMake(0, TOPWATER_Y, TOPWATERDROP_W, TOPWATERDROP_W)];
    self.topWaterDrop.alpha = 1;
#if test
    self.topWaterDrop.backgroundColor = [UIColor redColor];
#else
    self.topWaterDrop.backgroundColor = [UIColor whiteColor];
#endif
    self.topWaterDrop.layer.cornerRadius = TOPWATERDROP_W / 2.0f;
    self.topWaterDrop.clipsToBounds = YES;
    self.topWaterDrop.center = CGPointMake(self.frame.size.width / 2.0f, TOPWATER_Y - TOPWATERDROP_W / 2.0f);
    [self addSubview:self.topWaterDrop];
    
    self.topWaterDropAssistance = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TOPWATERDROP_ASSISTANCE_W, TOPWATERDROP_ASSISTANCE_W)];
    self.topWaterDropAssistance.backgroundColor = [UIColor clearColor];
    self.topWaterDropAssistance.center = CGPointMake(self.frame.size.width / 2.0f, TOPWATER_Y - TOPWATERDROP_ASSISTANCE_W);
    [self addSubview:self.topWaterDropAssistance];
    
    [self.collisionBehavior addItem:self.topWaterDrop];
    
    self.topWaterDropBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.topWaterDrop]];
    self.topWaterDropBehavior.elasticity = 0.4;
    self.topWaterDropBehavior.allowsRotation = NO;
    [self.animator addBehavior:self.topWaterDropBehavior];
    
    //display link
    self.topWaterDropFallDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(onTopWaterDropFallDisplayLink:)];
    self.topWaterDropFallDisplayLink.paused = YES;
    [self.topWaterDropFallDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    self.topWaterDropBackDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(onTopWaterDropBackDisplayLink:)];
    self.topWaterDropBackDisplayLink.paused = YES;
    [self.topWaterDropBackDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)setupBottomWater
{
    self.bottomWaterLayer = [CAShapeLayer layer];
    self.bottomWaterLayer.frame = CGRectMake(0, self.frame.size.height - BOTTOMWATER_H, self.frame.size.width, BOTTOMWATER_H);
    self.bottomWaterLayer.backgroundColor = [UIColor whiteColor].CGColor;
    self.bottomWaterLayer.fillColor = [UIColor whiteColor].CGColor;
    self.bottomWaterLayer.strokeColor = [UIColor clearColor].CGColor;
    [self.layer addSublayer:self.bottomWaterLayer];
    
    self.bottomWaterDropAssistance = [[UIView alloc] initWithFrame:CGRectMake(0, 0, BOTTOMWATERDROP_ASSISTANCE_W, BOTTOMWATERDROP_ASSISTANCE_W)];
#if test
    self.bottomWaterDropAssistance.backgroundColor = [UIColor blackColor];
#else
    self.bottomWaterDropAssistance.backgroundColor = [UIColor clearColor];
#endif
    self.bottomWaterDropAssistance.center = BOTTOMWATERDROP_ASSISTANCE_CENTER_INIT;
    
    [self addSubview:self.bottomWaterDropAssistance];
    
    //display link
    self.bottomWaterDropJumpDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(onBottomWaterDropJumpDisplayLink:)];
    self.bottomWaterDropJumpDisplayLink.paused = YES;
    [self.bottomWaterDropJumpDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    self.bottomWaterDropBackDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(onBottomWaterDropBackDisplayLink:)];
    self.bottomWaterDropBackDisplayLink.paused = YES;
    [self.bottomWaterDropBackDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

#pragma mark - Action
- (void)onTopWaterDropFallDisplayLink:(CADisplayLink *)displayLink
{
    if (self.topWaterDrop.center.y > TOPWATER_BROKEN_H) {
        self.topWaterDropFallDisplayLink.paused = YES;
        
        self.topWaterDropAssistance.center = self.topWaterDrop.center;
        [UIView animateWithDuration:0.5f animations:^{
            self.topWaterDropAssistance.center = CGPointMake(self.frame.size.width / 2.0f, TOPWATER_Y - TOPWATERDROP_ASSISTANCE_W);
        }];
        
        self.topWaterDrop.alpha = 1.0f;
        
        self.topWaterDropBackDisplayLink.paused = NO;
    } else {
        [self drawTopWaterWhenFall];
    }
}

- (void)onTopWaterDropBackDisplayLink:(CADisplayLink *)displayLink
{
    CGPoint assistancePoint = [[self.topWaterDropAssistance.layer.presentationLayer valueForKey:@"position"] CGPointValue];
    if (assistancePoint.y <= TOPWATER_Y - TOPWATERDROP_ASSISTANCE_W) {
        self.topWaterDropBackDisplayLink.paused = YES;
    } else {
        [self drawTopWaterWhenBack];
    }
}

- (void)onBottomWaterDropJumpDisplayLink:(CADisplayLink *)displayLink
{
    if ((self.frame.size.height - BOTTOMWATER_H) - self.topWaterDrop.center.y > BOTTOMWATER_BROKEN_H) {
        self.bottomWaterDropJumpDisplayLink.paused = YES;
        
        self.bottomWaterDropAssistance.center = self.topWaterDrop.center;
        [self.gravityBehavior addItem:self.bottomWaterDropAssistance];
        
        self.topWaterDrop.alpha = 1.0f;
        
        self.bottomWaterDropBackDisplayLink.paused = NO;
    } else {
        [self drawBottomWaterWhenJump];
    }
}

- (void)onBottomWaterDropBackDisplayLink:(CADisplayLink *)displayLink
{
    if (self.bottomWaterDropAssistance.center.y >= (self.frame.size.height - BOTTOMWATER_H - BOTTOMWATERDROP_ASSISTANCE_W)) {
        [self playWaveAnimation];
    }
    
    if (self.bottomWaterDropAssistance.center.y >= (self.frame.size.height - BOTTOMWATER_H + BOTTOMWATERDROP_ASSISTANCE_W)) {
        self.bottomWaterDropBackDisplayLink.paused = YES;
        [self.collisionBehavior addItem:self.bottomWaterDropAssistance];
    } else {
        [self drawBottomWaterWhenBack];
    }
}

#pragma mark - method
- (void)play
{
    
    [self.collisionBehavior addBoundaryWithIdentifier:COLLISION_BOUNDARY_ID_BOTTOMWATER fromPoint:CGPointMake(0, self.frame.size.height - BOTTOMWATER_H + TOPWATERDROP_W) toPoint:CGPointMake(self.frame.size.width, self.frame.size.height - BOTTOMWATER_H + TOPWATERDROP_W)];
    [self.gravityBehavior addItem:self.topWaterDrop];
    
    self.topWaterDropBehavior.resistance = 0;
    
    self.topWaterDropFallDisplayLink.paused = NO;
}

- (void)playWaveAnimation
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, WAVE_CONTROL_H)];
    [path addQuadCurveToPoint:CGPointMake(WAVE_W, WAVE_CONTROL_H)  controlPoint:CGPointMake(WAVE_W / 2.0f, 0)];
    [path closePath];
    
    CAShapeLayer *leftWave = [CAShapeLayer layer];
    leftWave.anchorPoint = CGPointMake(0.5, 0.5);
    leftWave.frame = CGRectMake(self.frame.size.width / 2.0f - BOTTOMWATER_R - WAVE_W / 2.0f, self.frame.size.height - BOTTOMWATER_H, WAVE_W, WAVE_CONTROL_H);
    leftWave.fillColor = [UIColor whiteColor].CGColor;
    leftWave.strokeColor = [UIColor clearColor].CGColor;
    leftWave.path = path.CGPath;
    [self.layer addSublayer:leftWave];

    [self moveWave:leftWave isToLeft:YES];
    
    CAShapeLayer *rightWave = [CAShapeLayer layer];
    rightWave.anchorPoint = CGPointMake(0.5, 0.5);
    rightWave.frame = CGRectMake(self.frame.size.width / 2.0f + BOTTOMWATER_R - WAVE_W / 2.0f, self.frame.size.height - BOTTOMWATER_H, WAVE_W, WAVE_CONTROL_H);
    rightWave.fillColor = [UIColor whiteColor].CGColor;
    rightWave.strokeColor = [UIColor clearColor].CGColor;
    rightWave.path = path.CGPath;
    [self.layer addSublayer:rightWave];
    
    [self moveWave:rightWave isToLeft:NO];
}

- (void)moveWave:(CAShapeLayer *)waveLayer isToLeft:(BOOL)isToLeft
{
    CGFloat offset = isToLeft? -WAVE_MOVE_DISTANCE : WAVE_MOVE_DISTANCE;

    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.duration = 1.5f;
    animation.values = @[[NSValue valueWithCGPoint:CGPointMake(waveLayer.position.x, self.frame.size.height - BOTTOMWATER_H + WAVE_CONTROL_H / 2.0f)],
                         [NSValue valueWithCGPoint:CGPointMake(waveLayer.position.x, self.frame.size.height - BOTTOMWATER_H - WAVE_CONTROL_H / 2.0f)],
                         [NSValue valueWithCGPoint:CGPointMake(waveLayer.position.x + offset, self.frame.size.height - BOTTOMWATER_H - WAVE_CONTROL_H / 2.0f)],
                         [NSValue valueWithCGPoint:CGPointMake(waveLayer.position.x + offset, self.frame.size.height - BOTTOMWATER_H + WAVE_CONTROL_H / 2.0f)],
                         ];
    animation.keyTimes = @[@(0), @(0.2), @(0.8), @(1)];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:@"linear"];
    animation.fillMode = kCAFillModeForwards;

    [waveLayer addAnimation:animation forKey:@"animation"];
}

- (void)drawTopWaterWhenFall
{
    UIBezierPath *path = [self getBezierPathFromPoint1:CGPointMake(self.frame.size.width / 2.0f, TOPWATER_Y) radius1:TOPWATER_R Point2:self.topWaterDrop.center radius2:TOPWATERDROP_W / 2.0f];
    [path addArcWithCenter:self.topWaterDrop.center radius:TOPWATERDROP_W / 2.0f startAngle:0 endAngle:M_PI clockwise:YES];
    self.topWaterLayer.path = path.CGPath;
}

- (void)drawTopWaterWhenBack
{
    CGPoint assistancePoint = [[self.topWaterDropAssistance.layer.presentationLayer valueForKey:@"position"] CGPointValue];
    
    UIBezierPath *path = [self getBezierPathFromPoint1:CGPointMake(self.frame.size.width / 2.0f, TOPWATER_Y) radius1:TOPWATER_R Point2:assistancePoint radius2:TOPWATERDROP_ASSISTANCE_W / 2.0f];
    
    [path addArcWithCenter:assistancePoint radius:TOPWATERDROP_ASSISTANCE_W / 2.0f startAngle:0 endAngle:M_PI clockwise:YES];
    
    self.topWaterLayer.path = path.CGPath;
}

- (void)drawBottomWaterWhenJump
{
    CGPoint point2 = CGPointMake(self.topWaterDrop.center.x, -((self.frame.size.height - BOTTOMWATER_H) - self.topWaterDrop.center.y));
    
    UIBezierPath *path = [self getBezierPathFromPoint1:CGPointMake(self.frame.size.width / 2.0f, 0) radius1:BOTTOMWATER_R Point2:point2 radius2:TOPWATERDROP_W / 2.0f];
    [path addArcWithCenter:point2 radius:TOPWATERDROP_W / 2.0f startAngle:-M_PI endAngle:0 clockwise:YES];
    self.bottomWaterLayer.path = path.CGPath;
}

- (void)drawBottomWaterWhenBack
{
    CGPoint point2 = CGPointMake(self.bottomWaterDropAssistance.center.x, -((self.frame.size.height - BOTTOMWATER_H) - self.bottomWaterDropAssistance.center.y));
    
    UIBezierPath *path = [self getBezierPathFromPoint1:CGPointMake(self.frame.size.width / 2.0f, 0) radius1:BOTTOMWATER_R Point2:point2 radius2:BOTTOMWATERDROP_ASSISTANCE_W / 2.0f];
    [path addArcWithCenter:point2 radius:BOTTOMWATERDROP_ASSISTANCE_W / 2.0f startAngle:-M_PI endAngle:0 clockwise:YES];
    self.bottomWaterLayer.path = path.CGPath;
}

- (UIBezierPath *)getBezierPathFromPoint1:(CGPoint)point1 radius1:(CGFloat)r1 Point2:(CGPoint)point2 radius2:(CGFloat)r2
{
    if (r1 > r2) {
        CGPoint tempPoint = point1;
        point1 = point2;
        point2 = tempPoint;
        
        CGFloat tempR = r1;
        r1 = r2;
        r2 = tempR;
    }
    
    CGFloat x1 = point1.x;
    CGFloat y1 = point1.y;
    CGFloat x2 = point2.x;
    CGFloat y2 = point2.y;
    
    CGFloat distance = sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
    
    CGFloat sinDegree = (x2 - x1) / distance;
    CGFloat cosDegree = (y2 - y1) / distance;
    
    CGPoint pointA = CGPointMake(x1 - r1 * cosDegree, y1 + r1 * sinDegree);
    CGPoint pointB = CGPointMake(x1 + r1 * cosDegree, y1 - r1 * sinDegree);
    CGPoint pointC = CGPointMake(x2 + r2 * cosDegree, y2 - r2 * sinDegree);
    CGPoint pointD = CGPointMake(x2 - r2 * cosDegree, y2 + r2 * sinDegree);
    CGPoint pointN;
    CGPoint pointM;

    pointM = CGPointMake(pointA.x + (distance / 2) * sinDegree, pointA.y + (distance / 2) * cosDegree);
    pointN = CGPointMake(pointB.x + (distance / 2) * sinDegree, pointB.y + (distance / 2) * cosDegree);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:pointA];
    [path addLineToPoint:pointB];
    [path addQuadCurveToPoint:pointC controlPoint:pointN];
    [path addLineToPoint:pointD];
    [path addQuadCurveToPoint:pointA controlPoint:pointM];
    
    return path;
    
}

#pragma mark - UICollisionBehaviorDelegate
- (void)collisionBehavior:(UICollisionBehavior *)behavior endedContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier
{
    NSString *identifierStr = (NSString *)identifier;
    if ([identifierStr isEqualToString:COLLISION_BOUNDARY_ID_BOTTOMWATER]) {
        self.topWaterDrop.alpha = 0;
        self.bottomWaterDropJumpDisplayLink.paused = NO;
        [self.collisionBehavior removeBoundaryWithIdentifier:COLLISION_BOUNDARY_ID_BOTTOMWATER];
    } else if ([identifierStr isEqualToString:COLLISION_BOUNDARY_ID_FLOOR]) {
        
        if ([item isEqual:self.topWaterDrop]) {

        }
        
        if ([item isEqual:self.bottomWaterDropAssistance]) {

        }
    }
}

@end
















