//
//  ViewController.m
//  findmine
//
//  Created by 凌空 on 2016/11/8.
//  Copyright © 2016年 amoyio. All rights reserved.
//
// Todo: 时间双倍计数


#import "ViewController.h"
#import "FMGameManager.h"
#import "FMButtonInfoDelegate.h"
#import "FMButton.h"
@interface ViewController ()<FMButtonInfoDelegate>

@property (weak, nonatomic) IBOutlet UIView *timePannel;
@property (weak, nonatomic) IBOutlet UILabel *levelLabel;

@property (weak, nonatomic) IBOutlet UIView *pannelView;
@property (weak, nonatomic) IBOutlet UIImageView *firstvalueImgView;
@property (weak, nonatomic) IBOutlet UIImageView *secondvalueImgView;
@property (weak, nonatomic) IBOutlet UIButton *gameStatusBtn;
@property (weak, nonatomic) IBOutlet UILabel *remainCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalCountLabel;
@property(nonatomic,strong) NSTimer *gameTimer;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupGameLayout];
    [self setupIndicateValue];
    [self bingAction];
    [self setupBasicComponent];
    [FMGameManager shareManager].delegate = self;

}


/**
 设置通知和基本样式
 */
-(void)setupBasicComponent{
    [self.gameStatusBtn setTitle:NSLocalizedString(@"Start", nil) forState:UIControlStateNormal];
    self.gameStatusBtn.layer.cornerRadius = (NSInteger)self.gameStatusBtn.frame.size.width * 0.5;
    self.timePannel.layer.cornerRadius = 4;
    self.timePannel.layer.masksToBounds = YES;
    [self.gameStatusBtn addTarget:self action:@selector(beginGame) forControlEvents:UIControlEventTouchUpInside];
    
    //NSNotification
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(gameOverReact) name:@"FM_GAME_OVER" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(gameWinReact) name:@"FM_GAME_WIN" object:nil];
}

#pragma mark - game logic
/**
 重新加载游戏
 */
- (void)reloadGame{
    [self.gameTimer invalidate];
    self.gameTimer = nil;
    [[FMGameManager shareManager] reloadGame];
    [[FMGameManager shareManager] randomize];
    [self setupGameLayout];
    [self setupIndicateValue];
    [self bingAction];
    [self beginGame];
    [self addCurrentMapStatus];
}

/**
 扫雷布局
 */
- (void)setupGameLayout{
    for (UIView *view in self.pannelView.subviews) {
        [view removeFromSuperview];
    }
    CGFloat cellSizeWidth = ([UIScreen mainScreen].bounds.size.width - 2 * boardLeftMargin - boardSelfMargin * (boardWidthCount - 1)) / boardWidthCount;
    for (int i = 0; i < boardHeightCount; i++) {
        for (int j = 0; j<boardWidthCount; j++) {
            FMButton *button = [[FMButton alloc]initWithFrame:CGRectMake(boardLeftMargin + j * cellSizeWidth + (j - 1) * boardSelfMargin, boardLeftMargin + i * (cellSizeWidth + boardSelfMargin), cellSizeWidth, cellSizeWidth)];
            //避免和没有设置tag的view重叠，所有的tag数加1
            button.backgroundColor = [UIColor cyanColor];
            button.tag = i * boardWidthCount + j + 1;
            button.userInteractionEnabled = NO;
            [self.pannelView addSubview:button];
            if ([[FMGameManager shareManager].mineSet containsObject:@(i * boardWidthCount + j + 1)]) {
                button.isMine = YES;
            }
            
        }
    }
}

/**
 开始游戏
 */
-(void)beginGame{
    self.levelLabel.hidden = NO;
    self.levelLabel.text = [NSString stringWithFormat:@"%@%d",NSLocalizedString(@"Lv.", nil),[FMGameManager shareManager].difficultLevel];
    self.gameStatusBtn.hidden = YES;
    self.firstvalueImgView.hidden = NO;
    self.secondvalueImgView.hidden = NO;
    self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [self displayRemainTime:[FMGameManager shareManager].gameTime];
        [[FMGameManager shareManager] decreaseTime];
        
    }];
    self.totalCountLabel.hidden = NO;
    self.remainCountLabel.hidden = NO;
    self.totalCountLabel.text = [NSString stringWithFormat:@"%@: %ld",NSLocalizedString(@"Total", nil),(unsigned long)[FMGameManager shareManager].mineSet.count];
    self.remainCountLabel.text = [NSString stringWithFormat:@"%@:  %ld",NSLocalizedString(@"Remain", nil),(unsigned long)[FMGameManager shareManager].mineSet.count];
    [self addCurrentMapStatus];
}


/**
 将当前状态写入游戏管理者类
 */
