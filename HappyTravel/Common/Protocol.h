//
//  Protocol.h
//  HappyTravel
//
//  Created by 陈奕涛 on 16/8/17.
//  Copyright © 2016年 陈奕涛. All rights reserved.
//

#ifndef Protocol_h
#define Protocol_h

#pragma pack(1)
struct TestHead {
    
    short packageLen;
    
    char isZipEncrypt;
    
    char type;

    short signature;
    
    short opcode;
    
    short dataLen;
    
    unsigned int timestamp;
    
    long long sessionID;
    
    int reserved;
    
} TestHead;
#pragma pack()



#endif /* Protocol_h */
