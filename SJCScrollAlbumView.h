//
//  SJCScrollAlbumView.h
//  Yehwang
//
//  Created by Yehwang on 2020/12/9.
//  Copyright © 2020 Yehwang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SJCScrollAlbumView : UIView

+ (instancetype)scrollAlbumViewWithFrame:(CGRect)frame imageURLStringsGroup:(NSArray *)imageURLStringsGroup;

/** 网络图片 url string 数组 */
@property (nonatomic, strong) NSArray *imageURLStringsGroup;
/** 滚动速度，默认为200，取值范围(10~1000) */
@property(assign,nonatomic) CGFloat speed;
/** 是否可以拖动，默认为NO */
@property(nonatomic,getter=isScrollEnabled) BOOL scrollEnabled;
@end

NS_ASSUME_NONNULL_END