-(void)addCurrentMapStatus{
    NSArray *openList = [FMGameManager shareManager].openedList;
    for(NSInteger i = 0; i < boardWidthCount * boardHeightCount ; i++){
        FMButton *button = [self buttonForIndex:i];
        button.userInteractionEnabled = YES;
        button.isHiden = YES;
        if (button.isMine) {
            //crash protection
            if ([openList[0] count] == 0) {
                return;
            }
            openList[i/boardWidthCount][i%boardWidthCount] = @(YES);
        }
    }
}


/**
 移除通知和timer
 */
-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self.gameTimer invalidate];
    self.gameTimer = nil;
}


/**
 游戏失败的表现
 */
-(void)gameOverReact{
    [self.gameTimer invalidate];
    self.gameTimer = nil;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"You Lose", nil) message:NSLocalizedString(@"You Lose\n Press Confirm Botton To Restart Game", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Restart", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [[FMGameManager shareManager] resetGameTime];
        [self reloadGame];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:confirmAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}



/**
 游戏成功的表现
 */
-(void)gameWinReact{
    [self.gameTimer invalidate];
    self.gameTimer = nil;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"You Win", nil) message:NSLocalizedString(@"You Win!!!\n Press \"Go\" Botton To Enter Next Level", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [[FMGameManager shareManager]resetGameTime];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Go", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [[FMGameManager shareManager] enterNextLevel];
        [[FMGameManager shareManager] resetGameTime];
        [self reloadGame];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:confirmAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - convience method

/**
 表现剩余时间

 @param time 时间常数
 */
-(void)displayRemainTime:(NSInteger)time{
    self.firstvalueImgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"d%d",time/10]];
    self.secondvalueImgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"d%d",time%10]];
}


/**
 按钮点击事件

 @param btn 按钮
 */
- (void)tapBlank:(FMButton *)btn{
    [[FMGameManager shareManager] tapRow:(btn.tag - 1) / boardWidthCount andColumn:(btn.tag - 1) % boardWidthCount];
}


/**
 长按点击事件

 @param gesture 长按手势
 */
-(void) longPress: (UILongPressGestureRecognizer *) gesture{
    if (gesture.state == UIGestureRecognizerStateEnded) {
        FMButton *button = (FMButton *)gesture.view;
        if (button.isHiden) {
            [button markAsUnknown];
        }
    }
}


/**
 给每个按钮添加点击事件
 */
- (void)bingAction{
    for(NSInteger i = 0; i < boardWidthCount * boardHeightCount ; i++){
        FMButton *button = [self buttonForIndex:i];
        [button addTarget:self action:@selector(tapBlank:) forControlEvents:UIControlEventTouchUpInside];
        UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
        [button addGestureRecognizer:longGesture];
    }
}





/**
 设置雷区附近的暗示值
 */
