//
//  settingsViewController.h
//  cubicalEnvrSystem
//
//  Created by 朱 皓斌 on 13-11-14.
//  Copyright (c) 2013年 朱 皓斌. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface settingsViewController : UITableViewController{
    
    IBOutlet UISwitch *rememberPWd;
    IBOutlet UITextField *IPAddress;
    IBOutlet UISegmentedControl *refreshIntval;
}
- (IBAction)saveSettings:(UIButton *)sender;

@end
