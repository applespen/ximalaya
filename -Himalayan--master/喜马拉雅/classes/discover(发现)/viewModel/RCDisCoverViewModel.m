//
//  RCDisCoverViewModel.m
//  喜马拉雅
//
//  Created by Raychen on 15/5/19.
//  Copyright (c) 2015年 Raychen. All rights reserved.
//

#import "RCDisCoverViewModel.h"
#import "RCDiscoverData.h"
#import "RCConst.h"
#import "MJExtension.h"
#import "Reachability.h"
#import "RCNetWorkingTool.h"
#import "RCFocusImage.h"
#import "RCRecommendAlbums.h"
#import "RCDiscoverDataTool.h"
@interface RCDisCoverViewModel ()
@property(nonatomic,strong) NSArray  *categories;
@property(nonatomic,strong) NSMutableArray  *focusImages;
@property(nonatomic,strong) NSMutableArray  *recommendAlbums;
@property(strong,nonatomic) NSTimer * timer;
@end
@implementation RCDisCoverViewModel

/**
 *  分类数据
 *
 */
-  (NSArray *)categories{
    if (!_categories) {
         self.categories = [RCCatrgory objectArrayWithFilename:@"Category.plist"];
    }
    return _categories;
}
/**
 *  发现界面的数据
 *
 */
-  (NSMutableArray *)focusImages{
    if (!_focusImages) {
        self.focusImages = [NSMutableArray array];
    }
    return _focusImages;
}
-  (NSMutableArray *)recommendAlbums{
    if (!_recommendAlbums) {
        self.recommendAlbums = [NSMutableArray array];
    }
    return _recommendAlbums;
}
- (void)fetchDiscoverDataWithSuccess:(void (^)(void))success failure:(void (^)(void))failure{
    if ([[Reachability reachabilityForInternetConnection] isNetWorking]) {
        [RCNetWorkingTool get:@"http://mobile.ximalaya.com/m/super_explore_index2?device=android&channel=and-c57&includeActivity=true&picVersion=5&scale=2&version=3.25.7.1" params:nil success:^(id json) {
            RCDiscoverData * discoverData = [RCDiscoverData objectWithKeyValues:json];
            self.discoverData = discoverData;
            [RCDiscoverDataTool saveDiscoverData:discoverData];
            [RCDiscoverDataTool saveFocusImages:discoverData.focusImages.list];
            [self.focusImages addObjectsFromArray:discoverData.focusImages.list];
            [RCDiscoverDataTool saveRecommendAlbums:discoverData.recommendAlbums.list];
            [self.recommendAlbums addObjectsFromArray:discoverData.recommendAlbums.list];
            if (success) {
                success();
            }
        } failure:^(NSError *error) {
            if (failure) {
                failure();
            }
            RCLog(@"%@",error);
        }];
    }else{
        self.discoverData = [RCDiscoverDataTool discoverData];
        [self.focusImages addObjectsFromArray:[RCDiscoverDataTool focusImages]];
        [self.recommendAlbums addObjectsFromArray:[RCDiscoverDataTool recommendAlbums]];

    }
   }
#pragma mark - collectionView
- (NSInteger)numberOfSectionsInCollectionView{
    return 1;
}
- (NSInteger)numberOfItemInSectionInCategoryCollectionView:(NSInteger)section{
        return self.categories.count;
}
- (NSInteger)numberOfItemInSectionInImgCollectionView:(NSInteger)section{
    return self.focusImages.count;
}
- (RCCatrgory *)categoryAtIndexPathInCollectionView:(NSIndexPath *)indexPath{
    return self.categories[indexPath.item];
}
- (RCList *)imgAtIndexPathInCollectionView:(NSIndexPath *)indexPath{
    return self.focusImages[indexPath.item];
}

#pragma mark - tableView

- (NSInteger)numberOfSectionsInTableView{

    return 4;
}
- (NSInteger)numberOfItemInSectionInTableView: (NSInteger)section{
    if (section == 0) {
        return 1;
    }else if (section == 1){
        return self.recommendAlbums.count;

    }else if (section == 2){

        return 1;
    }else if (section == 3){

        return 1;
    }
    return 1;

}
- (CGFloat)cellHeihtWithIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 ) {
        return 104;

    }else if (indexPath.section == 1){

        return 73;

    }
    return 80;

}
- (RCRecommendAlbums *)itemAtIndexPathInTableView: (NSIndexPath *)indexPath{
    return self.recommendAlbums[indexPath.row];
}
@end
