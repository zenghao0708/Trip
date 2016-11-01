//
//  TripManager.h
//  CJolDemo
//
//  Created by zenghao on 11/4/13.
//  Copyright (c) 2013 zenghao. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    RegisterErrorNoError = 0,
    RegisterErrorAlreadyExist,
}RegisterErrorType;

@interface TripManager : NSObject

@property (strong, nonatomic) NSDictionary * loginUser;

+(TripManager *)shareInstance;
+(BOOL) connectedToNetwork;

-(BOOL)login:(NSString *)username pwd:(NSString *)password;

-(BOOL)registerUser:(NSString *)username pwd:(NSString *)password phone:(NSString *)phoneNum;


//warnning
-(NSString *)addWarning:(NSString *)title detail:(NSString *)detailStr start_time:(NSDate *)startDate   b_warning:(NSString *)warningOn successDone:(BOOL *)done;

-(BOOL)removeWarning:(NSString *)warnningId;

-(NSArray *)getWarnning:(int)pageNum itemCount:(int)pageCount  successDone:(BOOL *)done;

//signin
-(BOOL)signin:(NSString *)userID warning_id:(NSString *)planID detail:(NSString *)detail status:(NSString *)ontimeStatus;

-(NSArray *)getPlanState:(NSString *)planID successDone:(BOOL *)done;

-(BOOL)setPlanFinalDate:(NSString *)planID finalDate:(NSDate *)date;

//version
-(int)getPlanVersion:(BOOL *)done;
-(int)getScheduleVersion:(BOOL *)done;

-(BOOL)isAdmin;
-(NSString *)LocalStringFromDate:(NSDate *)date;

-(NSDate *)LocalDateFromString:(NSString *)dateString;


-(NSData *)httpRequest:(NSString *)phpHeader params:(NSDictionary *)requestParams;

@end


