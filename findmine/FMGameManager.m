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


@property(nonatomic,assign) NSInteger remainMineValue;
@end


@implementation FMGameManager



+(instancetype)shareManager{
    static FMGameManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FMGameManager alloc]init];
        instance.difficultLevel = 1;
        instance.gameTime = BEGIN_TIME - 10 * instance.difficultLevel;
    });
    return instance;
}

-(BOOL)checkGameResult{
    return NO;
}





#pragma mark - convience method
-(void)addGuess:(NSInteger)guessVal{
    [self.guessSet addObject:@(guessVal)];
    [self.delegate setRemain:self.mineSet.count - self.guessSet.count];
    if ([self checkGameWin]) {
        [self gameWin];
    }
}

-(void)removeGuess:(NSInteger)guessVal{
    [self.delegate setRemain:self.mineSet.count - self.guessSet.count];
    if (self.guessSet.count == 0) {
        return;
    }
    [self.guessSet removeObject:@(guessVal)];
    if ([self checkGameWin]) {
        [self gameWin];
    }
}


-(NSInteger)decreaseTime{
    self.gameTime -= 1;
    if (self.gameTime < 0) {
        [self gameOver];
        return 0;
    }
    return self.gameTime;
}

#pragma mark - game logic

/**
 生成随机雷区列表

 @param count 生成数量
 @return 雷区集合
 */
-(NSSet *)generateRandomListWithCount:(NSUInteger)count{
    NSMutableSet *valueSet = [NSMutableSet set];
    do {
        NSNumber *randomIndex = @(arc4random() % (boardWidthCount * boardHeightCount) + 1);
        [valueSet addObject:randomIndex];
    } while (valueSet.count < count);
    return valueSet;
}


-(void)gameOver{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"FM_GAME_OVER" object:nil];
    
}

-(void)gameWin{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"FM_GAME_WIN" object:nil];
}



/**
 检测游戏成功

 @return 游戏成功为Yes
 */
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


/**
 进入下一个等级
 */
-(void)enterNextLevel{
    self.difficultLevel += 1;
}


/**
重置游戏时间
 */
-(void)resetGameTime{
    self.gameTime = BEGIN_TIME - 10 * self.difficultLevel;
}



/**
 随机化
 */
- (void)randomize{
    _mineSet = [self generateRandomListWithCount:MINE_COUNT];
}


/**
 重新载入游戏
 */
- (void)reloadGame{
    _guessSet = [NSMutableSet set];
    _openedList = [NSMutableArray arrayWithCapacity:boardHeightCount];
    for (NSInteger i = 0; i<boardHeightCount; i++) {
        [_openedList addObject:[NSMutableArray arrayWithCapacity:boardWidthCount]];
        for (NSInteger j = 0 ; j < boardWidthCount ; j++) {
            [_openedList[i] addObject:@(NO)];
        }
    }
    self.remainMineValue = MINE_COUNT;
}


/**
 玩家点击行为

 @param row 行号
 @param column 列号
 */
-(void)tapRow:(NSInteger)row andColumn:(NSInteger)column{

    // 检测雷区
    if ([[FMGameManager shareManager].mineSet containsObject:@(row * boardWidthCount + column + 1)]) {
        for(NSNumber *number in self.mineSet){
            
            FMButton *mineButton = [self.delegate buttonForIndex:([number integerValue] - 1)];
            [mineButton markAsMine];
        }
        FMButton *button = [self.delegate buttonForIndex:[self.delegate indexWithRow:row andColumn:column]];
        [button markAsFailFlag];
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
    if (arc4random() % 20 < 4) {
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
#pragma mark - lazy load
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

-(NSMutableSet *)guessSet{
    if (!_guessSet) {
        _guessSet = [NSMutableSet set];
    }
    return _guessSet;
}


-(NSSet *)mineSet{
    if (!_mineSet) {
        _mineSet = [self generateRandomListWithCount:MINE_COUNT];
    }
    return _mineSet;
}

@end
