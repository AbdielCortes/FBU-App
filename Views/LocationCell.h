//
//  LocationCell.h
//  YellowHouse
//
//  Created by zurken on 7/21/20.
//  Copyright © 2020 Abdiel Cortes. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LocationCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *address;

@property (weak, nonatomic) IBOutlet UIImageView *categoryImage;

@property (strong, nonatomic) NSDictionary *location;

- (void)updateWithLocation:(NSDictionary *)location;

@end

NS_ASSUME_NONNULL_END
