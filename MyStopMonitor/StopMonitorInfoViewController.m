//  StopMonitorInfoViewController.m                                          
//  MyStopMonitor

//  This class is used to create a UIViewController, that is used to show
//  both an information page such as instructions and upgrade announcments
//  but also an about page that lets users know what the app is all about,
//  who its made by and how to contact me should they wish to send in an idea.
//  It uses a UIWebView to display the formatted text i wanted quickly, i will change this
//  to a TextKit formatted attributed string and UITextView in the future.
//  This class is a subclass of the UIViewController class, and does not use any delegate methods.

//  Created by Eddie Power on 18/06/2014.
//  Copyright (c) 2014 Eddie Power. All rights reserved.

#import "StopMonitorInfoViewController.h"

@implementation StopMonitorInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Once the user has taped the info button and read the page
    //the badge will disapear as it is not needed
    self.tabBarItem.badgeValue = nil;

    //Check to see which segment is selected on load its always 0 but
    // this way if the view reloads it dosnt reset
    switch (self.infoTextSegment.selectedSegmentIndex)
    {
        case 0:
            //if first segment then show welcome and instruction webpage
            [self showFileWithFileName:@"WelcomeInfo"];
            break;
        case 1:
            //otherwise show the about info file
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
