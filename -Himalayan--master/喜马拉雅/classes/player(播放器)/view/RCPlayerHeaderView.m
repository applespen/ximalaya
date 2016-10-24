//
//  RCPlayerHeaderView.m
//  喜马拉雅
//
//  Created by Raychen on 15/5/30.
//  Copyright (c) 2015年 raychen. All rights reserved.
//

#import "RCPlayerHeaderView.h"
#import "RCConst.h"
#import "AFSoundManager.h"
#import "RCAudioTool.h"
#import "RCPlayerVIewModel.h"
#import "RCPlayerView.h"
#import "RCPlayerTool.h"
#import "RCPlayListViewController.h"
#import "UIImage+RC.h"
#import "RCplayerStatus.h"
#import "Novocaine.h"
#import "UIImageView+WebCache.h"
#import "UIImage+RC.h"
#import "RCPlayHistoryViewController.h"
#import "UIImage+ImageEffects.h"
#import "UIImageView+EXtension.h"
@interface RCPlayerHeaderView ()
@property (weak, nonatomic) IBOutlet UILabel *topTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *playCountButton;
@property (weak, nonatomic) IBOutlet UIImageView *smallIconVIew;
@property (weak, nonatomic) IBOutlet UIImageView *avatorIconView;
@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UIButton *careButton;
@property(nonatomic,assign) NSUInteger currentIndex;
@property(nonatomic,strong) RCPlayerVIewModel  *viewmodel;
@property (weak, nonatomic) IBOutlet UIImageView *currentprogressImageView;
@property (weak, nonatomic) IBOutlet UIImageView *bufferProgressImageView;
@property (weak, nonatomic) IBOutlet UIButton *progressButton;
@property (weak, nonatomic) IBOutlet UIView *pregressView;
@property (weak, nonatomic) IBOutlet UIView *timeView;
@property (weak, nonatomic) IBOutlet UIButton *playAndPauseButtton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *juhua;
@property (weak, nonatomic) IBOutlet UIScrollView *labelScrollView;

@property (weak, nonatomic) IBOutlet UILabel *playProgressLabel;
@property(nonatomic,assign) CGFloat currnetProgressButtonX;


@end
@implementation RCPlayerHeaderView

- (void)awakeFromNib{
    [super awakeFromNib];
    
    [RCNotificationCenter addObserver:self selector:@selector(changePlayerStatus) name:playingNotification object:nil];
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panPregoressButton:)];
    [self.progressButton addGestureRecognizer:pan];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapProgressView:)];
    [self.pregressView  addGestureRecognizer:tap];
    NSTimer * timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(startAnimation) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)startAnimation{
    [UIView animateKeyframesWithDuration:5
                                   delay:5
                                 options:UIViewKeyframeAnimationOptionAllowUserInteraction
                              animations:^{
                                  // 计算移动的距离
                                  CGPoint point = self.labelScrollView.contentOffset;
//                                  NSLog(@"%@--",NSStringFromCGPoint(point));
                                  point.x = 100;
                                  self.labelScrollView.contentOffset = point;
//                                      NSLog(@"%@",NSStringFromCGPoint(point));
//                                  NSLog(@"%@",[NSThread currentThread]);
                                  
                              }
                              completion:^(BOOL finished) {
                                  [UIView animateKeyframesWithDuration:5
                                                                 delay:5
                                                               options:UIViewKeyframeAnimationOptionAllowUserInteraction
                                                            animations:^{
                                                                // 计算移动的距离
                                                                CGPoint point = self.labelScrollView.contentOffset;
                                                                point.x = -10;
                                                                self.labelScrollView.contentOffset = point;
                                                            }
                                                            completion:nil];
                              }];
    
    
}

