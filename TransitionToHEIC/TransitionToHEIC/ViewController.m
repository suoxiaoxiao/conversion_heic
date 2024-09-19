//
//  ViewController.m
//  TransitionToHEIC
//
//  Created by 索晓晓 on 2024/9/14.
//

#import "ViewController.h"
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

@interface ViewController ()

@property (nonatomic, strong) NSButton *addBtn;

@property (nonatomic, strong) NSButton *startTaskBtn;

@property (nonatomic, strong) NSMutableArray *needTransFilePaths;
@property (nonatomic, strong) NSMutableArray *logcats;

@property (nonatomic, strong) NSTextView *textView;
@property (nonatomic, strong) NSScrollView *scrollView;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.needTransFilePaths = [NSMutableArray array];
    self.addBtn = [NSButton buttonWithTitle:@"添加文件" target:self action:@selector(clickAddFile)];
    
    [self.view addSubview:self.addBtn];
    [self.addBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
    // 添加约束
    [NSLayoutConstraint activateConstraints:@[
        // textView 左边距
        [self.addBtn.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:15],
        // textView 顶部距离
        [self.addBtn.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:15],
        [self.addBtn.widthAnchor constraintEqualToConstant:100],
        // textView 高度固定
        [self.addBtn.heightAnchor constraintEqualToConstant:30]
    ]];
    
    
    
    self.startTaskBtn =  [NSButton buttonWithTitle:@"开始转换" target:self action:@selector(transfromFile)];
    
    [self.view addSubview:self.startTaskBtn];
    
    [self.startTaskBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
    // 添加约束
    [NSLayoutConstraint activateConstraints:@[
        // textView 左边距
        [self.startTaskBtn.leadingAnchor constraintEqualToAnchor:self.addBtn.trailingAnchor constant:15],
        // textView 顶部距离
        [self.startTaskBtn.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:15],
        [self.startTaskBtn.widthAnchor constraintEqualToConstant:100],
        // textView 高度固定
        [self.startTaskBtn.heightAnchor constraintEqualToConstant:30]
    ]];
    
    
    
    self.scrollView = [[NSScrollView alloc] init];
    [self.view addSubview:self.scrollView];
    
    
    self.textView = [[NSTextView alloc] init];
    self.textView.backgroundColor = NSColor.blackColor;
    self.textView.textColor = NSColor.whiteColor;
    self.textView.editable = false;
    self.textView.selectable = true;
    self.textView.usesFontPanel = false;
    self.textView.fieldEditor = false;
    self.textView.verticallyResizable = true;
    self.textView.horizontallyResizable = true;
//    self.textView.
//    [self.view addSubview:self.textView];
    self.scrollView.documentView = self.textView;
    
    // 启用自动布局
    [self.scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    // 添加约束
    [NSLayoutConstraint activateConstraints:@[
        // textView 左边距
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:15],
        // textView 右边距
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:15],
        // textView 顶部距离
        [self.scrollView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:60],
        // textView 高度固定
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-15]
    ]];
        
    self.logcats = [NSMutableArray array];
    
    
    // Do any additional setup after loading the view.
}

- (void)requestOutputFilePathPermission {
    
}

- (void)test1 {
    // 定义要执行的命令   sips -s format heic personal_vip_yoga_logo.png -o personal_vip_yoga_logo.heic
//        NSString *command = [NSString stringWithFormat:@"%@ %@ -o %@",@"sips -s format heic",[path stringByAppendingPathComponent:name],[path stringByAppendingPathComponent:outputName]];
//
//        [self appendLog:command];
    
    NSString *command = @"sudo touch /Users/suoxiaoxiao/Documents/demo.txt";
    
    // 创建 NSTask 实例
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/sh"];
    
    // 设置命令参数
    NSArray *arguments = @[@"-c", command];
    [task setArguments:arguments];
    
    // 创建管道以捕获输出
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    
    // 启动任务
    NSError *error = nil;
    [task launchAndReturnError:&error];
    
    // 读取输出
    NSData *data = [[pipe fileHandleForReading] readDataToEndOfFile];
    NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    // 显示输出
    NSLog(@"Command output:\n%@", output);
    [self appendLog:@"***************************Terminal***************************"];
    [self appendLog:[NSString stringWithFormat:@"Command output:\n%@",output]];
    [self appendLog:@"***************************Terminal***************************"];
}

- (void)single {
    
    [self appendLog:@"***************************Save***************************"];

    NSMutableArray *heicResult = [NSMutableArray array];

    for (NSString *path in heicResult) {
        NSSavePanel *savePanel = [NSSavePanel savePanel];
        savePanel.directoryURL = [NSURL URLWithString:@""];
        [savePanel setNameFieldStringValue:path.lastPathComponent];
        [savePanel setCanCreateDirectories:YES];
        [savePanel setCanSelectHiddenExtension:YES];
        [savePanel setTreatsFilePackagesAsDirectories:YES];
        [savePanel beginSheetModalForWindow:[self view].window completionHandler:^(NSInteger result) {
            if (result == NSModalResponseOK) {
                // 用户点击了“保存”按钮
                NSURL *selectedURL = [savePanel URL];
                if (selectedURL) {
                    NSString *dirPath = [selectedURL path];
                    
//                    NSData *data = [NSData dataWithContentsOfFile:path];
//                    BOOL success = [data writeToFile:dirPath atomically:true];
//                    if (success) {
//                        [self appendLog:[NSString stringWithFormat:@"保存成功%@",path]];
//                    } else {
//                        [self appendLog:[NSString stringWithFormat:@"保存失败%@",path]];
//                    }
                    
                    
                    
                }
            } else {
                // 用户取消了操作
                [self appendLog:[NSString stringWithFormat:@"用户取消了操作"]];
            }
        }];
    }
    [self appendLog:@"***************************Save***************************"];
    
}

