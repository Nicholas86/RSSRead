//
//  SMFeedTableViewCell.m
//  RSSRead
//
//  Created by a on 2017/12/21.
//  Copyright © 2017年 Nicholas_锋. All rights reserved.
//

#import "SMFeedTableViewCell.h"
#import "SMFeedModel.h"

#define KScreenWidth  [UIScreen mainScreen].bounds.size.width
#define KScreenHeight [UIScreen mainScreen].bounds.size.height

@interface SMFeedTableViewCell ()
@property (nonatomic, strong) UIImageView *backImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation SMFeedTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSLog(@"单元格初始化");
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        self.contentView.backgroundColor = [UIColor clearColor];
        [self.contentView  addSubview:self.backImageView];
        [self.contentView  addSubview:self.titleLabel];
    }return self;
}

//背景相框
- (UIImageView *)backImageView
{
    if (!_backImageView) {
        self.backImageView = [[UIImageView  alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        _backImageView.backgroundColor = [UIColor  lightGrayColor];
    }return _backImageView;
}

//标题
- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        self.titleLabel = [[UILabel  alloc] initWithFrame:CGRectMake(30, 10, 160, 30)];
        _titleLabel.backgroundColor = [UIColor  yellowColor];
    }return _titleLabel;
}


//绘制
- (void)draw
{
    //异步 + 并行
    dispatch_queue_t queue  = dispatch_queue_create("com.rssread.smfeedcell", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queue, ^{
        //整个画板的frame
        CGRect rect = CGRectMake(0, 0, KScreenWidth, 80);
        UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [[UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1] set];
        CGContextFillRect(context, rect);
        UIImage *temp = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        dispatch_async(dispatch_get_main_queue(), ^{
            _backImageView.frame = rect;
            _backImageView.image = nil;
            _backImageView.image = temp;
            //标题
            _titleLabel.text = _model.title;
        });
    });
}

//赋值
- (void)setModel:(SMFeedModel *)model
{
    _model = model;
    
}

@end


