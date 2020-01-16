//
//  AppDelegate.m
//  FileRename
//
//  Created by 马雨辰 on 2020/1/7.
//  Copyright © 2020 马雨辰. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@property(nonatomic,strong)MainViewController *mainVC;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application

    [self.window setTitle:@"文件名转换"];
    
    self.mainVC = [[MainViewController alloc]initWithNibName:@"MainViewController" bundle:nil];
    
    [self.window.contentView addSubview:self.mainVC.view];
    
    self.mainVC.view.frame = self.window.contentView.bounds;
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
