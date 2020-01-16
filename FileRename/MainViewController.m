//
//  MainViewController.m
//  FileRename
//
//  Created by 马雨辰 on 2020/1/13.
//  Copyright © 2020 马雨辰. All rights reserved.
//

#import "MainViewController.h"

typedef NS_ENUM(NSInteger , OutputType)
{
    OutputType_unKnow = 0,
    OutputType_originFileNameDateTime = 1,
    OutputType_originFileNameDate = 2,
    OutputType_dateTimeOriginFileName = 3,
    OutputType_dateOriginFileName = 4
};


@interface MainViewController ()
@property (weak) IBOutlet NSTextField *inputPathTextField;
@property (weak) IBOutlet NSTextField *outputPathTextField;


@property (weak) IBOutlet NSButton *originFileNameDateTimeButton;
@property (weak) IBOutlet NSButton *originFileNameDateButton;
@property (weak) IBOutlet NSButton *dateTimeOriginFileNameButton;
@property (weak) IBOutlet NSButton *dateOriginFileNameButton;

@property (weak) IBOutlet NSButton *deleteOriginFileButton;




@property(nonatomic,assign)OutputType outputType;


@property(nonatomic,assign)BOOL finishedDeleteOriginFile;//完成后删除原文件

@property (weak) IBOutlet NSTextField *progressLabel;


@property(nonatomic,assign)NSInteger totalFileCount;
@property(nonatomic,assign)NSInteger copyFinishFileCount;
@property(nonatomic,assign)NSInteger deleteFileCount;





@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    
    // Do view setup here.
}


//选择输入路径点击
- (IBAction)selectInputPathButton:(id)sender {
    
    NSOpenPanel* panel = [NSOpenPanel openPanel];
       __weak typeof(self)weakSelf = self;
       //是否可以创建文件夹
       panel.canCreateDirectories = NO;
       //是否可以选择文件夹
       panel.canChooseDirectories = YES;
       //是否可以选择文件
       panel.canChooseFiles = NO;

       //是否可以多选
       [panel setAllowsMultipleSelection:NO];

       //显示
       [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {

           //是否点击open 按钮
           if (result == NSModalResponseOK) {
               NSString *pathString = [panel.URLs.firstObject path];
               
               weakSelf.inputPathTextField.stringValue = pathString;
           }
       }];
    
}


//选择导出路径点击
- (IBAction)selectOutputPathButton:(id)sender {

    NSOpenPanel* panel = [NSOpenPanel openPanel];
          __weak typeof(self)weakSelf = self;
          //是否可以创建文件夹
          panel.canCreateDirectories = YES;
          //是否可以选择文件夹
          panel.canChooseDirectories = YES;
          //是否可以选择文件
          panel.canChooseFiles = NO;

          //是否可以多选
          [panel setAllowsMultipleSelection:NO];

          //显示
          [panel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {

              //是否点击open 按钮
              if (result == NSModalResponseOK) {
                  NSString *pathString = [panel.URLs.firstObject path];
                  
                  weakSelf.outputPathTextField.stringValue = pathString;
              }
          }];
    
}
//原文件名-日期-时间
//开始转换点击
- (IBAction)startChangeButtonClick:(id)sender {

    NSLog(@"开始点击点击点击");
    
    NSString *inputPath = self.inputPathTextField.stringValue;
    if(!inputPath || inputPath.length <= 0)
    {
        [self showRemindMessage:@"请选择输入路径"];
        return;
    }

    NSString *outputPaht = self.outputPathTextField.stringValue;
    if(!outputPaht || outputPaht.length <= 0)
    {
        [self showRemindMessage:@"请选择输出路径"];
        return;
    }

    if(self.outputType == OutputType_unKnow)
     {
         [self showRemindMessage:@"请选择文件名输出格式"];
         return;
     }

    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsDirectory = inputPath;
    NSDirectoryEnumerator<NSString *> * myDirectoryEnumerator;
    myDirectoryEnumerator=  [fileManager enumeratorAtPath:documentsDirectory];
    
    self.totalFileCount = [fileManager subpathsAtPath:inputPath].count;
    
    self.copyFinishFileCount = 0;
    self.deleteFileCount = 0;
    [self updateProgress];
    while (documentsDirectory = [myDirectoryEnumerator nextObject])
    {
        for (NSString * namePath in documentsDirectory.pathComponents)
        {
            NSString *originFilePath = [inputPath stringByAppendingFormat:@"/%@", namePath];
            
            NSError *error = nil;
            
            NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:originFilePath error:&error];
            
            if (fileAttributes != nil)
            {
                NSDate *fileCreateDate = [fileAttributes objectForKey:NSFileCreationDate];
                
                NSString *newName = [self getNewFileNameWithOriginName:namePath fileDate:fileCreateDate];

                NSString *newFilePath = [outputPaht stringByAppendingFormat:@"/%@", newName];
                              
                //复制文件
//                [self copyFileWithOriginFilePath:originFilePath newFilePath:newFilePath];
          
                //删除文件
//                [self deleteFileWithPath:originFilePath];
            }
            else
            {
                NSLog(@"Path (%@) is invalid.", originFilePath);
            }
        }
    }
    
    
    NSLog(@"获取完成，总数量：%ld",self.totalFileCount);
    
}


