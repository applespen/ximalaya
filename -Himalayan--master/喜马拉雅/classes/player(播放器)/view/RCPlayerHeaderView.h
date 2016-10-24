//
//  RCPlayerHeaderView.h
//  喜马拉雅
//
//  Created by Raychen on 15/5/30.
//  Copyright (c) 2015年 raychen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARSegmentPageController.h"
#import "RCPlaylist.h"

//#import "RCPlayerInfo.h"
@interface RCPlayerHeaderView : UIView <ARSegmentPageControllerHeaderProtocol>
@property (weak, nonatomic) IBOutlet UIImageView *topImageView;
@property(nonatomic,strong) NSArray  *audios;
@property (weak, nonatomic) IBOutlet UIImageView *largeImageView;
@property(nonatomic,strong) RCPlaylist  *list;
@property(nonatomic,strong) NSArray  *playLists;
@property(nonatomic,assign) BOOL isLocalAudio;

+ (instancetype)headerView;

@end
