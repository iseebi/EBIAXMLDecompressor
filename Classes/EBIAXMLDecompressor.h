//
//  EBIAXMLDecompressor.h
//  decompressXML
//
//  Created by Nobuhiro Ito on 2017/09/23.
//  Copyright © 2017年 Nobuhiro Ito. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EBIAXMLDecompressor : NSObject
+ (NSString *)decompressFromData:(NSData *)xml;
@end
