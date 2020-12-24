//
//  SJCScrollAlbumView.m
//  Yehwang
//
//  Created by Yehwang on 2020/12/9.
//  Copyright © 2020 Yehwang. All rights reserved.
//

#import "SJCScrollAlbumView.h"

@interface SJCScrollAlbumItem : UICollectionViewCell
@property(strong,nonatomic) UIImageView *goodImageView;
@end

@implementation SJCScrollAlbumItem

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        [self setupControls];
    }
    return self;
}

- (void)setupControls {

    self.transform = CGAffineTransformMakeScale(-1, 1);
    
    _goodImageView = [[UIImageView alloc] init];
    _goodImageView.contentMode = UIViewContentModeScaleAspectFill;
    _goodImageView.backgroundColor = themeBackgroundColor;
    _goodImageView.clipsToBounds = YES;
    _goodImageView.sd_imageTransition = [SDWebImageTransition fadeTransition];
    [self.contentView addSubview:_goodImageView];

    [_goodImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(0);
        make.right.mas_equalTo(self.contentView).offset(-0);
        make.top.mas_equalTo(self.contentView).offset(0);
        make.bottom.mas_equalTo(self.contentView).offset(0);
    }];
}

@end


@interface SJCScrollAlbumView ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UICollectionView *mainView;
@property (assign,nonatomic) CGFloat offsetX;
@property (nonatomic, weak) NSTimer *timer;
@property (nonatomic, strong) NSArray *imagePathsGroup;
@end

@implementation SJCScrollAlbumView

+ (instancetype)scrollAlbumViewWithFrame:(CGRect)frame imageURLStringsGroup:(NSArray *)imageURLStringsGroup {
    NSAssert(frame.size.width&&frame.size.height, @"frame必须给定不为零");
    SJCScrollAlbumView *cycleScrollView = [[self alloc] initWithFrame:frame];
    cycleScrollView.imageURLStringsGroup = [NSMutableArray arrayWithArray:imageURLStringsGroup];
    return cycleScrollView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialization];
        [self setupMainView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initialization];
    [self setupMainView];
}

- (void)initialization {
    _offsetX = 0.0f;
    _speed = 200.f;
    _scrollEnabled = NO;
}

- (void)setupMainView {
    self.clipsToBounds = YES;
    
    //父视图的宽高
    double width = self.width;
    double height = self.height;
    
    double x = pow(width, 2);
    double y = pow(height, 2);
    double w = sqrt(x + y);
    double h = (width * height / w - height*0.5)*2+height;
    
    
    UIView *vvv = [[UIView alloc] initWithFrame:CGRectMake(-(w-width)*0.5, -(width * height / w - height*0.5), w, h)];
    vvv.backgroundColor = ClearColor;
    _containerView = vvv;
    [self addSubview:vvv];
    [_containerView addSubview:self.mainView];
    _containerView.transform = CGAffineTransformMakeRotation(-atan(height/width));
}

- (void)setImageURLStringsGroup:(NSArray *)imageURLStringsGroup {
    _imageURLStringsGroup = imageURLStringsGroup;
    
    NSMutableArray *temp = [NSMutableArray new];
    [_imageURLStringsGroup enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL * stop) {
        NSString *urlString;
        if ([obj isKindOfClass:[NSString class]]) {
            urlString = obj;
        } else if ([obj isKindOfClass:[NSURL class]]) {
            NSURL *url = (NSURL *)obj;
            urlString = [url absoluteString];
        }
        if (urlString) {
            [temp addObject:urlString];
        }
    }];
    self.imagePathsGroup = [temp copy];
}

- (void)setImagePathsGroup:(NSArray *)imagePathsGroup {
    [self invalidateTimer];
    
    _imagePathsGroup = imagePathsGroup;
    [self setupTimer];
    [self.mainView reloadData];
}

- (void)setSpeed:(CGFloat)speed {
    if (_speed != speed) {
        _speed = MAX(10, MIN(speed, 1000));
        [self invalidateTimer];
        [self setupTimer];
    }
}

- (void)setScrollEnabled:(BOOL)scrollEnabled {
    if (_scrollEnabled != scrollEnabled) {
        _scrollEnabled = scrollEnabled;
        _mainView.scrollEnabled = scrollEnabled;
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
    if (!newSuperview) {
        [self invalidateTimer];
    }
}

- (void)setupTimer {
    [self invalidateTimer];
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0/self.speed target:self selector:@selector(automaticScroll) userInfo:nil repeats:YES];
    _timer = timer;
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)invalidateTimer {
    [_timer invalidate];
    _timer = nil;
}

- (void)automaticScroll {
    //滚动速度,50/s
    self.offsetX += .1;
    [self.mainView setContentOffset:CGPointMake(self.offsetX, 0)];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self invalidateTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self setupTimer];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.offsetX = scrollView.contentOffset.x;
    [self setupTimer];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.offsetX = scrollView.contentOffset.x;
    if (scrollView.contentOffset.x>=(fabs(self.mainView.contentSize.width-self.mainView.width))) {
        [self invalidateTimer];
        self.offsetX = 0.0f;
        [self setupTimer];
    }
}

#pragma -mark UICollectionViewDelegate & UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imagePathsGroup.count*100;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SJCScrollAlbumItem *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SJCScrollAlbumItem" forIndexPath:indexPath];
    long itemIndex = (int)indexPath.item % self.imagePathsGroup.count;
    NSString *imagePath = self.imagePathsGroup[itemIndex];
    
    if ([imagePath isKindOfClass:[NSString class]]) {
        if ([imagePath hasPrefix:@"http"]) {
            [cell.goodImageView sd_setImageWithURL:[NSURL URLWithString:imagePath]];
        } else {
            UIImage *image = [UIImage imageNamed:imagePath];
            if (!image) {
                image = [UIImage imageWithContentsOfFile:imagePath];
            }
            cell.goodImageView.image = image;
        }
    }else if ([imagePath isKindOfClass:[UIImage class]]) {
        cell.goodImageView.image = (UIImage *)imagePath;
    }
    return cell;
}

- (UICollectionView *)mainView {
    if (!_mainView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 10;
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        layout.itemSize = CGSizeMake((self.containerView.width-20)/3, (self.containerView.height-20)/3);
        _mainView = [[UICollectionView alloc] initWithFrame:self.containerView.bounds collectionViewLayout:layout];
        _mainView.delegate = self;
        _mainView.dataSource = self;
        _mainView.scrollEnabled = self.scrollEnabled;
        _mainView.backgroundColor = [UIColor clearColor];
        [_mainView registerClass:[SJCScrollAlbumItem class] forCellWithReuseIdentifier:@"SJCScrollAlbumItem"];
        //镜像
        _mainView.transform = CGAffineTransformMakeScale(-1, 1);
    }
    return _mainView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)dealloc {
    _mainView.delegate = nil;
    _mainView.dataSource = nil;
}


@end
