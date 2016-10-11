//
//  CharacterViewController.m
//  Tools
//
//  Created by ml on 16/8/25.
//  Copyright © 2016年 李博文. All rights reserved.
//

#import "CharacterViewController.h"
#import "CBManagerHeader.h"
#import "CharactesTableViewCell.h"
#import "UpdateViewController.h"

@interface CharacterViewController ()<UITableViewDelegate,UITableViewDataSource,CBManagerCurrentPeripheralDelegte>
{
    UITableView * _tableView;
}
@end

@implementation CharacterViewController

-(void)viewDidLoad
{
    self.navigationItem.title = @"服务字段";
    
    LBWCBManagerGet.currentPeripheralDelegate = self;
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_tableView];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 90;
    [_tableView registerNib:[UINib nibWithNibName:@"CharactesTableViewCell" bundle:nil] forCellReuseIdentifier:@"character"];
}

#pragma mark     tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return LBWCBManagerGet.characteristics.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CharactesTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"character" forIndexPath:indexPath];
    
    CBCharacteristic * model = LBWCBManagerGet.characteristics[indexPath.row];
    
    cell.name.text = [model getCharacteristicNameForUUID];
    cell.jurisdiction.text = [model getPropertyString];
    cell.UUIDString.text = [NSString stringWithFormat:@"UUID : %@",model.UUID.UUIDString];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CBCharacteristic * model = LBWCBManagerGet.characteristics[indexPath.row];
    
    LBWCBManagerGet.currentCharacteristic = model;
    
    UpdateViewController * vc = [[UpdateViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    
    [LBWCBManagerGet.currentConnectPeripheral discoverDescriptorsForCharacteristic:LBWCBManagerGet.currentCharacteristic];
}

#pragma mark    pheripheral delegate
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        NSLog(@"error is %@",error);
    }
    else
    {
        NSArray * arr = characteristic.descriptors;
        NSLog(@"arr is %@",arr);
    }
}
@end
