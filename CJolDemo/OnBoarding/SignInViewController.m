//
//  SignInViewController.m
//  CJolDemo
//
//  Created by zenghao on 10/31/13.
//  Copyright (c) 2013 zenghao. All rights reserved.
//

#import "SignInViewController.h"
#import "AppDelegate.h"
#import "TripManager.h"

#define FILE_OF_REASON [NSHomeDirectory() stringByAppendingString:@"/Documents/reason.xml"]

#define REASON_FIELD            @"reason"

@interface SignInViewController ()
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptonLabel;
@property (weak, nonatomic) IBOutlet UISwitch *onTimeSwitch;
@property (weak, nonatomic) IBOutlet UITextField *lateMinuteField;
@property (weak, nonatomic) IBOutlet UILabel *lateMinuteLabel;
@property (retain, nonatomic) NSDictionary *dict;
@property (weak, nonatomic) IBOutlet UISwitch *remindSwitch;
@property (weak, nonatomic) IBOutlet UITextField *reasonField;

@property  (strong ,nonatomic)   NSMutableDictionary * reasonDict;

- (IBAction)back:(UIButton *)sender;
- (IBAction)valueChanged:(UISwitch *)sender;
- (IBAction)signin:(UIButton *)sender;
- (IBAction)endEdit:(id)sender;
@end

@implementation SignInViewController
@synthesize dateLabel;
@synthesize titleLabel;
@synthesize descriptonLabel;
@synthesize onTimeSwitch;
@synthesize lateMinuteField;
@synthesize lateMinuteLabel;
@synthesize dict;
@synthesize remindSwitch;
@synthesize reasonField;

@synthesize reasonDict;

-(id)initWithDictionary:(NSDictionary *)planDict{
    self = [super init];
    if (self) {
        self.dict=[[NSDictionary alloc] initWithDictionary:planDict];
    }
    return  self;
}

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
    
    reasonDict = [NSDictionary dictionaryWithContentsOfFile:FILE_OF_REASON];
    
    if (nil != reasonDict) {
        reasonField.text = [reasonDict objectForKey:REASON_FIELD];
    }else{
        reasonDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                      @"",REASON_FIELD
                      ,nil];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (nil != reasonDict) {
        [reasonDict setObject:reasonField.text forKey:REASON_FIELD];
        [reasonDict writeToFile:FILE_OF_REASON atomically:YES];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view
    //self.view = [[[NSBundle mainBundle] loadNibNamed:@"SignInViewController" owner:self options:nil] lastObject];
    
    NSString *title = [self.dict objectForKey:PLAN_TITLE];
    NSString *description = [self.dict objectForKey:PLAN_DESCRIPTION];
    titleLabel.text = [NSString stringWithFormat:@"标题： %@",title];
    descriptonLabel.text = [NSString stringWithFormat:@"%@",description];
    NSDate *date=[self.dict objectForKey:PLAN_DATE];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"YYYY-MM-dd HH:mm"];
    
    NSString *dateString = [format stringFromDate:date];
    dateLabel.text = [NSString stringWithFormat:@"时间： %@",dateString ];
    
    UIToolbar* inputAccessoryView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
    [inputAccessoryView setBarStyle:UIBarStyleBlack];
    UIBarButtonItem* spaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"完成输入" style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyBoard)];
    NSArray * buttonsArray = [NSArray arrayWithObjects:spaceButton,doneButton,nil];
    [inputAccessoryView setItems:buttonsArray];
    [lateMinuteField setInputAccessoryView:inputAccessoryView];
    
    lateMinuteField.enabled=NO;
    reasonField.enabled = NO;
}

-(void)dismissKeyBoard{
    [lateMinuteField resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)back:(UIButton *)sender {
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)valueChanged:(UISwitch *)sender {
    BOOL isOn= [sender isOn];
    if (isOn) {
        lateMinuteField.enabled=NO;
        reasonField.enabled = NO;
    }else{
        lateMinuteField.enabled=YES;
        reasonField.enabled = YES;
    }
}

-(void)stopTimerSchedule:(NSDictionary *)planDict{
    NSArray *array=[[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification *notification in array) {
        //在可以我们可以获取本地通知的值，如notification.userInfo等
        NSDate *date = [notification.userInfo objectForKey:PLAN_DATE];
        NSDate *planDate = [planDict objectForKey:PLAN_DATE];
        if ([date isEqualToDate:planDate]) {
            //[UIApplication sharedApplication].applicationIconBadgeNumber--;
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
    }
}

- (IBAction)signin:(UIButton *)sender {
    NSLog(@"signin");
    
    NSDate *planDate = [dict objectForKey:PLAN_DATE];
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:planDate];
    if (interval > 0.0f) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"签到失败"
                                                        message:@"行程时间已过，不能签到，请主动联系管理员"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }else if(interval < (-60* ALTER_MINITER) )
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"签到失败"
                                                     message:@"只能提前15分钟签到"
                                                    delegate:nil
                                           cancelButtonTitle:@"确定"
                                           otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    NSString *lateString = lateMinuteField.text;
    int minute = [lateString intValue];
    
    if (minute >30 || minute <= 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请重新输入时间"
                                                        message:@"延迟时间不能够超过30分钟"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if ( NO == [TripManager connectedToNetwork] ) {
        NSLog(@"can not connected to netword");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"网络连接问题"
                                                        message:@"请开启网络"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    NSString * userID = USER_ID;
    NSString * planID = [self.dict objectForKey:PLAN_ID];
    NSString * statusStr = @"1";
    NSString * detailStr = @"OK";
    
    if ([[self onTimeSwitch] isOn]) {
        statusStr = @"1";
    }else
    {
        statusStr = @"2";
        detailStr = [NSString stringWithFormat:@"%@分钟，%@",lateMinuteField.text,reasonField.text];

    }
    
    if ([[TripManager shareInstance] signin:userID warning_id:planID detail:detailStr status:statusStr]) {
        [self stopTimerSchedule:self.dict];
        [self addRemindSchedule];
                
        [self dismissViewControllerAnimated:YES completion:NULL];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"签到失败"
                                                        message:@"请检查网络"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
}

-(void)addRemindSchedule
{
    if ([remindSwitch isOn]) {
        UILocalNotification *notification=[[UILocalNotification alloc] init];
        if (notification!=nil)
        {
            
//          NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
//                                  title,PLAN_TITLE,
//                                  description,PLAN_DESCRIPTION,
//                                  datePlan,PLAN_DATE,
//                                  planID,PLAN_ID,
//                                  isWarnning,PLAN_WARNNING,
//                                  nil];
            //提前5分钟提醒
            notification.fireDate=[[NSDate date] dateByAddingTimeInterval:(60 *5) ];//距现在多久后触发代理方法
            NSLog(@"first date:%@",notification.fireDate);
            
            notification.timeZone=[NSTimeZone defaultTimeZone];
            notification.soundName = ALERT_RING;
            notification.alertBody = REMIND_ALERT_BODY;
//            notification.userInfo = dict;
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        }

    }
}

- (IBAction)endEdit:(id)sender {
    [lateMinuteField resignFirstResponder];
    [reasonField resignFirstResponder];
}

@end
