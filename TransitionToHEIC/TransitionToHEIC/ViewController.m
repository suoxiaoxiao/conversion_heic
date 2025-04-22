//
//  ViewController.m
//  TransitionToHEIC
//
//  Created by 索晓晓 on 2024/9/14.
//

#import "ViewController.h"
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>


@protocol NSDragScrollViewDelegate <NSObject>

- (void)dragEndFileUrls:(NSArray *)urls;

@end

@interface NSDragScrollView : NSScrollView<NSDraggingDestination>

@property (nonatomic, weak) id <NSDragScrollViewDelegate> TT_dragDelegate;

@end

@implementation NSDragScrollView

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self registerForDraggedTypes:@[NSPasteboardTypeFileURL]];
    }
    return self;
}


- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
    if ([sender draggingSourceOperationMask] & NSDragOperationCopy) {
        // 检查拖放的内容是否是可接受的类型
        if ([sender.draggingPasteboard.types containsObject:NSPasteboardTypeFileURL]) {
            return NSDragOperationCopy;
        }
    }
    return NSDragOperationNone;
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender {
    return YES;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
    NSPasteboard *pasteboard = [sender draggingPasteboard];
    if ([[pasteboard types] containsObject:NSPasteboardTypeFileURL]) {
        NSArray *filenames = [pasteboard propertyListForType:NSFilenamesPboardType];
        // 处理拖放的文件 URL
        NSMutableArray *array = [NSMutableArray array];
        for (NSString *filePath in filenames) {
            NSLog(@"Dragged file URL: %@", [NSURL fileURLWithPath:filePath]);
            [array addObject:[NSURL fileURLWithPath:filePath]];
        }
        if (self.TT_dragDelegate && [self.TT_dragDelegate respondsToSelector:@selector(dragEndFileUrls:)]) {
            [self.TT_dragDelegate dragEndFileUrls:array];
        }
        return YES;
    }
    return NO;
}

@end


@interface ViewController () <NSDragScrollViewDelegate>

@property (nonatomic, strong) NSButton *addBtn;

@property (nonatomic, strong) NSButton *startTaskBtn;

@property (nonatomic, strong) NSButton *heicBtn;

@property (nonatomic, strong) NSButton *jpegBtn;

@property (nonatomic, strong) NSButton *jpgBtn;

@property (nonatomic, strong) NSMutableArray *needTransFilePaths;
@property (nonatomic, strong) NSMutableArray *logcats;

@property (nonatomic, strong) NSTextView *textView;
@property (nonatomic, strong) NSDragScrollView *scrollView;

@property (nonatomic, strong) NSString *formatTarget;

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
    
    self.heicBtn =  [NSButton buttonWithTitle:@"HEIC格式" target:self action:@selector(transfromHeicTarget)];
    
    [self.view addSubview:self.heicBtn];
    
    [self.heicBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
    // 添加约束
    [NSLayoutConstraint activateConstraints:@[
        // textView 左边距
        [self.heicBtn.leadingAnchor constraintEqualToAnchor:self.startTaskBtn.trailingAnchor constant:15],
        // textView 顶部距离
        [self.heicBtn.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:15],
//        [self.heicBtn.widthAnchor constraintEqualToConstant:100],
        // textView 高度固定
        [self.heicBtn.heightAnchor constraintEqualToConstant:30]
    ]];
    
    self.jpegBtn =  [NSButton buttonWithTitle:@"JPEG格式" target:self action:@selector(transfromJpegTarget)];
    
    [self.view addSubview:self.jpegBtn];
    
    [self.jpegBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
    // 添加约束
    [NSLayoutConstraint activateConstraints:@[
        // textView 左边距
        [self.jpegBtn.leadingAnchor constraintEqualToAnchor:self.heicBtn.trailingAnchor constant:15],
        // textView 顶部距离
        [self.jpegBtn.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:15],
//        [self.jpegBtn.widthAnchor constraintEqualToConstant:100],
        // textView 高度固定
        [self.jpegBtn.heightAnchor constraintEqualToConstant:30]
    ]];
    
    
    self.jpgBtn =  [NSButton buttonWithTitle:@"JPG格式" target:self action:@selector(transfromJpgTarget)];
    
    [self.view addSubview:self.jpgBtn];
    
    [self.jpgBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
    // 添加约束
    [NSLayoutConstraint activateConstraints:@[
        // textView 左边距
        [self.jpgBtn.leadingAnchor constraintEqualToAnchor:self.jpegBtn.trailingAnchor constant:15],
        // textView 顶部距离
        [self.jpgBtn.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:15],
//        [self.jpegBtn.widthAnchor constraintEqualToConstant:100],
        // textView 高度固定
        [self.jpgBtn.heightAnchor constraintEqualToConstant:30]
    ]];
    
    self.scrollView = [[NSDragScrollView alloc] init];
    self.scrollView.TT_dragDelegate = self;
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
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-15],
        // textView 顶部距离
        [self.scrollView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:60],
        // textView 高度固定
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-15]
    ]];
        
    self.logcats = [NSMutableArray array];
    
    [self transfromHeicTarget];
    // Do any additional setup after loading the view.
}

