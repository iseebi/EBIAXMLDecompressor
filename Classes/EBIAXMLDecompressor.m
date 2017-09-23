//
//  EBIAXMLDecompressor.m
//  decompressXML
//
//  Created by Nobuhiro Ito on 2017/09/23.
//  Copyright © 2017年 Nobuhiro Ito. All rights reserved.
//

#import "EBIAXMLDecompressor.h"

static int EBIAXMLDecompressor_endDocTag = 0x00100101;
static int EBIAXMLDecompressor_startTag =  0x00100102;
static int EBIAXMLDecompressor_endTag =    0x00100103;

#define LEW(xml, off) [self lewForByte:(unsigned char*)[xml bytes] offset:off]
#define LEW_R(xml, off) [self lewForByte:xml offset:off]
#define compXmlString(xml, sitOff, stOff, strInd) [self decompressStringFromXMLByte:(unsigned char*)[xml bytes] sitOffset:sitOff stOffset:stOff stringIndex:strInd]
#define endDocTag EBIAXMLDecompressor_endDocTag
#define startTag EBIAXMLDecompressor_startTag
#define endTag EBIAXMLDecompressor_endTag


@implementation EBIAXMLDecompressor

+ (int) lewForByte:(unsigned char*)arr offset:(int)off {
    return (arr[off+3]<<24&0xff000000) | (arr[off+2]<<16&0xff0000) | (arr[off+1]<<8&0xff00) | (arr[off]&0xFF);
}

+ (NSString *) decompressStringFromXMLByte:(unsigned char*)xml sitOffset:(int)sitOff stOffset:(int)stOff stringIndex:(int)strInd {
    if (strInd < 0) return nil;
    int strOff = stOff + LEW_R(xml, sitOff+strInd*4);
    return [self decompressStringFromXMLByte:xml at:strOff];
}

+ (NSString *) decompressStringFromXMLByte:(unsigned char*)arr at:(int) strOff {
    int strLen = (arr[strOff+1]<<8&0xff00) | (arr[strOff]&0xff);
    NSMutableData *charsData = [[NSMutableData alloc] initWithLength:strLen];
    unsigned char *bytes =  (unsigned char *)charsData.bytes;
    for (int ii=0; ii<strLen; ii++) {
        bytes[ii] = arr[strOff+2+ii*2];
    }
    return [[NSString alloc] initWithData:charsData encoding:NSUTF8StringEncoding];
}


+ (NSString *)decompressFromData:(NSData *)xml {
    int numbStrings = LEW(xml, 4*4);
    // StringIndexTable starts at offset 24x, an array of 32 bit LE offsets
    // of the length/string data in the StringTable.
    int sitOff = 0x24;  // Offset of start of StringIndexTable
    
    // StringTable, each string is represented with a 16 bit little endian
    // character count, followed by that number of 16 bit (LE) (Unicode) chars.
    int stOff = sitOff + numbStrings*4;  // StringTable follows StrIndexTable
    
    // XMLTags, The XML tag tree starts after some unknown content after the
    // StringTable.  There is some unknown data after the StringTable, scan
    // forward from this point to the flag for the start of an XML start tag.
    int xmlTagOff = LEW(xml, 3*4);  // Start from the offset in the 3rd word.

    // Scan forward until we find the bytes: 0x02011000(x00100102 in normal int)
    for (int ii=xmlTagOff; ii<xml.length-4; ii+=4) {
        if (LEW(xml, ii) == startTag) {
            xmlTagOff = ii;  break;
        }
    } // end of hack, scanning for start of first start tag

    NSMutableString* buffer = [NSMutableString string];
    NSString *attrValue;
    NSString *attrName;
    int off = xmlTagOff;

    while (off < xml.length) {
        int tag0 = LEW(xml, off);
        int nameSi = LEW(xml, off+5*4);
        if (tag0 == startTag) { // XML START TAG
            int numbAttrs = LEW(xml, off+7*4);  // Number of Attributes to follow
            off += 9*4;  // Skip over 6+3 words of startTag data
            NSString *name = compXmlString(xml, sitOff, stOff, nameSi);
            NSMutableString* attrBuffer = [NSMutableString string];
            // Look for the Attributes
            for (int ii=0; ii<numbAttrs; ii++) {
                int attrNameSi = LEW(xml, off+1*4);  // AttrName String Index
                int attrValueSi = LEW(xml, off+2*4); // AttrValue Str Ind, or FFFFFFFF
                int attrResId = LEW(xml, off+4*4);  // AttrValue ResourceId or dup AttrValue StrInd
                off += 5*4;  // Skip over the 5 words of an attribute
                
                attrName = compXmlString(xml, sitOff, stOff, attrNameSi);
                attrValue = attrValueSi!=-1
                    ? compXmlString(xml, sitOff, stOff, attrValueSi)
                    : [NSString stringWithFormat:@"RES:0x%x", attrResId];
                [attrBuffer appendFormat:@" %@=\"%@\"", attrName, attrValue];
            }
            [buffer appendFormat:@"<%@%@>", name, attrBuffer];
            
        } else if (tag0 == endTag) { // XML END TAG
            off += 6*4;  // Skip over 6 words of endTag data
            NSString *name = compXmlString(xml, sitOff, stOff, nameSi);
            [buffer appendFormat:@"</%@>", name];
        } else if (tag0 == endDocTag) {  // END OF XML DOC TAG
            break;
        } else {
            break;
        }
    } // end of while loop scanning tags and attributes of XML tree
    
    return buffer;
}

@end

