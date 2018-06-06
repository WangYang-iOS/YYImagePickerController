//
//  HQPhotoBrowser.m
//  HQPhotoBrowser
//
//  Created by wangyang on 2018/4/25.
//  Copyright © 2018年 HangzhouHaiqu. All rights reserved.
//

#import "HQPhotoBrowser.h"
#import "HQPhotoView.h"

static const NSTimeInterval kAnimationDuration = 0.3;
static const NSTimeInterval kSpringAnimationDuration = 0.5;

@interface HQPhotoBrowser ()<UIScrollViewDelegate, UIViewControllerTransitioningDelegate, CAAnimationDelegate> {
    CGPoint _startLocation;
}

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *photoItems;
@property (nonatomic, strong) NSMutableSet *reusableItemViews;
@property (nonatomic, strong) NSMutableArray *visibleItemViews;
@property (nonatomic, assign) NSUInteger currentPage;
@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UILabel *pageLabel;
@property (nonatomic, assign) BOOL presented;

@end

@implementation HQPhotoBrowser

// MAKR: - Initializer

+ (instancetype)browserWithPhotoItems:(NSArray<HQPhotoItem *> *)photoItems selectedIndex:(NSUInteger)selectedIndex {
    HQPhotoBrowser *browser = [[HQPhotoBrowser alloc] initWithPhotoItems:photoItems selectedIndex:selectedIndex];
    return browser;
}

- (instancetype)init {
    NSAssert(NO, @"Use initWithMediaItems: instead.");
    return nil;
}

- (instancetype)initWithPhotoItems:(NSArray<HQPhotoItem *> *)photoItems selectedIndex:(NSUInteger)selectedIndex {
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        
        _photoItems = [NSMutableArray arrayWithArray:photoItems];
        _currentPage = selectedIndex;
        
        _dismissalStyle = HQPhotoBrowserInteractiveDismissalStyleScale;
        _pageindicatorStyle = HQPhotoBrowserPageIndicatorStyleDot;
        _backgroundStyle = HQPhotoBrowserBackgroundStyleBlack;
        _loadingStyle = HQPhotoBrowserImageLoadingStyleIndeterminate;
        
        _reusableItemViews = [[NSMutableSet alloc] init];
        _visibleItemViews = [[NSMutableArray alloc] init];
    }
    return self;
}

