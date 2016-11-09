//
//  FMGameManager.m
//  findmine
//
//  Created by 凌空 on 2016/11/8.
//  Copyright © 2016年 amoyio. All rights reserved.
//

#import "FMGameManager.h"
#import "FMConstant.h"
#import "ViewController.h"
#import "FMButton.h"
@interface FMGameManager()

@property(nonatomic,assign) NSUInteger difficultLevel;
@property(nonatomic,assign) NSInteger remainMineValue;
@end


@implementation FMGameManager

-(NSMutableSet *)guessSet{
    if (!_guessSet) {
        _guessSet = [NSMutableSet set];
    }
    return _guessSet;
}

-(NSInteger)decreaseTime{
    self.gameTime -= 1;
    if (self.gameTime < 0) {
        [self gameOver];
        return 0;
    }
    return self.gameTime;
}

-(void)gameOver{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"FM_GAME_OVER" object:nil];
    
}

-(void)gameWin{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"FM_GAME_WIN" object:nil];
}

-(void)addGuess:(NSInteger)guessVal{
    [self.guessSet addObject:@(guessVal)];
    if ([self checkGameWin]) {
        [self gameWin];
    }
}

-(void)removeGuess:(NSInteger)guessVal{
    if (self.guessSet.count == 0) {
        return;
    }
    [self.guessSet removeObject:@(guessVal)];
    if ([self checkGameWin]) {
        [self gameWin];
    }
}

-(BOOL)checkGameWin{
    if (self.guessSet.count < self.mineSet.count) {
        return NO;
    }
    
    if ([self.guessSet isEqual:self.mineSet]) {
        return YES;
    }else{
        return NO;
    }
}

-(void)enterNextLevel{
    self.difficultLevel += 1;
}

-(void)resetGameTime{
    self.gameTime = 20 - 10 * self.difficultLevel;
}

+(instancetype)shareManager{
    static FMGameManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FMGameManager alloc]init];
        instance.difficultLevel = 1;
        instance.gameTime = 20 - 10 * instance.difficultLevel;
    });
    return instance;
}

-(BOOL)checkGameResult{
    return NO;
}

-(NSSet *)generateRandomListWithCount:(NSUInteger)count{
        NSMutableSet *valueSet = [NSMutableSet set];
        do {
            NSNumber *randomIndex = @(arc4random() % (boardWidthCount * boardHeightCount) + 1);
            [valueSet addObject:randomIndex];
        } while (valueSet.count < count);
        return valueSet;
}

-(NSSet *)mineSet{
    if (!_mineSet) {
        _mineSet = [self generateRandomListWithCount:10];
    }
    return _mineSet;
}

- (void)randomize{
    _mineSet = [self generateRandomListWithCount:10];
}

-(NSMutableArray *)openedList{
    if (!_openedList) {
        _openedList = [NSMutableArray arrayWithCapacity:boardHeightCount];
        for (NSInteger i = 0; i<boardHeightCount; i++) {
            [_openedList addObject:[NSMutableArray arrayWithCapacity:boardWidthCount]];
            for (NSInteger j = 0 ; j < boardWidthCount ; j++) {
                [_openedList[i] addObject:@(NO)];
            }
        }
    }
    
    return _openedList;
}





