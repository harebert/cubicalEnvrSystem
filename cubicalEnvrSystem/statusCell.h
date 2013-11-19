//
//  statusCell.h
//  cubicalEnvrSystem
//
//  Created by 朱 皓斌 on 13-11-12.
//  Copyright (c) 2013年 朱 皓斌. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface statusCell : UITableViewCell{
    
}
@property (strong, nonatomic) IBOutlet UILabel *infoLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *tempLabel;
@property (strong, nonatomic) IBOutlet UILabel *humidityLabel;
@end
