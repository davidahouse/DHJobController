//
//  RAJobController.h
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
#import <Foundation/Foundation.h>

/** The 'RAJobController' class manages NSOperation tasks. Tasks are tracked by
 * the controller, and callbacks are made when tasks complete so that logic for
 * what happens next can be contained outside the task. The goal of the job controller
 * is to keep the tasks independent of each other, and connect them together in
 * the controller. This creates very clean code and places all the complexity for jobs
 * in a single place rather than spread across your code.
 *
 * The RAJobController is meant to be sub-classed. Subclasses have the option to respond
 * to generic callbacks when tasks are completed, or provide their own selectors/blocks
 * to handle callbacks. Also, the RAJobController is an NSOperation itself, so jobs can
 * be easily nested to create very complicated flows.
 */
@interface RAJobController : NSOperation

#pragma mark - Properties
@property (nonatomic,readonly) NSOperationQueue *defaultOperationQueue;

#pragma mark - Public Job Methods

/** Starts the job
 *
 * Starts the job on a random queue that is created just for this job operation.
 */
- (void)startJob;

/** Starts the job on a provided queue
 * 
 * Starts the job on a NSOperationQueue that is provided
 *
 * @param queue The queue to start the job on
 */
- (void)startJobOnQueue:(NSOperationQueue *)queue;

#pragma mark - Public Methods

/** Callback when a task is finished
 *
 * Called when ANY task in the job is finished. Should be overriden in a sub-class
 * to do anything useful.
 *
 * @param task The task object that was completed
 */
- (void)taskFinished:(id)task;

/** Callback when a task group is finished
 *
 * Called when the last task in a group is finished. Groups are the Class of the task,
 * so this will be called in addition to the taskFinished callback if there is only a single
 * task in a particular group.
 *
 * @param group The task group that was completed (the Class name in string form)
 */
- (void)taskGroupFinished:(NSString *)group;

/** Callback when all tasks are finished
 *
 * Called when the last task is finished and the
 * job itself is complete. Should be overriden
 * in a sub-class.
 */
- (void)allTasksFinished;

#pragma mark - Track Operations

/** Track a task
 *
 * Add a task to the internal tracking, but does not add it to an NSOperationQueue. Use
 * this method when you want to control the queuing, but still allow the Job Controller
 * to manage the callbacks once the task is finished.
 *
 * @param task The task to start tracking. Task should be an NSOperation subclass.
 */
- (void)trackTask:(id)task;

/** Track and queue a task
 *
 * Adds a task to the internal tracking queue and starts it. The task will start to run immediately
 * once this method has been called.
 *
 * @param task The task to start tracking. Task should be an NSOperation subclass.
 */
- (void)trackAndQueueTask:(id)task;

/** Track a task with a completion selector
 *
 * Add a task to the internal tracking, but does not add it to an NSOperationQueue. Use
 * this method when you want to control the queuing, but still allow the Job Controller
 * to manage the callbacks once the task is finished. Completion selector is called on the
 * job controller once the task is completed.
 *
 * @param task The task to start tracking. Task should be an NSOperation subclass.
 * @param completionSelector The selector to call on the job controller when the task
 * is completed.
 */
- (void)trackTask:(id)task withCompletion:(SEL)completionSelector;
 
/** Track a task and queue it, while also providing a completion selector
 *
 * Adds a task to the internal tracking queue and starts it. The task will start to run immediately
 * once this method has been called. Completion selector is called on the
 * job controller once the task is completed.
 *
 * @param task The task to start tracking. Task should be a NSOperation subclass.
 * @param completionSelector The selector to call on the job controller when the task
 * is completed.
 */
- (void)trackAndQueueTask:(id)task withCompletion:(SEL)completionSelector;

/** Set the completion selector for a task group
 *
 * Sets the completion selector that will be called on the job controller when a specified
 * task group is completed (once all the tasks in that group are finished).
 * 
 * @param completionSelector The selector to call on the job controller when the task
 * group is completed.
 * @param groupClass The Class of the tasks in this group
 */
- (void)setCompletion:(SEL)completionSelector group:(Class)groupClass;

@end
