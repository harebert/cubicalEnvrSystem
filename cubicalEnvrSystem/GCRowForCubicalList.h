//
//  GCRowForCubicalList.h
//  cubicalEnvrSystem
//
//  Created by 朱 皓斌 on 13-11-10.
//  Copyright (c) 2013年 朱 皓斌. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "GCRetractableSectionController.h"

@interface GCRowForCubicalList : GCRetractableSectionController{
    NSDictionary *content;

}
@property (nonatomic, retain) NSDictionary* content;
@end
