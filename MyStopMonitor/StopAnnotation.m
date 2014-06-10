/*////////////////////////////////////////////////////////////////////////////////
//  StopAnnotation.m                                                           //
//  MyStopMonitor                                                             //
//                                                                           //
//  This project is to use the ios core location to monitor a users         //
//  location while on public transport in this case a train running        //
//  on the Frankston Line and a user will set the stop they would         //
//  like to be notified before they reach, the phone will then           //
//  alert the user to the upcoming stop and they can wake up or         //
//  prepare to disembark the train with lots of time and not           //////////
//  missing there stop. This will be widened to accept multiple               //
//  train lines and transport types in an upcoming update soon.              //
//                                                                          //
//  The above copyright notice and this permission notice shall            //
//  be included in all copies or substantial portions of the              //
//  Software.                                                            //
//                                                                      //
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY          //
//  KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE        //
//  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR          //
//  PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE              //
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,          //
//  DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF           //
//  CONTRACT, TORT OR OTHERWISE, ARISING FROM,OUT OF OR IN       //
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER            //
//  DEALINGS IN THE SOFTWARE.                                  //
//                                                            //
//  Created by Eddie Power on 7/05/2014.                     //
//  Copyright (c) 2014 Eddie Power.                         //
//  All rights reserved.                                   //
////////////////////////////////////////////////////////////*/

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
		//radius = region.radius;
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

-(void)setLat:(double)lat andLong:(double)lon
{
    CLLocationCoordinate2D location;
    location.latitude = lat;
    location.longitude = lon;
    
    self.coordinate = location;
}

/*
 This method provides a custom setter so that the model is notified when the subtitle value has changed.
 * such as when a new radius is set or a pin is moved.
 */
- (void)setRadius:(CLLocationDistance)newRadius
{
	radius = newRadius;
}

@end
