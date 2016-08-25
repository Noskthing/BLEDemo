//
//  ViewController.m
//  Tools
//
//  Created by ml on 16/8/24.
//  Copyright © 2016年 李博文. All rights reserved.
//

#import "ViewController.h"
#import "CBManagerHeader.h"
#import "ServiceController.h"
#import "PhripheralTableViewCell.h"

@interface ViewController ()<CBManagerDiscoveryDelegate,UITableViewDelegate,UITableViewDataSource>
{
    UITableView * _tableView;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.title = @"搜索设备";
    
    [CBManagerGet startScan];
    CBManagerGet.discoveryDlegate = self;
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_tableView];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 80;
    [_tableView registerNib:[UINib nibWithNibName:@"PhripheralTableViewCell" bundle:nil] forCellReuseIdentifier:@"service"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark     tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return CBManagerGet.foundPeripherals.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PhripheralTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"service" forIndexPath:indexPath];
    
    CBPeripheralExt * model = CBManagerGet.foundPeripherals[indexPath.row];
    
    cell.name.text = [model getPeripheralName];
    cell.serviceCount.text = [model getServiceCount];
    cell.RSSI.text = [model getRSSI];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CBPeripheralExt * model = CBManagerGet.foundPeripherals[indexPath.row];
    
    [CBManagerGet connectPeripheral:model.mPeripheral CompletionBlock:^(BOOL result, NSError *error) {
        if (result)
        {
            ServiceController * nextVC = [[ServiceController alloc] init];
            [self.navigationController pushViewController:nextVC animated:YES];
        }
    }];
}

#pragma mark    discover delegate
- (void)discoveryNewPeripheral
{
    [_tableView reloadData];
}
@end