- (void)transfromHeicTarget {
    self.formatTarget = @"heic";
    
    [self.heicBtn setTitle:@"HEIC格式(选中)"];
    [self.jpegBtn setTitle:@"JPEG格式"];
    [self.jpgBtn setTitle:@"JPG格式"];
}

- (void)transfromJpegTarget {
    self.formatTarget = @"jpeg";
    
    [self.heicBtn setTitle:@"HEIC格式"];
    [self.jpegBtn setTitle:@"JPEG格式(选中)"];
    [self.jpgBtn setTitle:@"JPG格式"];
}

- (void)transfromJpgTarget {
    self.formatTarget = @"jpg";
    
    [self.heicBtn setTitle:@"HEIC格式"];
    [self.jpegBtn setTitle:@"JPEG格式"];
    [self.jpgBtn setTitle:@"JPG格式(选中)"];
}

- (void)requestOutputFilePathPermission {
    
}
//

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
        NSString *outputName = [[str lastPathComponent] stringByReplacingOccurrencesOfString:[str pathExtension] withString:self.formatTarget];
        // 定义要执行的命令   sips -s format heic personal_vip_yoga_logo.png -o personal_vip_yoga_logo.heic
        NSString *command = [NSString stringWithFormat:@"%@ %@ %@ -o %@",@"sips -s format",self.formatTarget,[path stringByAppendingPathComponent:name],[path stringByAppendingPathComponent:outputName]];
        
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
        
        [task waitUntilExit];
        
       // 校验文件是否存在
        if ([[NSFileManager defaultManager] fileExistsAtPath:[path stringByAppendingPathComponent:outputName]]) {
            
            NSImage *image = [[NSImage alloc] initWithContentsOfFile:[path stringByAppendingPathComponent:outputName]];
            
            if (![self verficationImageAlphaWhiteOfData:image]) {
                
                [self appendLog:[NSString stringWithFormat:@"转化成功%@",name]];
                [heicResult addObject:[path stringByAppendingPathComponent:outputName]];
                
            } else {
                [self appendLog:[NSString stringWithFormat:@"转化失败 转化HEIC图片懈怠了白色透明像素:%@",name]];
            }
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


CGImageRef getCGImageFromNSImage(NSImage *nsImage) {
    NSRect rect = NSMakeRect(0, 0, nsImage.size.width, nsImage.size.height);
    CGImageRef cgImage = [nsImage CGImageForProposedRect:&rect context:nil hints:nil];
    return cgImage;
}

/// 获取图片信息和像素
/// - Parameters:
-(BOOL)verficationImageAlphaWhiteOfData:(NSImage *)image
{
    
    // 获取CGImageRef
    CGImageRef cgimage = getCGImageFromNSImage(image);
//
    size_t width  = CGImageGetWidth(cgimage);
    size_t height = CGImageGetHeight(cgimage);
    size_t bpr = CGImageGetBytesPerRow(cgimage);
    size_t bpp = CGImageGetBitsPerPixel(cgimage);
    size_t bpc = CGImageGetBitsPerComponent(cgimage);
    size_t bytes_per_pixel = bpp / bpc;
//
//    // 获取位图数据
    CGDataProviderRef provider = CGImageGetDataProvider(cgimage);
    NSData* data = (__bridge NSData *)CGDataProviderCopyData(provider);
    const uint8_t* bytes = [data bytes];

//    NSLog(@"Pixel Data: %@\n",name);
    for(size_t row = 0; row < height; row++)
    {
        for(size_t col = 0; col < width; col++)
        {
            const uint8_t* pixel =
                &bytes[row * bpr + col * bytes_per_pixel];
            
//            printf("(");
            NSMutableString *mustr = [[NSMutableString alloc] init];
            for(size_t x = 0; x < bytes_per_pixel; x++)
            {
//                printf("%.2d", pixel[x]);
                [mustr appendFormat:@"%.2d", pixel[x]];
                if( x < bytes_per_pixel - 1 ) {
//                    printf(",");
                    [mustr appendString:@","];
                }
            }
            if ([mustr containsString:@"255,255,255"]) {
                NSString *alphaLast = [mustr componentsSeparatedByString:@","].lastObject;
                if ([alphaLast floatValue] > 0 && [alphaLast floatValue] < 255) {
//                    NSLog(@"%@",mustr);
                    return true;
                }
            }
//            printf(")");
//            if( col < width - 1 )
//                printf(", ");
        }
//        printf("\n");
    }
    return false;
}

- (void)appendLog:(NSString *)logcat {
    [self.logcats addObject:logcat ?: @""];
    self.textView.string = [self.logcats componentsJoinedByString:@"\n\n"];
}

- (void)dragEndFileUrls:(NSArray *)urls {
    [self copyFileToTempWithUrls:urls];
}

- (void)clickAddFile {

    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:true];
    [openPanel setCanChooseDirectories:false];
    [openPanel setAllowsMultipleSelection:true];
    openPanel.allowedContentTypes = @[UTTypeImage];
    
    if ([openPanel runModal] == NSModalResponseOK) {
        NSArray<NSURL *> *urls = [openPanel URLs];
//        for (NSURL *url in urls) {
//            // 写入到沙盒中
//            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//            NSString *documentsDirectory = [paths objectAtIndex:0];
//            
//            NSString *name = [url.path lastPathComponent];
//            NSData *data = [NSData dataWithContentsOfURL:url];
//            NSString *writePath = [documentsDirectory stringByAppendingPathComponent:name];
//            BOOL ret = [data writeToFile:[documentsDirectory stringByAppendingPathComponent:name] atomically:true];
//            [self appendLog:[NSString stringWithFormat:@"%@%@",name, ret ? @"写入成功" : @"写入失败"]];
//            if (ret) [self.needTransFilePaths addObject:writePath];
//        }
        [self copyFileToTempWithUrls:urls];
    }
    
}

