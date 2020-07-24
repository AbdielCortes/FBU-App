//
//  LocationCell.m
//  YellowHouse
//
//  Created by zurken on 7/21/20.
//  Copyright © 2020 Abdiel Cortes. All rights reserved.
//

#import "LocationCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@implementation LocationCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateWithLocation:(NSDictionary *)location {
    self.name.text = location[@"name"];
    self.address.text = [location valueForKeyPath:@"location.address"];
    
    // set image
    NSArray *categories = location[@"categories"];
    if (categories && categories.count > 0) {
        // create image url string
        NSDictionary *category = categories[0];
        NSString *urlPrefix = [category valueForKeyPath:@"icon.prefix"];
        NSString *urlSuffix = [category valueForKeyPath:@"icon.suffix"];
        NSString *urlString = [NSString stringWithFormat:@"%@bg_32%@", urlPrefix, urlSuffix];

        // get image using url and AFNetworking
        NSURL *url = [NSURL URLWithString:urlString];
        self.categoryImage.layer.cornerRadius = 10.0f;
        [self.categoryImage setImageWithURL:url];
    }
}

@end
