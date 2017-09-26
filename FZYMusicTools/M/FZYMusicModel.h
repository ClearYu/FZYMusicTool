//
//  FZYMusicModel.h
//  FZYMusicTools
//
//  Created by 冯振宇 on 2017/9/26.
//  Copyright © 2017年 Tool. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FZYMusicModel : NSObject

/**
 音乐路径
 */
@property (nonatomic ,copy) NSString *musicPath;

/**
 音乐名字
 */
@property (nonatomic ,copy) NSString *musicName;

/**
 音乐作曲家
 */
@property (nonatomic ,copy) NSString *musicComposer;

/**
 音乐演唱者
 */
@property (nonatomic ,copy) NSString *musicSinger;

/**
 音乐数据
 */
@property (nonatomic ,strong) NSData * musicData;

@end
