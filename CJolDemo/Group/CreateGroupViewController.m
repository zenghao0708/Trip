//
//  CreateGroupViewController.m
//  CJolDemo
//
//  Created by zenghao on 10/29/13.
//  Copyright (c) 2013 zenghao. All rights reserved.
//

#import "CreateGroupViewController.h"
#import "GroupManagerViewController.h"
#import "AppDelegate.h"

#define COOKBOOK_PURPLE_COLOR	[UIColor colorWithRed:0.20392f green:0.19607f blue:0.61176f alpha:1.0f]
#define BARBUTTON(TITLE, SELECTOR) 	[[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]

@interface CreateGroupViewController ()
@property (weak, nonatomic) id preViewController;
@property (weak, nonatomic) IBOutlet UITextField *GroupName;

@end

@implementation CreateGroupViewController
@synthesize preViewController;
@synthesize GroupName;

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
    
    //self.navigationController.navigationBar.tintColor = COOKBOOK_PURPLE_COLOR;
    self.navigationItem.rightBarButtonItem = BARBUTTON(@"Done", @selector(addGroup));

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)testURLRequest
{
    NSString *urlString =[NSString stringWithFormat:@"https://kc-web.vtechda.com/KidConnectFunction.php?cmd=checkIMUsernameAvailable&sUsername=%@",@"zaaah"];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:urlString]];
    
    [request setHTTPMethod:@"GET"];
    
    
    NSHTTPURLResponse* urlResponse = nil;
    
    NSError *error = [[NSError alloc] init];
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    
    NSMutableString *result = [[NSMutableString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    
    NSLog(@"The result string is :%@",result);
}

-(void)addGroup
{
    if ([self.GroupName.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"组名不能为空"
                                                        message:@"请输入组名"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    if ([preViewController respondsToSelector:@selector(addGroupInTableView:)]) {
        [preViewController addGroupInTableView:self.GroupName.text];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
