# EBIAXMLDecompressor

decompress zipaligned XML in Android APK

## How to use

```
NSData *data = [NSData dataWithContentsOfFile:@"/path/to/AndroidManifest.xml"];
NSString *result = [EBIAXMLDecompressor decompressFromData:data];
```
