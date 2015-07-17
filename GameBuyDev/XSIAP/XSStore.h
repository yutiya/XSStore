//
//  XSStore.h
//  GameBuyDev
//
//  Created by admin on 15/7/16.
//  Copyright (c) 2015年 Pandora. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#define NSLogFunc do{NSLog(@"%s", __func__);}while(0)

#warning 注释该行，可以去掉烦人的控制台日志输出
#define XSDEBUG

#ifdef XSDEBUG

#define XSLog(format, ...) do {                                                     \
fprintf(stderr, "<%s : %d> %s\n",                                           \
[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],  \
__LINE__, __func__);                                                        \
(NSLog)((format), ##__VA_ARGS__);                                           \
fprintf(stderr, "-------\n");                                               \
} while (0)
#define NSLogFunc do{NSLog(@"%s", __func__);}while(0)

#else

#define XSLog(format, ...) do{}while(0)
#define NSLogFunc do{}while(0)

#endif

/** 调用购买接口所获取的对应状态 **/
typedef enum
{
    /**
     *  商品Id错误
     */
    XSPayStateProductIDError = 0,
    /**
     *  商品Id未找到,请配置iTunes Connect
     */
    XSPayStateProductNotFound,
    /**
     *  商品请求失败
     */
    XSPayStateProductRequestError,
    /**
     *  等待上一次购买完成
     */
    XSPayStateWaitPre,
    /**
     *  购买失败
     */
    XSPayStateFailed,
    /**
     *  未知错误
     */
    XSPayStateUnknownError,
    /**
     *  不允许客户端发出请求
     */
    XSPayStateClientInvalid,
    /**
     *  用户取消该请求
     */
    XSPayStatePaymentCancelled,
    /**
     *  内购id不可用
     */
    XSPayStatePaymentInvalid,
    /**
     *  设备不支持购买
     */
    XSPayStatePaymentNotAllowed,
    /**
     *  商品不可用
     */
    XSPayStateStoreProductNotAvailable
}XSPayState;
/** 调用静态结果确认是否可以支付 **/
typedef enum
{
    /**
     *  可以购买
     */
    XSCanPayCodeYes = 0,
    /**
     *  网络不可访问
     */
    XSCanPayCodeNetWorkError,
    /**
     *  前一购买尚未结束，请等待
     */
    XSCanPayCodePreUnSuccessError,
    /**
     *  设备不允许等
     */
    XSCanPayCodePaymentQueueError
}XSCanPayCode;

typedef void(^SuccessBlock)(void);
typedef void(^FailedBolck)(XSPayState payState);


@interface XSStore : NSObject

@property (nonatomic, assign) XSPayState errStateCode;
/**
 *  得到单例对象
 */
+ (XSStore *)shardXSStore;
/**
 *  在进行付款前，应该确认是否可以进行购买
 *  该方法会检测网络是否可用、上一次的购买是否完成等
 */
+ (XSCanPayCode)canPayProduct;
/**
 *  给定商品Id（商品Id，需要前往iTunes Connect中进行配置）
 */
- (void)payProduct:(NSString *)productId withSuccess:(SuccessBlock)successBlock withFailed:(FailedBolck)failedBlock;

@end
