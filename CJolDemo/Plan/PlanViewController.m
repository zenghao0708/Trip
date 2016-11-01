//
//  GroupDetailViewController.m
//  CJolDemo
//
//  Created by zenghao on 10/29/13.
//  Copyright (c) 2013 zenghao. All rights reserved.
//

#import "PlanViewController.h"
#include <AudioToolbox/AudioToolbox.h>

#define PAGE_COUNT  50

#import "AppDelegate.h"

#import "ModalAlert.h"

#define FILE_OF_PLANVIEW [NSHomeDirectory() stringByAppendingString:@"/Documents/planview.xml"]

#define FILE_OF_PLANVER [NSHomeDirectory() stringByAppendingString:@"/Documents/planver.xml"]

@interface PlanViewController ()
@property                       NSString * ver;
@property                       BOOL needRemoveData;

@property (weak, nonatomic)     id preViewController;
@property (weak, nonatomic)     IBOutlet UITableView *tableView;
@property (strong,nonatomic)    NSDictionary *selection;
@property (copy,nonatomic)      NSMutableArray * planItems;

@property (weak, nonatomic)     IBOutlet UIBarButtonItem *addButton;
@property (strong,nonatomic)   NSTimer * updateTimer;

//使用下拉刷新 begin
@property(nonatomic,retain)UIImageView *barView;
//使用下拉刷新 end

@end

@implementation PlanViewController
@synthesize     preViewController;
@synthesize     selection;
@synthesize     tableView;
@synthesize     planItems;
@synthesize     needRemoveData;
@synthesize     ver;
@synthesize     updateTimer;

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
    
    
    [self updateWarning:0 pageCount:PAGE_COUNT];
    
    
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

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSString *filePath = FILE_OF_PLANVIEW;
    [planItems writeToFile:filePath atomically:YES];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //NSString *groupName = [selection objectForKey:@"groupName"];
    //self.title = groupName;
    
    
    if ([[TripManager shareInstance] isAdmin] == NO) {
        self.navigationItem.rightBarButtonItem.enabled = false;
    }
    
    tableView.delegate = self;
    tableView.dataSource = self;

        
    planItems =[planItems initWithContentsOfFile:FILE_OF_PLANVIEW];    
    if (nil == planItems) {
        planItems = [NSMutableArray array];
    }
    
    updateTimer = [NSTimer scheduledTimerWithTimeInterval:(AUTO_UPDATE_MINUTE * 60) target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
}

-(void)timerFired{
    NSLog(@"plan view  timerFired!");
    [self.tableView reloadData];
    [self updateWarning:0 pageCount:PAGE_COUNT];
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
    return planItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // Configure the cell...
    NSUInteger row = [indexPath row];
    NSString *identifier = @"PlanCell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    NSAssert(nil != cell, @"PlanCell is nil!");
    
    NSDictionary * dict = [planItems objectAtIndex:row];
    NSString * title = [dict objectForKey:PLAN_TITLE];
    NSDate * date = [dict objectForKey:PLAN_DATE];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"YYYY-MM-dd HH:mm"];
    NSString *dateString = [dateFormat stringFromDate:date];
    
    NSTimeInterval interval= [date timeIntervalSinceNow];
    
    int laterPlanInterval = ALTER_MINITER * 60;
    int prePlanInterval = (-1) * 60;
    
    
    
    UILabel * dateLabel = (UILabel *)[cell viewWithTag:101];
    UILabel * descriptionLabel = (UILabel *)[cell viewWithTag:102];
    UILabel * stateLabel = (UILabel *)[cell viewWithTag:103];
    
    NSAssert(nil != dateLabel, @"dateLabel is nil!");
    NSAssert(nil != descriptionLabel, @"descriptionLabel is nil");
    NSAssert(nil != stateLabel, @"stateLabel is nil");
    
    
    dateLabel.text = dateString;
    descriptionLabel.text = title;
   
    UIColor *color = [[UIColor alloc] init];
    NSString * stateString = @"";
    if (interval < prePlanInterval) {
        color = [UIColor grayColor];
        stateString = @"已过";
    }else if(interval > laterPlanInterval)
    {
        color = [UIColor greenColor];
        stateString = @"期待";
    }else {
        color = [UIColor redColor];
        stateString = @"正在进行";
    }
    
    stateLabel.text = stateString;
    stateLabel.textColor = color;
    
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


 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
     if (editingStyle == UITableViewCellEditingStyleDelete) {
         // Delete the row from the data source
         
         if ([[TripManager shareInstance] isAdmin] == NO) {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"删除行程失败"
                                                             message:@"只有管理员有权限删除行程"
                                                            delegate:nil
                                                   cancelButtonTitle:@"确定"
                                                   otherButtonTitles:nil];
             [alert show];
             return;
         }
         
         NSUInteger answer = [ModalAlert ask:@"确定要删除这条行程吗?"];
         if (answer == 1) {
             NSLog(@"answer:%d",answer);
             
             NSDictionary *dict = [planItems objectAtIndex:[indexPath row]];
             NSString * planID = [dict objectForKey:PLAN_ID];
             
             if ([[TripManager shareInstance] removeWarning:planID]) {
                 [self removeTimerSchedule:dict];
                 [planItems removeObjectAtIndex:[indexPath row]];
                 
                 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
             }else {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"删除行程失败"
                                                                 message:@"请检查网络是否连接正确！"
                                                                delegate:nil
                                                       cancelButtonTitle:@"确定"
                                                       otherButtonTitles:nil];
                 [alert show];
             }
             
         }
         
     }
     else if (editingStyle == UITableViewCellEditingStyleInsert) {
         // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
 }


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
}


