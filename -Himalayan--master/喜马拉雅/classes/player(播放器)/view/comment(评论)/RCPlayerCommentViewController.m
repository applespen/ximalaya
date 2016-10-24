//
//  RCPlayerCommentViewController.m
//  喜马拉雅
//
//  Created by Raychen on 15/5/30.
//  Copyright (c) 2015年 raychen. All rights reserved.
//

#import "RCPlayerCommentViewController.h"
#import "RCConst.h"
#import "RCPlayerVIewModel.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "RCPlayerCommentViewCell.h"
static NSString * const ID = @"playerCommentCell";
@interface RCPlayerCommentViewController ()
@property(nonatomic,strong) RCPlayerVIewModel  *viewmodel;

@end
@implementation RCPlayerCommentViewController

-  (RCPlayerVIewModel *)viewmodel{
    if (!_viewmodel) {
        self.viewmodel = [[RCPlayerVIewModel alloc]init];
    }
    return _viewmodel;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.gifFooter.hidden = NO;
    [RCNotificationCenter addObserver:self selector:@selector(fecthData:) name:sendNetWorkingNotification object:nil];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self.tableView registerNib:[UINib nibWithNibName:@"RCPlayerCommentViewCell" bundle:nil] forCellReuseIdentifier:ID];
    [self.tableView removeHeader];

}



- (void)fecthData:(NSNotification *)note{
    [KVNProgress showWithParameters:@{KVNProgressViewParameterStatus:@"正在加载..."}];
    self.viewmodel.trackId = note.userInfo[netWorkingTrackIdNotificationName];
    [self.viewmodel fetchNewPlayerCommnetWithSuccess:^{
        [self.tableView reloadData];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [KVNProgress dismiss];

        });
    } failure:^{
        [KVNProgress dismiss];
        [KVNProgress showErrorWithStatus:@"播放的音频不存在..."];
    }];
}
- (void)loadMoreData{
    [self.viewmodel fetchMorePlayerCommnetWithSuccess:^{
        [self.tableView reloadData];
        [self.tableView.gifFooter endRefreshing];
    } failure:^{
        [self.tableView.gifFooter endRefreshing];

    } completion:^{
        [self.tableView.gifFooter endRefreshing];
        [self.tableView.gifFooter setHidden:YES];

    }];

}
#pragma mark - UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RCPlayerCommentViewCell * cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    RCPlayerCommnetList * commentList = self.viewmodel.comments[indexPath.row];
    commentList.follor = @(indexPath.row+1);
    cell.list = commentList;
    return cell;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return self.viewmodel.comments.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return [tableView fd_heightForCellWithIdentifier:ID cacheByIndexPath:indexPath configuration:^(RCPlayerCommentViewCell * cell) {
        cell.list = self.viewmodel.comments[indexPath.row];

    }];
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];


}
#pragma mark - FeSpinnerTenDotDelegate
- (void)dealloc{

    [RCNotificationCenter removeObserver:self];
}
-(NSString *)segmentTitle{

return @"评论";
}


-(UIScrollView *)streachScrollView{

    return self.tableView;
}

@end
