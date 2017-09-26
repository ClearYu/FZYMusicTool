//
//  FZYMusicExportManager.m
//  FZYMusicTools
//
//  Created by 冯振宇 on 2017/9/26.
//  Copyright © 2017年 Tool. All rights reserved.
//

#import "FZYMusicExportManager.h"

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#import "lame.h"

@implementation FZYMusicExportManager

SYNTHESIZE_SINGLETON_FOR_CLASS(FZYMusicExportManager)

- (BOOL)directlyExportMusicWithPath:(NSString *)musicPath{
    if ([self writeFile:musicPath andSetMusicType:FZYMusicType_NULL]) {
        return 1;
    }else{
        return 0;
    }
}

- (BOOL)exportTheMusicAndConversionTheTargetType:(FZYMusicType)musicType{
    return 0;
}

- (BOOL)exportTheMusicAndConversionTheTargetType:(FZYMusicType)musicType andTargetPath:(NSString *)TargetPath{
    return 0;
}

- (BOOL)exportMusicWithPath:(NSString *)musicPath andTargetPath:(NSString *)TargetPath{
    return 0;
}

- (BOOL)writeFile:(NSString *)musicPath andSetMusicType:(FZYMusicType)musicType{
    //这个方法需要传入 MPMediaItem 获取本地URL
    //NSURL *assetURL = [mediaItem valueForProperty:MPMediaItemPropertyAssetURL];
    //缓存的本地路径
    NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectoryPath =  [dirs objectAtIndex:0];
    
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:musicPath] options:nil];
    
    NSError *assetError = nil;
    //使用AVAssetReader对象来获取 媒体数据
    AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:songAsset
                                                               error:&assetError];
    
    if (assetError) {
        NSLog (@"error: %@", assetError);
        return 0;
    }
    //用于从AVAssetReader对象读取一个公共媒体类型的单个样本集合
    AVAssetReaderOutput *assetReaderOutput = [AVAssetReaderAudioMixOutput
                                              assetReaderAudioMixOutputWithAudioTracks:songAsset.tracks
                                              audioSettings: nil];
    if (! [assetReader canAddOutput: assetReaderOutput]) {
        NSLog (@"can't add reader output... die!");
        return 0;
    }
    NSLog (@"assetReaderOutput.mediaType = %@", assetReaderOutput.mediaType);
    [assetReader addOutput: assetReaderOutput];
    
    
    NSString *exportPath = [documentsDirectoryPath stringByAppendingPathComponent:@"exported.caf"];
    //判断文件是不是存在
    if ([[NSFileManager defaultManager] fileExistsAtPath:exportPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:exportPath error:nil];
    }
    //通过url创建写的管理者
    NSURL *exportURL = [NSURL fileURLWithPath:exportPath];
    AVAssetWriter *assetWriter = [AVAssetWriter assetWriterWithURL:exportURL
                                                          fileType:AVFileTypeCoreAudioFormat
                                                             error:&assetError];//AVFileTypeMPEGLayer3
    if (assetError) {
        NSLog (@"error: %@", assetError);
        return 0;
    }
    AudioChannelLayout channelLayout;
    
    memset(&channelLayout, 0, sizeof(AudioChannelLayout));
    
    channelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
    
    NSDictionary *outputSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                                    [NSNumber numberWithFloat:44100.0], AVSampleRateKey,//采样率
                                    [NSNumber numberWithInt:2], AVNumberOfChannelsKey,//通道的数目
                                    [NSData dataWithBytes:&channelLayout length:sizeof(AudioChannelLayout)], AVChannelLayoutKey,
                                    [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,//采样位数
                                    [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
                                    [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,//采样信号是整数还是浮点数
                                    [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,//大端还是小端是(内存的组织方式从高位写还是从低位写)
                                    nil];
    AVAssetWriterInput *assetWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio
                                                                              outputSettings:outputSettings];
    if ([assetWriter canAddInput:assetWriterInput]) {
        [assetWriter addInput:assetWriterInput];
    } else {
        NSLog (@"can't add asset writer input... die!");
        return 0;
    }
    
    assetWriterInput.expectsMediaDataInRealTime = NO;
    //开始写,
    [assetWriter startWriting];
    [assetReader startReading];
    
    AVAssetTrack *soundTrack = [songAsset.tracks objectAtIndex:0];
    CMTime startTime = CMTimeMake (0, soundTrack.naturalTimeScale);
    [assetWriter startSessionAtSourceTime: startTime];
    
    __block UInt64 convertedByteCount = 0;
    
    dispatch_queue_t mediaInputQueue = dispatch_queue_create("mediaInputQueue", NULL);
    [assetWriterInput requestMediaDataWhenReadyOnQueue:mediaInputQueue
                                            usingBlock: ^
     {
         // NSLog (@"top of block");
         while (assetWriterInput.readyForMoreMediaData) {
             CMSampleBufferRef nextBuffer = [assetReaderOutput copyNextSampleBuffer];
             if (!nextBuffer) {
                 // done?
                 [assetWriterInput markAsFinished];
                 [assetWriter finishWritingWithCompletionHandler:^{
                     
                 }];
                 [assetReader cancelReading];
                 NSDictionary *outputFileAttributes = [[NSFileManager defaultManager]
                                                       attributesOfItemAtPath:exportPath
                                                       error:nil];
                 NSLog (@"done. file size is %llu",
                        [outputFileAttributes fileSize]);
                 // release a lot of stuff
                 //自己补充这里写后面的转换
//                 [self playAudioWithCafToMP3OfURL:musicPath andMusicType:0];//传出导出的音乐的.caf的
                 break;
             } else {
                 // append buffer
                 [assetWriterInput appendSampleBuffer: nextBuffer];
                 convertedByteCount += CMSampleBufferGetTotalSampleSize (nextBuffer);

             }
         }
     }];
    NSLog (@"bottom of convertTapped:");
    return 1;
}

-(void)playAudioWithCafToMP3OfURL:(NSString *)destPath andMusicType:(FZYMusicType)musicType{
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *suffix = nil;
    switch (musicType) {
        case 0:
            suffix = @"exported.mp3";
            break;
        case 1:
            suffix = @"exported.wav";
            break;
        case 2:
            suffix = @"exported.mp4";
            break;
        case 3:
            suffix = @"exported.caf";
            break;
        default:
            break;
    }
    NSString *musicExportPath = [docDir stringByAppendingPathComponent:suffix];
    
    //直接生成musicInCludName
    
//    NSString *musicInCludName = [NSString stringWithFormat:@"6-%@.mp3",[TYUUIDTools getUUID]];
    
//    NSString *mp3FilePath = [docDir stringByAppendingPathComponent:musicInCludName];
    
    NSString *playName = destPath;
    
    //删除转换好的.mp3文件
    if ([[NSFileManager defaultManager] fileExistsAtPath:musicExportPath]){
        [[NSFileManager defaultManager] removeItemAtPath:musicExportPath error:nil];
    }
    /**开始转换*/
    @try {
        int read, write;
        
        FILE *pcm = fopen ([playName cStringUsingEncoding : NSASCIIStringEncoding ], "rb" );  //source 被 转换的音频文件位置
        
        if (pcm == NULL )
            
        {
            NSLog ( @"file not found" );
        }
        
        else
            
        {
            //skip file header
            fseek (pcm, 4 * 1024 , SEEK_CUR );
            FILE *mp3 = fopen ([musicExportPath cStringUsingEncoding : NSASCIIStringEncoding ], "wb" );  //output 输出生成的 Mp3 文件位置
            const int PCM_SIZE = 8192 ;
            const int MP3_SIZE = 8192 ;
            short int pcm_buffer[PCM_SIZE * 2 ];
            unsigned char mp3_buffer[MP3_SIZE];
            lame_t lame = lame_init ();
            
            lame_set_num_channels (lame, 1 ); // 设置 1 为单通道，默认为 2 双通道
            
            lame_set_in_samplerate (lame, 44100.0 ); //11025.0
            //lame_set_VBR(lame, vbr_default);
            lame_set_brate (lame, 8 );
            lame_set_mode (lame, 3 );
            lame_set_quality (lame, 2 ); /* 2=high 5 = medium 7=low 音 质 */
            lame_init_params (lame);
            do {
                
                read = fread (pcm_buffer, 2 * sizeof ( short int ), PCM_SIZE, pcm);
                if (read == 0 )
                    write = lame_encode_flush (lame, mp3_buffer, MP3_SIZE);
                else
                    write = lame_encode_buffer_interleaved (lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
                fwrite (mp3_buffer, write, 1 , mp3);
            } while (read != 0 );
            lame_close (lame);
            fclose (mp3);
            fclose (pcm);
        }
    }
    
    @catch (NSException *exception) {
//        NSLog ( @"%@" ,[exception description ]);
//        if ([self.delegate respondsToSelector:@selector(musicInDocumentPath:andIsSuccess:)]) {
//            dispatch_sync(dispatch_get_main_queue(), ^(){
//                // 这里的代码会在主线程执行
////                [self.delegate musicInCludName:musicInCludName andMusicName:musicName isKo:NO];
//                [self.delegate musicInDocumentPath:musicExportPath andIsSuccess:NO];
//            });
//        }
//    }
    }
    @finally {
//        NSLog(@"-----转换MP3成功！！！");
//        //这里写回调
//        NSError *fileError = nil;
//        if () {
//            NSLog(@"------移动成功");
//            if ([self.delegate respondsToSelector:@selector(musicInDocumentPath:andIsSuccess:)]) {
//                dispatch_sync(dispatch_get_main_queue(), ^(){
//                    // 这里的代码会在主线程执行
//                    [self.delegate musicInDocumentPath:musicExportPath andIsSuccess:YES];
//                });
//            }
//        }else{
//            if ([self.delegate respondsToSelector:@selector(musicInDocumentPath:andIsSuccess:)]) {
//                dispatch_sync(dispatch_get_main_queue(), ^(){
//                    // 这里的代码会在主线程执行
//                    [self.delegate musicInDocumentPath:musicExportPath andIsSuccess:YES];
//                });
//            }
//        }
    }
}
@end
