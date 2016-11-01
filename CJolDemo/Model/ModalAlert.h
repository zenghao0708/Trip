//
//  ModalAlert.h
//  CJolDemo
//
//  Created by zenghao on 11/4/13.
//  Copyright (c) 2013 zenghao. All rights reserved.
//


#import <UIKit/UIKit.h>


@interface ModalAlert : NSObject
+ (BOOL) ask: (NSString *) question;
+ (BOOL) confirm:(NSString *) statement;
@end