// MARK: - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    _backgroundView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    _backgroundView.contentMode = UIViewContentModeScaleAspectFill;
    _backgroundView.alpha = 0;
    [self.view addSubview:_backgroundView];
    
    CGRect rect = self.view.bounds;
    rect.origin.x -= kHQPhotoViewPadding;
    rect.size.width += 2 * kHQPhotoViewPadding;
    _scrollView = [[UIScrollView alloc] initWithFrame:rect];
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
    
    if (_pageindicatorStyle == HQPhotoBrowserPageIndicatorStyleDot) {
        if (_photoItems.count > 1) {
            _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-40, self.view.bounds.size.width, 20)];
            _pageControl.numberOfPages = _photoItems.count;
            _pageControl.currentPage = _currentPage;
            [self.view addSubview:_pageControl];
        }
    } else {
        _pageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-40, self.view.bounds.size.width, 20)];
        _pageLabel.textColor = [UIColor whiteColor];
        _pageLabel.font = [UIFont systemFontOfSize:16];
        _pageLabel.textAlignment = NSTextAlignmentCenter;
        [self configPageLabelWithPage:_currentPage];
        [self.view addSubview:_pageLabel];
    }
    
    CGSize contentSize = CGSizeMake(rect.size.width * _photoItems.count, rect.size.height);
    _scrollView.contentSize = contentSize;
    
    [self addGestureRecognizer];
    
    CGPoint contentOffset = CGPointMake(_scrollView.frame.size.width*_currentPage, 0);
    [_scrollView setContentOffset:contentOffset animated:NO];
    if (contentOffset.x == 0) {
        [self scrollViewDidScroll:_scrollView];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    HQPhotoItem *item = [_photoItems objectAtIndex:_currentPage];
    HQPhotoView *photoView = [self photoViewForPage:_currentPage];
    
    photoView.imageView.image = item.thumbImage;
    [photoView resizeImageView];
    
    CGRect endRect = photoView.imageView.frame;
    CGRect sourceRect;
    float systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (systemVersion >= 8.0 && systemVersion < 9.0) {
        sourceRect = [item.sourceView.superview convertRect:item.sourceView.frame toCoordinateSpace:photoView];
    } else {
        sourceRect = [item.sourceView.superview convertRect:item.sourceView.frame toView:photoView];
    }
    photoView.imageView.frame = sourceRect;
    
    if (_backgroundStyle == HQPhotoBrowserBackgroundStyleBlur) {
        [self blurBackgroundWithImage:[self screenshot] animated:NO];
    } else if (_backgroundStyle == HQPhotoBrowserBackgroundStyleBlurPhoto) {
        [self blurBackgroundWithImage:item.thumbImage animated:NO];
    }
    if (_bounces) {
        [UIView animateWithDuration:kSpringAnimationDuration delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:kNilOptions animations:^{
            photoView.imageView.frame = endRect;
            self.view.backgroundColor = [UIColor blackColor];
            _backgroundView.alpha = 1;
        } completion:^(BOOL finished) {
            [self configPhotoView:photoView withItem:item];
            _presented = YES;
            [self setStatusBarHidden:YES];
        }];
    } else {
        [UIView animateWithDuration:kAnimationDuration animations:^{
            photoView.imageView.frame = endRect;
            self.view.backgroundColor = [UIColor blackColor];
            _backgroundView.alpha = 1;
        } completion:^(BOOL finished) {
            [self configPhotoView:photoView withItem:item];
            _presented = YES;
            [self setStatusBarHidden:YES];
        }];
    }
}

- (void)dealloc {
    
}

// MARK: - Public

- (void)showFromViewController:(UIViewController *)vc {
    [vc presentViewController:self animated:NO completion:nil];
}

// MARK: - Private

