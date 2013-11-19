//
//  loginViewController.h
//  cubicalEnvrSystem
//
//  Created by 朱 皓斌 on 13-11-6.
//  Copyright (c) 2013年 朱 皓斌. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBJson.h"
#import "MBProgressHUD.h"
#import "Reachability.h"
@interface loginViewController : UIViewController<NSURLConnectionDataDelegate,MBProgressHUDDelegate>{
    
    MBProgressHUD *HUD;
    MBProgressHUD *HUDloading;
    
    IBOutlet UISwitch *pwdButton;
    NSMutableData *JsonData;
    IBOutlet UITextField *usernameInput;
    IBOutlet UITextField *passwordInput;
    NSString *hostIPAddress;
}
- (IBAction)loginButtonOnClick:(UIButton *)sender;
- (IBAction)passwordDisplay:(UISwitch *)sender;
-(IBAction)textFiledReturnEditing:(id)sender;

@end
