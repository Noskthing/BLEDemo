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
#import "DataShowTableViewCell.h"

@interface ViewController ()<CBManagerDiscoveryDelegate,UITableViewDelegate,UITableViewDataSource>
{
    UITableView * _tableView;
    
    NSInteger _currentIndex;
    
    
}
@property (nonatomic,strong)UILabel * mask;
@end

@implementation ViewController

-(void)viewWillAppear:(BOOL)animated
{
    [LBWCBManagerGet disconnectPeripheral:LBWCBManagerGet.currentConnectPeripheral];
    [LBWCBManagerGet refreshPeripherals];
    [_tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.title = @"搜索设备";
    
    [LBWCBManagerGet startScan];
    LBWCBManagerGet.discoveryDlegate = self;
    
    _currentIndex = -1;
    
    [self createUI];

}

-(void)createUI
{
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_tableView];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerNib:[UINib nibWithNibName:@"PhripheralTableViewCell" bundle:nil] forCellReuseIdentifier:@"service"];
    [_tableView registerNib:[UINib nibWithNibName:@"DataShowTableViewCell" bundle:nil] forCellReuseIdentifier:@"serviceAdvertisementData"];
    
    UIButton * refreshBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [refreshBtn addTarget:self action:@selector(refreshButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [refreshBtn setImage:[UIImage imageNamed:@"refresh"] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:refreshBtn];
    
    _mask = [[UILabel alloc] initWithFrame:self.view.bounds];
    _mask.textColor = [UIColor whiteColor];
    _mask.textAlignment = NSTextAlignmentCenter;
    _mask.backgroundColor = [UIColor colorWithRed:0. green:0. blue:0. alpha:0.8];
    _mask.text = @"Connecting...";
}

- (void)refreshButtonTouched:(UIButton *)btn
{
    [LBWCBManagerGet refreshPeripherals];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark     tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    CBPeripheralExt * model = LBWCBManagerGet.foundPeripherals[section];
    return model.isShowAdvertisementData?model.mAdvertisementData.allKeys.count + 1:1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return LBWCBManagerGet.foundPeripherals.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CBPeripheralExt * model = LBWCBManagerGet.foundPeripherals[indexPath.section];
    if (indexPath.row == 0)
    {
        PhripheralTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"service" forIndexPath:indexPath];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.name.text = [model getPeripheralName];
        cell.serviceCount.text = [NSString stringWithFormat:@"Service : %@",[model getServiceCount]];
        cell.RSSI.text = [NSString stringWithFormat:@"RSSI : %@",[model getRSSI]];
        cell.UUIDString.text = [model getUUIDString];
        cell.state.text = model.state == CBPeripheralStateConnected?@"Connected":@"NO Connect";
        cell.state.textColor = model.state == CBPeripheralStateConnected?[UIColor redColor]:[UIColor greenColor];
        
        [cell.pullDownButton addTarget:self action:@selector(pullDownButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        cell.pullDownButton.tag = indexPath.section + 10;
        cell.pullDownButton.selected = model.isShowAdvertisementData;
        
        return cell;
    }
    else
    {
        DataShowTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"serviceAdvertisementData" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor lightGrayColor];
        
        NSString * key = model.mAdvertisementData.allKeys[indexPath.row - 1];
        cell.key.text = [NSString stringWithFormat:@"Key : %@",key];
        cell.value.text = [NSString stringWithFormat:@"Value : %@",model.mAdvertisementData[key]];
        cell.className.text = [NSString stringWithFormat:@"Class Type : %@",NSStringFromClass([model.mAdvertisementData[key] class])];
        
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row == 0?120:85;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row !=0)
    {
        return;
    }
    
    CBPeripheralExt * model = LBWCBManagerGet.foundPeripherals[indexPath.section];
    
    UIAlertController * action = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"确定和%@匹配",[model getPeripheralName]] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:nil];
    [action addAction:cancel];
    __weak __typeof(self)weakSelf = self;
    UIAlertAction * connect = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf.view addSubview:strongSelf.mask];
        [LBWCBManagerGet connectPeripheral:model.mPeripheral CompletionBlock:^(BOOL result, NSError *error) {
            [strongSelf.mask removeFromSuperview];
            if (result)
            {
                ServiceController * nextVC = [[ServiceController alloc] init];
                [self.navigationController pushViewController:nextVC animated:YES];
            }
        }];
    }];
    [action addAction:connect];
    
    [self presentViewController:action animated:YES completion:nil];
    
    
    
}

#pragma mark    pullDownButton Touch
-(void)pullDownButtonTouched:(UIButton *)btn
{
    CBPeripheralExt * currentModel = LBWCBManagerGet.foundPeripherals[btn.tag - 10];
    
    /* 收回当前设备展示的列表 */
    if (currentModel.isShowAdvertisementData)
    {
        _currentIndex = -1;
        currentModel.isShowAdvertisementData = NO;
        [_tableView reloadData];
        return;
    }
    
    /* 第一次点击 */
    if (_currentIndex >= 0)
    {
        CBPeripheralExt * previousModel = LBWCBManagerGet.foundPeripherals[_currentIndex];
        previousModel.isShowAdvertisementData = NO;
    }
    
    currentModel.isShowAdvertisementData = YES;
    _currentIndex = btn.tag - 10;
    [_tableView reloadData];

    
//    [_tableView reloadSections:idxSet withRowAnimation:UITableViewRowAnimationFade];
    
}

#pragma mark    discover delegate
- (void)discoveryNewPeripheral
{
//    NSLog(@"aaa");
    [_tableView reloadData];
}

- (void)disconnectPeripheral
{
    [_tableView reloadData];
}
@end
