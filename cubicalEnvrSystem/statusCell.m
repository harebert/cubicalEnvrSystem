//
//  statusCell.m
//  cubicalEnvrSystem
//
//  Created by 朱 皓斌 on 13-11-12.
//  Copyright (c) 2013年 朱 皓斌. All rights reserved.
//

#import "statusCell.h"

@implementation statusCell
@synthesize tempLabel,titleLabel,humidityLabel;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
