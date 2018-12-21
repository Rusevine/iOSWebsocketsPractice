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

}
