//
//  RCPlayListViewController.m
//  喜马拉雅
//
//  Created by Raychen on 15/6/5.
//  Copyright (c) 2015年 raychen. All rights reserved.
//

#import "RCPlayListViewController.h"
#import "RCPlaylist.h"
#import "RCPlayerViewController.h"
#import "RCPlayingListViewCell.h"
#import "RCPlayerView.h"
#import "ReactiveCocoa.h"
#import "RCConst.h"
@interface RCPlayListViewController ()

@end

@implementation RCPlayListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 70, 0)];
}
- (void)dealloc{
    [RCNotificationCenter removeObserver:self];
}
- (void)update{

    [self.tableView reloadData];
}
#pragma mark - UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RCPlayingListViewCell * cell = [RCPlayingListViewCell cell];
    RCPlaylist *list = self.playLists[indexPath.row];
    for (RCPlaylist * list in self.playLists) {
        if ([list.title isEqualToString:self.playingInfo.title]) {
            list.playing = YES;
        }else{
            list.playing = NO;
        }
    }
    cell.list = list;
    @weakify(self);
    [[cell.downloadButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        list.downloaded = YES;
        [[UIApplication sharedApplication].keyWindow makeToast:@"加入下载队列成功" duration:1 position:@"bottom"];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];

    }];
    return cell;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return self.playLists.count;
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    RCPlaylist *list = self.playLists[indexPath.row];
    [self.navigationController popViewControllerAnimated:YES];
    [[RCPlayerView playerView] showAnimationing:^{
        [RCNotificationCenter postNotificationName:sendNetWorkingNotification object:nil userInfo:@{netWorkingTrackIdNotificationName:list.trackId}];
    } completion:^{

    }];

}
@end
