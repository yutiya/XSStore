//
//  ViewController.m
//  GameBuyDev
//
//  Created by admin on 15/7/15.
//  Copyright (c) 2015年 Pandora. All rights reserved.
//

#import "ViewController.h"
#import "XSStore.h"
#import "XSTableViewCell.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate, XSTableViewCellDelegate>

@property (nonatomic, strong) NSArray *productArray;
@property (nonatomic, weak) UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //product array
    self.productArray = @[
                               @{
                                   @"product":@[
                                           @"com.xxx.xxx.jinbi1",
                                           @"com.xxx.xxx.jinbi2"
                                           ],
                                   @"header":@"conn - 消耗性购买"
                                 },
                               @{
                                   @"product":@[
                                           @"com.xxx.xxx.noncon1"
                                           ],
                                   @"header":@"noncon - 一次性购买"
                                   },
                               @{
                                   @"product":@[
                                           @"com.xxx.xxx.autorenew1"
                                           ],
                                   @"header":@"autorenew - 自动续订"
                                   },
                               @{
                                   @"product":@[
                                           @"com.xxx.xxx.freesub1"
                                           ],
                                   @"header":@"freesub - 免费订阅"
                                   },
                               @{
                                   @"product":@[
                                           @"com.xxx.xxx.nonrenew1"
                                           ],
                                   @"header":@"nonrenew - 非自动续订"
                                 }];
    self.title = @"应用内购买Demo";
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    tableView.dataSource = self;
    tableView.delegate = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
}
/**
 *  返回section的cell count
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.productArray[section][@"product"] count];
}
/**
 *  返回section count
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.productArray.count;
}
/**
 *  返回section的header
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.productArray[section] objectForKey:@"header"];
}
/**
 *  返回section的cell
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cell_ID = @"cellID";
    XSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_ID];
    if (!cell) {
        cell = [[XSTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_ID];
    }
    NSDictionary *dic =self.productArray[indexPath.section];
    NSArray *keyArr = dic.allKeys;
    NSArray *arr = [dic objectForKey:keyArr[0]];
    cell.productID = arr[indexPath.row];
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}

#pragma mark - XSTableViewCellDelegate
/**
 *  cell代理回调
 */
- (void)buyButtonTouchAction:(NSString *)productID
{
#warning 此处为调用检测接口和支付
    switch ([XSStore canPayProduct]) {
        case XSCanPayCodeYes:
        {
            [[XSStore shardXSStore] payProduct:[productID copy] withSuccess:^{
                NSLog(@"成功");
            } withFailed:^(XSPayState payState) {
                NSLog(@"失败,%d", payState);
            }];
        }
            break;
        case XSCanPayCodeNetWorkError:
        {
            XSLog(@"网络错误");
        }
            break;
        case XSCanPayCodePreUnSuccessError:
        {
            XSLog(@"设备不允许支付");
        }
            break;
        case XSCanPayCodePaymentQueueError:
        {
            XSLog(@"上一次的购买尚未完成，请等待");
        }
            break;
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
