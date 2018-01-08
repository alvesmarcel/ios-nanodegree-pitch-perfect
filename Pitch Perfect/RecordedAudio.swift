//
//  RecordedAudio.swift
//  UdacityPitchPerfect
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