- (void)setStatusBarHidden:(BOOL)hidden {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (hidden) {
        window.windowLevel = UIWindowLevelStatusBar + 1;
    } else {
        window.windowLevel = UIWindowLevelNormal;
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (HQPhotoView *)photoViewForPage:(NSUInteger)page {
    for (HQPhotoView *photoView in _visibleItemViews) {
        if (photoView.tag == page) {
            return photoView;
        }
    }
    return nil;
}

- (HQPhotoView *)dequeueReusableItemView {
    HQPhotoView *photoView = [_reusableItemViews anyObject];
    if (photoView == nil) {
        photoView = [[HQPhotoView alloc] initWithFrame:_scrollView.bounds];
    } else {
        [_reusableItemViews removeObject:photoView];
    }
    photoView.tag = -1;
    return photoView;
}

- (void)updateReusableItemViews {
    NSMutableArray *itemsForRemove = @[].mutableCopy;
    for (HQPhotoView *photoView in _visibleItemViews) {
        if (photoView.frame.origin.x + photoView.frame.size.width < _scrollView.contentOffset.x - _scrollView.frame.size.width ||
            photoView.frame.origin.x > _scrollView.contentOffset.x + 2 * _scrollView.frame.size.width) {
            [photoView removeFromSuperview];
            [self configPhotoView:photoView withItem:nil];
            [itemsForRemove addObject:photoView];
            [_reusableItemViews addObject:photoView];
        }
    }
    [_visibleItemViews removeObjectsInArray:itemsForRemove];
}

- (void)configItemViews {
    NSInteger page = _scrollView.contentOffset.x / _scrollView.frame.size.width + 0.5;
    for (NSInteger i = page - 1; i <= page + 1; i++) {
        if (i < 0 || i >= _photoItems.count) {
            continue;
        }
        HQPhotoView *photoView = [self photoViewForPage:i];
        if (photoView == nil) {
            photoView = [self dequeueReusableItemView];
            CGRect rect = _scrollView.bounds;
            rect.origin.x = i * _scrollView.bounds.size.width;
            photoView.frame = rect;
            photoView.tag = i;
            [_scrollView addSubview:photoView];
            [_visibleItemViews addObject:photoView];
        }
        NSLog(@"%@",photoView);
        if (photoView.item == nil && _presented) {
            HQPhotoItem *item = [_photoItems objectAtIndex:i];
            [self configPhotoView:photoView withItem:item];
        }
    }
    
    if (page != _currentPage && _presented && (page >= 0 && page < _photoItems.count)) {
        HQPhotoItem *item = [_photoItems objectAtIndex:page];
        if (_backgroundStyle == HQPhotoBrowserBackgroundStyleBlurPhoto) {
            [self blurBackgroundWithImage:item.thumbImage animated:YES];
        }
        _currentPage = page;
        if (_pageindicatorStyle == HQPhotoBrowserPageIndicatorStyleDot) {
            _pageControl.currentPage = page;
        } else {
            [self configPageLabelWithPage:_currentPage];
        }
//        if (_delegate && [_delegate respondsToSelector:@selector(ks_photoBrowser:didSelectItem:atIndex:)]) {
//            [_delegate ks_photoBrowser:self didSelectItem:item atIndex:page];
//        }
    }
}

- (void)dismissAnimated:(BOOL)animated {
    for (HQPhotoView *photoView in _visibleItemViews) {
//        [photoView cancelCurrentImageLoad];
    }
    HQPhotoItem *item = [_photoItems objectAtIndex:_currentPage];
    if (animated) {
        [UIView animateWithDuration:kAnimationDuration animations:^{
            item.sourceView.alpha = 1;
        }];
    } else {
        item.sourceView.alpha = 1;
    }
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)performRotationWithPan:(UIPanGestureRecognizer *)pan {
    CGPoint point = [pan translationInView:self.view];
    CGPoint location = [pan locationInView:self.view];
    CGPoint velocity = [pan velocityInView:self.view];
    HQPhotoView *photoView = [self photoViewForPage:_currentPage];
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            _startLocation = location;
            [self handlePanBegin];
            break;
        case UIGestureRecognizerStateChanged: {
            CGFloat angle = 0;
            if (_startLocation.x < self.view.frame.size.width/2) {
                angle = -(M_PI / 2) * (point.y / self.view.frame.size.height);
            } else {
                angle = (M_PI / 2) * (point.y / self.view.frame.size.height);
            }
            CGAffineTransform rotation = CGAffineTransformMakeRotation(angle);
            CGAffineTransform translation = CGAffineTransformMakeTranslation(0, point.y);
            CGAffineTransform transform = CGAffineTransformConcat(rotation, translation);
            photoView.imageView.transform = transform;
            
            double percent = 1 - fabs(point.y)/(self.view.frame.size.height/2);
            self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:percent];
            _backgroundView.alpha = percent;
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            if (fabs(point.y) > 200 || fabs(velocity.y) > 500) {
                [self showRotationCompletionAnimationFromPoint:point];
            } else {
                [self showCancellationAnimation];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)performScaleWithPan:(UIPanGestureRecognizer *)pan {
    CGPoint point = [pan translationInView:self.view];
    CGPoint location = [pan locationInView:self.view];
    CGPoint velocity = [pan velocityInView:self.view];
    HQPhotoView *photoView = [self photoViewForPage:_currentPage];
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            _startLocation = location;
            [self handlePanBegin];
            break;
        case UIGestureRecognizerStateChanged: {
            double percent = 1 - fabs(point.y) / self.view.frame.size.height;
            percent = MAX(percent, 0);
            double s = MAX(percent, 0.5);
            CGAffineTransform translation = CGAffineTransformMakeTranslation(point.x/s, point.y/s);
            CGAffineTransform scale = CGAffineTransformMakeScale(s, s);
            photoView.imageView.transform = CGAffineTransformConcat(translation, scale);
            self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:percent];
            _backgroundView.alpha = percent;
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            if (fabs(point.y) > 100 || fabs(velocity.y) > 500) {
                [self showDismissalAnimation];
            } else {
                [self showCancellationAnimation];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)performSlideWithPan:(UIPanGestureRecognizer *)pan {
    CGPoint point = [pan translationInView:self.view];
    CGPoint location = [pan locationInView:self.view];
    CGPoint velocity = [pan velocityInView:self.view];
    HQPhotoView *photoView = [self photoViewForPage:_currentPage];
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            _startLocation = location;
            [self handlePanBegin];
            break;
        case UIGestureRecognizerStateChanged: {
            photoView.imageView.transform = CGAffineTransformMakeTranslation(0, point.y);
            double percent = 1 - fabs(point.y)/(self.view.frame.size.height/2);
            self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:percent];
            _backgroundView.alpha = percent;
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            if (fabs(point.y) > 200 || fabs(velocity.y) > 500) {
                [self showSlideCompletionAnimationFromPoint:point];
            } else {
                [self showCancellationAnimation];
            }
        }
            break;
            
        default:
            break;
    }
}

- (UIImage *)screenshot {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIGraphicsBeginImageContextWithOptions(window.bounds.size, YES, [UIScreen mainScreen].scale);
    [window.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)blurBackgroundWithImage:(UIImage *)image animated:(BOOL)animated {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //模糊效果未实现需要自行实现
//        UIImage *blurImage = [image hq_imageByBlurDark];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (animated) {
                [UIView animateWithDuration:kAnimationDuration animations:^{
                    _backgroundView.alpha = 0;
                } completion:^(BOOL finished) {
//                    _backgroundView.image = blurImage;
                    [UIView animateWithDuration:kAnimationDuration animations:^{
                        _backgroundView.alpha = 1;
                    } completion:nil];
                }];
            } else {
//                _backgroundView.image = blurImage;
            }
        });
    });
}

