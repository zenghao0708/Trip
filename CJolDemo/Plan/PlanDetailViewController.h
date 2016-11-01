//
//  SignInViewController.h
//  CJolDemo
//
//  Created by zenghao on 10/30/13.
//  Copyright (c) 2013 zenghao. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EGORefreshTableHeaderView.h"

@interface PlanDetailViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,EGORefreshTableHeaderDelegate>
{
    //使用下拉刷新 begin
    EGORefreshTableHeaderView *_refreshHeaderView;
    
    BOOL _reloading;
    //使用下拉刷新 end
}

//使用下拉刷新 begin
- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

//使用下拉刷新 end

@end
