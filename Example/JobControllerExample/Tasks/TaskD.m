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
    NSTimeInterval taskDelay = arc4random() % 2;
    [self execute:@selector(timerFired) afterDelay:taskDelay];
}

- (void)timerFired
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

@end
