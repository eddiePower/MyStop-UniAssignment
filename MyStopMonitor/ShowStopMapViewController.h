/*///////////////////////////////////////////////////////////////////////////////////
//  ShowStopMapViewController.h                                                   //
//  MyStopMonitor                                                                //
//                                                                              //
//  This view controller draws the map details for the alarm                   //
//  in the users main alarm list                                              //
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

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Station.h"
#import "StopAnnotation.h"

@interface ShowStopMapViewController : UIViewController <MKMapViewDelegate>

//Station Detail output.
@property (weak, nonatomic) IBOutlet UILabel *stationNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *stationTypeLabel;
//station mapView output.
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, readonly) MKMapRect boundingMapRect;
@property (nonatomic) CLLocationCoordinate2D mapCoordinate;
//Station object passed from alarm list to display
@property (strong, nonatomic) Station* mapStation;

@end
