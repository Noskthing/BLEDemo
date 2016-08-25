//
//  ServiceController.m
//  Tools
//
//  Created by ml on 16/8/25.
//  Copyright © 2016年 李博文. All rights reserved.
//

#import "ServiceController.h"
#import "CBManagerHeader.h"
#import "CharacterViewController.h"

@interface ServiceController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView * _tableView;
}
@end

@implementation ServiceController


-(void)viewDidLoad
{
    self.navigationItem.title = @"设备服务";
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_tableView];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 60;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"service"];
}


#pragma mark     tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return CBManagerGet.services.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"service" forIndexPath:indexPath];
    
    CBService * model = CBManagerGet.services[indexPath.row];
    
    cell.textLabel.text = [model getServiceNameForUUID];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CBService * model = CBManagerGet.services[indexPath.row];
    
    [CBManagerGet connectService:model CompletionBlock:^(BOOL result, NSError *error) {
        if (result)
        {
            CharacterViewController * vc = [[CharacterViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];
}
@end
