//
//  SignInViewController.m
//  CJolDemo
//
//  Created by zenghao on 10/30/13.
//  Copyright (c) 2013 zenghao. All rights reserved.
//

#import "PlanDetailViewController.h"
#import "AppDelegate.h" 
#import "SignInViewController.h"

#include <AudioToolbox/AudioToolbox.h>

enum {
    TagInTime = 101,
    TagLate ,
    TagUnKnown,
}TagStatueLabel;

@interface PlanDetailViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic) NSMutableArray * userInfoItems;
@property (retain,nonatomic) NSDictionary  * dict;
@property (weak,nonatomic) id preViewController;
@property (weak, nonatomic) IBOutlet UILabel *onTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *delayLabel;
@property (weak, nonatomic) IBOutlet UILabel *unknownLabel;
@property (weak, nonatomic) IBOutlet UITextField *delayTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *putoffButton;
@property (weak, nonatomic) IBOutlet UILabel *planFinalLabel;
- (IBAction)endEdit:(id)sender;


- (IBAction)putOff:(UIButton *)sender;



- (IBAction)showSignInView:(id)sender;
- (IBAction)callAction:(UIButton *)sender;


//使用下拉刷新 begin
@property(nonatomic,retain)UIImageView *barView;
//使用下拉刷新 end

@end

@implementation PlanDetailViewController
@synthesize tableView;
@synthesize userInfoItems;
@synthesize preViewController;
@synthesize dict;
@synthesize delayTimeLabel;
@synthesize putoffButton;

//使用下拉刷新 begin
@synthesize barView;
//使用下拉刷新 end

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
    
    //使用下拉更新 begin
    if (_refreshHeaderView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
        NSLog(@"headView:%f,%f,%f,%f",0.0f,0.0f-self.tableView.bounds.size.height,self.view.frame.size.width,self.tableView.bounds.size.height);
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
		
	}
    //使用下拉更新 end
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    if ( NO == [[TripManager shareInstance] isAdmin] ) {
        self.delayTimeLabel.enabled = NO;
        self.putoffButton.enabled = NO;
    }
    
    NSDate * finalDate = [dict objectForKey:PLAN_FINALTIME];
    self.planFinalLabel.text = [[TripManager shareInstance] LocalStringFromDate:finalDate];
    
    userInfoItems = [NSMutableArray array];
    [self getPlanState];
    [self.tableView reloadData];
    
    UIToolbar* inputAccessoryView = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
    [inputAccessoryView setBarStyle:UIBarStyleBlack];
    UIBarButtonItem* spaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"完成输入" style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyBoard)];
    NSArray * buttonsArray = [NSArray arrayWithObjects:spaceButton,doneButton,nil];
    [inputAccessoryView setItems:buttonsArray];
    [delayTimeLabel setInputAccessoryView:inputAccessoryView];
    
    
    
}

