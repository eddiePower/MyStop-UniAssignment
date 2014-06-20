//  Station.h
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

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Alarm;

@interface Station : NSManagedObject

//dynamic meaning pulled from core data similar to a database

@property (nonatomic, retain) NSNumber * stationDistance;
@property (nonatomic, retain) NSNumber * stationLatitude;
@property (nonatomic, retain) NSNumber * stationLongitude;
@property (nonatomic, retain) NSString * stationName;
@property (nonatomic, retain) NSNumber * stationStopId;
@property (nonatomic, retain) NSString * stationStopType;
@property (nonatomic, retain) NSString * stationSuburb;
@property (nonatomic, retain) NSSet *alarmStation;
@end

@interface Station (CoreDataGeneratedAccessors)

- (void)addAlarmStationObject:(Alarm *)value;
- (void)removeAlarmStationObject:(Alarm *)value;
- (void)addAlarmStation:(NSSet *)values;
- (void)removeAlarmStation:(NSSet *)values;

@end
