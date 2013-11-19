//
//  currentStatusViewController.m
//  cubicalEnvrSystem
//
//  Created by 朱 皓斌 on 13-11-12.
//  Copyright (c) 2013年 朱 皓斌. All rights reserved.
//

#import "currentStatusViewController.h"

@interface currentStatusViewController ()

@end

@implementation currentStatusViewController
@synthesize refreshControl;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    cell.accessoryView.alpha = 0.4;
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.refreshController beginRefreshing];
}

- (void)viewDidLoad
{
        self.refreshController=[[UIRefreshControl alloc]init];
    [self.refreshController addTarget:self action:@selector(RefreshViewControlEventValueChanged) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshController];
    self.tableView.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"login_bak@568.png"]];
    NSString *IPAddress=[NSString stringWithFormat:@"http://%@", [self readValueFromPlistFileWithKey:@"IPAddress" andFile:@""] ];
    NSURLConnection *newConnection=[[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/api_interface.action?cmd=CURRENT&cabinetId=3",IPAddress]]] delegate:self];
    JsonData=[[NSMutableData alloc]init];
    tableViewContent=[[NSArray alloc]init];
    [super viewDidLoad];

    NSTimer *timer;
    timer = [NSTimer
             scheduledTimerWithTimeInterval:2.f//定时时间，即此时间后执行某个事件，这里为0.1秒
             target:self
             selector:@selector(timer_proc)//表示到时间后执行的函数
             userInfo:nil
             repeats:YES//NO表示不重复执行。如果为YES，则每隔0.1秒都会调用一次
             ];
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
    return [tableViewContent count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    statusCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSDictionary *thisCabi=[tableViewContent objectAtIndex:[indexPath row]];
    cell.titleLabel.text=[NSString stringWithFormat:@"ID:%@--%@",[thisCabi objectForKey:@"cabinetId"],[thisCabi objectForKey:@"cabinetName"]];
    cell.infoLabel.text=[thisCabi objectForKey:@"cabinetDesc"];
    cell.tempLabel.text=[NSString stringWithFormat:@"温度：%@℃",[thisCabi objectForKey:@"temp"]];
    cell.humidityLabel.text=[NSString stringWithFormat:@"湿度：%@%%",[thisCabi objectForKey:@"humidity"]];
    // Configure the cell...
    
    return cell;
}
-(CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    statusCell *newCell=(statusCell *)sender;
    NSIndexPath *newIndexPath=[self.tableView indexPathForCell:newCell];
    chartViewController *desChartView=[segue destinationViewController];
    desChartView.cabinetId=[[tableViewContent objectAtIndex:[newIndexPath row]] objectForKey:@"cabinetId"];
    
}


-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [JsonData appendData:data];
    //NSLog(@"receivedata:%@",data);
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSString *JsonString=[[NSString alloc]initWithData:JsonData encoding:NSUTF8StringEncoding];
    //NSLog(@"%@",JsonData);
    NSDictionary *newDic=[[NSDictionary alloc]init];
    SBJsonParser *newJson=[[SBJsonParser alloc]init];
    newDic=[newJson objectWithString:JsonString];
    tableViewContent=[newDic objectForKey:@"cabinetList"];
    //NSLog(@"%@",tableViewContent);
    [self.refreshController endRefreshing];
    [self.tableView reloadData];
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

-(void)RefreshViewControlEventValueChanged{
    JsonData=[NSMutableData dataWithLength:0];
    NSString *IPAddress=[NSString stringWithFormat:@"http://%@", [self readValueFromPlistFileWithKey:@"IPAddress" andFile:@""] ];
    NSURLConnection *newConnection=[[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/api_interface.action?cmd=CURRENT&cabinetId=3",IPAddress]]] delegate:self];
    //[self.tableView reloadData];
    
}
-(void)timer_proc{
    JsonData=[NSMutableData dataWithLength:0];
    NSString *IPAddress=[NSString stringWithFormat:@"http://%@", [self readValueFromPlistFileWithKey:@"IPAddress" andFile:@""] ];
    NSURLConnection *newConnection=[[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/api_interface.action?cmd=CURRENT&cabinetId=3",IPAddress]]] delegate:self];
    
}
- (IBAction)backToIndex:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)goToSettings:(UIBarButtonItem *)sender {
    NSLog(@"gotosetting");
    [self performSegueWithIdentifier:@"goToSettingPage" sender:self];
    
}
@end
