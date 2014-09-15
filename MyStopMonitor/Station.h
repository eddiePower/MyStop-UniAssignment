//
//  Station.h
//  MyStopMonitor
//
//  Created by Eddie Power on 15/09/2014.
//  Copyright (c) 2014 Eddie Power. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Alarm;

@interface Station : NSManagedObject

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
