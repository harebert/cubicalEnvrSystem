//
//  chartViewController.m
//  cubicalEnvrSystem
//
//  Created by 朱 皓斌 on 13-11-12.
//  Copyright (c) 2013年 朱 皓斌. All rights reserved.
//
#define IS_IPHONE_5 ( [ [ UIScreen mainScreen ] bounds ].size.height == 568 )


#import "chartViewController.h"

@interface chartViewController ()

@end

@implementation chartViewController
@synthesize cabinetId,reportDate;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    //初始化参数
    [self.navigationController setNavigationBarHidden:YES animated:YES];

    chartType=@"温度变化";//默认采用温度变化
    NSString *IPAddress=[NSString stringWithFormat:@"http://%@", [self readValueFromPlistFileWithKey:@"IPAddress" andFile:@""] ];
    refreshInterval=[self readValueFromPlistFileWithKey:@"refreshIntval" andFile:@""];
    
    
    
    NSURLConnection *newConnection=[[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/api_interface.action?cmd=REPORT&year=2013&month=11&day=16&cabinetId=1",IPAddress]]] delegate:self];
    JsonData=[[NSMutableData alloc]init];
    statusArray=[[NSArray alloc]init];
    
  
    
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark protocol S7GraphViewDataSource

- (NSUInteger)graphViewMaximumNumberOfXaxisValues:(S7GraphView *)graphView {
    
    return [refreshInterval intValue];
}

- (NSUInteger)graphViewNumberOfPlots:(S7GraphView *)graphView {
    /* Return the number of plots you are going to have in the view. 1+ */
    return [statusArray count];
}

- (NSArray *)graphViewXValues:(S7GraphView *)graphView {
    /* An array of objects that will be further formatted to be displayed on the X-axis.
     The number of elements should be equal to the number of points you have for every plot. */
    NSMutableArray *array = [[NSMutableArray alloc]initWithArray:timeArray];
    //NSLog(@"%@",timeArray);
    return array;
}

- (NSArray *)graphView:(S7GraphView *)graphView yValuesForPlot:(NSUInteger)plotIndex {
    /* Return the values for a specific graph. Each plot is meant to have equal number of points.
     And this amount should be equal to the amount of elements you return from graphViewXValues: method. */
    
    if ([chartType isEqualToString:@"温度变化"]) {
        return tempertureArray;
    }
    else{
        return humidityArray;
    }
    
}

- (BOOL)graphView:(S7GraphView *)graphView shouldFillPlot:(NSUInteger)plotIndex {
    return NO;
}

- (void)graphView:(S7GraphView *)graphView indexOfTappedXaxis:(NSInteger)indexOfTappedXaxis {
    
}
CGAffineTransform CGAffineTransformMakeRotationAt(CGFloat angle, CGPoint pt){
    const CGFloat fx = pt.x;
    const CGFloat fy = pt.y;
    const CGFloat fcos = cos(angle);
    const CGFloat fsin = sin(angle);
    return CGAffineTransformMake(fcos, fsin, -fsin, fcos, fx - fx * fcos + fy * fsin, fy - fx * fsin - fy * fcos);
}


-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [JsonData appendData:data];
    //NSLog(@"receivedata:%@",data);
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
//在这里作图
    NSString *JsonString=[[NSString alloc]initWithData:JsonData encoding:NSUTF8StringEncoding];
    
    NSDictionary *newDic=[[NSDictionary alloc]init];
    SBJsonParser *newJson=[[SBJsonParser alloc]init];
    newDic=[newJson objectWithString:JsonString];
    //NSLog(@"chartDic:%@",newDic);
    NSArray *tempDIc=[newDic objectForKey:@"cabinetList"];
    //NSLog(@"tempDIc:%@",tempDIc);
    statusArray=[[tempDIc objectAtIndex:0] objectForKey:@"deviceStateList"];
    //NSLog(@"chartarray:%@",statusArray);
    
    
    int i=0;
    NSMutableArray *tempTempArray=[[NSMutableArray alloc]init];
    NSMutableArray *temphumiArray=[[NSMutableArray alloc]init];
    NSMutableArray *tempTimeArray=[[NSMutableArray alloc]init];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    for (i=0; i<[statusArray count]; i++) {
        [tempTempArray addObject:[(NSDictionary *)[statusArray objectAtIndex:i] objectForKey:@"temp"]];
        //NSLog(@"temp:%@",[(NSDictionary *)[statusArray objectAtIndex:i] objectForKey:@"temp"]);
        [temphumiArray addObject:[(NSDictionary *)[statusArray objectAtIndex:i] objectForKey:@"humidity"]];
        //NSLog(@"humidity:%@",[(NSDictionary *)[statusArray objectAtIndex:i] objectForKey:@"humidity"]);
        //NSLog(@"%@",dateFormatter);
        NSDate *date = [dateFormatter dateFromString:[(NSDictionary *)[statusArray objectAtIndex:i] objectForKey:@"createTime"]];
        [tempTimeArray addObject:date];
        //NSLog(@"date:%@",date);
    }
    //先定义范围，
    //range=NSMakeRange([statusArray count]-25, 24);
    refreshInterval=[self readValueFromPlistFileWithKey:@"refreshIntval" andFile:@""];
    switch ([refreshInterval intValue]) {
            //选择显示多少小时的数据，
            //2小时显示24个，4小时显示48个，8小时显示96个，24小时显示所有
        case 2:
            range=NSMakeRange([statusArray count]-25, 24);
            break;
        case 4:
            range=NSMakeRange([statusArray count]-49, 48);
            break;
        case 8:
            range=NSMakeRange([statusArray count]-97, 96);
            break;
        case 24:
            range=NSMakeRange(0, [statusArray count]);
            break;
            
        default:
            break;
    }

    
    tempertureArray=[tempTempArray subarrayWithRange:range];
    humidityArray=[temphumiArray subarrayWithRange:range];
    timeArray=[tempTimeArray subarrayWithRange:range];
    //timeArray=tempTimeArray;
//构建绘图区域
    if (IS_IPHONE_5) {//将绘图区域撑满整屏
        if ([refreshInterval intValue]*100<546) {
            graphView_=[[S7GraphView alloc]initWithFrame:CGRectMake(0, 40, 546, 280)];
        }else{
            graphView_=[[S7GraphView alloc]initWithFrame:CGRectMake(0, 40, [refreshInterval intValue]*100, 280)];
        }
        
    }else{
        if ([refreshInterval intValue]*100<480-22) {
            graphView_=[[S7GraphView alloc]initWithFrame:CGRectMake(0, 0, 480-22, 280)];}
        else{
            graphView_=[[S7GraphView alloc]initWithFrame:CGRectMake(0, 0, [refreshInterval intValue]*100, 280)];
        }
    }
   
    [graphView_ setDelegate:self];
    [graphView_ setDataSource:self];
    
    //CGAffineTransform rotation2=CGAffineTransformMakeRotationAt(M_PI_2, CGPointMake(-40, 40));
    //[graphView_ setTransform:rotation];
    containView=[[UIScrollView alloc]init];
    containView.tag=1;
    float containViewContentWidth;
    if (IS_IPHONE_5) {
        containView.frame=CGRectMake(-120, 120, 546, 320);
        if ([refreshInterval intValue]*100>546) {
            containViewContentWidth=[refreshInterval intValue]*100;
        }else{
            containViewContentWidth=546;
        }
        [containView setContentSize:CGSizeMake(containViewContentWidth, 280)];
    }
    else{
        containView.frame=CGRectMake(-120, 120, 458, 320);
        if ([refreshInterval intValue]*100>458) {
            containViewContentWidth=[refreshInterval intValue]*100;
        }else{
            containViewContentWidth=458;
        }
        containView.frame=CGRectMake(-120, 120, 458, 320);
        [containView setContentSize:CGSizeMake(containViewContentWidth, 280)];
    }

    
    
    [containView setBackgroundColor:[UIColor whiteColor]];
    [containView addSubview:graphView_];
    
    [graphView_ setBackgroundColor:[UIColor clearColor]];
    graphView_.drawAxisX = YES;
    graphView_.drawAxisY = YES;
    graphView_.drawGridX = YES;
    graphView_.drawGridY = YES;
    
    graphView_.xValuesColor = [UIColor blackColor];
    graphView_.yValuesColor = [UIColor blackColor];
    
    graphView_.gridXColor = [UIColor blackColor];
    graphView_.gridYColor = [UIColor blueColor];
    
    //graphInfoList_ = [GraphInfoList loadGraphInfoList];
    graphView_.xUnit = @"  （时间）";
    graphView_.yUnit=@"℃";
    NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setMinimumFractionDigits:0];
    [numberFormatter setMaximumFractionDigits:0];
    
    graphView_.yValuesFormatter = numberFormatter;
    graphView_.PlotColorForChart=[UIColor redColor];
    NSDateFormatter *dateFormatter1 = [NSDateFormatter new];
    [dateFormatter1 setDateFormat:@"HH点"];
    graphView_.xValuesFormatter = dateFormatter1;
    
    
    
    
    
    
    //旋转containView
    CGAffineTransform rotation = CGAffineTransformMakeRotation(M_PI_2);
    [containView setTransform:rotation];
    [self.view addSubview:containView];
    
    
    //图标标题
    UILabel *titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(100, 270, 400, 30)];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    titleLabel.text=[NSString stringWithFormat:@"%@ 至 %@",[self stringFromDate:[timeArray objectAtIndex:0] withDateFormat:@"yyyy年MM月dd日 HH点"],[self stringFromDate:[timeArray lastObject] withDateFormat:@"yyyy年MM月dd日 HH点"]];
    [titleLabel setTransform:rotation];
    [self.view addSubview:titleLabel];
    
    //添加选择按钮
    UISegmentedControl *newSegmentedControl=[[UISegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:@"温度变化",@"湿度变化", nil]];
    [newSegmentedControl addTarget:self action:@selector(changeChartType:) forControlEvents:UIControlEventValueChanged];
    newSegmentedControl.frame=CGRectMake(190, 140, 160, 20);
    newSegmentedControl.selectedSegmentIndex=0;
    [newSegmentedControl setTransform:rotation];
    [self.view addSubview:newSegmentedControl];
	// Do any additional setup after loading the view.
    
    //添加分时选择按钮
    timeInterval=[[UISegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:@"2小时",@"4小时",@"8小时",@"24小时", nil]];
    switch ([refreshInterval intValue]) {
        case 2:
            timeInterval.selectedSegmentIndex=0;
            break;
        case 4:
            timeInterval.selectedSegmentIndex=1;
            break;
        case 8:
            timeInterval.selectedSegmentIndex=2;
            break;
        case 24:
            timeInterval.selectedSegmentIndex=3;
            break;
            
        default:
            break;
    }
    timeInterval.frame=CGRectMake(180, 340, 180, 20);
    [timeInterval setTransform:rotation];
    [timeInterval addTarget:self action:@selector(timeIntervalHasChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:timeInterval];
    
    //添加返回按钮
    UIButton *backButton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [backButton setTitle:@"↓返回列表" forState:UIControlStateNormal];
    backButton.frame=CGRectMake(250, 45,100, 20);
    [backButton setTransform:rotation];
    [backButton addTarget:self action:@selector(backToPrev:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    
    
    
    [graphView_ reloadData];
    
    
    
   
}
-(void)changeChartType:(UISegmentedControl *)Seg{
    if (Seg.selectedSegmentIndex==0) {
       chartType=@"温度变化";
         graphView_.yUnit=@"℃";
        graphView_.PlotColorForChart=[UIColor redColor];
    }else{
        chartType=@"湿度变化";
         graphView_.yUnit=@"%";
        graphView_.PlotColorForChart=[UIColor blueColor];
    }
    [graphView_ reloadData];
}

-(void)timeIntervalHasChanged:(UISegmentedControl *)sender{
    
    NSString *refresh;
    switch (timeInterval.selectedSegmentIndex) {
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
    
    [containView removeFromSuperview];

//先移除绘图区域，然后重建绘图区域
    
    int i=0;
    NSMutableArray *tempTempArray=[[NSMutableArray alloc]init];
    NSMutableArray *temphumiArray=[[NSMutableArray alloc]init];
    NSMutableArray *tempTimeArray=[[NSMutableArray alloc]init];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //NSDate *date = [dateFormatter dateFromString:@"2010-08-04 16:01:03"];
    
    for (i=0; i<[statusArray count]; i++) {
        [tempTempArray addObject:[(NSDictionary *)[statusArray objectAtIndex:i] objectForKey:@"temp"]];
        //NSLog(@"temp:%@",[(NSDictionary *)[statusArray objectAtIndex:i] objectForKey:@"temp"]);
        [temphumiArray addObject:[(NSDictionary *)[statusArray objectAtIndex:i] objectForKey:@"humidity"]];
        //NSLog(@"humidity:%@",[(NSDictionary *)[statusArray objectAtIndex:i] objectForKey:@"humidity"]);
        //NSLog(@"%@",dateFormatter);
        NSDate *date = [dateFormatter dateFromString:[(NSDictionary *)[statusArray objectAtIndex:i] objectForKey:@"createTime"]];
        [tempTimeArray addObject:date];
        //NSLog(@"date:%@",date);
    }
    //先定义范围，
    //range=NSMakeRange([statusArray count]-25, 24);
    refreshInterval=[self readValueFromPlistFileWithKey:@"refreshIntval" andFile:@""];
    switch ([refreshInterval intValue]) {
            //选择显示多少小时的数据，
            //2小时显示24个，4小时显示48个，8小时显示96个，24小时显示所有
        case 2:
            range=NSMakeRange([statusArray count]-25, 24);
            break;
        case 4:
            range=NSMakeRange([statusArray count]-49, 48);
            break;
        case 8:
            range=NSMakeRange([statusArray count]-97, 96);
            break;
        case 24:
            range=NSMakeRange(0, [statusArray count]);
            break;
            
        default:
            break;
    }
    
    
    tempertureArray=[tempTempArray subarrayWithRange:range];
    humidityArray=[temphumiArray subarrayWithRange:range];
    timeArray=[tempTimeArray subarrayWithRange:range];
    //timeArray=tempTimeArray;
    //构建绘图区域
    if (IS_IPHONE_5) {//将绘图区域撑满整屏
        if ([refreshInterval intValue]*100<546) {
            graphView_=[[S7GraphView alloc]initWithFrame:CGRectMake(0, 40, 546, 280)];
        }else{
            graphView_=[[S7GraphView alloc]initWithFrame:CGRectMake(0, 40, [refreshInterval intValue]*100, 280)];
        }
        
    }else{
        if ([refreshInterval intValue]*100<480-22) {
            graphView_=[[S7GraphView alloc]initWithFrame:CGRectMake(0, 0, 480-22, 280)];}
        else{
            graphView_=[[S7GraphView alloc]initWithFrame:CGRectMake(0, 0, [refreshInterval intValue]*100, 280)];
        }
    }
    
    [graphView_ setDelegate:self];
    [graphView_ setDataSource:self];
    
    //CGAffineTransform rotation2=CGAffineTransformMakeRotationAt(M_PI_2, CGPointMake(-40, 40));
    //[graphView_ setTransform:rotation];
    containView=[[UIScrollView alloc]init];
    containView.tag=1;
    float containViewContentWidth;
    if (IS_IPHONE_5) {
        containView.frame=CGRectMake(-120, 120, 546, 320);
        if ([refreshInterval intValue]*100>546) {
            containViewContentWidth=[refreshInterval intValue]*100;
        }else{
            containViewContentWidth=546;
        }
        [containView setContentSize:CGSizeMake(containViewContentWidth, 280)];
    }
    else{
        containView.frame=CGRectMake(-120, 120, 458, 320);
        if ([refreshInterval intValue]*100>458) {
            containViewContentWidth=[refreshInterval intValue]*100;
        }else{
            containViewContentWidth=458;
        }
        containView.frame=CGRectMake(-120, 120, 458, 320);
        [containView setContentSize:CGSizeMake(containViewContentWidth, 280)];
    }
    
    
    [containView setBackgroundColor:[UIColor whiteColor]];
    [containView addSubview:graphView_];
    
    [graphView_ setBackgroundColor:[UIColor clearColor]];
    graphView_.drawAxisX = YES;
    graphView_.drawAxisY = YES;
    graphView_.drawGridX = YES;
    graphView_.drawGridY = YES;
    
    graphView_.xValuesColor = [UIColor blackColor];
    graphView_.yValuesColor = [UIColor blackColor];
    
    graphView_.gridXColor = [UIColor blackColor];
    graphView_.gridYColor = [UIColor blueColor];
    
    
    
    //graphInfoList_ = [GraphInfoList loadGraphInfoList];
    graphView_.xUnit = @"  （时间）";
    
    NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setMinimumFractionDigits:0];
    [numberFormatter setMaximumFractionDigits:0];
    
    graphView_.yValuesFormatter = numberFormatter;
    if ([chartType isEqualToString:@"温度变化"]) {
        graphView_.PlotColorForChart=[UIColor redColor];
        graphView_.yUnit=@"℃";
    }
    else
    {
        graphView_.PlotColorForChart=[UIColor blueColor];
        graphView_.yUnit=@"%";
    }
    
    NSDateFormatter *dateFormatter1 = [NSDateFormatter new];
    [dateFormatter1 setDateFormat:@"HH点"];
    graphView_.xValuesFormatter = dateFormatter1;
    //[graphView_ reloadData];
    
    
    
    
    //旋转containView
    CGAffineTransform rotation = CGAffineTransformMakeRotation(M_PI_2);
    [containView setTransform:rotation];
    [self.view addSubview:containView];
    
    
    //图标标题
    UILabel *titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(100, 270, 400, 30)];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    titleLabel.text=[NSString stringWithFormat:@"%@ 至 %@",[self stringFromDate:[timeArray objectAtIndex:0] withDateFormat:@"yyyy年MM月dd日 HH点"],[self stringFromDate:[timeArray lastObject] withDateFormat:@"yyyy年MM月dd日 HH点"]];
    [titleLabel setTransform:rotation];
    [self.view addSubview:titleLabel];
    
    //添加选择按钮
    UISegmentedControl *newSegmentedControl=[[UISegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:@"温度变化",@"湿度变化", nil]];
    [newSegmentedControl addTarget:self action:@selector(changeChartType:) forControlEvents:UIControlEventValueChanged];
    newSegmentedControl.frame=CGRectMake(190, 140, 160, 20);
    if ([chartType isEqualToString:@"温度变化"]) {
        newSegmentedControl.selectedSegmentIndex=0;
    }else{
        newSegmentedControl.selectedSegmentIndex=1;
    }
    
    [newSegmentedControl setTransform:rotation];
    [self.view addSubview:newSegmentedControl];
	// Do any additional setup after loading the view.
    
    //添加分时选择按钮
    timeInterval=[[UISegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:@"2小时",@"4小时",@"8小时",@"24小时", nil]];
    switch ([refreshInterval intValue]) {
        case 2:
            timeInterval.selectedSegmentIndex=0;
            break;
        case 4:
            timeInterval.selectedSegmentIndex=1;
            break;
        case 8:
            timeInterval.selectedSegmentIndex=2;
            break;
        case 24:
            timeInterval.selectedSegmentIndex=3;
            break;
            
        default:
            break;
    }
    timeInterval.frame=CGRectMake(180, 340, 180, 20);
    [timeInterval setTransform:rotation];
    [timeInterval addTarget:self action:@selector(timeIntervalHasChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:timeInterval];
    
    //添加返回按钮
    UIButton *backButton=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [backButton setTitle:@"↓返回列表" forState:UIControlStateNormal];
    backButton.frame=CGRectMake(250, 45,100, 20);
    [backButton setTransform:rotation];
    [backButton addTarget:self action:@selector(backToPrev:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    
    
    
    [graphView_ reloadData];


}

-(void)backToPrev:(UIButton *)bkBtn{
    [self.navigationController popViewControllerAnimated:YES];
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

- (void) hideTabBar:(UITabBarController *) tabbarcontroller {
    
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.1];
    for(UIView *view in tabbarcontroller.view.subviews)
    {
        if([view isKindOfClass:[UITabBar class]])
        {
            [view setFrame:CGRectMake(view.frame.origin.x, 480, view.frame.size.width, view.frame.size.height)];
        }
        else
        {
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, 480)];
        }
        
    }
    
    [UIView commitAnimations];
    
    
    
    
    
}
- (void) showTabBar:(UITabBarController *) tabbarcontroller {
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.1];
    for(UIView *view in tabbarcontroller.view.subviews)
    {
        //NSLog(@"%@", view);
        
        if([view isKindOfClass:[UITabBar class]])
        {
            [view setFrame:CGRectMake(view.frame.origin.x, 431, view.frame.size.width, view.frame.size.height)];
            
        }
        else
        {
            [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, 431)];
        }
        
        
    }
    
    [UIView commitAnimations];
}
- (NSString *)stringFromDate:(NSDate *)date withDateFormat:(NSString *)DateFormat{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    //zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息 +0000。
    
    [dateFormatter setDateFormat:DateFormat];
    
    NSString *destDateString = [dateFormatter stringFromDate:date];
    
    
    return destDateString;
    
}

@end
