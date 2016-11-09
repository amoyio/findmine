//
//  FMButton.h
//  findmine
//
//  Created by 凌空 on 2016/11/8.
//  Copyright © 2016年 amoyio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMConstant.h"



@interface FMButton : UIButton
@property(nonatomic,assign)CellState cellState;
@property(nonatomic,assign) BOOL isMine;
@property(nonatomic,assign) BOOL isHiden;
@property(nonatomic,assign) NSInteger indicateVal;
@property(nonatomic,assign) BOOL isFlag;
-(void)markAsMine;
-(void)showIndicate;
- (void)markAsReveal;
-(void)markAsExplosion;
-(void)markAsUnknown;
@end
