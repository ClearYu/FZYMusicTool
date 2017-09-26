//
//  FZYMusicExportManager.h
//  FZYMusicTools
//
//  Created by 冯振宇 on 2017/9/26.
//  Copyright © 2017年 Tool. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FZYMusicHeader.h"

typedef NS_OPTIONS(NSUInteger, FZYMusicType) {
    FZYMusicType_MP3 = 0,
    FZYMusicType_WAV = 1,
    FZYMusicType_MP4 = 2,
    FZYMusicType_CAF = 3,
    FZYMusicType_NULL = 4
};
@protocol FZYMusicExportManager <NSObject>

- (void)musicInDocumentPath:(NSString *)musicPath andIsSuccess:(BOOL)success;

@end

@interface FZYMusicExportManager : NSObject

SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(FZYMusicExportManager)

/**
 直接导出音乐,不设置音乐格式,音乐路径

 @param musicPath 在itunes里面的路径
 @return 1成功0失败
 */
- (BOOL)directlyExportMusicWithPath:(NSString *)musicPath;

/**
  导出音乐,音乐路径

 @param musicPath 在itunes里面的路径
 @param TargetPath 目标路径(注意路径尽量不要有中文,可能会造成崩溃)
 @return 1成功0失败
 */
- (BOOL)exportMusicWithPath:(NSString *)musicPath andTargetPath:(NSString *)TargetPath;

/**
 导出音乐,设置音乐格式

 @param musicType 音乐格式
 @return 1成功0失败
 */
- (BOOL)exportTheMusicAndConversionTheTargetType:(FZYMusicType)musicType;

/**
 导出音乐,设置音乐格式,设置音乐路径

 @param musicType 音乐格式
 @param TargetPath 目标路径(注意路径尽量不要有中文,可能会造成崩溃)
 @return 1成功0失败
 */
- (BOOL)exportTheMusicAndConversionTheTargetType:(FZYMusicType)musicType andTargetPath:(NSString *)TargetPath;

@property (nonatomic ,weak) id <FZYMusicExportManager> delegate;

@end
