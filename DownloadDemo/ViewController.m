//
//  ViewController.m
//  DownloadDemo
//
//  Created by Carmine on 2018/7/9.
//  Copyright © 2018年 Carmine. All rights reserved.
//

#import "ViewController.h"
#import "DownloadTaskManager.h"
#import "DLModel.h"
#import "DLCell.h"

static NSString * idf = @"download_cell";

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray * models;

@end

@implementation ViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.models = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.tableView registerNib:[UINib nibWithNibName:@"DLCell" bundle:nil] forCellReuseIdentifier:idf];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSDictionary * downloadURLs = @{
                                    @"0" : @"http://devstreaming.apple.com/videos/wwdc/2014/402xxgg8o88ulsr/402/402_hd_introduction_to_swift.mov",
                                    @"1" : @"http://devstreaming.apple.com/videos/wwdc/2014/707xx1o5tdjnvg9/707/707_hd_whats_new_in_foundation_networking.mov",
                                    @"2" : @"http://devstreaming.apple.com/videos/wwdc/2014/402xxgg8o88ulsr/402/402_sd_introduction_to_swift.mov",
                                    @"3" : @"https://ar-scene-source.nosdn.127.net/b1463df0-d715-479f-9250-43edeabc1b31.zip?x=y",
                                    @"4" : @"https://ar-scene-source.nosdn.127.net/ed46f269-94e9-42ed-9b6e-e567cc27736e.zip?x=y",
                                    @"5" : @"https://ar-scene-source.nosdn.127.net/6a6506a7-5e4c-4367-af67-f4753722eefb.zip?x=y",
                                    @"6" : @"https://ar-scene-source.nosdn.127.net/384bb7f5-4f00-4210-ba2a-75cea6858331.zip?x=y",
                                    @"7" : @"https://ar-scene-source.nosdn.127.net/58b1f2be-c8ea-4d7d-b794-3672517d60a5.zip?x=y",
                                    };
    __weak typeof(self) ws = self;
    [downloadURLs enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        DLModel * model = [[DLModel alloc]init];
        model._id = key;
        model.url = obj;
        [ws.models addObject:model];
        [[DownloadTaskManager sharedManager] download:model progress:^(float progress) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSInteger pos = [ws.models indexOfObject:model];
                DLCell * cell = [ws.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:pos inSection:0]];
                if (cell) {
                    cell.progressView.progress = progress;
                    cell.progressLabel.text = [NSString stringWithFormat:@"%ld%%", [NSNumber numberWithFloat:progress * 100].integerValue];
                    cell.nameLabel.text = model._id;
                }
            });
        } complete:^(NSString *taskId) {
//            NSLog(@"-----下载完成，刷新界面-----");
        }];
    }];
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.models.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DLModel * model = self.models[indexPath.row];
    DLCell * cell = [tableView dequeueReusableCellWithIdentifier:idf forIndexPath:indexPath];
    cell.nameLabel.text = model._id;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DLModel * model = self.models[indexPath.row];
    [[DownloadTaskManager sharedManager] topTaskWithId:model._id];
}

@end
