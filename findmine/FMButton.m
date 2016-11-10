//
//  FMButton.m
//  findmine
//
//  Created by 凌空 on 2016/11/8.
//  Copyright © 2016年 amoyio. All rights reserved.
//

#import "FMButton.h"
#import "FMGameManager.h"
@implementation FMButton

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.cellState = CellStateUnopen;
        [self setImage:[UIImage imageNamed:@"unopen"] forState:UIControlStateNormal];
        self.indicateVal = 0;

    }
    return self;
}

-(void)showIndicate{
    [self setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%ld",self.indicateVal]] forState:UIControlStateNormal];
    self.isHiden = NO;
}

-(void)markAsFailFlag{
    [self setImage:[UIImage imageNamed:@"failed_flag"] forState:UIControlStateNormal];
}


-(void)markAsMine{
    [self setImage:[UIImage imageNamed:@"mine"] forState:UIControlStateNormal];
}

- (void)markAsReveal{
    [self setImage:[UIImage imageNamed:@"opened"] forState:UIControlStateNormal];
    self.isHiden = NO;
}

-(void)markAsExplosion{
    [self setImage:[UIImage imageNamed:@"explode"] forState:UIControlStateNormal];
}

-(void)markAsUnknown{
    if (self.cellState == CellStateUnopen) {
        [[FMGameManager shareManager]addGuess:self.tag];
        self.cellState = CellStateFlag;
    }else if(self.cellState == CellStateFlag){
        [[FMGameManager shareManager]removeGuess:self.tag];
        self.cellState = CellStateQuestion;
    }else if(self.cellState == CellStateQuestion){
        [[FMGameManager shareManager]removeGuess:self.tag];
        self.cellState = CellStateUnopen;
    }else{
        self.cellState = CellStateUnopen;
    }
    
    switch (self.cellState) {
        case CellStateUnopen:
            [self setImage:[UIImage imageNamed:@"unopen"] forState:UIControlStateNormal];
            
            break;
        case CellStateFlag:
            [self setImage:[UIImage imageNamed:@"flag"] forState:UIControlStateNormal];
            
            break;
        case CellStateQuestion:
            [self setImage:[UIImage imageNamed:@"question"] forState:UIControlStateNormal];
            break;
        default:
            [self setImage:[UIImage imageNamed:@"unopen"] forState:UIControlStateNormal];
            break;
    }
    
}

@end
