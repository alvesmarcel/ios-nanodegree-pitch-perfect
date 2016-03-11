//
//  Constants.swift
//  Pitch Perfect
//
//  Created by Marcel Oliveira Alves on 4/3/15.
//  Copyright (c) 2015 Marcel Oliveira Alves. All rights reserved.
//
//  - Useful constants used in the code; avoid "magic numbers"

import Foundation

struct Constants {
    struct FadeTimes {
        static let tapToRecordLabel = 4.0
        static let recordingLabel = 0.5
    }
    
    struct ButtonTags {
        static let slow = 1
        static let fast = 2
        static let chipmunk = 3
        static let darthVader = 4
        static let delay = 5
    }
    
    struct AudioParams {
        static let slow = Float(0.5)
        static let fast = Float(1.5)
        static let chipmunk = Float(1000)
        static let darthVader = Float(-1000)
        static let delay = Float(0.125)
    }
    
    
}