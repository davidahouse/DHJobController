//
//  DHConcurrentOperation.m
//  
//
//  Created by David House on 5/18/14.
//
//

#import "DHConcurrentOperation.h"

@interface DHConcurrentOperation()

#pragma mark - Properties
@property (nonatomic,assign,getter = isDone) BOOL done;

@end

@implementation DHConcurrentOperation

#pragma mark - Public Methods
- (void)operationDone
{
    [self willChangeValueForKey:@"isFinished"];
    self.done = YES;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)operationStart
{
    
}

#pragma mark - NSOperation Methods

- (void)start
{
    @autoreleasepool {
        
        if (![NSThread isMainThread])
        {
            [self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
            return;
        }
        
        if ( [self isCancelled] ) {
            [self operationDone];
            return;
        }
        
        self.done = NO;
        [self operationStart];
    }
}

- (BOOL)isFinished
{
    return self.isDone;
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
    [self operationDone];
    [super cancel];
}

@end
