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
#import "SMSubContentLabel.h"
#import "SMDB.h"
#import "SMFeedStore.h"
#import <MJRefresh/MJRefresh.h>

static NSString *rootViewControllerIdentifier = @"SMRootViewControllerCell";

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>
/** 数据源 */
@property (nonatomic, strong) NSMutableArray <SMFeedModel*>*feeds;

/**表视图**/
@property (nonatomic, strong) UITableView *tableView;

/**header**/
@property (nonatomic, strong) UIView     *tbHeaderView;
//添加到header
@property (nonatomic, strong) SMSubContentLabel *tbHeaderLabel;

//viewModel
@property (nonatomic, strong) SMFeedViewModel *viewModel;

//记录抓取个数
@property (nonatomic) NSUInteger fetchingCount;

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
        UIView *tbFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 50)];
        _tableView.tableFooterView = tbFooterView;
        
        //下拉刷新
        __block typeof(self) weakSelf = self;
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [weakSelf  fetchAllFeeds];
        }];
        MJRefreshNormalHeader *header = (MJRefreshNormalHeader *)_tableView.mj_header;
        header.lastUpdatedTimeLabel.hidden = YES;
        [header.arrowView setImage:[UIImage imageNamed:@""]];
        header.stateLabel.font = [SMStyle fontSmall];
        header.stateLabel.textColor = [SMStyle colorPaperGray];
        [header setTitle:@"下拉更新数据" forState:MJRefreshStateIdle];
        [header setTitle:@"松开立刻更新" forState:MJRefreshStatePulling];
        [header setTitle:@"更新数据..." forState:MJRefreshStateRefreshing];
        
    }return _tableView;
}

//headerView
- (UIView *)tbHeaderView
{
    if (!_tbHeaderView) {
        self.tbHeaderView = [[UIView  alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 30)];
    }return _tbHeaderView;
}

- (SMSubContentLabel *)tbHeaderLabel
{
    if (!_tbHeaderLabel) {
        self.tbHeaderLabel = [[SMSubContentLabel  alloc] init];
        _tbHeaderLabel.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, CGRectGetHeight(self.tbHeaderView.frame));
    }return _tbHeaderLabel;
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
    
    //添加到根视图上
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:rootViewControllerIdentifier];
    [self.view   addSubview:self.tableView];
    
    //headerLabel添加到headerView上
    [self.tbHeaderView  addSubview:self.tbHeaderLabel];
    
    //1.加载本地数据
    NSMutableArray *smdbMutableArray = [[SMDB   shareInstance]  selectAllFeeds];
    NSLog(@"smdb数组个数:%lu", (unsigned long)smdbMutableArray.count);

    if (smdbMutableArray.count == 0) {
        //本地fmdb数据,就加载json文件数据
        //json数据源,model都没有fid
        self.feeds = [SMFeedStore  defaultFeeds];
    }else{
        //本地fmdb有数据,就用本地fmdb的数据
        //本地fmdb数据源,model都有fid
        self.feeds = smdbMutableArray;
    }
    
    NSLog(@"本地json数组个数:%lu", (unsigned long)self.feeds.count);

    //2.获取网络数据
       //2.1---回调
    [self   configureViewModel];
       //2.2---开始获取
    [self   fetchAllFeeds];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//回调
- (void)configureViewModel
{
    __block typeof(self) weakSelf = self;
    
    self.fetchingCount = 0;
    
    [self.viewModel  setBlockWithSuccessBlock:^(int i, SMFeedModel *model) {
        //抓完一个
        //接收的model,某些字段已处理
        dispatch_async(dispatch_get_main_queue(), ^{
            //添加tableHeaderView
            weakSelf.tableView.tableHeaderView = weakSelf.tbHeaderView;
            //显示抓取状态
            weakSelf.fetchingCount += 1;
            weakSelf.tbHeaderLabel.text = [NSString  stringWithFormat:@"正在获取%@...%ld/%ld",model.title, weakSelf.fetchingCount, weakSelf.feeds.count];
            model.isSync = YES;
            
            //将外面的 self.feeds数组中的数据,根据指定下标替换
            weakSelf.feeds[i] = model;
            NSLog(@"成功回调:%d", i);
            [weakSelf.tableView reloadData];
        });
        
    } failueBlock:^(NSError *error) {
        NSLog(@"失败:%@", error);
        
    } finishBlock:^(BOOL isFinish) {
        NSLog(@"全部完成:%d", isFinish);
        
        //全部抓取完成
        
        //关闭网络指示器
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        //主线程刷新
        dispatch_async(dispatch_get_main_queue(), ^{
            //设置默认状态
            weakSelf.tbHeaderLabel.text = @"";
            weakSelf.tableView.tableHeaderView = [[UIView  alloc] init];
            weakSelf.fetchingCount = 0;
            
            //下拉刷新关闭
            [weakSelf.tableView.mj_header  endRefreshing];
            
            [weakSelf.tableView reloadData];
        });
        
    }];
}

#pragma mark 抓取数据
- (void)fetchAllFeeds
{
    NSLog(@"抓取数据");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
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
    
    if (self.feeds.count == 0) {
        return cell;
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    SMFeedModel *model = self.feeds[indexPath.row];
    cell.textLabel.text = model.title;
    
    return cell;
}

@end