- (void)configPhotoView:(HQPhotoView *)photoView withItem:(HQPhotoItem *)item {
    [photoView setItem:item determinate:(_loadingStyle == HQPhotoBrowserImageLoadingStyleDeterminate)];
}

- (void)configPageLabelWithPage:(NSUInteger)page {
    _pageLabel.text = [NSString stringWithFormat:@"%lu / %lu", page+1, _photoItems.count];
}

- (void)handlePanBegin {
    HQPhotoView *photoView = [self photoViewForPage:_currentPage];
//    [photoView cancelCurrentImageLoad];
    HQPhotoItem *item = [_photoItems objectAtIndex:_currentPage];
    [self setStatusBarHidden:NO];
    item.sourceView.alpha = 0;
}

// MARK: - Gesture Recognizer

- (void)addGestureRecognizer {
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTap];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSingleTap:)];
    singleTap.numberOfTapsRequired = 1;
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [self.view addGestureRecognizer:singleTap];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPress:)];
    [self.view addGestureRecognizer:longPress];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
    [self.view addGestureRecognizer:pan];
}

- (void)didSingleTap:(UITapGestureRecognizer *)tap {
    [self showDismissalAnimation];
}

- (void)didDoubleTap:(UITapGestureRecognizer *)tap {
    HQPhotoView *photoView = [self photoViewForPage:_currentPage];
    HQPhotoItem *item = [_photoItems objectAtIndex:_currentPage];
    if (!item.finished) {
        return;
    }
    if (photoView.zoomScale > 1) {
        [photoView setZoomScale:1 animated:YES];
    } else {
        CGPoint location = [tap locationInView:self.view];
        CGFloat maxZoomScale = photoView.maximumZoomScale;
        CGFloat width = self.view.bounds.size.width / maxZoomScale;
        CGFloat height = self.view.bounds.size.height / maxZoomScale;
        [photoView zoomToRect:CGRectMake(location.x - width/2, location.y - height/2, width, height) animated:YES];
    }
}

