//
//  TaskA.m
//  JobControllerExample
//
//  Created by David House on 4/27/14.
//  Copyright (c) 2014 randomaccident. All rights reserved.
//

#import "TaskA.h"

@interface TaskA()

#pragma mark - Properties

@end

@implementation TaskA

#pragma mark - DHConcurrentOperation stuff
- (void)operationStart
{
    NSTimeInterval taskDelay = (arc4random() % 3);
    [self execute:@selector(timerFired) afterDelay:taskDelay];
}

- (void)timerFired
{
    if ( self.isCancelled ) {
        return;
    }
    
    NSLog(@"taskA timerFired...");
    // calculate a random color in the red spectrum
    self.outputColor = [UIColor colorWithRed:(((arc4random() % 206) + 50.0) / 256.0) green:0.0 blue:0.0 alpha:1.0];
    
    [self operationDone];
}

@end
