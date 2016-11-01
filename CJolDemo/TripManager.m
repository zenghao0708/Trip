//
//  TripManager.m
//  CJolDemo
//
//  Created by zenghao on 11/4/13.
//  Copyright (c) 2013 zenghao. All rights reserved.
//

#import "TripManager.h"

#import "AppDelegate.h"

#import <SystemConfiguration/SystemConfiguration.h>
#import <netdb.h>


#define URL_HOST @"http://www.vtede.com/tourist/"


static TripManager * instance=nil;


@implementation TripManager

@synthesize loginUser;

+(TripManager *)shareInstance
{
    if (nil == instance) {
        instance = [[TripManager alloc] init];
    }
    return instance;
}

-(id)init
{
    self = [super init];
    if (self) {
        loginUser = [NSDictionary dictionary];
    }
    return self;
}

+(BOOL) connectedToNetwork
{
    // Create zero addy
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    
    if (!didRetrieveFlags)
    {
        printf("Error. Could not recover network reachability flags\n");
        return NO;
    }
    
    BOOL isReachable = ((flags & kSCNetworkFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkFlagsConnectionRequired) != 0);
    return (isReachable && !needsConnection) ? YES : NO;
}


-(BOOL)login:(NSString *)username pwd:(NSString *)password
{
    NSDictionary * requestParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                    username,@"account",
                                    password,@"pw",
                                    nil];
    NSData * responseData = [self httpRequest:@"user/login.php?" params:requestParams];
    
    if (nil == responseData) {
        return NO;
    }
    
    //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
    NSError *error;
    NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
    NSDictionary *resultClass = [resultDict objectForKey:@"resultClass"];
    NSString *errorCode = [resultClass objectForKey:@"errorcode"];
    NSInteger code = [errorCode integerValue];
    
    self.loginUser = [resultDict objectForKey:@"data"];
    
    if (code == 0 ) {
        return  YES;
    }else{
        return NO;
    }
    
//    [self testURLRequest];
}

-(BOOL)registerUser:(NSString *)username pwd:(NSString *)password phone:(NSString *)phoneNum
{
    NSDictionary * requestParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                    username,@"account",
                                    password,@"pw",
                                    phoneNum,@"phone",
                                    nil];
    NSData * responseData = [self httpRequest:@"user/register.php?" params:requestParams];
    
    if( nil == responseData)
    {
        return NO;
    }
    
    NSError *error;
    NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
    NSDictionary *resultClass = [resultDict objectForKey:@"resultClass"];
    NSString *errorCode = [resultClass objectForKey:@"errorcode"];
    NSInteger code = [errorCode integerValue];
    
    if (code == 0 ) {
        return  YES;
    }else{
        return NO;
    }
}

-(NSString *) LocalStringFromDate:(NSDate *)date
{
    NSDateFormatter *format =[[NSDateFormatter alloc] init];
    [format setTimeZone:[NSTimeZone localTimeZone]];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:00"];
    
    NSString * dateString= [format stringFromDate:date];
    return dateString;
}

-(NSDate *)LocalDateFromString:(NSString *)dateString
{  
    
    NSDateFormatter *format =[[NSDateFormatter alloc] init];
    //NSTimeZone* GTMzone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSTimeZone *GTMzone = [NSTimeZone localTimeZone];
    [format setTimeZone:GTMzone];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:00"];
    
    NSDate * date= [format dateFromString:dateString];
    return date;
}

-(NSString *)addWarning:(NSString *)title detail:(NSString *)detailStr start_time:(NSDate *)startDate   b_warning:(NSString *)warningOn successDone:(BOOL *)done
{
   
    
    
    NSString * dateString= [self LocalStringFromDate:startDate];
    
    NSDictionary * requestParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                    title,@"title",
                                    detailStr,@"detail",
                                    dateString,@"start_time",
                                    warningOn,@"b_warning",
                                    nil];
    NSData * responseData = [self httpRequest:@"info/add_warning_info.php?" params:requestParams];
    
    if( nil == responseData)
    {
        return nil;
    }
    
    NSError *error;
    NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
    NSDictionary *resultClass = [resultDict objectForKey:@"resultClass"];
    NSString *errorCode = [resultClass objectForKey:@"errorcode"];
    NSInteger code = [errorCode integerValue];
    
     
    
    NSDictionary *data = [resultDict objectForKey:@"data"];
    NSString *info_id =[data objectForKey:@"info_id"];
    
    if (code == 0 ) {
        *done = YES;
    }else{
        *done = NO;
    }
    return info_id;
}

-(BOOL)removeWarning:(NSString *)warnningId
{
    NSDictionary * requestParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                    warnningId,@"info_id",
                                    nil];
    
    //fixed me
    NSData * responseData = [self httpRequest:@"info/delete_warning_info.php?" params:requestParams];
    if( nil == responseData)
    {
        return NO;
    }
    
    NSError *error;
    NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
    NSDictionary *resultClass = [resultDict objectForKey:@"resultClass"];
    NSString *errorCode = [resultClass objectForKey:@"errorcode"];
    NSInteger code = [errorCode integerValue];
    
    if (code == 0 ) {
        return  YES;
    }else{
        return NO;
    }
}