- (void)didLongPress:(UILongPressGestureRecognizer *)longPress {
    if (longPress.state != UIGestureRecognizerStateBegan) {
        return;
    }
    HQPhotoView *photoView = [self photoViewForPage:_currentPage];
    UIImage *image = photoView.imageView.image;
    if (!image) {
        return;
    }
    
//    [HQCommenMethods showSheetViewWithTitle:nil message:nil cancelButtonTitle:@"取消" titleArray:@[@"保存图片"] cancelBlock:nil sureBlock:^(UIAlertAction *action) {
//        // 保存相册
//        SEL saveImage = @selector(imagWasSaveSuccessfully:didFinishWithError:contextInfo:);
//        UIImageWriteToSavedPhotosAlbum(image, self, saveImage, nil);
//    }];
}

- (void)imagWasSaveSuccessfully:(UIImage *)image
             didFinishWithError:(NSError *)paraError
                    contextInfo:(void *)info {
    if (!paraError) {
//        HUDM(@"图片保存成功", [Commen getCurrentWindow])
    }
}

- (void)didPan:(UIPanGestureRecognizer *)pan {
    HQPhotoView *photoView = [self photoViewForPage:_currentPage];
    if (photoView.zoomScale > 1.1) {
        return;
    }
    
    switch (_dismissalStyle) {
        case HQPhotoBrowserInteractiveDismissalStyleRotation:
            [self performRotationWithPan:pan];
            break;
        case HQPhotoBrowserInteractiveDismissalStyleScale:
            [self performScaleWithPan:pan];
            break;
        case HQPhotoBrowserInteractiveDismissalStyleSlide:
            [self performSlideWithPan:pan];
            break;
        default:
            break;
    }
}

// MARK: - Animation

- (void)showCancellationAnimation {
    HQPhotoView *photoView = [self photoViewForPage:_currentPage];
    HQPhotoItem *item = [_photoItems objectAtIndex:_currentPage];
    item.sourceView.alpha = 1;
    
    if (_bounces && _dismissalStyle == HQPhotoBrowserInteractiveDismissalStyleScale) {
        [UIView animateWithDuration:kSpringAnimationDuration delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:kNilOptions animations:^{
            photoView.imageView.transform = CGAffineTransformIdentity;
            self.view.backgroundColor = [UIColor blackColor];
            _backgroundView.alpha = 1;
        } completion:^(BOOL finished) {
            [self setStatusBarHidden:YES];
            [self configPhotoView:photoView withItem:item];
        }];
    } else {
        [UIView animateWithDuration:kAnimationDuration animations:^{
            photoView.imageView.transform = CGAffineTransformIdentity;
            self.view.backgroundColor = [UIColor blackColor];
            _backgroundView.alpha = 1;
        } completion:^(BOOL finished) {
            [self setStatusBarHidden:YES];
            [self configPhotoView:photoView withItem:item];
        }];
    }
}

