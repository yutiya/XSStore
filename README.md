# XSStore-初学者小试牛刀，IAP
------
### iOS内购
> * 在[苹果开发者中心](https://developer.apple.com/account/ios/identifiers/bundle/bundleList.action)注册App ID（com.xxx.xxx）
> * 在iTunes Connect的[My Apps](https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/ng/app)中创建以com.xxx.xxx为App ID的应用
> * 确认开发者账户已经填写完所有的信息（联系人、银行卡等等），位于iTunes Connect的[Agreements, Tax, and Banking](https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/da/jumpTo?page=contracts)
> * 在iTunes Connect中，给相应的App设置商品清单，商品ID一般设置为（com.xxx.xxx.productxxx），价格也一并设置了
> * 在iTunes Connect的[Users and Roles](https://itunesconnect.apple.com/WebObjects/iTunesConnect.woa/ra/ng/users_roles/sandbox_users)设置沙盒测试用户

------
### 使用
>GameBuyDev
        XSIAP（iOS内购模块所需的所有代码，使用了第三方的网络检测 @nsdictionary）

*       导入系统框架库StoreKit、SystemConfiguration
*       导入 #import "XSStore.h"
*       购买前调用接口，确认可以支付
```
        [XSStore canPayProduct];
```
*       调用购买接口，传递IAP中设置的商品ID，请设置iTunes Connect的IAP
    成功和失败结果均采用代码块方式进行回调，回调均在主线程中执行，调用者只需要关注
    逻辑处理和UI交互即可，失败代码块中会传递错误代码，在注释中均有提示
```
        [[XSStore shardXSStore] payProduct:product withSuccess:^{
                NSLog(@"购买完成");
        } withFailed:^(XSPayState payState) {
                NSLog(@"购买失败:%u", payState);
        }];
```

------

### **注意**：（重要）
- > 请添加系统框架StoreKit、SystemConfiguration
- >	仅支持消耗性商品的购买（其余商品尚未开发测试）
- >	请使用沙盒测试用户进行测试，上面已写出
- >	测试前，请在真机的App store中退出已登录的账户，否则会一直出现购买失败

        有问题，请 Issue 我，谢谢
        如果你想改进这个框架，就 Pull Request
        邮箱： youtiya@163.com
