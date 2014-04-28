//
//  ExampleJob.m
//  JobControllerExample
//
//  Created by David House on 4/27/14.
//  Copyright (c) 2014 randomaccident. All rights reserved.
//

#import "ExampleJob.h"
#import "TaskA.h"
#import "TaskB.h"
#import "TaskC.h"
#import "TaskD.h"

const NSString *kExampleJobUpdateNotification = @"EXAMPLEJOBNOTIFICATION";

@interface ExampleJob()

#pragma mark - Properties
@property (nonatomic,strong) NSOperationQueue *taskCQueue;

@end

@implementation ExampleJob

#pragma mark - NSOperation stuff
- (void)start
{
    @autoreleasepool {
        
        // Setup a queue for the TaskC tasks
        self.taskCQueue = [[NSOperationQueue alloc] init];
        [self.taskCQueue setMaxConcurrentOperationCount:1];
        
        // Start the first task
        TaskA *firstTask = [[TaskA alloc] init];
        [self trackAndQueueTask:firstTask withCompletion:@selector(taskAFinished:)];
    }
}

#pragma mark - Completion Selectors
- (void)taskAFinished:(id)task
{
    TaskA *taskA = (TaskA *)task;
    self.taskAColor = taskA.outputColor;
    
    // Send a notification for this first color completion
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:(NSString *)kExampleJobUpdateNotification object:nil];
    });
    
    TaskB *secondTask = [[TaskB alloc] init];
    [self trackAndQueueTask:secondTask withCompletion:@selector(taskBFinished:)];
}

- (void)taskBFinished:(id)task
{
    TaskB *taskB = (TaskB *)task;
    self.taskBColor = taskB.outputColor;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:(NSString *)kExampleJobUpdateNotification object:nil];
    });
    
    // Fire off a bunch of TaskCs!
    [self setCompletion:@selector(allTaskCFinished) group:[TaskC class]];
    for ( int i = 0; i < 25; i++ ) {
        TaskC *task = [[TaskC alloc] init];
        [self trackTask:task withCompletion:@selector(singleTaskCFinished:)];
        [self.taskCQueue addOperation:task];
    }
}

- (void)singleTaskCFinished:(id)task
{
    TaskC *taskC = (TaskC *)task;
    self.taskCColor = taskC.outputColor;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:(NSString *)kExampleJobUpdateNotification object:nil];
    });
}

- (void)allTaskCFinished
{
    TaskD *taskD = [[TaskD alloc] initWithRedColor:self.taskAColor greenColor:self.taskBColor blueColor:self.taskCColor];
    [self trackAndQueueTask:taskD withCompletion:@selector(taskDFinished:)];
}

- (void)taskDFinished:(id)task
{
    TaskD *taskD = (TaskD *)task;
    self.taskDColor = taskD.outputColor;
}

@end
