//
//  GroupDetailViewController.h
//  CJolDemo
//
//  Created by zenghao on 10/29/13.
//  Copyright (c) 2013 zenghao. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EGORefreshTableHeaderView.h"

@interface PlanViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,EGORefreshTableHeaderDelegate>
{
    //使用下拉刷新 begin
    EGORefreshTableHeaderView *_refreshHeaderView;
    
    BOOL _reloading;
    //使用下拉刷新 end
    
}
-(void)addPlanDetail:(NSString *)planTitle description:(NSString *)planDescription date:(NSDate *)planDate;

//使用下拉刷新 begin
- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

//使用下拉刷新 end

@end
