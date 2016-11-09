//
//  FMGameManager.h
//  findmine
//
//  Created by 凌空 on 2016/11/8.
//  Copyright © 2016年 amoyio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMButtonInfoDelegate.h"
@interface FMGameManager : NSObject
@property(nonatomic,copy)NSSet *mineSet;
@property(nonatomic,copy)NSMutableSet *guessSet;
@property(nonatomic,assign) NSInteger gameTime;
@property(nonatomic,copy) NSMutableArray *openedList;
@property(nonatomic,weak) id<FMButtonInfoDelegate> delegate;
+(instancetype)shareManager;
-(void)enterNextLevel;
-(NSInteger)decreaseTime;
-(void)resetGameTime;
- (void)randomize;
-(NSSet *)generateRandomListWithCount:(NSUInteger)count;
-(void)tapRow:(NSInteger)row andColumn:(NSInteger)column;

-(void)addGuess:(NSInteger)guessVal;
-(void)removeGuess:(NSInteger)guessVal;
@end
