//  TrainLine.m
//  MyStopMonitor
 
//  This class is used to generate train line objects at this point in time
//  it is not in use but when the app is expanded to handle multiple train lines
//  this class will be used to link many station objects together as a train line.
 
//  Created by Eddie Power on 11/06/2014.
//  Copyright (c) 2014 Eddie Power. All rights reserved.

#import "TrainLine.h"

@implementation TrainLine

-(id)initWithTrainLineName:(NSString *)aName andLineNumber:(NSNumber *)aLineNumber
{
    if (self = [super init])
    {
        self.lineName = aName;
        self.lineNumber = aLineNumber;
    }
    
    return self;
}

@end
