// Copyright (c) 2012 Alex Wiltschko
// 
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
// 
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.


#import "AppDelegate.h"
#import <AudioUnit/AudioUnit.h>

@implementation AppDelegate

float *volumes;

- (void)dealloc
{
    if (_ringBuffer){
        delete _ringBuffer;
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
    self.audioManager = [Novocaine audioManager];
    volumes = (float *)malloc(sizeof(float) * 2);
    volumes[0] = _sliderLeft.floatValue/100.0f;
    volumes[1] = _sliderRight.floatValue/100.0f;
    
//    self.ringBuffer = new RingBuffer(32768, 2);
        self.ringBuffer = new RingBuffer(2048, 2);
    
    __weak AppDelegate * wself = self;

// A simple delay that's hard to express without ring buffers
// ========================================

    [self.audioManager setInputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels) {
        NSData *e = [self encodeFloat:data];
        float *d = [self decodeFloat:e];
        
//        wself.ringBuffer->AddNewInterleavedFloatData(data, numFrames, numChannels);
        wself.ringBuffer->AddNewInterleavedFloatData(d, numFrames, numChannels);
    }];
    
    //int echoDelay = 11025;
  //  float *holdingBuffer = (float *)calloc(16384, sizeof(float));
    [self.audioManager setOutputBlock:^(float *outData, UInt32 numFrames, UInt32 numChannels) {
        
        // Grab the play-through audio
        wself.ringBuffer->FetchInterleavedData(outData, numFrames, numChannels);
//        float volume = 0.8;
//        vDSP_vsmul(outData, 1, &volume, outData, 1, numFrames*numChannels);
        
        
        
//        volumes[0] = 0.8;
//        volumes[1] = 0.8;
//        float volumeLeft = 0.8;
//        float volumeRight = 0.8;
        
        for(int i = 0; i < numFrames; i++){
            int l = i*numChannels;
            for (int j = 0; j < numChannels; j++) {
                outData[l+j] = outData[l+j] * volumes[j];
            }
            
//            if(i%2 == 0){
//                //vDSP_vsmul(&outData[i], 1, &volumeLeft, &outData[i], 1, 1);
//                outData[i] = outData[i] * volumeLeft;
//            } else {
//                //vDSP_vsmul(&outData[i], 1, &volumeRight, &outData[i], 1, 1);
//                 outData[i] = outData[i] * volumeRight;
//            }
        }
        
//        // Seek back, and grab some delayed audio
//        wself.ringBuffer->SeekReadHeadPosition(-echoDelay-numFrames);
//        wself.ringBuffer->FetchInterleavedData(holdingBuffer, numFrames, numChannels);
//        wself.ringBuffer->SeekReadHeadPosition(echoDelay);
//        
//        volume = 0.5;
//        vDSP_vsmul(holdingBuffer, 1, &volume, holdingBuffer, 1, numFrames*numChannels);
//        vDSP_vadd(holdingBuffer, 1, outData, 1, outData, 1, numFrames*numChannels);
    }];
    
    
    // AUDIO FILE READING COOL!
    // ========================================    

    
//    NSURL *inputFileURL = [[NSBundle mainBundle] URLForResource:@"TLC" withExtension:@"mp3"];
//    
//    self.fileReader = [[AudioFileReader alloc]
//                       initWithAudioFileURL:inputFileURL 
//                       samplingRate:self.audioManager.samplingRate
//                       numChannels:self.audioManager.numOutputChannels];
//
//    self.fileReader.currentTime = 5;
//    [self.fileReader play];
//    
//    
//    __block int counter = 0;
//    
//    
//    [self.audioManager setOutputBlock:^(float *data, UInt32 numFrames, UInt32 numChannels)
//     {
//         [wself.fileReader retrieveFreshAudio:data numFrames:numFrames numChannels:numChannels];
//         counter++;
//         if (counter % 80 == 0)
//             NSLog(@"Time: %f", wself.fileReader.currentTime);
//         
//     }];
    
    
    // AUDIO FILE WRITING YEAH!
    // ========================================    
//    NSArray *pathComponents = [NSArray arrayWithObjects:
//                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject], 
//                               @"My Recording.m4a", 
//                               nil];
//    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
//
//    self.fileWriter = [[AudioFileWriter alloc]
//                       initWithAudioFileURL:outputFileURL 
//                       samplingRate:self.audioManager.samplingRate
//                       numChannels:self.audioManager.numInputChannels];
//    
//    
//    __block int counter = 0;
//    self.audioManager.inputBlock = ^(float *data, UInt32 numFrames, UInt32 numChannels) {
//        [wself.fileWriter writeNewAudio:data numFrames:numFrames numChannels:numChannels];
//        counter += 1;
//        if (counter > 10 * wself.audioManager.samplingRate / numChannels) { // 10 seconds of recording
//            wself.audioManager.inputBlock = nil;
//        }
//    };

    // START IT UP YO
    [self.audioManager play];
}

- (NSData *)encodeFloat:(float *)abl {
    NSMutableData *data = [NSMutableData data];
    [data appendBytes:&abl length:sizeof(abl)];
    return data;
}

- (float *)decodeFloat:(NSData *)data {
    float *d = (float *)malloc(sizeof(float) * 2);
    [data getBytes:&d length:sizeof(data)];
    return d;
}

- (IBAction)sliderRightValueChanged:(id)sender {
    volumes[1] = _sliderRight.floatValue/100.0f;

}

- (IBAction)sliderLeftValueChanged:(id)sender {
    volumes[0] = _sliderLeft.floatValue/100.0f;
}
@end
