//
//  RecordedAudio.swift
//  Pitch Perfect
//
//  Created by Marcel Oliveira Alves on 3/27/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//
//  - Stores the URL for the audioFile recorded and the audio title

import Foundation

class RecordedAudio: NSObject{
    var filePathUrl: NSURL!
    var title: String!
    
    init(filePathUrl: NSURL, title: String) {
        self.filePathUrl = filePathUrl
        self.title = title
    }
}