//
//  XSTableViewCell.h
//  GameBuyDev
//
//  Created by admin on 15/7/17.
//  Copyright (c) 2015年 Pandora. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XSTableViewCellDelegate;

@interface XSTableViewCell : UITableViewCell

@property (nonatomic, copy) NSString *productID;//商品ID
@property (nonatomic, weak) id<XSTableViewCellDelegate> delegate;//代理对象

@end

@protocol XSTableViewCellDelegate <NSObject>

@optional
/**
 *  buy按钮触摸事件代理回调
 */
- (void)buyButtonTouchAction:(NSString *)productID;

@end