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
@property (nonatomic,assign,getter = isStarted) BOOL started;

@end

@implementation DHConcurrentOperation {
    dispatch_source_t _delayTimer;
    dispatch_source_t _runtimeTimer;
}

#pragma mark - Public Methods
- (void)operationDone
{
    [self clearTimers];
    
    [self willChangeValueForKey:@"isFinished"];
    self.done = YES;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)operationStart
{
    
}

- (void)execute:(SEL)selector afterDelay:(NSUInteger)seconds
{
    __weak typeof(self) weakself = self;
    _delayTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) );
    dispatch_source_set_timer(_delayTimer, dispatch_time(DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC), DISPATCH_TIME_FOREVER, 0);
    dispatch_source_set_event_handler(_delayTimer, ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if ( [weakself respondsToSelector:selector] ) {
            [weakself performSelector:selector];
        }
#pragma clang diagnostic pop
        if ( _delayTimer ) {
            dispatch_source_cancel(_delayTimer);
        }
    });
    dispatch_resume(_delayTimer);
}

#pragma mark - NSOperation Methods

- (void)start
{
    @autoreleasepool {
        
        self.started = YES;
        if ( [self isCancelled] ) {
            [self operationDone];
            return;
        }
        
        if ( self.maximumRuntime > 0 ) {
            [self startRuntimeTimer];
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
    if ( self.isStarted ) {
        [self operationDone];
    }
    [super cancel];
}

- (void)dealloc
{
    [self clearTimers];
}

#pragma mark - Private methods
- (void)startRuntimeTimer
{
    __weak typeof(self) weakself = self;
    _runtimeTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) );
    dispatch_source_set_timer(_runtimeTimer, dispatch_time(DISPATCH_TIME_NOW, self.maximumRuntime * NSEC_PER_SEC), DISPATCH_TIME_FOREVER, 0);
    dispatch_source_set_event_handler(_runtimeTimer, ^{
        [weakself cancel];
    });
    dispatch_resume(_runtimeTimer);
}

- (void)clearTimers
{
    if ( _delayTimer ) {
        dispatch_source_cancel(_delayTimer);
        _delayTimer = nil;
    }
    
    if ( _runtimeTimer ) {
        dispatch_source_cancel(_runtimeTimer);
        _runtimeTimer = nil;
    }
}

@end
