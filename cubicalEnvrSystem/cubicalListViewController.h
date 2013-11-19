//
//  cubicalListViewController.h
//  cubicalEnvrSystem
//
//  Created by 朱 皓斌 on 13-11-7.
//  Copyright (c) 2013年 朱 皓斌. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "cubicalListCell.h"
#import "SBJson.h"
@interface cubicalListViewController : UITableViewController<NSURLConnectionDataDelegate>{
    NSMutableData *JsonData;
    NSArray *tableViewContent;
    
}

@end
