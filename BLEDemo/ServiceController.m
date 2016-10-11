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
#import "ServiceTableViewCell.h"

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
    _tableView.rowHeight = 80;
    [_tableView registerNib:[UINib nibWithNibName:@"ServiceTableViewCell" bundle:nil] forCellReuseIdentifier:@"service"];
}


#pragma mark     tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return LBWCBManagerGet.services.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ServiceTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"service" forIndexPath:indexPath];
    
    CBService * model = LBWCBManagerGet.services[indexPath.row];
    
    cell.serviceName.text = [model getServiceNameForUUID];
    cell.UUIDString.text = [NSString stringWithFormat:@"UUID : %@",model.UUID.UUIDString];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CBService * model = LBWCBManagerGet.services[indexPath.row];
    
    [LBWCBManagerGet connectService:model CompletionBlock:^(BOOL result, NSError *error) {
        if (result)
        {
            CharacterViewController * vc = [[CharacterViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];
}
@end
