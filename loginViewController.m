//
//  loginViewController.m
//  cubicalEnvrSystem
//
//  Created by 朱 皓斌 on 13-11-6.
//  Copyright (c) 2013年 朱 皓斌. All rights reserved.
//

#import "loginViewController.h"

@interface loginViewController ()

@end

@implementation loginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:YES];

}
- (void)viewDidLoad
{
    //初始化设置
    JsonData=[[NSMutableData alloc]init];
        NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *path=[paths objectAtIndex:0];
    NSString *filename=[path stringByAppendingPathComponent:@"settings.plist"];

    if (![[NSFileManager defaultManager]fileExistsAtPath:filename]) {
        [self initPlistFile];
    }
    HUD=[[MBProgressHUD alloc]init];
    if ([(NSNumber *)[self readValueFromPlistFileWithKey:@"recordPassword" andFile:@""]boolValue]) {
        usernameInput.text=[self readValueFromPlistFileWithKey:@"username" andFile:@""];
        //NSLog(@"username is %@",[self readValueFromPlistFileWithKey:@"username" andFile:@""]);
        passwordInput.text=[self readValueFromPlistFileWithKey:@"password" andFile:@""];
         //NSLog(@"password is %@",(NSString *)[self readValueFromPlistFileWithKey:@"password" andFile:@""]);
    }//读取记录在案的用户名密码
    if ([[self readValueFromPlistFileWithKey:@"IPAddress" andFile:@""]isEqualToString:@""]) {//如果没有填写ipaddress则不让通过
        [self.view addSubview:HUD];
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SettingWhite.png"]] ;
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.delegate = self;
        HUD.labelText = @"请先填写IP地址";
        //HUD.detailsLabelText = @"updating data";
        [HUD show:YES];
        [HUD hide:YES afterDelay:1];
    }
    hostIPAddress=[NSString stringWithFormat:@"http://%@", [self readValueFromPlistFileWithKey:@"IPAddress" andFile:@""] ];
    self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"login_bak@568.png"]];
    //pwdButton.frame=CGRectMake(pwdButton.frame.origin.x, pwdButton.frame.origin.y, 20, 10);
    //pwdButton.transform=CGAffineTransformMakeScale(0.75, 0.75);
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginButtonOnClick:(UIButton *)sender {
    hostIPAddress=[NSString stringWithFormat:@"http://%@",[self readValueFromPlistFileWithKey:@"IPAddress" andFile:@""]];
    if ([usernameInput.text isEqualToString:@""]||[passwordInput.text isEqualToString:@""]) {
        [self.view addSubview:HUD];
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-cross.png"]] ;
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.delegate = self;
        HUD.labelText = @"用户名或密码不能为空";
        //HUD.detailsLabelText = @"updating data";
        [HUD show:YES];
        [HUD hide:YES afterDelay:1];
        return;
    }
    if ([hostIPAddress isEqualToString:@""]||[passwordInput.text isEqualToString:@""]) {
        [self.view addSubview:HUD];
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-cross.png"]] ;
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.delegate = self;
        HUD.labelText = @"请先设置IP地址";
        //HUD.detailsLabelText = @"updating data";
        [HUD show:YES];
        [HUD hide:YES afterDelay:1];
        return;
    }

    if (![self isConnectionAvailable]) {
        
        [self.view addSubview:HUD];
        HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-cross.png"]] ;
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.delegate = self;
        HUD.labelText = @"当前网络不可用";
        //HUD.detailsLabelText = @"updating data";
        [HUD show:YES];
        [HUD hide:YES afterDelay:1];
        return;
    }
    //先保存用户名密码
    [self writePlistFileValueWithValue:usernameInput.text withKey:@"username" withFile:@""];
    [self writePlistFileValueWithValue:passwordInput.text withKey:@"password" withFile:@""];
    NSURLConnection *newConnection=[[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/apilogin.action?userName=%@&password=%@",hostIPAddress,usernameInput.text,passwordInput.text]]] delegate:self];
    //NSURLConnection *newConnection=[[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://app.sfls.cn/aircon/json.html"]] delegate:self];
    
    //NSLog(@"%@",[NSString stringWithFormat:@"%@/apilogin.action?userName=%@&password=%@",hostIPAddress,usernameInput.text,passwordInput.text]);
    
}


-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [JsonData appendData:data];
    //NSLog(@"receivedata:%@",data);
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
    NSString *JsonString=[[NSString alloc]initWithData:JsonData encoding:NSUTF8StringEncoding];
    //NSLog(@"json:%@",JsonString);
    NSDictionary *newDic=[[NSDictionary alloc]init];
    SBJsonParser *newJson=[[SBJsonParser alloc]init];
    newDic=[newJson objectWithString:JsonString];
    if ([newDic valueForKey:@"error"]==0) {
        //NSLog(@"成功");
        HUDloading = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUDloading];
        [self performSegueWithIdentifier:@"loginSuccess" sender:self];
    }else{
        //NSLog(@"失败");
    }
    
}

