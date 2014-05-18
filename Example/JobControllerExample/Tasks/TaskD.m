//
//  TaskD.m
//  JobControllerExample
//
//  Created by David House on 4/27/14.
//  Copyright (c) 2014 randomaccident. All rights reserved.
//

#import "TaskD.h"

@interface TaskD()

#pragma mark - Properties
@property (nonatomic,strong) UIColor *redColor;
@property (nonatomic,strong) UIColor *greenColor;
@property (nonatomic,strong) UIColor *blueColor;
@property (nonatomic,strong) NSTimer *timer;

@end

@implementation TaskD

#pragma mark - Initializer
- (id)initWithRedColor:(UIColor *)redColor greenColor:(UIColor *)greenColor blueColor:(UIColor *)blueColor
{
    if ( self = [super init] ) {
        _redColor = redColor;
        _greenColor = greenColor;
        _blueColor = blueColor;
    }
    return self;
}

#pragma mark - NSOperation stuff
- (void)operationStart
{
    NSTimeInterval taskDelay = (arc4random() % 50) / 100.0;
    self.timer = [NSTimer timerWithTimeInterval:taskDelay target:self selector:@selector(timerFired:) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
}

- (void)timerFired:(NSTimer *)timer
{
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    [self.redColor getRed:&red green:NULL blue:NULL alpha:NULL];
    [self.greenColor getRed:NULL green:&green blue:NULL alpha:NULL];
    [self.blueColor getRed:NULL green:NULL blue:&blue alpha:NULL];
    
    self.outputColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];

    [self operationDone];
}

- (void)cancel
{
    if ( self.timer ) {
        [self.timer invalidate];
        self.timer = nil;
        [self operationDone];
    }
    [super cancel];
}
@end
