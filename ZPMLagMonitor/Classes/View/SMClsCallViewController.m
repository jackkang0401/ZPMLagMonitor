//
//  SMClsCallViewController.m
//  DecoupleDemo
//
//  Created by DaiMing on 2017/8/10.
//  Copyright © 2017年 Starming. All rights reserved.
//

#import "SMClsCallViewController.h"
#import "MJRefresh.h"
#import "SMClsCallCell.h"
#import "Masonry.h"
#import "SMLagDB.h"
#import "SMCallTraceTimeCostModel.h"
#import "SMLagButton.h"

static NSString *smClsCallCellIdentifier = @"smClsCallCell";

@interface SMClsCallViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *listData;
@property (nonatomic, strong) UITableView *tbView;
@property (nonatomic) NSUInteger page;
@property (nonatomic, strong) SMLagButton *closeView;
@property (nonatomic, strong) SMLagButton *clearAndCloseView;

@end

@implementation SMClsCallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.page = 0;
    [self selectItems];
    [self.tbView registerClass:[UITableViewCell class] forCellReuseIdentifier:smClsCallCellIdentifier];
    [self.view addSubview:self.tbView];
    [self.tbView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self.view);
        make.top.equalTo(self.view).offset(20);
    }];
    [self.view addSubview:self.closeView];
    [self.closeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-10);
        make.top.equalTo(self.view).offset(20);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    [self.view addSubview:self.clearAndCloseView];
    [self.clearAndCloseView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.closeView.mas_left).offset(-10);
        make.top.equalTo(self.closeView);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)selectItems {
    __weak typeof(self) weakSelf = self;
    [[SMLagDB shareInstance] selectClsCallWithPage:self.page completion:^(NSArray *array) {
        __strong typeof(weakSelf) strongSelf = weakSelf; if(!strongSelf) return;
        strongSelf.tbView.mj_footer.hidden = array.count < 50; // 每页50条，如果小于50说明没有更多数据了
        if (array.count > 0) {
            if (strongSelf.listData.count > 0) {
                //加载更多
                [strongSelf.listData addObjectsFromArray:array];
            } else {
                //进入时加载
                strongSelf.listData = [array mutableCopy];
            }
            [strongSelf.tbView reloadData];
            strongSelf.page += 1;
        }
        [strongSelf.tbView.mj_footer endRefreshingWithNoMoreData];
        [strongSelf.tbView.mj_footer endRefreshing];
    }];
}

#pragma mark - UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listData.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    SMCallTraceTimeCostModel *model = self.listData[indexPath.row];
    CGRect frame = [model.path boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width - 20*2, 999) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:nil];
    return 80 + frame.size.height;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:smClsCallCellIdentifier];
    cell.backgroundColor = [UIColor clearColor];
    cell.selected = UITableViewCellSelectionStyleNone;
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    SMClsCallCell *v = (SMClsCallCell *)[cell viewWithTag:123422];
    if (!v) {
        v = [[SMClsCallCell alloc] init];
        v.tag = 123422;
        if (cell) {
            [cell.contentView addSubview:v];
            [v mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.left.top.bottom.equalTo(cell.contentView);
            }];
        }
    }
    
    SMCallTraceTimeCostModel *model = self.listData[indexPath.row];
    [v updateWithModel:model];
    
    return cell;
}
- (void)close {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Getter
- (NSMutableArray *)listData {
    if (!_listData) {
        _listData = [NSMutableArray array];
    }
    return _listData;
}
- (UITableView *)tbView {
    if (!_tbView) {
        _tbView = [[UITableView alloc] initWithFrame:CGRectZero];
        _tbView.dataSource = self;
        _tbView.delegate = self;
        _tbView.backgroundColor = [UIColor clearColor];
        _tbView.separatorStyle = UITableViewCellSeparatorStyleNone;
        //mj
        _tbView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(selectItems)];
        MJRefreshAutoNormalFooter *footer = (MJRefreshAutoNormalFooter *)_tbView.mj_footer;
        footer.stateLabel.font = [UIFont systemFontOfSize:12];
        footer.stateLabel.textColor = [UIColor lightGrayColor];
        [footer setTitle:@"上拉读取更多" forState:MJRefreshStateIdle];
        [footer setTitle:@"正在读取..." forState:MJRefreshStateRefreshing];
        [footer setTitle:@"已读取完毕" forState:MJRefreshStateNoMoreData];
        
    }
    return _tbView;
}
- (SMLagButton *)closeView {
    if (!_closeView) {
        _closeView = [[SMLagButton alloc] initWithStr:@"退出" size:16 backgroundColor:[UIColor blackColor]];
        __weak typeof(self) weakSelf = self;
        _closeView.clickBlock = ^{
            __strong typeof(weakSelf) strongSelf = weakSelf; if(!strongSelf) return;
            [strongSelf close];
        };
    }
    return _closeView;
}
- (SMLagButton *)clearAndCloseView {
    if (!_clearAndCloseView) {
        _clearAndCloseView = [[SMLagButton alloc] initWithStr:@"清理" size:16 backgroundColor:[UIColor redColor]];
        __weak typeof(self) weakSelf = self;
        _clearAndCloseView.clickBlock = ^{
            __strong typeof(weakSelf) strongSelf = weakSelf; if(!strongSelf) return;
            [[SMLagDB shareInstance] clearClsCallData];
            [strongSelf close];
            
        };
    }
    return _clearAndCloseView;
}

@end
