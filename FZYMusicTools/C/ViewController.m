//
//  ViewController.m
//  FZYMusicTools
//
//  Created by 冯振宇 on 2017/9/25.
//  Copyright © 2017年 Tool. All rights reserved.
//

#import "ViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#import "FZYMusicModel.h"
#import "FZYMusicPlayManager.h"
#import "FZYMusicExportManager.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic ,strong) UITableView *fzyTableView;

@property (nonatomic ,strong) NSMutableArray <FZYMusicModel *> *localDataArray;

@end

@implementation ViewController

-(UITableView *)FZYTableView{
    if (_fzyTableView == nil) {
        _fzyTableView = [[UITableView alloc]init];
        [_fzyTableView setFrame:CGRectMake( 0, 0, [UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height)];
        [self.view addSubview:_fzyTableView];
    }
    return _fzyTableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fzyTableView.dataSource = self;
    self.fzyTableView.delegate = self;
    [FZYMusicExportManager sharedFZYMusicExportManager].delegate = self;
    // Do any additional setup after loading the view, typically from a nib.
    
    _localDataArray = [[NSMutableArray<FZYMusicModel *> alloc]init];
    //初始化MPMediaQuery 两种获取本地musicLibrary的方式这是其中之一
    MPMediaQuery *mediaQuery = [[MPMediaQuery alloc] init];
    //初始化一个音乐的谓词 通过音乐谓词 筛选出需要的数据
    MPMediaPropertyPredicate *albumNamePredicate = [MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithInt:MPMediaTypeMusic] forProperty: MPMediaItemPropertyMediaType];
    [mediaQuery addFilterPredicate:albumNamePredicate];
    //转模型
    [self localMusicDataTransferNewModel:mediaQuery.items];
    //删除空数据
    [self removeLocalMusicDataIsZero:[NSArray arrayWithArray:_localDataArray]];
}
- (void)removeLocalMusicDataIsZero:(NSArray *)itunesMusic{
    for (FZYMusicModel *model in itunesMusic) {
        AVAudioPlayer *play = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL URLWithString:model.musicPath] error:nil];
        if (play == nil) {
            [_localDataArray removeObject:model];
        }
    }
}
- (void)localMusicDataTransferNewModel:(NSArray *)musics{
    for (MPMediaItem *music in musics) {
        FZYMusicModel *model = [[FZYMusicModel alloc]init];
        model.musicPath = [music.assetURL absoluteString];
        model.musicName = music.title;
        model.musicComposer = music.composer;
        model.musicSinger = music.artist;
        [_localDataArray addObject:model];
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"FZY";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.textLabel.text = _localDataArray[indexPath.row].musicName;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _localDataArray.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [[FZYMusicPlayManager sharedFZYMusicPlayManager] loadMusicWithPath:_localDataArray[indexPath.row].musicPath];
    [[FZYMusicExportManager sharedFZYMusicExportManager] directlyExportMusicWithPath:_localDataArray[indexPath.row].musicPath];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
