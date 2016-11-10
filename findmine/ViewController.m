//
//  ViewController.m
//  findmine
//
//  Created by 凌空 on 2016/11/8.
//  Copyright © 2016年 amoyio. All rights reserved.
//

#import "ViewController.h"
#import "FMGameManager.h"
#import "FMButtonInfoDelegate.h"
#import "FMButton.h"
@interface ViewController ()<FMButtonInfoDelegate>
@property (weak, nonatomic) IBOutlet UIView *pannelView;
@property (weak, nonatomic) IBOutlet UIImageView *firstvalueImgView;
@property (weak, nonatomic) IBOutlet UIImageView *secondvalueImgView;
@property (weak, nonatomic) IBOutlet UIButton *gameStatusBtn;
@property (weak, nonatomic) IBOutlet UILabel *remainCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalCountLabel;
@property(nonatomic,strong) NSTimer *gameTimer;

@end

@implementation ViewController

-(void)getRemainTime{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupGameLayout];
    [self setupIndicateValue];
    [self bingAction];
    [self setupBasicComponent];
    [FMGameManager shareManager].delegate = self;

}


-(void)setupBasicComponent{
    [self.gameStatusBtn setTitle:@"开始" forState:UIControlStateNormal];
    self.gameStatusBtn.layer.cornerRadius = (NSInteger)self.gameStatusBtn.frame.size.width * 0.5;
    [self.gameStatusBtn addTarget:self action:@selector(beginGame) forControlEvents:UIControlEventTouchUpInside];
    
    //NSNotification
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(gameOverReact) name:@"FM_GAME_OVER" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(gameWinReact) name:@"FM_GAME_WIN" object:nil];
    
}

-(void)beginGame{
    self.gameStatusBtn.hidden = YES;
    self.firstvalueImgView.hidden = NO;
    self.secondvalueImgView.hidden = NO;
    self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [self displayRemainTime:[FMGameManager shareManager].gameTime];
        [[FMGameManager shareManager] decreaseTime];
        
    }];
    self.totalCountLabel.hidden = NO;
    self.remainCountLabel.hidden = NO;
    self.totalCountLabel.text = [NSString stringWithFormat:@"Total: %ld",[FMGameManager shareManager].mineSet.count];
    self.remainCountLabel.text = [NSString stringWithFormat:@"Remain:  %ld",[FMGameManager shareManager].mineSet.count];
    [self addCurrentMapStatus];
}

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


-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self.gameTimer invalidate];
    self.gameTimer = nil;
}

-(void)gameOverReact{
    [self.gameTimer invalidate];
    self.gameTimer = nil;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"You Lose" message:@"You Lose\n Press Confirm Botton To Restart Game" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [[FMGameManager shareManager] resetGameTime];
        [self reloadGame];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:confirmAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)setRemain:(NSInteger)remainVal{
    self.remainCountLabel.text = [NSString stringWithFormat:@"Remain: %ld",(long)remainVal];
}

-(void)gameWinReact{
    [self.gameTimer invalidate];
    self.gameTimer = nil;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"You Win" message:@"You Win!!!\n Press Confirm Botton To Enter Next Level" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [[FMGameManager shareManager]resetGameTime];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [[FMGameManager shareManager] enterNextLevel];
        [[FMGameManager shareManager] resetGameTime];
        [self reloadGame];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:confirmAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)displayRemainTime:(NSInteger)time{
    self.firstvalueImgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"d%ld",time/10]];
    self.secondvalueImgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"d%ld",time%10]];
}

- (void)tapBlank:(FMButton *)btn{
    [[FMGameManager shareManager] tapRow:(btn.tag - 1) / boardWidthCount andColumn:(btn.tag - 1) % boardWidthCount];
}

-(void) longPress: (UILongPressGestureRecognizer *) gesture{
    if (gesture.state == UIGestureRecognizerStateEnded) {
        FMButton *button = (FMButton *)gesture.view;
        if (button.isHiden) {
            [button markAsUnknown];
        }
    }
}

- (void)bingAction{
    for(NSInteger i = 0; i < boardWidthCount * boardHeightCount ; i++){
        FMButton *button = [self buttonForIndex:i];
        [button addTarget:self action:@selector(tapBlank:) forControlEvents:UIControlEventTouchUpInside];
        UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
        [button addGestureRecognizer:longGesture];
    }
}

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
//            button.userInteractionEnabled = NO;
            [self.pannelView addSubview:button];
            if ([[FMGameManager shareManager].mineSet containsObject:@(i * boardWidthCount + j + 1)]) {
                button.isMine = YES;
                [button markAsMine];
            }
            
        }
    }
}

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


- (NSInteger)tagWithRow:(NSInteger)row andColumn:(NSInteger)column{
    return boardWidthCount * row + column + 1;
}

- (NSInteger)rowFromIndex:(NSInteger)index{
    if (index == 0) {
        return 0;
    }else{
        return (index - 1) / boardWidthCount ;
    }
    
}

- (NSInteger)columnFromIndex:(NSInteger)index{
    return (index - 1) % boardWidthCount;
}

- (void)addIndicateValToButtonInRow:(NSInteger)rowVal Column:(NSInteger)columnVal By:(NSInteger)val{
    FMButton *button = [self buttonForIndex:[self indexWithRow:rowVal andColumn:columnVal]];
    if (!button.isMine) {
        button.indicateVal += 1;
    }
}


- (void)reloadGame{
    [self.gameTimer invalidate];
    self.gameTimer = nil;
    [[FMGameManager shareManager] reloadGame];
    [[FMGameManager shareManager] randomize];
    [self setupGameLayout];
    [self setupIndicateValue];
    [self bingAction];
    self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [self displayRemainTime:[FMGameManager shareManager].gameTime];
        [[FMGameManager shareManager] decreaseTime];
    }];
    [self beginGame];
    [self addCurrentMapStatus];
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


@end
