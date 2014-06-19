/*////////////////////////////////////////////////////////////////////////////////
 //  StopMonitorInfoViewController.m                                           //
 //  MyStopMonitor                                                            //
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
 //  Created by Eddie Power on 10/06/2014                     //
 //  Copyright (c) 2014 Eddie Power.                         //
 //  All rights reserved.                                   //
 ////////////////////////////////////////////////////////////*/

#import "StopMonitorInfoViewController.h"

@implementation StopMonitorInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
   

    //Check to see which segment is selected on load its always 0 but
    // this way if the view reloads it dosnt reset
    switch (self.infoTextSegment.selectedSegmentIndex)
    {
        case 0:
            [self showFileWithFileName:@"WelcomeInfo"];
            break;
        case 1:
            [self showFileWithFileName:@"AboutInfo"];
            break;
        default:
            break;
    }
    
}

//Get the fileName passed into this method to build a URL to show as an information page
- (void)showFileWithFileName:(NSString *)aName
{
    //Build the url with file types not a directory
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:aName ofType:@"html"] isDirectory:NO];
    
    //Set the request object with the url
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    //load the request result into the webView on this page.
    [self.aboutWebView loadRequest:request];
}

//catch the value of the changing segment control
- (IBAction)indexChanged:(UISegmentedControl *)sender
{
    //check if segment 0 is pressed show welcome page otherwise show about page.
    switch (self.infoTextSegment.selectedSegmentIndex)
    {
        case 0:
            [self showFileWithFileName:@"WelcomeInfo"];
            break;
        case 1:
            [self showFileWithFileName:@"AboutInfo"];
            break;
        default:
            break;
    }
}
@end