-(void)dismissKeyBoard{
    [delayTimeLabel resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    return userInfoItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // Configure the cell...
    NSUInteger row = [indexPath row];
    NSString *identifier = @"UserStatusCell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    NSAssert(nil != cell, @"UserStatusCell is nil!");
    
    NSDictionary * userdict = [userInfoItems objectAtIndex:row];
    NSString * name = [userdict objectForKey:PLANSTATUS_ACCOUNT];
    NSString * state = [userdict objectForKey:PLANSTATUS_STATUS];
    NSString * detail = [userdict objectForKey:PLANSTATUS_DETAIL];
    
    UILabel * nameLabel = (UILabel *)[cell viewWithTag:101];
    UILabel * stateLabel = (UILabel *)[cell viewWithTag:102];    
    UIButton * phoneButton = (UIButton *)[cell viewWithTag:103];
    
    NSAssert(nil != nameLabel, @"dateLabel is nil!");
    NSAssert(nil != stateLabel, @"descriptionLabel is nil");
    NSAssert(nil != phoneButton, @"phoneButton is nil");
    
    
    
    
    //[phoneButton addTarget:self action:@selector(callAction) forControlEvents:UIControlEventTouchUpInside];
    UIView *view = [[UIView alloc] init];
    view.tag = row;
    [phoneButton addSubview:view];
    
    NSString * reason = @"";
    
    NSAssert(nil != nameLabel, @"dateLabel is nil!");
    NSAssert(nil != stateLabel, @"descriptionLabel is nil");
    
    if ([state isEqualToString:@"1"]) {
        reason = @"准时";
        stateLabel.textColor = [UIColor greenColor];
        
    }else if([state isEqualToString:@"3"])
    {
        reason = @"无应答";
        stateLabel.textColor = [UIColor redColor];
    }else if([state isEqualToString:@"2"])
    {
        reason = detail;
        stateLabel.textColor = [UIColor grayColor];
    }
    
    
    
    nameLabel.text = name;
    stateLabel.text = reason;
    
    
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    NSAssert(nil != cell, @"UserStatusCell is nil!");
//       
//    UILabel * stateLabel = (UILabel *)[cell viewWithTag:102];
//
//    NSAssert(nil != stateLabel, @"descriptionLabel is nil");
//    
//
//    CGRect frame = stateLabel.frame;
//	frame.origin.x = 200;
//	stateLabel.frame = frame;
//	
//	[UIView beginAnimations:@"testAnimation" context:NULL];
//	[UIView setAnimationDuration:8.8f];
//	[UIView setAnimationCurve:UIViewAnimationCurveLinear];
//	[UIView setAnimationDelegate:self];
//	[UIView setAnimationRepeatAutoreverses:NO];
//	[UIView setAnimationRepeatCount:2];
//	
//	frame = stateLabel.frame;
//	frame.origin.x = -60;
//	stateLabel.frame = frame;
//	[UIView commitAnimations];
}


- (IBAction)endEdit:(id)sender {
    [self.delayTimeLabel resignFirstResponder];
}

- (IBAction)putOff:(UIButton *)sender {
    
    NSString * minuteString = self.delayTimeLabel.text;
    
    int minute = [minuteString intValue];
    
    if (minute >30 || minute <= 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请重新输入时间"
                                                        message:@"延迟时间不能够超过30分钟"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    NSString *planID = [self.dict objectForKey:PLAN_ID];
     NSDate * date = [self.dict objectForKey:PLAN_DATE];
    NSDate * finalDate = [date dateByAddingTimeInterval:(minute * 60)];
    
    BOOL done = NO;
    
    NSString * title = @"";
    NSString * msg = @"";
    
   done = [[TripManager shareInstance] setPlanFinalDate:planID finalDate:finalDate];
    
    if (done) {
        title = @"推迟行程成功";
        msg = @"推迟行程成功";
        
        NSString *dateString = [[TripManager shareInstance] LocalStringFromDate:finalDate];
        
        self.planFinalLabel.text = dateString;
    }else{
        title = @"推迟行程成功";
         msg = @"请检查网络连接状态";
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:msg
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
    
}

- (IBAction)showSignInView:(id)sender {
    SignInViewController *sivc=[[SignInViewController alloc] initWithDictionary:self.dict];
    sivc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    [self presentViewController:sivc animated:YES completion:NULL];
    
}

- (IBAction)callAction:(UIButton *)sender {
    //UITableViewCell * cellView = (UITableViewCell *)[sender superview];
    NSArray *array = [sender subviews];
    NSLog(@"array count:%d",[array count]);
    
    UIView *view = [array lastObject];
    int index = view.tag;
    NSString *number = [[self.userInfoItems objectAtIndex:index] objectForKey:PLANSTATUS_PHONE];// 此处读入电话号码
    
    // NSString *num = [[NSString alloc] initWithFormat:@"tel://%@",number]; //number为号码字符串 如果使用这个方法 结束电话之后会进入联系人列表
    
    NSLog(@"phone NUM:%@",number);
    
    NSString *num = [[NSString alloc] initWithFormat:@"telprompt://%@",number];
    //而这个方法则打电话前先弹框  是否打电话 然后打完电话之后回到程序中 网上说这个方法可能不合无法通过审核
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:num]]; //拨号
}

-(BOOL)getPlanState
{
    NSString * planID = [dict objectForKey:PLAN_ID];
    BOOL done = YES;
    NSArray * array =[[TripManager shareInstance] getPlanState:planID successDone:&done];
    
    if (done) {
        int count =[array count];
        if (count != 0) {
            int ontimeNum = 0;
            int delayNum = 0;
            int unknownNum = 0;
            NSString * final_time = @"";
            
            [userInfoItems removeAllObjects];
            
            for (int i=0; i < count ; i++) {
                NSDictionary * userdict = [array objectAtIndex:i];
                NSString * status = [userdict objectForKey:PLANSTATUS_STATUS];
                final_time = [userdict objectForKey:PLANSTATUS_FINALTIME];
                if ([status isEqualToString:@"1"]) {
                    ontimeNum++;
                }else if([status isEqualToString:@"2"])
                {
                    delayNum++;
                }else if([status isEqualToString:@"3"])
                {
                    unknownNum++;
                }
                
                [userInfoItems addObject:userdict];
            }
            self.onTimeLabel.text = [NSString stringWithFormat:@"%d",ontimeNum];
            self.delayLabel.text = [NSString stringWithFormat:@"%d",delayNum];
            self.unknownLabel.text = [NSString stringWithFormat:@"%d",unknownNum];
            self.planFinalLabel.text =  final_time;
            [self.tableView reloadData];
        }
        
        
    }

    return done;
}


#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)reloadTableViewDataSource{
    NSLog(@"Enter reloadTableViewDataSource!");
	_reloading = YES;
	
}

