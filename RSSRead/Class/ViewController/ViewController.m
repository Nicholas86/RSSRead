//
//  ViewController.m
//  RSSRead
//
//  Created by a on 2017/11/6.
//  Copyright © 2017年 Nicholas_锋. All rights reserved.
//

#import "ViewController.h"
#import "SMFeedModel.h"
#import "SMFeedViewModel.h"

static NSString *rootViewControllerIdentifier = @"SMRootViewControllerCell";

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>
/** 数据源 */
@property (nonatomic, strong) NSMutableArray <SMFeedModel*>*feeds;

/**表视图**/
@property (nonatomic, strong) UITableView *tableView;


//viewModel
@property (nonatomic, strong) SMFeedViewModel *viewModel;

@end

@implementation ViewController

- (NSMutableArray<SMFeedModel *> *)feeds
{
    if (!_feeds) {
        self.feeds = [[NSMutableArray  alloc]  init];
    }return _feeds;
}

- (UITableView *)tableView
{
    if (!_tableView) {
        self.tableView = [[UITableView  alloc]  initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.rowHeight = 80;
    }return _tableView;
}

- (SMFeedViewModel *)viewModel
{
    if (!_viewModel) {
        self.viewModel = [[SMFeedViewModel  alloc] init];
    }return _viewModel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSLog(@"首页标题");
    
    
    [self.view   addSubview:self.tableView];
    
    //成功回调
    [self.viewModel  setBlockWithSuccessBlock:^(int i) {
        
        NSLog(@"%d", i);
    } WithFailueBlock:^(NSError *error) {
        //失败回调
        NSLog(@"%@", error);
        
    }];
    
    [self   fetchAllFeeds];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark 抓取数据
- (void)fetchAllFeeds
{
    NSLog(@"抓取数据");
    
    [self.viewModel   fetchAllFeedWithModelArray:self.feeds];
}


#pragma mark table
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.feeds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:rootViewControllerIdentifier];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    return cell;
}

@end