-(void)pushAddPlan{
    [self performSegueWithIdentifier:@"PlanDetail" sender:self];
}

-(void)addPlanDetail:(NSString *)planTitle description:(NSString *)planDescription date:(NSDate *)planDate
{
    
    //提交到网络数据库
    BOOL done = YES;
    NSString  *planID = [[TripManager shareInstance] addWarning:planTitle detail:planDescription start_time:planDate b_warning:WARNNING_ON successDone:&done];
    if (done) {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              planTitle,PLAN_TITLE,
                              planDescription,PLAN_DESCRIPTION,
                              planDate, PLAN_DATE,
                              planID,PLAN_ID,
                              WARNNING_ON,PLAN_WARNNING,
                              nil];
        [self.planItems addObject:dict];
        [self addTimerSchedule:dict];
        [self.tableView reloadData];        
    }else{
        NSLog(@"can not connected to netword");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"添加行程失败"
                                                        message:@"请开启网络"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
    }

    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"UserInfo"]) {
        NSLog(@"prepareForSegue UserInfo!");
        UIViewController * destination = [segue destinationViewController];
        if ([destination respondsToSelector:@selector(setPreViewController:)]){
            
            [destination setValue:self forKey:@"preViewController"];
        }
        
        if ([destination respondsToSelector:@selector(setDict:)]) {
            NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
            id object = [self.planItems objectAtIndex:indexPath.row];
            [destination setValue:object forKey:@"dict"];
        }
    }
    
    if ([segue.identifier isEqualToString:@"AddPlan"]) {
        NSLog(@"prepareForSegue AddPlan!");
        UIViewController * destination = [segue destinationViewController];
        if ([destination respondsToSelector:@selector(setPreViewController:)]){
            
            [destination setValue:self forKey:@"preViewController"];
        }
    }
}


//添加 定时提醒功能
-(void)addTimerSchedule:(NSDictionary *)planDict{
    //计算多少秒后闹钟响应时间
        
    //提前5分钟提醒
    NSDate *datePlan = [planDict objectForKey:PLAN_DATE];  
    NSString *title = [planDict objectForKey:PLAN_TITLE];
    NSString *description = [planDict objectForKey:PLAN_DESCRIPTION];
    NSString  *isWarnning = [planDict objectForKey:PLAN_WARNNING];
    NSString *planID = [planDict objectForKey:PLAN_ID];
    
    //不需要添加
    NSTimeInterval intervalSinceNow = [datePlan timeIntervalSinceNow];
    
    if (intervalSinceNow < 60 * ALTER_MINITER) {
        NSLog(@"do not need to add timerSchedule,because interval:%lf",intervalSinceNow);
        return ;
    }
    
    //建立后台消息对象
    UILocalNotification *notification=[[UILocalNotification alloc] init];
    if (notification!=nil)
    {
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              title,PLAN_TITLE,
                              description,PLAN_DESCRIPTION,
                              datePlan,PLAN_DATE,
                              planID,PLAN_ID,
                              isWarnning,PLAN_WARNNING,
                              nil];
        notification.repeatInterval=NSMinuteCalendarUnit;
        //提前5分钟提醒
        notification.fireDate=[datePlan dateByAddingTimeInterval:(-60 *ALTER_MINITER) ];//距现在多久后触发代理方法
        NSLog(@"first date:%@",notification.fireDate);
        
        notification.timeZone=[NSTimeZone defaultTimeZone];
        notification.soundName = ALERT_RING;
        notification.alertBody = PLAN_ALERT_BODY;
        notification.userInfo = dict;
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        //[UIApplication sharedApplication].applicationIconBadgeNumber++;
    }  
    
}


-(void)removeTimerSchedule:(NSDictionary *)planDict{
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

-(BOOL)updateWarning:(int)pageNum pageCount:(int)pageCount
{
    BOOL done = YES;
    [self checkVer];
    
    if (needRemoveData) {
        NSArray * array = [[TripManager shareInstance] getWarnning:pageNum itemCount:pageCount successDone:&done];
        
        if ([array count] >0) {
            
            [planItems removeAllObjects];
            
            [planItems addObjectsFromArray:array];
            [self  updatePlanSchedule];
            [planItems writeToFile:FILE_OF_PLANVIEW atomically:YES];
            [self.tableView reloadData];
        }
        
        return done;

    }else{
        return NO;
    }
}

-(void)updatePlanSchedule
{
    UIApplication * app = [UIApplication sharedApplication];
    NSArray * array= app.scheduledLocalNotifications;
    
    int lnCount = [array count];
    for (int i = 0; i < lnCount; i++) {
        UILocalNotification * ln = [array objectAtIndex:i];
        NSLog(@"alert body:%@",ln.alertBody);
        if ([ln.alertBody isEqualToString:PLAN_ALERT_BODY]) {
            [app cancelLocalNotification:ln];
        }
    }
    
    int planCount = [planItems count];
    for (int i = 0 ; i <planCount; i++) {
        NSDictionary *dict = [planItems objectAtIndex:i];
        [self addTimerSchedule:dict];
    }

}

-(void)checkVer
{
    BOOL done = NO;
    int serverVer = [[TripManager shareInstance] getPlanVersion:&done];
    
    if (done == NO) {
        needRemoveData = NO;
    }else
    {
        if ([ver intValue] < serverVer) {
            needRemoveData = YES;
            ver = [NSString stringWithFormat:@"%d",serverVer];
        }else
        {
            needRemoveData = NO;
        }
    }
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
    
    [self updateWarning:0 pageCount:PAGE_COUNT];
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
