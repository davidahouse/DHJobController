//
//  ExampleJob.h
//  JobControllerExample
//
//  Created by David House on 4/27/14.
//  Copyright (c) 2014 randomaccident. All rights reserved.
//

#import "DHJobController.h"

FOUNDATION_EXPORT const NSString *kExampleJobUpdateNotification;

@interface ExampleJob : DHJobController

#pragma mark - Properties
@property (nonatomic,strong) UIColor *taskAColor;
@property (nonatomic,strong) UIColor *taskBColor;
@property (nonatomic,strong) UIColor *taskCColor;
@property (nonatomic,strong) UIColor *taskDColor;

@end
