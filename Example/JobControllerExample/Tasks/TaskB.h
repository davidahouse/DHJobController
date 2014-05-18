//
//  TaskB.h
//  JobControllerExample
//
//  Created by David House on 4/27/14.
//  Copyright (c) 2014 randomaccident. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DHConcurrentOperation.h"

@interface TaskB : DHConcurrentOperation

#pragma mark - Properties
@property (nonatomic,strong) UIColor *outputColor;

@end
