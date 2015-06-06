//
//  DRNRoomStatusViewController.m
//  DonggukLibrary
//
//  Created by 1001246 on 2015. 5. 10..
//  Copyright (c) 2015년 USAIU. All rights reserved.
//

#import "DRNRoomStatusViewController.h"

// Model
#import "DRNRoom.h"
#import "DRNSeat.h"

// View
#import "DRNSeatLabel.h"

// Utility
#import "DRNNetwork.h"

// Library
#import <Masonry/Masonry.h>

@interface DRNRoomStatusViewController ()

@property (strong, nonatomic) NSArray *enable;
@property (strong, nonatomic) NSArray *disable;
@property (strong, nonatomic) NSArray *using;

@end

@implementation DRNRoomStatusViewController

- (instancetype)initWithRoom:(DRNRoom *)room
{
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor whiteColor];
        _room = room;
        
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.contentInset = UIEdgeInsetsMake(50, 50, 50, 50);
        [self.view addSubview:_scrollView];
        
        [self makeAutoLayoutConstraints];
    }
    return self;
}

- (void)makeAutoLayoutConstraints
{
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [DRNNetwork getRoomStatusWithRoom:_room success:^(NSDictionary *responseObject) {
        NSLog(@"%@", responseObject);
        
        _enable = [responseObject objectForKey:@"enable"];
        _disable = [responseObject objectForKey:@"disable"];
        _using = [responseObject objectForKey:@"using"];
        [self parse];
        
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

- (void)parse
{
    NSURL *filePath = [[NSBundle mainBundle] URLForResource:@"map"
                                              withExtension:@"json"];
    NSData *data = [NSData dataWithContentsOfURL:filePath];
    NSError *error;
    
    NSMutableArray *array = [NSJSONSerialization JSONObjectWithData:data
                                                            options:NSJSONReadingMutableContainers
                                                              error:&error];
    if (error) {
        NSLog(@"JSONObjectWithData error: %@", error);
    } else {
        NSArray *mapArray = [[array objectAtIndex:_room.numberInteger-1] objectForKey:@"map"];
        mapArray = [DRNSeat seatsWithMapArray:mapArray];
        
        CGFloat maxWidth = 0, maxHeight = 0;
        for (DRNSeat *seat in mapArray) {
            DRNSeatLabel *label = [[DRNSeatLabel alloc] initWithSeat:seat];
            maxWidth    = MAX(maxWidth, label.right);
            maxHeight   = MAX(maxHeight, label.bottom);
            
            if ([_enable containsObject:seat.number]) {
                label.type = DRNSeatLabelTypeEnable;
            } else if ([_disable containsObject:seat.number]) {
                label.type = DRNSeatLabelTypeDisbale;
            } else if ([_using containsObject:seat.number]) {
                label.type = DRNSeatLabelTypeUsing;
            }
            
            [_scrollView addSubview:label];
        }
        _scrollView.contentSize = CGSizeMake(maxWidth, maxHeight);
    }
}

@end