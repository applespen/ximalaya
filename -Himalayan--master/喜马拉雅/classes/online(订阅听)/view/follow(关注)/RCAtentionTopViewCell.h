//
//  RCAtentionTopViewCell.h
//  喜马拉雅
//
//  Created by Raychen on 15/5/29.
//  Copyright (c) 2015年 raychen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCAttentionOneData.h"
@interface RCAtentionTopViewCell : UITableViewCell
+ (instancetype)cell;
@property(nonatomic,strong) RCAttentionOneData  *data;
@end