- (void)copyFileToTempWithUrls:(NSArray <NSURL *>*)urls {
//    NSArray<NSURL *> *urls = files;
    for (NSURL *url in urls) {
        // 写入到沙盒中
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSString *name = [url.path lastPathComponent];
        NSData *data = [NSData dataWithContentsOfURL:url];
        NSString *writePath = [documentsDirectory stringByAppendingPathComponent:name];
        BOOL ret = [data writeToFile:[documentsDirectory stringByAppendingPathComponent:name] atomically:true];
        [self appendLog:[NSString stringWithFormat:@"%@%@",name, ret ? @"写入成功" : @"写入失败"]];
        if (ret) [self.needTransFilePaths addObject:writePath];
    }
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end



//- (void)test1 {
//    // 定义要执行的命令   sips -s format heic personal_vip_yoga_logo.png -o personal_vip_yoga_logo.heic
////        NSString *command = [NSString stringWithFormat:@"%@ %@ -o %@",@"sips -s format heic",[path stringByAppendingPathComponent:name],[path stringByAppendingPathComponent:outputName]];
////
////        [self appendLog:command];
//
//    NSString *command = @"sudo touch /Users/suoxiaoxiao/Documents/demo.txt";
//
//    // 创建 NSTask 实例
//    NSTask *task = [[NSTask alloc] init];
//    [task setLaunchPath:@"/bin/sh"];
//
//    // 设置命令参数
//    NSArray *arguments = @[@"-c", command];
//    [task setArguments:arguments];
//
//    // 创建管道以捕获输出
//    NSPipe *pipe = [NSPipe pipe];
//    [task setStandardOutput:pipe];
//
//    // 启动任务
//    NSError *error = nil;
//    [task launchAndReturnError:&error];
//
//    // 读取输出
//    NSData *data = [[pipe fileHandleForReading] readDataToEndOfFile];
//    NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//
//    // 显示输出
//    NSLog(@"Command output:\n%@", output);
//    [self appendLog:@"***************************Terminal***************************"];
//    [self appendLog:[NSString stringWithFormat:@"Command output:\n%@",output]];
//    [self appendLog:@"***************************Terminal***************************"];
//}
