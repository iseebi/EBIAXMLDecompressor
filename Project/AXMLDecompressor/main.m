//
//  main.m
//  AXMLDecompressor
//
//  Created by Nobuhiro Ito on 2017/09/24.
//  Copyright © 2017年 Nobuhiro Ito. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EBIAXMLDecompressor/EBIAXMLDecompressor.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if (argc < 2) {
            fprintf(stderr, "usage: AXMLDecompressor [file]");
            exit(1);
        }
        NSString *path = [NSString stringWithUTF8String:argv[1]];
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            fprintf(stderr, "file not found");
            exit(1);
        }
        NSData *data = [NSData dataWithContentsOfFile:path];
        NSString *result = [EBIAXMLDecompressor decompressFromData:data];
        printf("%s", result.UTF8String);
    }
    return 0;
}
