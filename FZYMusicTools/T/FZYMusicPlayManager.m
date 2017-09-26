//
//  FZYMusicPlayManager.m
//  FZYMusicTools
//
//  Created by 冯振宇 on 2017/9/26.
//  Copyright © 2017年 Tool. All rights reserved.
//

#import "FZYMusicPlayManager.h"

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface FZYMusicPlayManager()

@property (nonatomic ,strong) AVAudioPlayer *musicPlayer;

@end

@implementation FZYMusicPlayManager

SYNTHESIZE_SINGLETON_FOR_CLASS(FZYMusicPlayManager)

- (BOOL)musicPlay{
    if ([_musicPlayer play]) {
        return 1;
    }else{
        return 0;
    }
    //或者使用_musicPlayer.play属性判断
}

- (void)musicStop{
    [_musicPlayer stop];
}

- (void)musicPause{
    [_musicPlayer pause];
}

- (void)loadMusicWithData:(NSData *)musicData{
    NSError *error = nil;
    _musicPlayer = [[AVAudioPlayer alloc]initWithData:musicData
                                                error:&error];
    [self musicPlay];
}

- (void)loadMusicWithPath:(NSString *)musicPath{
    NSError *error = nil;
    _musicPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL URLWithString:musicPath] error:&error];
    [self musicPlay];
}
- (void)playItunesMusicWithPath:(NSString *)musicPath{
    NSError *error = nil;
    _musicPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL URLWithString:musicPath] error:&error];
}

@end
