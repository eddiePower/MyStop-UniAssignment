//  StopAnnotation.h
//  MyStopMonitor

//  Thid class is used to create custom annotations on the map for the station objects, It
//  follows the MKAnnotation protocol it generates a region with a custom name and title
//  which is then shown in the callout.

//  Created by Eddie Power on 7/05/2014.
//  Copyright (c) 2014 Eddie Power.
//  All rights reserved.

#import <MapKit/MapKit.h>

@interface StopAnnotation : NSObject <MKAnnotation>

@property (nonatomic, retain) CLRegion *region;
@property (nonatomic, readwrite) CLLocationDistance radius;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* subtitle;

//Used for region creation
-(id)initWithCLRegion:(CLRegion *)newRegion aCoord:(CLLocationCoordinate2D)aCoord aTitle:(NSString *)aTitle andSubtitle:(NSString *)subTitle;
-(id)initWithTitle:(NSString *)aTitle aCoord:(CLLocationCoordinate2D)aCoord andSubtitle:(NSString *)subTitle;

//change annotation location for later use
-(void)setLat:(double)lat andLong:(double)lon;

@end
