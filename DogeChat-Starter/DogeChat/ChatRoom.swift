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
        
        inputStream.delegate = self
    }
    
    func joinChat(username: String){
        
        let data = "iam: \(username)".data(using: .ascii)!
        
        self.username = username
        
        _ = data.withUnsafeBytes { outputStream.write($0, maxLength: data.count)}
        
    }

}

extension ChatRoom: StreamDelegate {
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        
        switch eventCode {
        case Stream.Event.hasBytesAvailable:
            print("New message received")
            readAvailableBytes(stream: aStream as! InputStream)
        case Stream.Event.endEncountered:
            print("New message received")
        case Stream.Event.errorOccurred:
            print("Error has occured")
        case Stream.Event.hasSpaceAvailable:
            print("Has space availiable")
        default:
            print("Some other event")
        }
        
    }
    
    private func readAvailableBytes(stream: InputStream) {
        
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: maxReadLength)
        
        while stream.hasBytesAvailable {
            
            let numberOfBytesRead = inputStream.read(buffer, maxLength: maxReadLength)
            
            if numberOfBytesRead < 0 {
                if let _ = stream.streamError {
                    break
                }
            }
        }
    }
    
}
