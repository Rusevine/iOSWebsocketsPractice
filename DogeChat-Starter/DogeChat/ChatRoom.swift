//
//  ChatRoom.swift
//  DogeChat
//
//  Created by Wiljay Flores on 2018-12-20.
//  Copyright © 2018 Luke Parham. All rights reserved.
//

import UIKit

class ChatRoom: NSObject {
    
    var inputStream: InputStream!
    var outputStream: OutputStream!
    
    var username = ""
    
    var maxReadLength = 4096



    func setupNetworkConnection() {
    
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
    
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, "localhost" as CFString, 80, &readStream, &writeStream)
        
        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()
        
        inputStream.schedule(in: .current, forMode: .commonModes)
        outputStream.schedule(in: .current, forMode: .commonModes)
        
        inputStream.open()
        outputStream.open()
    }

}