- (void)doneLoadingTableViewData{
    NSLog(@"Enter doneLoadingTableViewData!");
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}
//下拉到一定距离，手指放开时调用
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	[self reloadTableViewDataSource];
    
    //停止加载，弹回下拉
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:2.0];
    
    if (barView == nil) {
        UIImage *img = [[UIImage imageNamed:@"timeline_new_status_background.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
        barView = [[UIImageView alloc] initWithImage:img];
        barView.frame = CGRectMake(5, -40, 320-10, 40);
        [self.view addSubview:barView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.tag = 100;
        label.font = [UIFont systemFontOfSize:16.0f];
        label.textColor = [UIColor greenColor];
        label.backgroundColor = [UIColor clearColor];
        [barView addSubview:label];
    }
    UILabel *label = (UILabel *)[barView viewWithTag:100];
    label.text = @"更新成功";
    
    [label sizeToFit];
    CGRect frame = label.frame;
    frame.origin = CGPointMake((barView.frame.size.width - frame.size.width)/2, (barView.frame.size.height - frame.size.height)/2);
    label.frame = frame;
    

    [self performSelector:@selector(updateUI) withObject:nil afterDelay:2.0];
    
}

- (void)updateUI {
    [UIView animateWithDuration:0.6 animations:^{
        CGRect frame = barView.frame;
        frame.origin.y = 5;
        barView.frame = frame;
    } completion:^(BOOL finished){
        if (finished) {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDelay:1.0];
            [UIView setAnimationDuration:0.6];
            CGRect frame = barView.frame;
            frame.origin.y = -40;
            barView.frame = frame;
            [UIView commitAnimations];
        }
    }];
    
    [self   getPlanState];
    //获取资源文件的路径,然后播放声音
    NSString *path = [[NSBundle mainBundle] pathForResource:@"msgcome" ofType:@"wav"];
    NSURL *url = [NSURL fileURLWithPath:path];
    SystemSoundID soundId;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundId);
    AudioServicesPlaySystemSound(soundId);
    
    
    [tableView reloadData];
    
}
- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	return _reloading; // should return if data source model is reloading
	
}

//取得下拉刷新的时间
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	return [NSDate date]; // should return date data source was last changed
	
}


@end
