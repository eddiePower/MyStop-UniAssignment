//  Station.m
//  MyStopMonitor

//  This class is used to create station object to store data
//  about the different stations on a train line, this data is
//  stored in Core Data and this file is an auto generated file
//  and a subclass of NSManagedObject.  It refrences a set of alarms
//  as the relationship with Alarm and Station in CD is 1...* or 1 to many
//  With An Alarm haveing One station and each station can be in many alarms,
//  I think i will change this soon as the region monitoring only handles one entry
//  of a geographical area at a time and one alarm can be turned on and off when needed.

//  Created by Eddie Power on 11/06/2014.
//  Copyright (c) 2014 Eddie Power. All rights reserved.

#import "Station.h"
#import "Alarm.h"

@implementation Station

@dynamic stationDistance;
@dynamic stationLatitude;
@dynamic stationLongitude;
@dynamic stationName;
@dynamic stationStopId;
@dynamic stationStopType;
@dynamic stationSuburb;
@dynamic alarmStation;

@end
