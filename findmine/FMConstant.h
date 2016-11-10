//
//  FMConstant.h
//  findmine
//
//  Created by 凌空 on 2016/11/8.
//  Copyright © 2016年 amoyio. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum : NSUInteger {
    CellStateUnopen,
    CellStateFlag,
    CellStateQuestion,
    CellStateReveal,
    CellStateMine,
    CellStateExplosion
} CellState;

#define boardWidthCount 8
#define boardHeightCount 12
#define pannelTopMargin 60
#define boardLeftMargin 4
#define boardSelfMargin 0

@interface FMConstant : NSObject

@end
