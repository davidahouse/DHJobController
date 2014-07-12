//
//  TaskB.m
//  JobControllerExample
//
//  Created by David House on 4/27/14.
//  Copyright (c) 2014 randomaccident. All rights reserved.
//

#import "TaskB.h"

@interface TaskB()

#pragma mark - Properties

@end

@implementation TaskB

#pragma mark - NSOperation stuff
- (void)operationStart
{
    NSTimeInterval taskDelay = arc4random() % 5;
    [self execute:@selector(timerFired) afterDelay:taskDelay];
}

- (void)timerFired
{
    // calculate a random color in the red spectrum
    self.outputColor = [UIColor colorWithRed:0.0 green:(((arc4random() % 206) + 50.0) / 256.0) blue:0.0 alpha:1.0];
    [self operationDone];
}

@end
