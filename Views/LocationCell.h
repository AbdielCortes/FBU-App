//
//  LocationCell.h
//  YellowHouse
//
//  Created by zurken on 7/21/20.
//  Copyright © 2020 Abdiel Cortes. All rights reserved.
//
//  LocationCell is an UITableViewCell used in the LocationViewController. It is used
//  to display the location info recieved from the Foursquare API.
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
