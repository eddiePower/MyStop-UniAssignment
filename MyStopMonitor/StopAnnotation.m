//  StopAnnotation.m                                                           //
//  MyStopMonitor

//  Thid class is used to create custom annotations on the map for the station objects, It
//  follows the MKAnnotation protocol it generates a region with a custom name and title
//  which is then shown in the callout.

//  Created by Eddie Power on 7/05/2014.
//  Copyright (c) 2014 Eddie Power.
//  All rights reserved.

#import "StopAnnotation.h"

@implementation StopAnnotation

//Using synthesize insted of self. to show what the compiler does under the hood.
//Now old probably soon to be depreciated code
@synthesize region, coordinate, radius, title, subtitle;

//Used to init annotation with built in region for monitoring
-(id)initWithCLRegion:(CLRegion *)newRegion aCoord:(CLLocationCoordinate2D)aCoord aTitle:(NSString *)aTitle andSubtitle:(NSString *)subTitle
{
    if(self = [super init])
    {
        title = aTitle;
        subtitle = subTitle;
        region = newRegion;
		coordinate = aCoord;
    }
    
    return self;
}


//Used for creating only station annotations for map display only.
-(id)initWithTitle:(NSString *)aTitle aCoord:(CLLocationCoordinate2D)aCoord andSubtitle:(NSString *)subTitle
{
    if(self = [super init])
    {
        self.coordinate = aCoord;
        self.title = aTitle;
        self.subtitle = subTitle;
    }
    
    
    return self;
}

//change lat and long of an annotation
-(void)setLat:(double)lat andLong:(double)lon
{
    CLLocationCoordinate2D location;
    location.latitude = lat;
    location.longitude = lon;
    
    self.coordinate = location;
}

@end
