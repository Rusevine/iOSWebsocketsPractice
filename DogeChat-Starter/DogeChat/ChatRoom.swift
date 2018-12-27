//
//  ChatRoom.swift
//  DogeChat
//
//  Created by Wiljay Flores on 2018-12-20.
//  Copyright © 2018 Luke Parham. All rights reserved.
//

import UIKit

protocol ChatRoomDelegate {
    func receivedMessage(message: Message)

}

class ChatRoom: NSObject {
    
    var inputStream: InputStream!
    var outputStream: OutputStream!
    
    var delegate: ChatRoomDelegate?
    
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
        
        let data = "iam:\(username)".data(using: .ascii)!
        
        self.username = username
        
        _ = data.withUnsafeBytes { outputStream.write($0, maxLength: data.count)}
        
    }
    
    func sendMessage(message: String) {
        let data = "msg:\(message)".data(using: .ascii)!
        
        _ = data.withUnsafeBytes { outputStream.write($0, maxLength: data.count) }
    }
    
    func stopChatSession() {
        inputStream.close()
        outputStream.close()
    }

}

extension ChatRoom: StreamDelegate {
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        
        switch eventCode {
        case Stream.Event.hasBytesAvailable:
            print("New message received")
            readAvailableBytes(stream: aStream as! InputStream)
        case Stream.Event.endEncountered:
            stopChatSession()
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
            
            if let message = processMessageString(buffer: buffer, length: numberOfBytesRead) {
                delegate?.receivedMessage(message: message)
            }
        }
        
    }
    
    private func processMessageString(buffer: UnsafeMutablePointer<UInt8>, length: Int) -> Message? {
        
        guard let stringArray = String(bytesNoCopy: buffer, length: length, encoding: .ascii, freeWhenDone: true)?.components(separatedBy: ":"),
            let name = stringArray.first,
            let message = stringArray.last else { return nil }
        
        let messageSender: MessageSender = (name == self.username) ? .ourself : .someoneElse
        
        return Message(message: message, messageSender: messageSender, username: name)
    }
    
}
