//
//  chartViewController.h
//  cubicalEnvrSystem
//
//  Created by 朱 皓斌 on 13-11-12.
//  Copyright (c) 2013年 朱 皓斌. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "S7GraphView.h"
#import "SBJson.h"
@interface chartViewController : UIViewController<S7GraphViewDataSource,S7GraphViewDelegate,NSURLConnectionDataDelegate>{
    S7GraphView *graphView_;
    NSArray *statusArray;//接收deviceStateList
    NSArray *timeArray;
    NSArray *tempertureArray;
    NSArray *humidityArray;
    
    NSString *cabinetId;
    NSString *reportDate;
    
    NSMutableData *JsonData;
    
    NSString *chartType;
    
    NSString *refreshInterval;
    
    NSRange range;
    
    UISegmentedControl *timeInterval;
    
    UIScrollView *containView;
}
@property(nonatomic,retain)NSString *cabinetId;
@property(nonatomic,retain)NSString *reportDate;

@end
