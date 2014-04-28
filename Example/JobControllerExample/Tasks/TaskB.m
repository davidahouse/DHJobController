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
@property (nonatomic,assign,getter = isDone) BOOL done;
@property (nonatomic,strong) NSTimer *timer;

@end

@implementation TaskB

#pragma mark - NSOperation stuff
- (void)start
{
    @autoreleasepool {
        
        if (![NSThread isMainThread])
        {
            [self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
            return;
        }

        self.done = NO;
        if ( [self isCancelled] ) {
            self.done = YES;
            return ;
        }
        
        NSTimeInterval taskDelay = (arc4random() % 200) / 100.0;
        self.timer = [NSTimer timerWithTimeInterval:taskDelay target:self selector:@selector(timerFired:) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    }
}

- (void)timerFired:(NSTimer *)timer
{
    // calculate a random color in the red spectrum
    self.outputColor = [UIColor colorWithRed:0.0 green:(((arc4random() % 206) + 50.0) / 256.0) blue:0.0 alpha:1.0];
    
    [self willChangeValueForKey:@"isFinished"];
    self.done = YES;
    [self didChangeValueForKey:@"isFinished"];
}

- (BOOL)isFinished
{
    return [self isDone];
}

- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isExecuting
{
    return ![self isDone];
}

- (void)cancel
{
    if ( self.timer )  {
        [self.timer invalidate];
        self.timer = nil;
        [self willChangeValueForKey:@"isFinished"];
        self.done = YES;
        [self didChangeValueForKey:@"isFinished"];
    }
    [super cancel];
}

@end
