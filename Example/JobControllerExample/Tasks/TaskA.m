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
@property (nonatomic,strong) NSTimer *timer;

@end

@implementation TaskA

#pragma mark - DHConcurrentOperation stuff
- (void)operationStart
{
    NSTimeInterval taskDelay = (arc4random() % 100) / 100.0;
    self.timer = [NSTimer timerWithTimeInterval:taskDelay target:self selector:@selector(timerFired:) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
}

- (void)timerFired:(NSTimer *)timer
{
    // calculate a random color in the red spectrum
    self.outputColor = [UIColor colorWithRed:(((arc4random() % 206) + 50.0) / 256.0) green:0.0 blue:0.0 alpha:1.0];
    
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
