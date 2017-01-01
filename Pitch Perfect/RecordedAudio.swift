//
//  RecordedAudio.swift
//  UdacityPitchPerfect
//
//  Created by Marcel Oliveira Alves on 3/27/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//
//  - Stores the URL for the audioFile recorded and the audio title
//  TODO: Make child of NSManagedObject to use with CoreData

import Foundation

class RecordedAudio {
    var filePathUrl: URL!
    var title: String!
    
    init(filePathUrl: URL, title: String) {
        self.filePathUrl = filePathUrl
        self.title = title
    }
}
