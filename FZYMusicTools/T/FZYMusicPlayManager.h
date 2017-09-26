//
//  FZYMusicPlayManager.h
//  FZYMusicTools
//
//  Created by 冯振宇 on 2017/9/26.
//  Copyright © 2017年 Tool. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FZYMusicHeader.h"

@interface FZYMusicPlayManager : NSObject

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(FZYMusicPlayManager)


/**
 音乐播放

 @return 1成功0失败
 */
- (BOOL)musicPlay;

/**
 音乐停止
 */
- (void)musicStop;

/**
 音乐暂停
 */
- (void)musicPause;

/**
 
 @param path musicPath
 */
- (void)playItunesMusicWithPath:(NSString *)path;
/**
 通过流加载音乐

 @param musicData 音乐流
 */
- (void)loadMusicWithData:(NSData *)musicData;

/**
 通过路径加载音乐

 @param musicPath 路径
 */
- (void)loadMusicWithPath:(NSString *)musicPath;

@end
