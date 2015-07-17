//
//  XSTableViewCell.m
//  GameBuyDev
//
//  Created by admin on 15/7/17.
//  Copyright (c) 2015年 Pandora. All rights reserved.
//

#import "XSTableViewCell.h"

@interface XSTableViewCell ()

@property (nonatomic, weak) UILabel *productLabel;

@end

@implementation XSTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.frame = CGRectMake(self.contentView.frame.origin.x, self.contentView.frame.origin.y, self.contentView.frame.size.width, 64);
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 100, 20)];
        [label setFont:[UIFont systemFontOfSize:14]];
        label.textColor = [UIColor blueColor];
        label.text = @"商品ID:";
        [self.contentView addSubview:label];
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(self.contentView.bounds.size.width - 75, 18, 60, 40)];
        [button setTitle:@"buy" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(cellBuyButtonTouchAction) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:button];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (_productLabel) {
        [_productLabel setNeedsDisplay];
    }
}
/**
 *  利用property属性生成的方法，懒加载添加label
 */
- (void)setProductID:(NSString *)productID
{
    _productID = [productID copy];
    if (!_productLabel) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(18, 33, 220, 20)];
        [label setFont:[UIFont systemFontOfSize:14]];
        label.textColor = [UIColor redColor];
        label.text = _productID;
        [self.contentView addSubview:label];
        _productLabel = label;
    }
}
/**
 *  cell中buy按钮触摸事件
 */
- (void)cellBuyButtonTouchAction
{
    if (_delegate) {
        if([_delegate respondsToSelector:@selector(buyButtonTouchAction:)]) {
            [_delegate buyButtonTouchAction:_productID];
        }
    }
}

/**
 *  从xib中加载cell,自动调用
 */
- (void)awakeFromNib {
    
}

@end