-(NSArray *)getWarnning:(int)pageNum itemCount:(int)pageCount  successDone:(BOOL *)done
{
    
    NSDictionary * requestParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                    INT_TO_STRIG(pageNum),@"page",
                                    INT_TO_STRIG(pageCount),@"item_number",
                                    nil];
    
    //fixed me
    NSData * responseData = [self httpRequest:@"info/warning_info.php?" params:requestParams];
    
    if( nil == responseData)
    {
        return nil;
    }
    
    NSError *error;
    NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
    NSDictionary *resultClass = [resultDict objectForKey:@"resultClass"];
    NSString *errorCode = [resultClass objectForKey:@"errorcode"];
    NSInteger code = [errorCode integerValue];
    NSDictionary *data = [resultDict objectForKey:@"data"];

    if (code == 0 ) {
        *done = YES;
    }else{
        *done = NO;
    }
    NSArray * returnArray = [NSArray array];
    
    NSString *countStr = [data objectForKey:@"count"];
    int count =[countStr intValue];
    
    if (count != 0 ) {
        NSArray * array = [data objectForKey:@"WarningInfo"];
        
        if (nil != array) {
            int count = [array count];
            
            for (int i = 0; i < count; i++) {
                NSDate *date= [self LocalDateFromString:[[array objectAtIndex:i] objectForKey:PLAN_DATE]];
                NSDate *final_date = [self LocalDateFromString:[[array objectAtIndex:i] objectForKey:PLAN_FINALTIME]];
                
                NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [[array objectAtIndex:i] objectForKey:PLAN_TITLE],PLAN_TITLE,
                                       [[array objectAtIndex:i] objectForKey:PLAN_DESCRIPTION],PLAN_DESCRIPTION,
                                       [[array objectAtIndex:i] objectForKey:PLAN_ID],PLAN_ID,
                                       [[array objectAtIndex:i] objectForKey:PLAN_WARNNING],PLAN_WARNNING,
                                       final_date,PLAN_FINALTIME,
                                       date,PLAN_DATE,
                                       nil];
                
                returnArray = [returnArray arrayByAddingObject:dict];
                
            }
            
        }
    }
    
    return returnArray;
}


-(BOOL)signin:(NSString *)userID warning_id:(NSString *)planID detail:(NSString *)detailStr status:(NSString *)statusStr
{
    NSDictionary * requestParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                    userID,@"user_id",
                                    planID,@"warning_id",
                                    detailStr,@"detail",
                                    statusStr,@"status",
                                    nil];
    
    //fixed me
    NSData * responseData = [self httpRequest:@"info/set_user_warning_status.php?" params:requestParams];
    
    if( nil == responseData)
    {
        return NO;
    }
    
    NSError *error;
    NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
    NSDictionary *resultClass = [resultDict objectForKey:@"resultClass"];
    NSString *errorCode = [resultClass objectForKey:@"errorcode"];
    NSInteger code = [errorCode integerValue];

    if (code == 0 ) {
        return  YES;
    }else{
        return NO;
    }

}

-(NSArray *)getPlanState:(NSString *)planID successDone:(BOOL *)done
{
    NSDictionary * requestParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                    planID,@"warning_id",
                                    nil];
    
    //fixed me
    NSData * responseData = [self httpRequest:@"info/get_user_warning_status.php?" params:requestParams];
    
    if( nil == responseData)
    {
        return nil;
    }
    
    NSError *error;
    NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
    NSDictionary *resultClass = [resultDict objectForKey:@"resultClass"];
    NSString *errorCode = [resultClass objectForKey:@"errorcode"];
    NSInteger code = [errorCode integerValue];
    NSDictionary *data = [resultDict objectForKey:@"data"];
    
    if (code == 0 ) {
        *done = YES;
    }else{
        *done = NO;
    }
    
    NSArray * returnArray = [NSArray array];
    
    int count =[[data objectForKey:@"count"] intValue];
    
    if (count != 0 ) {
        NSArray * array = [data objectForKey:@"WarningUserStatus"];
        
        if (nil != array) {
            returnArray = [NSArray arrayWithArray:array];                
        }            
    }
    
    return  returnArray;

}

-(int)getPlanVersion:(BOOL *)done
{
    BOOL successDone = NO;
    NSArray * array =  [self getVersion:&successDone];
    
    *done = successDone;
    
    if (successDone) {
        int verID =0;
        int count = [array count];
        for (int i =0 ; i <count ; i++) {
            NSDictionary *dict = [array objectAtIndex:i];
            NSString * type = [dict objectForKey:@"version_type"];
            if ( [type isEqualToString:@"WARNING_UPDATE"]) {
                verID = [[dict objectForKey:@"version"] intValue];
                return verID;
            }
        }
        
    }
    return -1;

}

