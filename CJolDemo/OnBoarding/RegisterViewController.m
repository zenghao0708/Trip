//
//  RegisterViewController.m
//  CJolDemo
//
//  Created by zenghao on 9/25/13.
//  Copyright (c) 2013 zenghao. All rights reserved.
//

#import "RegisterViewController.h"
#import "AppDelegate.h"

extern NSString *CTSettingCopyMyPhoneNumber();

enum{
    TagUserName=101,
    TagPassword,
    TagRepeatPassword,
    TagEmail,
    TagRegister
}RegisterTags;

@interface RegisterViewController ()
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *repeat;
@property (weak, nonatomic) IBOutlet UITextField *phone;
@property Boolean isMoveUp;

- (IBAction)enterEmailBegin:(id)sender;
- (IBAction)registerUser:(UIButton *)sender;



-(IBAction)backgrandTap:(id)sender;
-(IBAction)textFieldReturnEditing:(UITextField *)sender;
@end

@implementation RegisterViewController
@synthesize username;
@synthesize password;
@synthesize repeat;
@synthesize phone;
@synthesize isMoveUp;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.isMoveUp = NO;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //接受端：接受（第一步）
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationHandler:) name:@"mynotification" object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationHandler2:) name:@"mynotification2" object:nil];
    
    NSString * phoneString = CTSettingCopyMyPhoneNumber();
    int len = [phoneString length] ;
    if (len != 0) {
        if (len == 14) {
            NSRange range;
            range.location = 3;
            range.length = 11;
            phoneString = [phoneString substringWithRange:range];
            phone.text = phoneString;
        }
        
    }
}

//自定义接收信息和处理的方法（第二步）
-(void) notificationHandler:(NSNotification *) notification{
    
    username.text = [notification object];//收到消息后在UItextField中显示出来
    
}
//自定义接收字典信息的方法
-(void) notificationHandler2:(NSNotification *) notification2{
    
    NSDictionary *dict = [notification2 object];
    NSLog(@"receive dict :%@,forkey:%@",dict,[dict objectForKey:@"one"]);
    
}


- (void)viewDidUnload
{
    [self setUsername:nil];
    [self setPassword:nil];
    [self setRepeat:nil];
    [self setPhone:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    SetCurViewController(self);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(IBAction)textFieldReturnEditing:(UITextField *)sender
{
    [sender resignFirstResponder];
    if (isMoveUp == YES) {
        isMoveUp = NO;
        [self moveViewCenterVertical:20.0f];
    }
    NSInteger tag = sender.tag;
    tag = tag+1;
    [[self.view viewWithTag:tag] becomeFirstResponder];
    if (tag == TagRegister) {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
   
}

- (IBAction)enterEmailBegin:(id)sender {
    if (NO == isMoveUp) {
        [self moveViewCenterVertical:-20.0f];
        isMoveUp = YES;
    }
   
}

- (IBAction)registerUser:(UIButton *)sender {
    
    BOOL needInputAgain = NO;
    NSString *reason=@"";
    
    NSString *user =username.text;
    NSString *pwd = password.text;
    NSString *repeatPwd = repeat.text;
    NSString *phoneStr = phone.text;
    
    if ([user length] ==0 || [pwd length] ==0 || [repeatPwd length] == 0 || phoneStr == 0) {
        needInputAgain = YES;
        reason = @"请输入完整信息";
    }else if ([password.text isEqualToString:repeat.text] == NO) {
        needInputAgain = YES;
        reason = @"两次输入密码不同";
    }else if ([[TripManager shareInstance] registerUser:user pwd:pwd phone:phoneStr] == NO) {
        needInputAgain = YES;
        reason = @"注册失败，请更换用户名";
    }
    
    if (needInputAgain) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请重新输入"
                                                        message:reason
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }   
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"注册成功"
                                                    message:@"请登录"
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
    
    [self.navigationController popViewControllerAnimated:YES];
}



-(void) moveViewCenterVertical:(CGFloat)distict
{
    CGPoint oldCenter = self.view.center;
    self.view.center = CGPointMake(oldCenter.x,oldCenter.y + distict);
}

-(IBAction)backgrandTap:(id)sender
{
    if (isMoveUp == YES) {
        isMoveUp = NO;
        [self moveViewCenterVertical:20.0f];
    }
    [username resignFirstResponder];
    [password resignFirstResponder];
    [repeat resignFirstResponder];
    [phone resignFirstResponder];
}
@end
