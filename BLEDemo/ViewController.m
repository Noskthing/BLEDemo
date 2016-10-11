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
    
    NSInteger _currentIndex;
}
@end

@implementation ViewController

-(void)viewWillAppear:(BOOL)animated
{
    [self disconnectPeripheral];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.title = @"搜索设备";
    
    [LBWCBManagerGet startScan];
    LBWCBManagerGet.discoveryDlegate = self;
    
    _currentIndex = -1;
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_tableView];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 120;
    [_tableView registerNib:[UINib nibWithNibName:@"PhripheralTableViewCell" bundle:nil] forCellReuseIdentifier:@"service"];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark     tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    CBPeripheralExt * model = LBWCBManagerGet.foundPeripherals[section];
    return model.isShowAdvertisementData?model.mAdvertisementData.allKeys.count:1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return LBWCBManagerGet.foundPeripherals.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PhripheralTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"service" forIndexPath:indexPath];
    
    CBPeripheralExt * model = LBWCBManagerGet.foundPeripherals[indexPath.section];
    
    cell.name.text = [model getPeripheralName];
    cell.serviceCount.text = [NSString stringWithFormat:@"Service : %@",[model getServiceCount]];
    cell.RSSI.text = [NSString stringWithFormat:@"RSSI : %@",[model getRSSI]];
    cell.UUIDString.text = [model getUUIDString];
    
    [cell.pullDownButton addTarget:self action:@selector(pullDownButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    cell.pullDownButton.tag = indexPath.section + 10;
    cell.pullDownButton.selected = model.isShowAdvertisementData;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CBPeripheralExt * model = LBWCBManagerGet.foundPeripherals[indexPath.section];
    
    [LBWCBManagerGet connectPeripheral:model.mPeripheral CompletionBlock:^(BOOL result, NSError *error) {
        if (result)
        {
            ServiceController * nextVC = [[ServiceController alloc] init];
            [self.navigationController pushViewController:nextVC animated:YES];
        }
    }];
}

#pragma mark    pullDownButton Touch
-(void)pullDownButtonTouched:(UIButton *)btn
{
    if (_currentIndex > 0)
    {
        CBPeripheralExt * previousModel = LBWCBManagerGet.foundPeripherals[_currentIndex];
        previousModel.isShowAdvertisementData = NO;
    }
    
    CBPeripheralExt * currentModel = LBWCBManagerGet.foundPeripherals[btn.tag - 10];
    currentModel.isShowAdvertisementData = YES;
    
    NSMutableIndexSet *idxSet = [[NSMutableIndexSet alloc] init];
    [idxSet addIndex:_currentIndex];
    [idxSet addIndex:btn.tag - 10];
    
    [_tableView reloadData];
//    [_tableView reloadSections:idxSet withRowAnimation:UITableViewRowAnimationFade];
    
}

#pragma mark    discover delegate
- (void)discoveryNewPeripheral
{
    NSLog(@"aaa");
    [_tableView reloadData];
}

- (void)disconnectPeripheral
{
    [_tableView reloadData];
}
@end
