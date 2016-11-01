//
//  ScheduleViewController.m
//  CJolDemo
//
//  Created by zenghao on 11/6/13.
//  Copyright (c) 2013 zenghao. All rights reserved.
//

#import "ScheduleViewController.h"
#import "AppDelegate.h"

@interface ScheduleViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation ScheduleViewController

@synthesize webView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    SetCurViewController(self);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.vtede.com/tourist/schedule/schedule_info_page.php"]];
    [self.view addSubview: webView];
    [webView loadRequest:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setWebView:nil];
    [super viewDidUnload];
}


@end
