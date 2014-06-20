//  StopMonitorInfoViewController.h
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

#import <UIKit/UIKit.h>

@interface StopMonitorInfoViewController : UIViewController
@property (weak, nonatomic) IBOutlet UISegmentedControl *infoTextSegment;
@property (strong, nonatomic) IBOutlet UIWebView *aboutWebView;

//return value of the segment selected
- (IBAction)indexChanged:(UISegmentedControl *)sender;

@end