-(BOOL) isConnectionAvailable{
    
    BOOL isExistenceNetwork = YES;
    Reachability *reach = [Reachability reachabilityWithHostName:hostIPAddress];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:
            isExistenceNetwork = NO;
            //NSLog(@"notReachable");
            break;
        case ReachableViaWiFi:
            isExistenceNetwork = YES;
            //NSLog(@"WIFI");
            break;
        case ReachableViaWWAN:
            isExistenceNetwork = YES;
            //NSLog(@"3G");
            break;
    }
    
    if (!isExistenceNetwork) {
        //        UIAlertView *newAlert=[[UIAlertView alloc]initWithTitle:@"现在没有网络" message:@"请检查网络配置！" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        //        [newAlert show];
        //        return NO;
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];//<span style="font-family: Arial, Helvetica, sans-serif;">MBProgressHUD为第三方库，不需要可以省略或使用AlertView</span>
        hud.removeFromSuperViewOnHide =YES;
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"当前网络不可用", nil);
        hud.detailsLabelText = @"请检查网络配置";
        hud.minSize = CGSizeMake(132.f, 108.0f);
        [hud hide:YES afterDelay:3];
        return NO;
    }
    
    return isExistenceNetwork;
}
- (IBAction)passwordDisplay:(UISwitch *)sender {
    if (sender.isOn) {
        [passwordInput setSecureTextEntry:YES];
    }else{
        [passwordInput setSecureTextEntry:NO];
    }
    
}

#pragma 以下是内置函数
- (void)initPlistFile{
    //NSLog(@"here is the plistfile init");
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *path=[paths     objectAtIndex:0];
    NSString *filename=[path stringByAppendingPathComponent:@"settings.plist"];
    NSMutableDictionary *rootDictionary=[[NSMutableDictionary alloc]init];
    [rootDictionary setValue:@"" forKey:@"IPAddress"];
    [rootDictionary setValue:@"" forKey:@"username"];
    [rootDictionary setValue:@"" forKey:@"password"];
    [rootDictionary setValue:@""  forKey:@"refreshIntval"];
    [rootDictionary setValue:[NSNumber numberWithBool:NO] forKey:@"recordPassword"];
    [rootDictionary writeToFile:filename atomically:YES];
}
-(void)writePlistFileValueWithValue:(id)value withKey:(NSString *)key withFile:(NSString *)file{
    
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *path=[paths     objectAtIndex:0];
    NSString *filename;
    if ([file isEqualToString:@""]) {
        filename=[path stringByAppendingPathComponent:@"settings.plist"];
    }else{
        filename=[path stringByAppendingPathComponent:file];
    }
    NSMutableDictionary *rootDictionary=[[NSMutableDictionary alloc]initWithContentsOfFile:filename];
    [rootDictionary setValue:value forKey:key];
    [rootDictionary writeToFile:filename atomically:YES];
}
-(id)readValueFromPlistFileWithKey:(NSString *)key andFile:(NSString *)file{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *path=[paths     objectAtIndex:0];
    NSString *filename=[path stringByAppendingPathComponent:@"settings.plist"];
    if ([file isEqualToString:@""]) {
        filename=[path stringByAppendingPathComponent:@"settings.plist"];
    }
    else{
        filename=[path stringByAppendingPathComponent:file];
    }
    NSMutableDictionary *rootDictionary=[[NSMutableDictionary alloc]initWithContentsOfFile:filename];
    
    return [rootDictionary objectForKey:key];
}

-(IBAction)textFiledReturnEditing:(id)sender {
    [sender resignFirstResponder];
}
@end
