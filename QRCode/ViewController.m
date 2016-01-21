//
//  ViewController.m
//  QRCode



#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>//需要添加AVFoundation系统库
@interface ViewController ()<AVCaptureMetadataOutputObjectsDelegate>//遵守相应代理
@property (strong,nonatomic) AVCaptureDevice * device;//采集的设备
@property (strong,nonatomic) AVCaptureDeviceInput * input;//设备的输入
@property (strong,nonatomic) AVCaptureMetadataOutput * output;//输出
@property (strong,nonatomic) AVCaptureSession * session;//采集流
@property (strong,nonatomic) AVCaptureVideoPreviewLayer * preview;//窗口

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton * button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"iOS原生扫描二维码" forState:UIControlStateNormal];
    button.frame = CGRectMake(50, 100, self.view.bounds.size.width - 100, 50);
    [button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)buttonClick{
    // Device 实例化设备
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input 设备输入
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output 设备的输出
    _output = [[AVCaptureMetadataOutput alloc]init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // Session
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:self.input])
    {
        [_session addInput:self.input];
    }
    
    if ([_session canAddOutput:self.output])
    {
        [_session addOutput:self.output];
    }
    
    // 条码类型 AVMetadataObjectTypeQRCode
    _output.metadataObjectTypes =@[AVMetadataObjectTypeCode128Code,AVMetadataObjectTypeUPCECode,AVMetadataObjectTypeCode39Code,AVMetadataObjectTypeCode39Mod43Code,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeCode93Code,AVMetadataObjectTypePDF417Code,AVMetadataObjectTypeQRCode,AVMetadataObjectTypeAztecCode,AVMetadataObjectTypeInterleaved2of5Code,AVMetadataObjectTypeITF14Code,AVMetadataObjectTypeDataMatrixCode];
    
    // Preview 扫描窗口设置
    _preview =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _preview.frame = CGRectMake(20,150,self.view.bounds.size.width - 40,300);
    [self.view.layer insertSublayer:self.preview atIndex:0];
    
    // Start 开始扫描
    [_session startRunning];
}
//解析结果的代理方法
#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    //得到解析到的结果
    NSString *stringValue;
    
    if ([metadataObjects count] >0)
    {
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
    }
    
    [_session stopRunning];//停止扫描
    
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"提示" message:[NSString stringWithFormat:@"结果：%@",stringValue] delegate:self cancelButtonTitle:nil otherButtonTitles:@"知道了",@"重新扫描",  nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        [self dismissViewControllerAnimated:YES completion:^
         {
            //
         }];
    }
    else
    {
        //重新扫描
        [_session startRunning];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