- (void)changePlayerStatus{
    if ([AFSoundManager sharedManager].isPlaying) {
        self.playAndPauseButtton.selected = YES;
        [self.smallIconVIew.layer addAnimation:[self animation] forKey:nil];
    }else{
        [self.smallIconVIew.layer removeAllAnimations];
        self.playAndPauseButtton.selected = NO;
    }
    
}
- (void)layoutSubviews{
    
    [super layoutSubviews];
    self.timeView.frame = CGRectMake(10, CGRectGetMaxY(self.smallIconVIew.frame) +60, 72, 26);
}
+ (instancetype)headerView{
    return [[[NSBundle mainBundle] loadNibNamed:@"RCPlayerHeaderView" owner:nil options:nil]lastObject];
    
}
- (void)setList:(RCPlaylist *)list
{
    _list = list;
    [self.topImageView sd_setImageWithURL:[NSURL URLWithString:list.coverLarge] placeholderImage:[UIImage imageNamed:@"albumBg"]completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        self.topImageView.image = [image  applyDarkEffect];
        
    }];
    self.topTitleLabel.text = list.title;
    [self setUpWithButton:self.playCountButton count:  [list.playtimes intValue]  title:nil];
    [self.smallIconVIew sd_setImageWithURL:[NSURL URLWithString: list.coverLarge] placeholderImage:[UIImage imageNamed:@"findCategory_default"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        self.smallIconVIew.image = [UIImage circleImage:image borderWidth:10 borderColor:[UIColor blackColor]];
    }];
    [self.largeImageView sd_setImageWithURL:[NSURL URLWithString:list.coverLarge] placeholderImage:[UIImage imageNamed:@"sound_albumcover"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [self.largeImageView setImageToBlur:image blurRadius:60 completionBlock:nil];
    }];
    [self.avatorIconView sd_setImageWithURL:[NSURL URLWithString:list.albumImage] placeholderImage:[UIImage imageNamed:@"sound_albumcover"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        self.avatorIconView.image = [UIImage circleImage:image borderWidth:0 borderColor:nil];
    }];
    
    self.userLabel.text = list.userInfo.nickname;
    self.countLabel.text = [NSString stringWithFormat:@"声音 %@ 粉丝 %@",[self countStr:[list.userInfo.tracks intValue]],[self countStr:[list.userInfo.followers intValue]]];
    self.descLabel.text =  list.userInfo.personDescribe;
    [self.progressButton setTitle:@"00:00" forState:UIControlStateNormal];
    if (self.isLocalAudio) {
        [self playLoacalAudio:list];
    }else{
        [self playRemoteAudio:list.playUrl64];
        
    }
    RCLog(@"%d-----%s",self.isLocalAudio,__func__);
    
}
- (NSString *)countStr:(int)count {
    NSString * str = nil;
    if (count ==0) {
    }else{
        
        //小于1000
        if (count <10000) {  //小于1000
            str = [NSString stringWithFormat:@"%d",count];
        }else if(count >10000){    //大于一万
            str = [NSString stringWithFormat:@"%.1f万",count/10000.0];
            str = [str stringByReplacingOccurrencesOfString:@".0" withString:@""];
        }
        
    }
    return str;
}

- (void)setUpWithButton:(UIButton *)button count:(int)count title:(NSString *)title {
    if (count ==0) {
        [button setTitle:title forState:UIControlStateNormal];
    }else{
        
        //小于1000
        if (count <10000) {  //小于1000
            title = [NSString stringWithFormat:@"%d",count];
        }else if(count >10000){    //大于一万
            title = [NSString stringWithFormat:@"%.1f万",count/10000.0];
            title = [title stringByReplacingOccurrencesOfString:@".0" withString:@""];
        }
        
        //大于14000  -> 1.4万
        
        //大于10445  -> 1万
        [button setTitle:title forState:UIControlStateNormal];
        
        
    }
    
}

