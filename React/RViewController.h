//ouhdf9894 "sku"
//  RViewController.h
//  React
//
//  Created by Andreas Hammer on 02/11/13.
//  Copyright (c) 2013 Andreas Hammer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

@class GameCenterManager;
@interface RViewController : UIViewController <UIAlertViewDelegate>

@property (nonatomic, retain) IBOutlet UIButton *button;
-(IBAction)click:(id)sender;

@end
