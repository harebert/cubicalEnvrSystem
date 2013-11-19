//
//  currentStatusViewController.h
//  cubicalEnvrSystem
//
//  Created by 朱 皓斌 on 13-11-12.
//  Copyright (c) 2013年 朱 皓斌. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBJson.h"
#import "statusCell.h"
#import "chartViewController.h"
@interface currentStatusViewController : UITableViewController<NSURLConnectionDataDelegate>{
    NSMutableData *JsonData;
    NSArray *tableViewContent;
}

@property(nonatomic,retain)UIRefreshControl *refreshController;
- (IBAction)backToIndex:(UIButton *)sender;
- (IBAction)goToSettings:(UIButton *)sender;
@end
