//
//  ViewController.m
//  AudioTrim
//
//  Created by wos on 12/07/17.
//  Copyright © 2017 Ravi. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>


@interface ViewController ()
{
    __weak IBOutlet UILabel *lblStatus;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)btnAudioTrim:(id)sender
{
    [self exportAsset:[NSURL fileURLWithPath:@"AUDIO_FILE_PATH"]];
}

- (BOOL)exportAsset:(NSURL *)audioFileInput {
    
    float vocalStartMarker = 0.0f;
    float vocalEndMarker = 5.0f; //Audio cut time set manually.
    
    NSURL *audioFileOutput;
    NSString *docsDirs;
    NSArray *dirPath;
    dirPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDirs = [dirPath objectAtIndex:0];
    NSString *destinationURLs = [docsDirs stringByAppendingPathComponent:@"trim.m4a"];
    audioFileOutput = [NSURL fileURLWithPath:destinationURLs];
    
    if (!audioFileInput || !audioFileOutput)
    {
        return NO;
    }
    [[NSFileManager defaultManager] removeItemAtURL:audioFileOutput error:NULL];
    AVAsset *asset = [AVURLAsset URLAssetWithURL:audioFileInput options:nil];
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:asset presetName:AVAssetExportPresetAppleM4A];
    if (exportSession == nil)
    {
        return NO;
    }
    CMTime startTime = CMTimeMake((int)(floor(vocalStartMarker * 100)), 100);
    CMTime stopTime = CMTimeMake((int)(ceil(vocalEndMarker * 100)), 100);
    CMTimeRange exportTimeRange = CMTimeRangeFromTimeToTime(startTime, stopTime);
    exportSession.outputURL = audioFileOutput;
    exportSession.outputFileType = AVFileTypeAppleM4A;
    exportSession.timeRange = exportTimeRange;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^
     {
         if (AVAssetExportSessionStatusCompleted == exportSession.status)
         {
             // It worked!
             NSLog(@"DONE TRIMMING.....");
             NSLog(@"ouput audio trim file %@",audioFileOutput);
             lblStatus.text = @"DONE TRIMMING.....";
         }
         else if (AVAssetExportSessionStatusFailed == exportSession.status)
         {
             // It failed...
             NSLog(@"FAILED TRIMMING.....");
             lblStatus.text = @"FAILED TRIMMING.....";
         }
     }];
    return YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
