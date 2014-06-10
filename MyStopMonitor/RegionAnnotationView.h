

#import <MapKit/MapKit.h>
#import "StopAnnotation.h"

@class RegionAnnotation;

@interface RegionAnnotationView : MKPinAnnotationView
{
  @private MKCircle *radiusOverlay;
  BOOL isRadiusUpdated;
}

@property (nonatomic, assign) MKMapView *map;
@property (nonatomic, assign) StopAnnotation *theAnnotation;

- (id)initWithAnnotation:(id <MKAnnotation>)annotation;
- (void)updateRadiusOverlay;
- (void)removeRadiusOverlay;

@end