//
//  cubicalListViewController.m
//  cubicalEnvrSystem
//
//  Created by 朱 皓斌 on 13-11-7.
//  Copyright (c) 2013年 朱 皓斌. All rights reserved.
//

#import "cubicalListViewController.h"
    #import "GCRetractableSectionController.h"
    #import "GCSimpleSectionController.h"
    #import "GCArraySectionController.h"
    #import "GCCustomSectionController.h"
    #import "GCEmptySectionController.h"
    #import "GCRowForCubicalList.h"
@interface cubicalListViewController ()
@property (nonatomic, retain) NSArray* retractableControllers;
@end

@implementation cubicalListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    NSURLConnection *newConnection=[[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://app.sfls.cn/aircon/json.html"]] delegate:self];
    JsonData=[[NSMutableData alloc]init];
    tableViewContent = [[NSArray alloc]init];
    
    self.title=@"机柜列表";
//   
//    GCRowForCubicalList *cubicallist=[[GCRowForCubicalList alloc]initWithViewController:self];
//    cubicallist.content=[NSArray arrayWithObjects:@"This", @"content", @"is", @"in", @"an", @"array", nil];
//
//    self.retractableControllers = [NSArray arrayWithObjects: cubicallist,nil];

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
    
    return [tableViewContent count];
    }

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    GCRetractableSectionController* sectionController = [self.retractableControllers objectAtIndex:section];
    return sectionController.numberOfRow;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GCRetractableSectionController* sectionController = [self.retractableControllers objectAtIndex:indexPath.section];
    return [sectionController cellForRow:indexPath.row];
    }


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    GCRetractableSectionController* sectionController = [self.retractableControllers objectAtIndex:indexPath.section];
    return [sectionController didSelectCellAtRow:indexPath.row];
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

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */
#pragma JsonConnection
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [JsonData appendData:data];
    //NSLog(@"receivedata:%@",data);
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSString *JsonString=[[NSString alloc]initWithData:JsonData encoding:NSUTF8StringEncoding];
    NSDictionary *newDic=[[NSDictionary alloc]init];
    SBJsonParser *newJson=[[SBJsonParser alloc]init];
    newDic=[newJson objectWithString:JsonString];
    tableViewContent=[newDic objectForKey:@"cabinetList"];
    NSLog(@"%@",newDic);
    NSMutableArray *templistMArray=[[NSMutableArray alloc]init];
    int i=0;
    for (i=0; i<tableViewContent.count; i++) {
        GCCustomSectionController *newGCRowForCubicalList=[[GCCustomSectionController alloc]initWithViewController:self];
        //newGCRowForCubicalList.content=[tableViewContent objectAtIndex:i];
        [templistMArray addObject:newGCRowForCubicalList];
       
    }
    NSLog(@"%@",templistMArray);
    
    
    
    self.retractableControllers=templistMArray;
    //self.retractableControllers = [NSArray arrayWithObjects:newGCRowForCubicalList,newGCRowForCubicalList, nil];
    [self.tableView reloadData];

}
@end
