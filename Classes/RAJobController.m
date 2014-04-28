//
//  RAJobController.m
//  RAJobController
//
//  Created by David House on 4/13/14.
//  Copyright (c) 2014 David House <davidahouse@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//

#import "RAJobController.h"
#import <Objc/runtime.h>
#import "RAJobControllerTask.h"
#import "RAJobControllerTaskGroup.h"

//
//
//
@interface RAJobController()

#pragma mark - Properties
@property (nonatomic,strong) NSMutableDictionary *currentTasks;
@property (nonatomic,strong) NSMutableDictionary *groupedTasks;

@end


//
//
//
@implementation RAJobController {
    NSOperationQueue *_defaultOperationQueue;
    dispatch_queue_t _completionQueue;
    NSOperationQueue *_concurrentQueue;
}

#pragma mark - Initilizer
- (id)init
{
    if ( self = [super init] ) {
        _currentTasks = [[NSMutableDictionary alloc] init];
        _groupedTasks = [[NSMutableDictionary alloc] init];
        _completionQueue = dispatch_queue_create([[[NSUUID UUID] UUIDString] cStringUsingEncoding:NSASCIIStringEncoding], DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

#pragma mark - Properties
- (NSOperationQueue *)defaultOperationQueue
{
    if ( !_defaultOperationQueue ) {
        _defaultOperationQueue = [[NSOperationQueue alloc] init];
    }
    return _defaultOperationQueue;
}

#pragma mark - NSOperation
- (BOOL)isFinished
{
    return [[self.currentTasks allKeys] count] == 0;
}

- (BOOL)isExecuting
{
    return [[self.currentTasks allKeys] count] > 0;
}

- (BOOL)isConcurrent
{
    return YES;
}

- (void)cancel
{
    [super cancel];
    
    NSLog(@"cancelling job. isCancelled == %@",[self isCancelled] ? @"YES" : @"NO");
    
    for ( RAJobControllerTask *trackedOperation in [self.currentTasks allValues] ) {
        [trackedOperation.operation cancel];
    }
    [self.currentTasks removeAllObjects];
    [self willChangeValueForKey:@"isFinished"];
    [self didChangeValueForKey:@"isFinished"];    
}

#pragma mark - Public Job Methods
- (void)startJob
{
    // create a random queue for this to run on
    NSOperationQueue *jobQueue = [[NSOperationQueue alloc] init];
    [jobQueue addOperation:self];
}

- (void)startJobOnQueue:(NSOperationQueue *)queue
{
    [queue addOperation:self];
}

#pragma mark - Public Methods
- (void)taskFinished:(id)task
{
}

- (void)taskGroupFinished:(NSString *)group
{
}

- (void)allTasksFinished
{
}

#pragma mark - Track Operations
- (void)trackTask:(id)task
{
    RAJobControllerTask *trackedOperation = [self jobOperationFromOperation:task];
    [self addTrackedOperation:trackedOperation];
}

- (void)trackAndQueueTask:(id)task
{
    [self trackTask:task];
    [self.defaultOperationQueue addOperation:task];
}

- (void)trackTask:(id)task withCompletion:(SEL)completionSelector
{
    RAJobControllerTask *trackedOperation = [self jobOperationFromOperation:task withCompletion:completionSelector];
    [self addTrackedOperation:trackedOperation];
}

- (void)trackAndQueueTask:(id)task withCompletion:(SEL)completionSelector
{
    [self trackTask:task withCompletion:completionSelector];
    [self.defaultOperationQueue addOperation:task];
}

- (void)setCompletion:(SEL)completionSelector group:(Class)groupClass
{
    NSString *groupKey = NSStringFromClass(groupClass);

    // If we are already tracking this group, append this
    // operation to the list, otherwise we need to create it
    if ( [self.groupedTasks objectForKey:groupKey] ) {
        
        RAJobControllerTaskGroup *group = [self.groupedTasks objectForKey:groupKey];
        group.groupCompletionSelector = completionSelector;
    }
    else {
        
        RAJobControllerTaskGroup *group = [[RAJobControllerTaskGroup alloc] init];
        group.groupName = groupKey;
        group.operationCount = 0;
        group.groupCompletionSelector = completionSelector;
        [self.groupedTasks setObject:group forKey:groupKey];
    }
}

#pragma mark - Private Methods
- (void)operationDone:(NSString *)operationID
{
    RAJobControllerTask *trackedOperation = [self.currentTasks objectForKey:operationID];
    NSString *groupKey = NSStringFromClass([trackedOperation.operation class]);
    
    // Remove operation from our dictionary
    [self.currentTasks removeObjectForKey:operationID];
    if ( !self.isCancelled ) {
        if ( trackedOperation.completionSelector ) {
            IMP imp = [self methodForSelector:trackedOperation.completionSelector];
            void (*func)(id,SEL,NSOperation *) = (void *)imp;
            func(self,trackedOperation.completionSelector,trackedOperation.operation);
        }
        else {
            [self taskFinished:trackedOperation.operation];
        }
    }
    
    // Now lets check the group as well
    if ( [self.groupedTasks objectForKey:groupKey] ) {
        RAJobControllerTaskGroup *group = [self.groupedTasks objectForKey:groupKey];
        group.operationCount--;
        if ( group.operationCount == 0 ) {
            
            if ( !self.isCancelled ) {
                if ( group.groupCompletionSelector ) {
                    IMP imp = [self methodForSelector:group.groupCompletionSelector];
                    void (*func)(id,SEL) = (void *)imp;
                    func(self,group.groupCompletionSelector);
                }
                else {
                    [self taskGroupFinished:groupKey];
                }
            }
        }
    }
    
    if ( [self.currentTasks count] == 0 && !self.isCancelled ) {
        [self allTasksFinished];
    }
    
    // do the KVO stuff
    [self willChangeValueForKey:@"isFinished"];
    [self didChangeValueForKey:@"isFinished"];
}

- (RAJobControllerTask *)jobOperationFromOperation:(id)operation
{
    NSString *operationID = [NSString stringWithFormat:@"%@_%@",NSStringFromClass([operation class]),[[NSUUID UUID] UUIDString]];

    RAJobControllerTask *trackedOperation = [[RAJobControllerTask alloc] init];
    trackedOperation.operation = operation;
    trackedOperation.operationID = operationID;
    return trackedOperation;
}

- (RAJobControllerTask *)jobOperationFromOperation:(id)operation withCompletion:(SEL)completionSelector
{
    NSString *operationID = [NSString stringWithFormat:@"%@_%@",NSStringFromClass([operation class]),[[NSUUID UUID] UUIDString]];

    RAJobControllerTask *trackedOperation = [[RAJobControllerTask alloc] init];
    trackedOperation.operationID = operationID;
    trackedOperation.operation = operation;
    trackedOperation.completionSelector = completionSelector;
    return trackedOperation;
}

- (void)addTrackedOperation:(RAJobControllerTask *)trackedOperation
{
    NSString *groupKey = NSStringFromClass([trackedOperation.operation class]);

    // Setup the correct completed block
    NSOperation *op = (NSOperation *)trackedOperation.operation;
    __weak id weakself = self;
    [op setCompletionBlock:^{
        dispatch_async(_completionQueue, ^{
            [weakself operationDone:trackedOperation.operationID];
        });
    }];
    
    // Add to our tracked operations
    [self.currentTasks setObject:trackedOperation forKey:trackedOperation.operationID];
    
    // If we are already tracking this group, append this
    // operation to the list, otherwise we need to create it
    if ( [self.groupedTasks objectForKey:groupKey] ) {
        
        RAJobControllerTaskGroup *group = [self.groupedTasks objectForKey:groupKey];
        group.operationCount++;
    }
    else {
        
        RAJobControllerTaskGroup *group = [[RAJobControllerTaskGroup alloc] init];
        group.groupName = groupKey;
        group.operationCount = 1;
        [self.groupedTasks setObject:group forKey:groupKey];
    }
}

@end
