//
//  ViewController.m
//  CJolDemo
//
//  Created by zenghao on 9/25/13.
//  Copyright (c) 2013 zenghao. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "AppDelegate.h"
#import "TripManager.h"





enum TagLoginView {
    TagUsernae = 101,
    TagPassword,
    TagLogin,
    };

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *Password;
@property (strong ,nonatomic) NSMutableDictionary * loginInfo;
@property BOOL successLogin;

- (IBAction)login:(UIButton *)sender;
- (IBAction)textFieldReturnEditing:(UITextField *)sender;
- (IBAction)backgrandTap:(id)sender;


@end

@implementation LoginViewController

@synthesize usernameField;
@synthesize Password;
@synthesize loginInfo;
@synthesize successLogin;

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    SetCurViewController(self);
    
    loginInfo = [NSMutableDictionary dictionaryWithContentsOfFile:LOGIN_INFO_FILE_PATH];
    if (nil != loginInfo ) {
        NSString *user = [loginInfo objectForKey:LOGIN_USERNMAE];
        NSString *password = [loginInfo objectForKey:LOGIN_PASSWORD];
        
        self.usernameField.text = user;
        self.Password.text = password;
        
        [self performSelector:@selector(tryAutoLogin) withObject:self afterDelay:1];
    }
    
    if (successLogin == NO) {
        loginInfo = [NSMutableDictionary dictionary];
    }
       
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (nil != loginInfo) {
        if ([[loginInfo objectForKey:LOGIN_USERNMAE] length ] != 0) {
            [loginInfo writeToFile:LOGIN_INFO_FILE_PATH atomically:YES];
        }
    
    }

    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
        
    loginInfo = [NSMutableDictionary dictionaryWithContentsOfFile:LOGIN_INFO_FILE_PATH];
    if (nil != loginInfo ) {
        NSString *user = [loginInfo objectForKey:LOGIN_USERNMAE];
        NSString *password = [loginInfo objectForKey:LOGIN_PASSWORD];
        
        self.usernameField.text = user;
        self.Password.text = password;
        
        [self performSelector:@selector(tryAutoLogin) withObject:self afterDelay:1];
    }
    
    if (successLogin == NO) {
        loginInfo = [NSMutableDictionary dictionary];
    }
    
}

-(void)showMainView
{
    [self performSegueWithIdentifier:@"Login" sender:self];
}

-(void)tryAutoLogin{
    
    UIActivityIndicatorView *acv = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f,0.0f, 32.0f, 32.0f)];
    [acv setCenter:CGPointMake(160.f, 208.0f)];
    [acv setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
       
    
    NSString *user = self.usernameField.text;
    NSString *password = self.Password.text;
        
    if ([user length] ==0 || [password length] ==0) {
        self.successLogin = NO;
        return;
    }
        
    [self.view addSubview:acv];
    [acv startAnimating];
    if ([[TripManager shareInstance] login:user pwd:password]) {
        [acv stopAnimating];
        successLogin = YES;
        [self performSegueWithIdentifier:@"Login" sender:self];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"登陆失败"
                                                            message:@"请检查用户名、密码是否正确"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
        [alert show];
        usernameField.text = user;
        Password.text=@"";
    }

}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    //return (interfaceOrientation != UIInterfaceOrientationPortrait);
}

- (IBAction)login:(UIButton *)sender {
    if ([usernameField.text length] == 0 || [Password.text length] ==0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"用户名、密码不能为空"
                                                        message:@"请正确输入用户名和密码"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if ([[TripManager shareInstance] login:usernameField.text pwd:Password.text] == NO) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"登陆失败"
                                                        message:@"请确认用户名、密码是否正确"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [loginInfo setObject:usernameField.text forKey:LOGIN_USERNMAE];
    [loginInfo setObject:Password.text forKey:LOGIN_PASSWORD];
    
    [self performSegueWithIdentifier:@"Login" sender:self];
}

-(IBAction)textFieldReturnEditing:(UITextField *)sender
{
    [sender resignFirstResponder];
    int tag = sender.tag;
    tag = tag+1;
    [[self.view viewWithTag:tag] becomeFirstResponder];
    if (TagLogin == tag) {
        [self performSegueWithIdentifier:@"ContentTab" sender:self];
    }
}

- (IBAction)backgrandTap:(id)sender {
    [usernameField resignFirstResponder];
    [Password resignFirstResponder];
}


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}



@end
