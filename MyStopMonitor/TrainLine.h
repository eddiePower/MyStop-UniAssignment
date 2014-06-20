//  TrainLine.h
//  MyStopMonitor

//  This class is used to generate train line objects at this point in time
//  it is not in use but when the app is expanded to handle multiple train lines
//  this class will be used to link many station objects together as a train line.
 
//  Created by Eddie Power on 11/06/2014.
//  Copyright (c) 2014 Eddie Power. All rights reserved.

#import <Foundation/Foundation.h>
#import "Station.h"

@interface TrainLine : NSObject

//An array of station objects making up the train line.
//TL to many Stations. Arrays as TrainLine stops dont change.
@property (strong, nonatomic) NSArray* lineStops;

//The train Line name for user display etc.
@property (strong, nonatomic) NSString* lineName;

-(id)initWithStopsArray:(NSArray *)anArray andTrainLineName:(NSString *)aName;

@end
