//
//  ViewController.m
//  JobControllerExample
//
//  Created by David House on 4/27/14.
//  Copyright (c) 2014 randomaccident. All rights reserved.
//

#import "ViewController.h"
#import "ExampleJob.h"

@interface ViewController ()

#pragma mark - Properties
@property (nonatomic,strong) ExampleJob *job;
@property (weak, nonatomic) IBOutlet UIView *taskACircle;
@property (weak, nonatomic) IBOutlet UIView *taskBCircle;
@property (weak, nonatomic) IBOutlet UIView *taskCCircle;
@property (weak, nonatomic) IBOutlet UIView *taskDCircle;
- (IBAction)refreshColorsPressed:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    __weak ViewController *weakself = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:(NSString *)kExampleJobUpdateNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        
        [weakself updateUI];
    }];
    
    self.taskACircle.layer.cornerRadius = 25;
    self.taskBCircle.layer.cornerRadius = 25;
    self.taskCCircle.layer.cornerRadius = 25;
    self.taskDCircle.layer.cornerRadius = 25;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)refreshColorsPressed:(id)sender {

    if ( !self.job ) {
        
        NSLog(@"starting job!");
        self.taskACircle.backgroundColor = [UIColor lightGrayColor];
        self.taskBCircle.backgroundColor = [UIColor lightGrayColor];
        self.taskCCircle.backgroundColor = [UIColor lightGrayColor];
        self.taskDCircle.backgroundColor = [UIColor lightGrayColor];
        
        self.job = [[ExampleJob alloc] init];
        __weak ViewController *weakself = self;
        [self.job setCompletionBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself jobFinished];
            });
        }];
        [self.job startJob];
    }
    else {
        NSLog(@"cancelling job!");
        [self.job cancel];
    }
}

- (void)jobFinished
{
    NSLog(@"job finished! cancelled? %@", [self.job isCancelled] ? @"YES" : @"NO");
    if ( ![self.job isCancelled] ) {
        [self updateUI];
    }
    else {
        self.taskACircle.backgroundColor = [UIColor lightGrayColor];
        self.taskBCircle.backgroundColor = [UIColor lightGrayColor];
        self.taskCCircle.backgroundColor = [UIColor lightGrayColor];
        self.taskDCircle.backgroundColor = [UIColor lightGrayColor];
    }
    self.job = nil;
}

- (void)updateUI
{
    // Update our circles based on the job properties
    if ( self.job.taskAColor ) {
        self.taskACircle.backgroundColor = self.job.taskAColor;
    }
    
    if ( self.job.taskBColor ) {
        self.taskBCircle.backgroundColor = self.job.taskBColor;
    }
    
    if ( self.job.taskDColor ) {
        self.taskDCircle.backgroundColor = self.job.taskDColor;
    }
    
    if ( self.job.taskCColor ) {
        self.taskCCircle.backgroundColor = self.job.taskCColor;
    }
}

@end
