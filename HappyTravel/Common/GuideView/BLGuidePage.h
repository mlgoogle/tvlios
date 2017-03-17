//
//  BLGuidePages.h
//
//  Created by 千山暮雪 on 16/3/7.
//  Copyright © 2016年 千山暮雪. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GuidePageDelegate <NSObject>
- (void)lastImageClicked ;
@end
@interface BLGuidePage : UIView

@property (nonatomic, assign) id<GuidePageDelegate> delegate ;
-(instancetype)initWithImageArray: (NSArray *) imageSource ;
@end