-(void)tapRow:(NSInteger)row andColumn:(NSInteger)column{

    // 检测雷区
    if ([[FMGameManager shareManager].mineSet containsObject:@(row * boardWidthCount + column + 1)]) {
        [self gameOver];
        return;
    }
    
    // 呈现暗示值
    if ([self.delegate buttonHasIndicateValInRow:row AndColumn:column]) {
        FMButton *button = [self.delegate buttonForIndex:[self.delegate indexWithRow:row andColumn:column]];
        [button showIndicate];
        self.openedList[row][column] = @(YES);
        return;
    }
    
    FMButton *button = [self.delegate buttonForIndex:[self.delegate indexWithRow:row andColumn:column]];
    [button markAsReveal];
    self.openedList[row][column] = @(YES);
    //增加可玩性
    if (arc4random() % 20 < 2) {
        return;
    }
    if (row == 0 || column == 0|| row == boardHeightCount - 1 || column == boardWidthCount - 1) {
        if (row == 0 && column == 0) {
            if (![self.openedList[row + 1][column + 1] boolValue]) {
                [self tapRow:row + 1 andColumn:column + 1];
            }
            if (![self.openedList[row + 1][column] boolValue]) {
                [self tapRow:row + 1 andColumn:column];
            }
            if (![self.openedList[row][column + 1] boolValue]) {
                [self tapRow:row andColumn:column + 1];
            }
            return;
        }

        if (row == boardHeightCount - 1 && column == boardWidthCount - 1) {
            if (![self.openedList[row - 1][column] boolValue]) {
                [self tapRow:row - 1 andColumn:column];
            }
            if (![self.openedList[row - 1][column - 1] boolValue]) {
                [self tapRow:row - 1 andColumn:column - 1];
            }
            if (![self.openedList[row][column - 1] boolValue]) {
                [self tapRow:row andColumn:column - 1];
            }
            return;
        }
        if (row == 0 && column == boardWidthCount - 1) {
            if (![self.openedList[row + 1][column] boolValue]) {
                [self tapRow:row + 1 andColumn:column];
            }
            if (![self.openedList[row + 1][column - 1] boolValue]) {
                [self tapRow:row + 1 andColumn:column - 1];
            }
            if (![self.openedList[row][column - 1] boolValue]) {
                [self tapRow:row andColumn:column - 1];
            }
            return;
        }
        if (row == boardHeightCount - 1 && column == 0) {
            if (![self.openedList[row - 1][column] boolValue]) {
                [self tapRow:row - 1 andColumn:column];
            }
            if (![self.openedList[row - 1][column + 1] boolValue]) {
                [self tapRow:row - 1 andColumn:column + 1];
            }
            if (![self.openedList[row][column + 1] boolValue]) {
                [self tapRow:row andColumn:column + 1];
            }
            return;
        }

        if (row == 0) {
            if (![self.openedList[row + 1][column] boolValue]) {
                [self tapRow:row + 1 andColumn:column];
            }
            if (![self.openedList[row ][column - 1] boolValue]) {
                [self tapRow:row andColumn:column - 1];
            }
            if (![self.openedList[row + 1][column - 1] boolValue]) {
                [self tapRow:row + 1 andColumn:column - 1];
            }
            if (![self.openedList[row][column + 1] boolValue]) {
                [self tapRow:row andColumn:column + 1];
            }
            if (![self.openedList[row + 1][column + 1] boolValue]) {
                [self tapRow:row + 1 andColumn:column + 1];
            }
            return;
        }

        if (column == 0) {
            if (![self.openedList[row + 1][column] boolValue]) {
                [self tapRow:row + 1 andColumn:column];
            }
            if (![self.openedList[row ][column + 1] boolValue]) {
                [self tapRow:row andColumn:column + 1];
            }
            if (![self.openedList[row + 1][column + 1] boolValue]) {
                [self tapRow:row + 1 andColumn:column + 1];
            }
            if (![self.openedList[row - 1][column + 1] boolValue]) {
                [self tapRow:row - 1 andColumn:column + 1];
            }
            if (![self.openedList[row - 1][column ] boolValue]) {
                [self tapRow:row - 1 andColumn:column];
            }
            return;
        }

        if (row == boardHeightCount - 1) {
            if (![self.openedList[row - 1][column] boolValue]) {
                [self tapRow:row - 1 andColumn:column];
            }
            if (![self.openedList[row ][column - 1] boolValue]) {
                [self tapRow:row andColumn:column - 1];
            }
            if (![self.openedList[row - 1][column - 1] boolValue]) {
                [self tapRow:row - 1 andColumn:column - 1];
            }
            if (![self.openedList[row][column + 1] boolValue]) {
                [self tapRow:row andColumn:column + 1];
            }
            if (![self.openedList[row - 1][column + 1] boolValue]) {
                [self tapRow:row - 1 andColumn:column + 1];
            }
            return;
        }
        if (column == boardWidthCount - 1) {
            if (![self.openedList[row - 1][column] boolValue]) {
                [self tapRow:row - 1 andColumn:column];
            }
            if (![self.openedList[row ][column - 1] boolValue]) {
                [self tapRow:row andColumn:column - 1];
            }
            if (![self.openedList[row - 1][column - 1] boolValue]) {
                [self tapRow:row - 1 andColumn:column - 1];
            }
            if (![self.openedList[row + 1][column - 1] boolValue]) {
                [self tapRow:row + 1 andColumn:column - 1];
            }
            if (![self.openedList[row + 1][column] boolValue]) {
                [self tapRow:row + 1 andColumn:column];
            }
            return;
        }

    }

    if (![self.openedList[row + 1][column + 1] boolValue]) {
        [self tapRow:row + 1 andColumn:column + 1];
    }
    if (![self.openedList[row + 1][column] boolValue]) {
        [self tapRow:row + 1 andColumn:column];
    }
    if (![self.openedList[row + 1][column - 1] boolValue]) {
        [self tapRow:row + 1 andColumn:column - 1];
    }
    if (![self.openedList[row][column + 1] boolValue]) {
        [self tapRow:row andColumn:column + 1];
    }
    if (![self.openedList[row][column - 1] boolValue]) {
        [self tapRow:row andColumn:column - 1];
    }
    if (![self.openedList[row - 1][column + 1] boolValue]) {
        [self tapRow:row - 1 andColumn:column + 1];
    }
    if (![self.openedList[row - 1][column] boolValue]) {
        [self tapRow:row - 1 andColumn:column];
    }
    if (![self.openedList[row - 1][column - 1] boolValue]) {
        [self tapRow:row - 1 andColumn:column - 1];
    }

}

@end