- (IBAction)back:(id)sender {
    [RCNotificationCenter postNotificationName:backHomeNotification object:nil];
}
- (void)dealloc{
    [RCNotificationCenter removeObserver:self];
}
- (IBAction)playListButtonDidClicked:(UIButton *)sender {
    RCPlayListViewController * listVC = [[RCPlayListViewController alloc]init];
    listVC.title = @"播放列表";
    listVC.playLists = self.playLists;
    listVC.playingInfo = self.list;
    [RCPlayerView pushViewController:listVC];
}
- (IBAction)playHistoryButtonDidClicked:(UIButton *)sender {
    RCPlayHistoryViewController * listVC = [[RCPlayHistoryViewController alloc]init];
    listVC.title = @"播放历史";
    [RCPlayerView pushViewController:listVC];
    
}
- (IBAction)preButtonDidClicked:(UIButton *)sender {
    if (self.currentIndex <=0) {
        self.currentIndex = self.playLists.count;
    }
    self.currentIndex --;
    RCPlaylist * info = self.playLists[self.currentIndex];
    [RCNotificationCenter postNotificationName:sendNetWorkingNotification object:nil userInfo:@{netWorkingTrackIdNotificationName:info.trackId}];
    
}
- (IBAction)nextButtonDidClicked:(UIButton *)sender {
    if (self.currentIndex >= self.playLists.count-1) {
        self.currentIndex = 0;
    }
    self.currentIndex ++;
    RCPlaylist * info = self.playLists[self.currentIndex];
    [RCNotificationCenter postNotificationName:sendNetWorkingNotification object:nil userInfo:@{netWorkingTrackIdNotificationName:info.trackId}];
    
}
- (IBAction)playAndPauseButtonDidClicked:(UIButton *)sender {
    if ([AFSoundManager sharedManager].isPlaying) {
        sender.selected = NO;
        [self.smallIconVIew.layer removeAllAnimations];
        [[AFSoundManager sharedManager] pause];
    }else{
        sender.selected = YES;
        [self.smallIconVIew.layer addAnimation:[self animation] forKey:nil];
        [[AFSoundManager sharedManager] resume];
        
    }
    //    sender.selected = !sender.isSelected;
    //    BOOL isPlaying =  [AFSoundManager sharedManager].isPlaying;
    //    if (isPlaying) {
    //        NSLog(@"playAndPauseButtonDidClicked--正在播放.....");
    //    }else{
    //        NSLog(@"playAndPauseButtonDidClicked---停止播放.....");
    //
    //    }
    [RCNotificationCenter postNotificationName:playingNotification object:nil];
    
}
- (IBAction)pgoressValueChange:(UISlider *)sender {
    [[AFSoundManager sharedManager]moveToSection:sender.value];
    
}

#pragma mark - 播放本地音频

#pragma mark - 播放网络音频
- (void)playRemoteAudio:(NSString *)urlStr{
    [RCPlayerTool savePlayedAudio:self.list];
    [self.smallIconVIew.layer addAnimation:[self animation] forKey:nil];
    self.playAndPauseButtton.selected = YES;
    [[AFSoundManager sharedManager] startStreamingRemoteAudioFromURL:urlStr andBlock:^(int percentage, CGFloat elapsedTime, CGFloat timeRemaining, NSError *error, BOOL finished) {
        if (!error) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"mm:ss"];
            NSDate *elapsedTimeDate = [NSDate dateWithTimeIntervalSince1970:elapsedTime];
            NSDate *totalTimeDate = [NSDate dateWithTimeIntervalSince1970:timeRemaining+elapsedTime];
            NSString *  totalTimeDateStr=   [formatter  stringFromDate:totalTimeDate];
            NSString *  elapsedTimeDateStr=   [formatter  stringFromDate:elapsedTimeDate];
            self.playProgressLabel.text = [NSString stringWithFormat:@"%@/%@",elapsedTimeDateStr,totalTimeDateStr];
            [self.progressButton setTitle:[NSString stringWithFormat:@"%@",elapsedTimeDateStr] forState:UIControlStateNormal];
            [self.juhua stopAnimating];
            if (percentage < 0) {
                percentage = 0;
            }
            self.progressButton.x = percentage * 0.01* (self.pregressView.bounds.size.width  - self.progressButton.width);;
            
            self.currentprogressImageView.width = self.progressButton.centerX;//?
            NSLog(@"%f",self.currentprogressImageView.width);
            self.list.playTime = elapsedTimeDateStr;
        } else {
            self.playAndPauseButtton.selected = NO;
            [self.smallIconVIew.layer removeAllAnimations];
            NSLog(@"There has been an error playing the remote file: %@", [error description]);
        }
        if (finished) {
            [self nextButtonDidClicked:nil];
            
        }
    }];
    //    BOOL isPlaying =  [AFSoundManager sharedManager].isPlaying;
    //    if (isPlaying) {
    //        NSLog(@"playRemoteAudio--正在播放.....");
    //    }else{
    //        NSLog(@"playRemoteAudio---停止播放.....");
    //
    //    }
    [RCNotificationCenter postNotificationName:playingNotification object:nil];
    
}
- (void)playLoacalAudio:(RCPlaylist *)playingAudio{
    [RCPlayerTool savePlayedAudio:playingAudio];
    self.playAndPauseButtton.selected = YES;
    NSLog(@"playLoacalAudio-----%d",self.playAndPauseButtton.selected);
    [self.smallIconVIew.layer addAnimation:[self animation] forKey:nil];
    [[AFSoundManager sharedManager] startPlayingLocalFileWithName:[NSString stringWithFormat:@"%@.mp3",playingAudio.title] andBlock:^(int percentage, CGFloat elapsedTime, CGFloat timeRemaining, NSError *error, BOOL finished) {
        if (!error) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"mm:ss"];
            NSDate *elapsedTimeDate = [NSDate dateWithTimeIntervalSince1970:elapsedTime];
            NSDate *totalTimeDate = [NSDate dateWithTimeIntervalSince1970:timeRemaining+elapsedTime];
            NSString *  totalTimeDateStr=   [formatter  stringFromDate:totalTimeDate];
            NSString *  elapsedTimeDateStr=   [formatter  stringFromDate:elapsedTimeDate];
            self.playProgressLabel.text = [NSString stringWithFormat:@"%@/%@",elapsedTimeDateStr,totalTimeDateStr];
            [self.progressButton setTitle:[NSString stringWithFormat:@"%@",elapsedTimeDateStr] forState:UIControlStateNormal];
            [self.juhua stopAnimating];
            if (percentage < 0) {
                percentage = 0;
            }
            self.progressButton.x = percentage * 0.01* (self.pregressView.bounds.size.width  - self.progressButton.width);;
            self.currentprogressImageView.width = self.progressButton.centerX;
            self.list.playTime = elapsedTimeDateStr;
            NSLog(@"isplaying =========== %d",percentage);
            
        } else {
            //            self.playAndPauseButtton.selected = NO;
            //            [self.smallIconVIew.layer removeAllAnimations];
            
            NSLog(@"There has been an error playing the remote file: %@", [error description]);
        }
        if (finished) {
            [self nextButtonDidClicked:nil];
            
        }
    }];
    
    [RCNotificationCenter postNotificationName:playingNotification object:nil];
    
}

