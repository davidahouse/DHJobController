# DHJobController

[![Version](http://cocoapod-badges.herokuapp.com/v/DHJobController/badge.png)](http://cocoadocs.org/docsets/DHJobController)
[![Platform](http://cocoapod-badges.herokuapp.com/p/DHJobController/badge.png)](http://cocoadocs.org/docsets/DHJobController)

## Usage

To run the example project; clone the repo, and run `pod install` from the Example directory first.

## Requirements

* iOS 6+

## Installation

DHJobController is available through [CocoaPods](http://cocoapods.org), to install
it simply add the following line to your Podfile:

    pod "DHJobController"

## Documentation

### DHJobController

DHJobController helps to manage a job of NSOperations (tasks). Instead of creating dependencies ahead of time,
the job controller provides method callbacks when tasks are completed, which gives the job a place to decide
the next step in the job. The job (also a NSOperation) is not considered complete until all the tasks that
it is managing are complete. The result is very concise code for managing a series of sync or async steps.

To create a job, subclass the DHJobController and then implement the job in the start method as in a normal
NSOperation:

```objectivec
- (void)main
{
  // start the initial task(s) that run in the job
}
```

DHJobControllers are just NSOperations, so normal NSOperation API can be used, but two helper methods can
be used for starting the jobs.

```objectivec
  MyJob *job = [MyJob alloc] init];
  [job startJob];

  MyJob *secondJob = [MyJob alloc] init];
  [job startJobOnQueue:opQueue];
```

The job manages tasks, which are just NSOperations. The job controller can start a task on a queue that
it manages, or you can supply one. To track a task, create an instance of it's class, then use one of the
track... methods.

```objectivec
- (void)main
{
  MyTask *task = [MyTask alloc] init];

  // use trackTask to simply add the task to the list to be monitored. You have to add it to a queue
  // yourself.
  [self trackTask:task];
  [someQueue addOperation:task];

  // use trackAndQueueTask to add the task to a queue and monitor it's progress
  [self trackAndQueueTask:task];
}
```

When tasks are completed there are two options for the job controller to respond and decide what
happens next in the job. The first mechanism for responding to task completion is to implement
the method taskFinished: in your job controller subclass.

```objectivec
- (void)taskFinished:(id)task
{
  if ( [task isKindOfClass:[MyTask class]] ) {
    MyTask *finishedTask = (MyTask *)task;
    // decide what to do next in the job (start more tasks, for example)
  }
}
```

Another option for responding to a task completion is to set a completion selector in your
job controller for the individual task. You can set completion selectors for each individual
task in a job, or mix and match between the taskFinished general method and specific completion
selectors.

```objectivec
- (void)main
{
  MyTask *task = [MyTask alloc] init];
  [self trackAndQueueTask:task withCompletion:@selector(myTaskFinished:)];
}

- (void)myTaskFinished:(id)myTask
{
  MyTask *task = (MyTask *)myTask;
}
```

Additional completion methods are available for tracking the completion of a group of tasks
based on the task Class. First there is a callback when any task group is completed.

```objectivec
- (void)taskGroupFinished:(NSString *)groupName
{
  if ( [groupName isEqualToString:NSStringFromClass([MyTask class]))] ) {
    // all the MyTask tasks are completed
  }
}
```

And a specific selector can be set for a group.

```objectivec
- (void)main
{
  [self setCompletion:@selector(myTasksFinished) group:[MyTask class]];
}

- (void)myTasksFinished
{
  // all the MyTask tasks are done
}
```

Finally there is a method you can override in the job subclass that will get called when
every single task is finished.

```objectivec
- (void)allTasksFinished
{
  // all tasks finished and the job is basically done
}
```

### DHConcurrentOperation

A common need when using NSOperations is to handle asynchronous operations that will
not be complete when the NSOperation main method is completed. In order to handle this case,
your NSOperation must manage the isFinished and isExecuting properties manually. The DHConcurrentOperation
class provides a simpler way to create concurrent operations. To use the class, subclass DHConcurrentOperation
instead of NSOperation, then implement the operationStart method, and finally call the operationDone method
once the asynchronous operation is complete.

## Author

David House, davidahouse@gmail.com

## License

DHJobController is available under the MIT license. See the LICENSE file for more info.
