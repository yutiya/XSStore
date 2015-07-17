//
//  XSStore.m
//  GameBuyDev
//
//  Created by admin on 15/7/16.
//  Copyright (c) 2015年 Pandora. All rights reserved.
//

#import "XSStore.h"
#import "CoreStatus.h"


@interface XSStore ()<NSCopying, SKPaymentTransactionObserver, SKProductsRequestDelegate>
{
    SuccessBlock _successBlock;
    FailedBolck _failedBlock;
}
/**
 *  防止用户重复点击，需要等待上一次购买完成后才能进行下一次购买
 */
@property (nonatomic, assign) BOOL isPaying;

@end

static XSStore *_instance;

@implementation XSStore
//单例，保证实例化一次
+ (id)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}
//单例，保证实例化一次
+ (XSStore *)shardXSStore
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[XSStore alloc] init];
        //设置监听
        [[SKPaymentQueue defaultQueue] addTransactionObserver:_instance];
    });
    return _instance;
}

#pragma mark - NSCopying协议
//保证使用copy时返回单例对象
- (id)copyWithZone:(NSZone *)zone {
    return _instance;
}

#pragma mark - XSStore检测是否可以购买
+ (XSCanPayCode)canPayProduct
{
    if([CoreStatus isNetworkEnable]){
        if(!_instance.isPaying) {
            if ([SKPaymentQueue canMakePayments]) {
                return XSCanPayCodeYes;
            } else {
                return XSCanPayCodePaymentQueueError;
            }
        } else {
            return XSCanPayCodePreUnSuccessError;
        }
    } else {
        return XSCanPayCodeNetWorkError;
    }
}

- (void)payProduct:(NSString *)productId withSuccess:(SuccessBlock)successBlock withFailed:(FailedBolck)failedBlock
{
    if (!_isPaying) {
        //可以进行购买
        if (productId != nil && ![@"" isEqualToString:productId]) {
            _isPaying = YES;//防止多次触碰进行购买
            _successBlock = successBlock;
            _failedBlock = failedBlock;
            XSLog(@"----请求产品信息----");
            NSSet *set = [NSSet setWithObjects:productId, nil];
            SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
            request.delegate = self;
            [request start];
        } else {
            //产品ID错误
            if (failedBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    failedBlock(XSPayStateProductIDError);
                });
            }
            _isPaying = NO;
        }
    } else {
        //上一次购买还未完成
        if (failedBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                failedBlock(XSPayStateWaitPre);
            });
        }
        _isPaying = NO;
    }
}
#pragma mark - SKProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    XSLog(@"----收到产品信息----");
    NSArray *product = response.products;
    if ([product count] == 0) {
        XSLog(@"----没有找到商品----");
        if (_failedBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _failedBlock(XSPayStateProductNotFound);
            });
        }
        _isPaying = NO;
        return;
    }
    XSLog(@"产品付费数量:%lu", (unsigned long)[product count]);
    SKProduct *p = product[0];
    
    SKPayment *payment = [SKPayment paymentWithProduct:p];
    XSLog(@"发送购买请求");
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}
//请求失败
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    XSLog(@"----请求失败:%@", error.description);
    if (_failedBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _failedBlock(XSPayStateProductNotFound);
        });
    }
    _isPaying = NO;
}
#pragma mark - SKPaymentTransactionObserver
//监听购买结果
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *tran in transactions) {
        switch (tran.transactionState) {
            case SKPaymentTransactionStatePurchased:
                XSLog(@"交易完成");
                //完成事务
                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
                if (_successBlock) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        _successBlock();
                    });
                }
                _isPaying = NO;
                break;
            case SKPaymentTransactionStatePurchasing:
                XSLog(@"商品添加进列表");
                break;
            case SKPaymentTransactionStateRestored:
                XSLog(@"已经购买过商品");
                break;
            case SKPaymentTransactionStateFailed:
                NSLog(@"%@", tran);
                XSLog(@"交易失败");
                XSPayState tempXSIAP = XSPayStateFailed;
                switch (tran.error.code) {
                    case SKErrorPaymentCancelled:
                        tempXSIAP = XSPayStatePaymentCancelled;
                        break;
                    case SKErrorPaymentNotAllowed:
                        tempXSIAP = XSPayStatePaymentNotAllowed;
                    default:
                        break;
                }
                //即使支付失败，也需要完成这次事务
                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
                if (_failedBlock) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        _failedBlock(tempXSIAP);
                    });
                }
                _isPaying = NO;
                break;
            default:
                break;
        }
    }
}

#ifdef XSDEBUG

#pragma mark - SKPaymentTransactionObserver
// Sent when transactions are removed from the queue (via finishTransaction:).
- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions NS_AVAILABLE_IOS(3_0)
{
    NSLogFunc;
}

// Sent when an error is encountered while adding transactions from the user's purchase history back to the queue.
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error NS_AVAILABLE_IOS(3_0)
{
    NSLogFunc;
}

// Sent when all transactions from the user's purchase history have successfully been added back to the queue.
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue NS_AVAILABLE_IOS(3_0)
{
    NSLogFunc;
}

// Sent when the download state has changed.
- (void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray *)downloads NS_AVAILABLE_IOS(6_0)
{
    NSLogFunc;
}

#endif

- (void)dealloc
{
    //移除监听
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

@end