- (BOOL)moveFile:(NSString *)filePath toOutputDir:(NSString *)outputDir {
    
    NSString *command = [NSString stringWithFormat:@"mv -f %@ %@/ && echo \"已保存到原目录\"",filePath,outputDir];

    // 创建 NSTask 实例
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/sh"];
    
    // 设置命令参数
    NSArray *arguments = @[@"-c", command];
    [task setArguments:arguments];
    
    // 创建管道以捕获输出
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    
    // 启动任务
    NSError *error = nil;
    [task launchAndReturnError:&error];
    
    // 读取输出
    NSData *data = [[pipe fileHandleForReading] readDataToEndOfFile];
    NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    // 显示输出
    [self appendLog:[NSString stringWithFormat:@"文件:%@,%@",filePath.lastPathComponent,output]];
    
    return error == nil;
}

- (void)transfromFile {
    
    if (self.needTransFilePaths.count <= 0) {
        [self appendLog:@"文件为空"];
        return;
    }
    
    NSMutableArray *heicResult = [NSMutableArray array];
    
    for (int i = 0; i < self.needTransFilePaths.count; i++) {
        NSString *str = self.needTransFilePaths[i];
        NSString *path = [str stringByDeletingLastPathComponent];
        NSString *name = [str lastPathComponent];
        NSString *outputName = [[str lastPathComponent] stringByReplacingOccurrencesOfString:[str pathExtension] withString:@"heic"];
        // 定义要执行的命令   sips -s format heic personal_vip_yoga_logo.png -o personal_vip_yoga_logo.heic
        NSString *command = [NSString stringWithFormat:@"%@ %@ -o %@",@"sips -s format heic",[path stringByAppendingPathComponent:name],[path stringByAppendingPathComponent:outputName]];
        
//        [self appendLog:command];
        
        // 创建 NSTask 实例
        NSTask *task = [[NSTask alloc] init];
        [task setLaunchPath:@"/bin/sh"];
        
        // 设置命令参数
        NSArray *arguments = @[@"-c", command];
        [task setArguments:arguments];
        
        // 创建管道以捕获输出
        NSPipe *pipe = [NSPipe pipe];
        [task setStandardOutput:pipe];
        
        // 启动任务
        NSError *error = nil;
        [task launchAndReturnError:&error];
        
        // 读取输出
        NSData *data = [[pipe fileHandleForReading] readDataToEndOfFile];
        NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        // 显示输出
//        [self appendLog:@"***************************Terminal***************************"];
//        [self appendLog:[NSString stringWithFormat:@"%@",output]];
//        [self appendLog:@"***************************Terminal***************************"];
       // 校验文件是否存在
        if ([[NSFileManager defaultManager] fileExistsAtPath:[path stringByAppendingPathComponent:outputName]]) {
            [self appendLog:[NSString stringWithFormat:@"转化成功%@",name]];
            [heicResult addObject:[path stringByAppendingPathComponent:outputName]];
        } else {
            [self appendLog:[NSString stringWithFormat:@"转化失败%@",name]];
        }
    }
    
    [self.needTransFilePaths removeAllObjects];
    
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:false];
    [openPanel setCanChooseDirectories:true];
    
    [openPanel beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse result) {
        if (result == NSModalResponseOK) {
            NSArray <NSURL *>*selectedURLs = [openPanel URLs];
            if ([selectedURLs count] > 0) {
                NSString *dirUrl = selectedURLs.firstObject.path;
                [self appendLog:[NSString stringWithFormat:@"保存目录: %@", dirUrl]];
                // 执行保存操作
                for (NSString *path in heicResult) {

//                    NSString *filePAth = [dirUrl stringByAppendingPathComponent:path.lastPathComponent];
//                    [self appendLog:[NSString stringWithFormat:@"保存的文件路径: %@", filePAth]];
//                    
//                    NSData *data = [NSData dataWithContentsOfFile:path];
//                    BOOL success = [data writeToFile:filePAth atomically:true];
//                    if (success) {
//                        [self appendLog:[NSString stringWithFormat:@"保存成功%@",path]];
//                    } else {
//                        [self appendLog:[NSString stringWithFormat:@"保存失败%@",path]];
//                    }
                    [self moveFile:path toOutputDir:dirUrl];
                }
                
            }
        } else {
            NSLog(@"User cancelled the operation.");
        }
    }];
}


- (void)appendLog:(NSString *)logcat {
    [self.logcats addObject:logcat ?: @""];
    self.textView.string = [self.logcats componentsJoinedByString:@"\n\n"];
}

- (void)clickAddFile {

    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:true];
    [openPanel setCanChooseDirectories:false];
    [openPanel setAllowsMultipleSelection:true];
    openPanel.allowedContentTypes = @[UTTypeImage];
    
    if ([openPanel runModal] == NSModalResponseOK) {
        NSArray<NSURL *> *urls = [openPanel URLs];
        for (NSURL *url in urls) {
//            [self appendLog:url.path];
            // 写入到沙盒中
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
//            [self appendLog:documentsDirectory];
            
            NSString *name = [url.path lastPathComponent];
            NSData *data = [NSData dataWithContentsOfURL:url];
            NSString *writePath = [documentsDirectory stringByAppendingPathComponent:name];
//            [self appendLog:writePath];
            BOOL ret = [data writeToFile:[documentsDirectory stringByAppendingPathComponent:name] atomically:true];
            [self appendLog:[NSString stringWithFormat:@"%@%@",name, ret ? @"写入成功" : @"写入失败"]];
            if (ret) [self.needTransFilePaths addObject:writePath];
        }
    }
    
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