-(int)getScheduleVersion:(BOOL *)done
{
    BOOL successDone = NO;
    NSArray * array =  [self getVersion:&successDone];
    
    *done = successDone;
    
    if (successDone) {
        int verID =0;
        int count = [array count];
        for (int i =0 ; i <count ; i++) {
            NSDictionary *dict = [array objectAtIndex:i];
            NSString * type = [dict objectForKey:@"version_type"];
            if ( [type isEqualToString:@"ScheduleUpdate"]) {
                verID = [[dict objectForKey:@"version"] intValue];
                return verID;
            }
        }
        
        
    }
    return -1;

}

-(NSArray *)getVersion:(BOOL *)done
{
    NSDictionary * requestParams = [NSDictionary dictionary];
    
    NSData * responseData = [self httpRequest:@"version/get_version.php" params:requestParams];
    
    if( nil == responseData)
    {
        return nil;
    }
    
    NSError *error;
    NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
    NSDictionary *resultClass = [resultDict objectForKey:@"resultClass"];
    NSString *errorCode = [resultClass objectForKey:@"errorcode"];
    NSInteger code = [errorCode integerValue];
    NSArray * returnArray = [NSArray array];
    
    if (code == 0 ) {
       *done = YES;
    
        NSDictionary *data = [resultDict objectForKey:@"data"];
        NSString * countStr = [data objectForKey:@"count"];
        
        if ([countStr intValue] != 0) {
           returnArray = [data objectForKey:@"VersionInfo"];
        }
        
    }else{
        *done = NO;       
    }
    return returnArray;
}

-(BOOL)setPlanFinalDate:(NSString *)planID finalDate:(NSDate *)date
{
    NSString * dateString= [self LocalStringFromDate:date];
    //fixed me
    NSDictionary * requestParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                    planID,@"info_id",
                                    dateString,@"final_time",
                                    nil];
    
    NSData * responseData = [self httpRequest:@"info/update_warning_final_time.php?" params:requestParams];
    
    if(nil == responseData)
    {
        return NO;
    }
    
    NSError *error;
    NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
    NSDictionary *resultClass = [resultDict objectForKey:@"resultClass"];
    NSString *errorCode = [resultClass objectForKey:@"errorcode"];
    NSInteger code = [errorCode integerValue];
    
    if (code == 0 ) {
        return  YES;
    }else{
        return NO;
    }
}



-(NSData *)httpRequest:(NSString *)phpHeader params:(NSDictionary *)requestParams
{
    NSString *urlString = URL_HOST;
    urlString = [urlString stringByAppendingString:phpHeader];
    
    NSString * params = [[NSString alloc] init];
    
    UIApplication * app= [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;
    
    NSArray *keys;
    int i, count;
    id key, value;
    
    keys = [requestParams allKeys];
    count = [keys count];
    for (i = 0; i < count; i++)
    {
        key = [keys objectAtIndex: i];
        value = [requestParams objectForKey: key];
        NSString * param = [NSString stringWithFormat:@"%@=%@&",key,[requestParams objectForKey:key]];
        params = [params stringByAppendingString:param];
    }
    
    urlString = [urlString stringByAppendingString:params];
       
    NSLog(@"usrString:%@",urlString);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding ]];
    
    [request setURL:url];
    [request setHTTPMethod:@"GET"];   
    NSHTTPURLResponse* urlResponse = nil;    
    NSError *error = [[NSError alloc] init];
    
    if( NO == [TripManager connectedToNetwork] )
    {
        AppDelegate * delegate = [AppDelegate app];
        NSString * titleString = delegate.curViewController.navigationItem.title;
        NSLog(@"title：%@",titleString);
        if( NSNotFound == [titleString rangeOfString:@"(未连接)"].location )
        {
            delegate.curViewController.navigationItem.title = [titleString stringByAppendingString:@"(未连接)"];
        }
        
        return nil;
    }
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    
    if( !responseData )
    {
        NSLog(@"Network Error!:%d",error.code);
        return nil;
    }
    
    NSMutableString *result = [[NSMutableString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSLog(@"The result string is :%@",result);
    
    app.networkActivityIndicatorVisible = !app.networkActivityIndicatorVisible;
    
    return responseData;
    
}

-(void)testURLRequest
{
    NSString *urlString =@"http://www.vtede.com/tourist/user/login.php?pw=123456&account=曾浩";
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding ]];
    
    [request setURL:url];
    
    [request setHTTPMethod:@"GET"];
    
    
    NSHTTPURLResponse* urlResponse = nil;
    
    NSError *error = [[NSError alloc] init];
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    
    NSMutableString *result = [[NSMutableString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    NSLog(@"The result string is :%@",result);
}

-(BOOL)isAdmin
{
    return [USER_PRIVILIEGE isEqualToString:@"0"];
}

@end
