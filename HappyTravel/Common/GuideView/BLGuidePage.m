//
//  BLGuidePages.m
//
//  Created by 千山暮雪 on 16/3/7.
//  Copyright © 2016年 千山暮雪. All rights reserved.
//

#import "BLGuidePage.h"

@interface BLGuidePage ()<UIScrollViewDelegate>

@property(nonatomic, strong)UIScrollView *scrollView;

@end
@implementation BLGuidePage

-(instancetype)initWithImageArray: (NSArray *) imageSource {
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if ( self ) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.frame];
        _scrollView.delegate = self;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.bounces = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width * imageSource.count, [UIScreen mainScreen].bounds.size.height);
        [self addSubview:self.scrollView ];
     
        for (int i = 0; i < imageSource.count; i ++ ) {
            UIImageView *imgView = [[UIImageView alloc] init];
            imgView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width * i, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
            imgView.image = [UIImage imageNamed:imageSource[i]];
            [self.scrollView addSubview:imgView];
            
            if ( i == imageSource.count - 1) {
                imgView.userInteractionEnabled = YES ;
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
                [imgView addGestureRecognizer:tap];
            }
        }
    }
    return  self ;
}

- (void) tapAction {
    if ([self.delegate respondsToSelector:@selector(lastImageClicked)]) {
        [self.delegate lastImageClicked ];
    }
}
- (void)clickPageAction:(UIPageControl *)pageControl {
    
    NSInteger page = pageControl.currentPage;
    NSInteger offsetX = page * [UIScreen mainScreen].bounds.size.width;
    [_scrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
}

@end
