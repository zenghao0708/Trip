//
//  PlanDetailViewController.m
//  CJolDemo
//
//  Created by zenghao on 10/29/13.
//  Copyright (c) 2013 zenghao. All rights reserved.
//

#import "AddPlanViewController.h"
#import "PlanViewController.h"
#import "AppDelegate.h"
@interface AddPlanViewController ()
- (IBAction)addPlanDone:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *planDescription;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak,nonatomic) id preViewController;
@property (weak, nonatomic) IBOutlet UITextField *planTitle;

@end

@implementation AddPlanViewController

@synthesize planDescription;
@synthesize datePicker;
@synthesize preViewController;
@synthesize planTitle;

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
    
    UIToolbar* inputAccessoryView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
    [inputAccessoryView setBarStyle:UIBarStyleBlack];
    UIBarButtonItem* spaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"完成输入" style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyBoard)];
    NSArray * buttonsArray = [NSArray arrayWithObjects:spaceButton,doneButton,nil];
    [inputAccessoryView setItems:buttonsArray];
    [planDescription setInputAccessoryView:inputAccessoryView];
    
    planDescription.backgroundColor = [UIColor grayColor];
    
    datePicker.date = [NSDate date];

}
- (IBAction)endEdit:(id)sender {
    [planTitle resignFirstResponder];
}

-(void)dismissKeyBoard{
    [planDescription resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (IBAction)addPlanDone:(id)sender {
    
    NSTimeInterval interval = [[datePicker date] timeIntervalSinceDate:[NSDate date]];
    
    NSLog(@"inteval:%lf",interval);
    BOOL needAlert = NO;
    NSString *title = @"";
    NSString *msg = @"";
    
    if (interval < 5*60) {
       title = @"请选择时间";
        msg = @"行程时间必须大于当前时间5分钟";
        needAlert = YES;
    }else if([planTitle.text length] == 0)
    {
        title = @"标题不能为空";
        msg =@"请输入标题";
        needAlert = YES;
    }else if([planDescription.text length] == 0)
    {
        title = @"描述不能为空";
        msg = @"请输入描述";
        needAlert = YES;
    }
    
    if (needAlert) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:msg
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if ([preViewController respondsToSelector:@selector(addPlanDetail:description:date:)]) {
        NSDate *datePlan = datePicker.date;
        NSTimeZone* GTMzone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        NSDateFormatter *format =[[NSDateFormatter alloc] init];
        [format setTimeZone:GTMzone];
        [format setDateFormat:@"yyyy-MM-dd HH:mm:00"];
        
        NSString * string= [format stringFromDate:datePlan];
        NSDate *date = [format dateFromString:string];
        
        NSString * detail = planDescription.text;
        
        if ([detail length] == 0) {
            detail = @"";
        }
        
        [preViewController addPlanDetail:planTitle.text description:detail date:date];
    }
    [self.navigationController popViewControllerAnimated:YES];
    
}
@end
