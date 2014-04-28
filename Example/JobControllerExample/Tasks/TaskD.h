//
//  TaskD.h
//  JobControllerExample
//
//  Created by David House on 4/27/14.
//  Copyright (c) 2014 randomaccident. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaskD : NSOperation

#pragma mark - Properties
@property (nonatomic,strong) UIColor *outputColor;

#pragma mark - Initializer
- (id)initWithRedColor:(UIColor *)redColor greenColor:(UIColor *)greenColor blueColor:(UIColor *)blueColor;

@end
