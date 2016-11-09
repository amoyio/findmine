//
//  FMButtonInfoDelegate.h
//  findmine
//
//  Created by 凌空 on 2016/11/9.
//  Copyright © 2016年 amoyio. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FMButton;
@protocol FMButtonInfoDelegate <NSObject>
-(BOOL)buttonHasIndicateValInRow:(NSInteger)row AndColumn:(NSInteger)column;
- (FMButton *)buttonForIndex:(NSInteger)index;
- (NSInteger)indexWithRow:(NSInteger)row andColumn:(NSInteger)column;
@end