- (void)setupIndicateValue{
    for (NSNumber *mineIndex in [FMGameManager shareManager].mineSet) {
        NSInteger rowVal = [self rowFromIndex:[mineIndex integerValue]];
        NSInteger columnVal = [self columnFromIndex:[mineIndex integerValue]];
        if (rowVal == 0 || columnVal == 0 || rowVal == boardHeightCount - 1 || columnVal == boardWidthCount - 1) {
            if (columnVal == 0 && rowVal == 0) {
                [self addIndicateValToButtonInRow:1 Column:1 By:1];
                [self addIndicateValToButtonInRow:0 Column:1 By:1];
                [self addIndicateValToButtonInRow:1 Column:0 By:1];
                continue;
            }
            if (columnVal == boardWidthCount - 1 && rowVal == 0) {
                [self addIndicateValToButtonInRow:1 Column:boardWidthCount - 2 By:1];
                [self addIndicateValToButtonInRow:0 Column:boardWidthCount - 2 By:1];
                [self addIndicateValToButtonInRow:1 Column:boardWidthCount - 1 By:1];
                continue;
            }
            if (columnVal == boardWidthCount - 1 && rowVal == boardHeightCount - 1) {
                [self addIndicateValToButtonInRow:boardHeightCount - 2 Column:boardWidthCount - 2 By:1];
                [self addIndicateValToButtonInRow:boardHeightCount - 1 Column:boardWidthCount - 2 By:1];
                [self addIndicateValToButtonInRow:boardHeightCount - 2 Column:boardWidthCount - 1 By:1];
                continue;
            }
            if (columnVal == 0 && rowVal == boardHeightCount - 1) {
                [self addIndicateValToButtonInRow:boardHeightCount - 2 Column:1 By:1];
                [self addIndicateValToButtonInRow:boardHeightCount - 2 Column:0 By:1];
                [self addIndicateValToButtonInRow:boardHeightCount - 1 Column:1 By:1];
                continue;
            }
            if (rowVal == 0) {
                [self addIndicateValToButtonInRow:0 Column:columnVal + 1 By:1];
                [self addIndicateValToButtonInRow:0 Column:columnVal - 1 By:1];
                [self addIndicateValToButtonInRow:rowVal + 1 Column:columnVal + 1 By:1];
                [self addIndicateValToButtonInRow:rowVal + 1 Column:columnVal - 1 By:1];
                [self addIndicateValToButtonInRow:rowVal + 1 Column:columnVal By:1];
            }
            if (columnVal == 0) {
                [self addIndicateValToButtonInRow:rowVal + 1 Column:0 By:1];
                [self addIndicateValToButtonInRow:rowVal - 1 Column:0 By:1];
                [self addIndicateValToButtonInRow:rowVal - 1 Column:columnVal + 1 By:1];
                [self addIndicateValToButtonInRow:rowVal Column:columnVal + 1 By:1];
                [self addIndicateValToButtonInRow:rowVal + 1 Column:columnVal + 1 By:1];
            }
            if (rowVal == boardHeightCount - 1) {
                [self addIndicateValToButtonInRow:boardHeightCount - 1 Column:columnVal + 1 By:1];
                [self addIndicateValToButtonInRow:boardHeightCount - 1 Column:columnVal - 1 By:1];
                [self addIndicateValToButtonInRow:rowVal - 1 Column:columnVal - 1 By:1];
                [self addIndicateValToButtonInRow:rowVal - 1 Column:columnVal By:1];
                [self addIndicateValToButtonInRow:rowVal - 1 Column:columnVal + 1 By:1];
            }
            if (columnVal == boardWidthCount - 1) {
                [self addIndicateValToButtonInRow:rowVal + 1 Column:boardWidthCount - 1 By:1];
                [self addIndicateValToButtonInRow:rowVal - 1 Column:boardWidthCount - 1 By:1];
                [self addIndicateValToButtonInRow:rowVal - 1 Column:columnVal - 1 By:1];
                [self addIndicateValToButtonInRow:rowVal Column:columnVal - 1 By:1];
                [self addIndicateValToButtonInRow:rowVal + 1 Column:columnVal - 1 By:1];
            }
            

            
        }else{
            [self addIndicateValToButtonInRow:rowVal - 1 Column:columnVal - 1 By:1];
            [self addIndicateValToButtonInRow:rowVal Column:columnVal - 1 By:1];
            [self addIndicateValToButtonInRow:rowVal + 1 Column:columnVal - 1 By:1];
            [self addIndicateValToButtonInRow:rowVal - 1 Column:columnVal By:1];
            [self addIndicateValToButtonInRow:rowVal + 1 Column:columnVal By:1];
            [self addIndicateValToButtonInRow:rowVal - 1 Column:columnVal + 1 By:1];
            [self addIndicateValToButtonInRow:rowVal Column:columnVal + 1 By:1];
            [self addIndicateValToButtonInRow:rowVal + 1 Column:columnVal + 1 By:1];
        }
        
    }
    
}


/**
 通过行列定位按钮标签

 @param row 行号
 @param column 列号
 @return 按钮标签值
 */
- (NSInteger)tagWithRow:(NSInteger)row andColumn:(NSInteger)column{
    return boardWidthCount * row + column + 1;
}


/**
 通过index定位行号
 @return 行号
 */
- (NSInteger)rowFromIndex:(NSInteger)index{
    if (index == 0) {
        return 0;
    }else{
        return (index - 1) / boardWidthCount ;
    }
}

/**
 通过index定位列号

 @param index index
 @return 列号
 */
- (NSInteger)columnFromIndex:(NSInteger)index{
    return (index - 1) % boardWidthCount;
}

/**
 添加暗示值方法

 @param rowVal 行
 @param columnVal 列
 @param val 数值
 */
- (void)addIndicateValToButtonInRow:(NSInteger)rowVal Column:(NSInteger)columnVal By:(NSInteger)val{
    FMButton *button = [self buttonForIndex:[self indexWithRow:rowVal andColumn:columnVal]];
    if (!button.isMine) {
        button.indicateVal += 1;
    }
}






#pragma mark - FMButtonInfoDelegate

- (FMButton *)buttonForIndex:(NSInteger)index{
    return (FMButton *)[self.pannelView viewWithTag:index + 1];
}

- (NSInteger)indexWithRow:(NSInteger)row andColumn:(NSInteger)column{
    return boardWidthCount * row + column;
}

-(BOOL)buttonHasIndicateValInRow:(NSInteger)row AndColumn:(NSInteger)column{
    FMButton *button = [self buttonForIndex:[self indexWithRow:row andColumn:column]];
    if (button.indicateVal > 0) {
        return YES;
    }else{
        return NO;
    }
}

- (void)setRemain:(NSInteger)remainVal{
    self.remainCountLabel.text = [NSString stringWithFormat:@"Remain: %ld",(long)remainVal];
}

@end