#pragma mark - 进度条
- (void)tapProgressView:(UITapGestureRecognizer *)sender {
    CGPoint point = [sender locationInView:sender.view];
    self.progressButton.x = point.x;
    double progress = point.x/(self.pregressView.bounds.size.width - self.progressButton.width);
    self.currentprogressImageView.width = self.progressButton.centerX;
    [[AFSoundManager sharedManager] moveToSection:0];
    [[AFSoundManager sharedManager]moveToSection:progress];
    
}
- (void)panPregoressButton:(UIPanGestureRecognizer *)recognizer {
    CGPoint point = [recognizer translationInView:recognizer.view];
    [recognizer setTranslation:CGPointZero inView:recognizer.view];
    self.progressButton.x += point.x;
    self.timeView.centerX =self.progressButton.centerX;
    self.currentprogressImageView.width = self.progressButton.centerX;
    CGFloat progress = self.progressButton.x/(self.pregressView.bounds.size.width - self.progressButton.width);
    [[AFSoundManager sharedManager]moveToSection:progress];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"mm:ss"];
    long long currentTime = progress* ([AFSoundManager sharedManager].player.currentItem.duration.value);
    NSDate *currentTimeDate = [NSDate dateWithTimeIntervalSince1970:currentTime];
    NSString * currentTimeDateStr = [formatter stringFromDate:currentTimeDate];
    CGFloat durationTime =  ([AFSoundManager sharedManager].player.currentItem.duration.value);
    NSDate *durationTimeData = [NSDate dateWithTimeIntervalSince1970:durationTime];
    NSString * durationTimeDataStr = [formatter stringFromDate:durationTimeData];
    self.playProgressLabel.text = [NSString stringWithFormat:@"%@/%@",currentTimeDateStr,durationTimeDataStr];
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [[AFSoundManager sharedManager]pause];
        self.timeView.hidden = NO;
    }else if (recognizer.state == UIGestureRecognizerStateEnded|| recognizer.state == UIGestureRecognizerStateCancelled){
        [[AFSoundManager sharedManager]resume];
        self.timeView.hidden = YES;
        
    }
    
}
- (CABasicAnimation *)animation{
    CABasicAnimation * transformAnim = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    transformAnim.fromValue          = @(0);
    transformAnim.toValue            = @(360 * M_PI/180);
    transformAnim.duration           = 10;
    transformAnim.repeatCount        = INFINITY;
    transformAnim.fillMode = kCAFillModeForwards;
    transformAnim.removedOnCompletion = NO;
    return transformAnim;
}

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    if (view == self) {
        return nil;
    }
    return view;
}

//-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    [super touchesBegan:touches withEvent:event];
//    NSLog(@"%f--",self.currentprogressImageView.frame.size.width);
//}

@end