- (void)showRotationCompletionAnimationFromPoint:(CGPoint)point {
    HQPhotoView *photoView = [self photoViewForPage:_currentPage];
    BOOL startFromLeft = _startLocation.x < self.view.frame.size.width / 2;
    BOOL throwToTop = point.y < 0;
    CGFloat angle, toTranslationY;
    if (throwToTop) {
        angle = startFromLeft ? (M_PI / 2) : -(M_PI / 2);
        toTranslationY = -self.view.frame.size.height;
    } else {
        angle = startFromLeft ? -(M_PI / 2) : (M_PI / 2);
        toTranslationY = self.view.frame.size.height;
    }
    
    CGFloat angle0 = 0;
    if (_startLocation.x < self.view.frame.size.width/2) {
        angle0 = -(M_PI / 2) * (point.y / self.view.frame.size.height);
    } else {
        angle0 = (M_PI / 2) * (point.y / self.view.frame.size.height);
    }
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.fromValue = @(angle0);
    rotationAnimation.toValue = @(angle);
    CABasicAnimation *translationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    translationAnimation.fromValue = @(point.y);
    translationAnimation.toValue = @(toTranslationY);
    CAAnimationGroup *throwAnimation = [CAAnimationGroup animation];
    throwAnimation.duration = kAnimationDuration;
    throwAnimation.delegate = self;
    throwAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    throwAnimation.animations = @[rotationAnimation, translationAnimation];
    [throwAnimation setValue:@"throwAnimation" forKey:@"id"];
    [photoView.imageView.layer addAnimation:throwAnimation forKey:@"throwAnimation"];
    
    CGAffineTransform rotation = CGAffineTransformMakeRotation(angle);
    CGAffineTransform translation = CGAffineTransformMakeTranslation(0, toTranslationY);
    CGAffineTransform transform = CGAffineTransformConcat(rotation, translation);
    photoView.imageView.transform = transform;
    
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.view.backgroundColor = [UIColor clearColor];
        _backgroundView.alpha = 0;
    } completion:nil];
}

- (void)showDismissalAnimation {
    HQPhotoItem *item = [_photoItems objectAtIndex:_currentPage];
    HQPhotoView *photoView = [self photoViewForPage:_currentPage];
//    [photoView cancelCurrentImageLoad];
    [self setStatusBarHidden:NO];
    
    if (item.sourceView == nil) {
        [UIView animateWithDuration:kAnimationDuration animations:^{
            self.view.alpha = 0;
        } completion:^(BOOL finished) {
            [self dismissAnimated:NO];
        }];
        return;
    }
    
    item.sourceView.alpha = 0;
    CGRect sourceRect;
    float systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (systemVersion >= 8.0 && systemVersion < 9.0) {
        sourceRect = [item.sourceView.superview convertRect:item.sourceView.frame toCoordinateSpace:photoView];
    } else {
        sourceRect = [item.sourceView.superview convertRect:item.sourceView.frame toView:photoView];
    }
    if (_bounces) {
        [UIView animateWithDuration:kSpringAnimationDuration delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:kNilOptions animations:^{
            photoView.imageView.frame = sourceRect;
            self.view.backgroundColor = [UIColor clearColor];
            _backgroundView.alpha = 0;
        } completion:^(BOOL finished) {
            [self dismissAnimated:NO];
        }];
    } else {
        [UIView animateWithDuration:kAnimationDuration animations:^{
            photoView.imageView.frame = sourceRect;
            self.view.backgroundColor = [UIColor clearColor];
            _backgroundView.alpha = 0;
        } completion:^(BOOL finished) {
            [self dismissAnimated:NO];
        }];
    }
}

- (void)showSlideCompletionAnimationFromPoint:(CGPoint)point {
    HQPhotoView *photoView = [self photoViewForPage:_currentPage];
    BOOL throwToTop = point.y < 0;
    CGFloat toTranslationY = 0;
    if (throwToTop) {
        toTranslationY = -self.view.frame.size.height;
    } else {
        toTranslationY = self.view.frame.size.height;
    }
    [UIView animateWithDuration:kAnimationDuration animations:^{
        photoView.imageView.transform = CGAffineTransformMakeTranslation(0, toTranslationY);
        self.view.backgroundColor = [UIColor clearColor];
        _backgroundView.alpha = 0;
    } completion:^(BOOL finished) {
        [self dismissAnimated:YES];
    }];
}

// MARK: - Animation Delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if ([[anim valueForKey:@"id"] isEqualToString:@"throwAnimation"]) {
        [self dismissAnimated:YES];
    }
}

// MARK: - ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateReusableItemViews];
    [self configItemViews];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
