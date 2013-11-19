//
//  settingsViewController.m
//  cubicalEnvrSystem
//
//  Created by 朱 皓斌 on 13-11-14.
//  Copyright (c) 2013年 朱 皓斌. All rights reserved.
//

#import "settingsViewController.h"

@interface settingsViewController ()

@end

@implementation settingsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)viewDidLoad
{
    IPAddress.text=(NSString *)[self readValueFromPlistFileWithKey:@"IPAddress" andFile:@""];
    [rememberPWd setOn:[(NSNumber *)[self readValueFromPlistFileWithKey:@"recordPassword" andFile:@""]boolValue]];
    NSInteger segNo = 0;
    switch ([(NSString *)[self readValueFromPlistFileWithKey:@"refreshIntval" andFile:@""]intValue]) {
        case 2:
            segNo=0;
            break;
        case 4:
            segNo=1;
            break;
        case 8:
            segNo=2;
            break;
        case 24:
            segNo=3;
            break;
            
        default:
            break;
    }
    
    
    [refreshIntval setSelectedSegmentIndex:segNo];
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 3;
}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    
//    // Configure the cell...
//    
//    return cell;
//}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

- (IBAction)saveSettings:(UIButton *)sender {
    [self writePlistFileValueWithValue:IPAddress.text withKey:@"IPAddress" withFile:@""];
    NSString *refresh;
    switch (refreshIntval.selectedSegmentIndex) {
        case 0:
            refresh=@"2";
            break;
        case 1:
            refresh=@"4";
            break;
        case 2:
            refresh=@"8";
            break;
        case 3:
            refresh=@"24";
            break;
        default:
            break;
    }
    [self writePlistFileValueWithValue:refresh withKey:@"refreshIntval" withFile:@""];
    if (rememberPWd.isOn) {
        [self writePlistFileValueWithValue:[NSNumber numberWithBool:YES] withKey:@"recordPassword" withFile:@""];
    }else{
        [self writePlistFileValueWithValue:[NSNumber numberWithBool:NO] withKey:@"recordPassword" withFile:@""];
    }
    
    
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

@end
