//
//  SignInViewController.h
//  CJolDemo
//
//  Created by zenghao on 10/31/13.
//  Copyright (c) 2013 zenghao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignInViewController : UIViewController
{
    NSDictionary *dict;
}
-(id)initWithDictionary:(NSDictionary *)planDict;
@end