-(void)copyFileWithOriginFilePath:(NSString *)originFilePath newFilePath:(NSString *)newFilePath
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        BOOL copySuccess = [fileManager copyItemAtPath:originFilePath toPath:newFilePath error:nil];
        
        if(copySuccess)
        {
           dispatch_async(dispatch_get_main_queue(), ^{
                self.copyFinishFileCount+= 1;
                
                [self updateProgress];
            });
            
            
        }
    });
}




-(void)deleteFileWithPath:(NSString *)path
{
    dispatch_async(dispatch_get_main_queue(), ^{
        //判断是否删除原文件
        if(self.deleteOriginFileButton.state == NSControlStateValueOn)
        {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            BOOL deleteSuccess = [fileManager removeItemAtPath:path error:nil];
            
            if(deleteSuccess)
            {
                self.deleteFileCount+= 1;
                
                [self updateProgress];
            }
        }
    });
}


-(void)updateProgress
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *progressStr = [NSString stringWithFormat:@"当前进度：%ld/%ld,删除原文件：%ld",self.copyFinishFileCount,self.totalFileCount,self.deleteFileCount];
        NSLog(@"%@", progressStr);
        self.progressLabel.stringValue = progressStr;
    });
}


-(NSString *)getNewFileNameWithOriginName:(NSString *)originName fileDate:(NSDate *)fileDate
{
    NSString *newName = originName;
    
    if(originName && originName.length > 0)
    {
        NSString *pathExtension = [originName pathExtension];
        
        pathExtension = [@"." stringByAppendingString:pathExtension];
        
        originName = [originName stringByReplacingOccurrencesOfString:pathExtension withString:@""];

        if(fileDate == nil)
        {
            fileDate = [NSDate date];
        }
        
        NSString *dateTimeStr = [self getDateTimeStrWithDate:fileDate type:self.outputType];
        
        if(self.outputType == OutputType_originFileNameDateTime || self.outputType == OutputType_originFileNameDate)
        {
            newName = [originName stringByAppendingFormat:@"-%@", dateTimeStr];
        }
        else if(self.outputType == OutputType_dateTimeOriginFileName || self.outputType == OutputType_dateOriginFileName)
        {
            newName = [dateTimeStr stringByAppendingFormat:@"-%@", originName];
        }
        
        newName = [newName stringByAppendingString:pathExtension];
    }
    return newName;
}


- (NSString *)getDateTimeStrWithDate:(NSDate *)date type:(OutputType )type
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    if(type == OutputType_originFileNameDateTime || type == OutputType_dateTimeOriginFileName)
    {
        [formatter setDateFormat:@"yyyyMMddHHmmss"];
    }
    else if(type == OutputType_originFileNameDate || type == OutputType_dateOriginFileName)
    {
        [formatter setDateFormat:@"yyyyMMdd"];
    }
    
    NSString *dateTime = [formatter stringFromDate:date];
    return dateTime;
}




- (IBAction)outputTypeButtonClick:(id)sender {
    
    NSButton *button = sender;
    
    NSLog(@"buttonTag----%ld",button.tag);
    
    self.outputType = button.tag;
    
    self.originFileNameDateTimeButton.state = self.originFileNameDateTimeButton.tag == button.tag;
    self.originFileNameDateButton.state = self.originFileNameDateButton.tag == button.tag;
    self.dateTimeOriginFileNameButton.state = self.dateTimeOriginFileNameButton.tag == button.tag;
    self.dateOriginFileNameButton.state = self.dateOriginFileNameButton.tag == button.tag;

}



-(void)showRemindMessage:(NSString *)message
{
    NSAlert *alert = [[NSAlert alloc] init];
    alert.alertStyle = NSAlertStyleWarning;
    [alert addButtonWithTitle:@"确定"];
    alert.messageText = @"温馨提示";
    alert.informativeText = message;
    [alert beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:nil];
}

@end
