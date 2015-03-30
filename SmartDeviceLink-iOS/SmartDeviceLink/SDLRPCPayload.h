//  SDLRPCPayload.h
//


@import Foundation;

@interface SDLRPCPayload : NSObject

@property (assign) Byte rpcType;
@property (assign) UInt32 functionID;
@property (assign) UInt32 correlationID;
@property (strong) NSData *jsonData;
@property (strong) NSData *binaryData;

- (NSData *)data;
+ (id)rpcPayloadWithData:(NSData *)data;

@end