//
//  Hand.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 23/06/26.
//

import ARKit.hand_skeleton

struct Hand {
    static let joints: [(HandSkeleton.JointName, Finger, Bone)] = [
        // Define the thumb bones.
        (.thumbKnuckle, .thumb, .knuckle),
        (.thumbIntermediateBase, .thumb, .intermediateBase),
        (.thumbIntermediateTip, .thumb, .intermediateTip),
        (.thumbTip, .thumb, .tip),

        // Define the index-finger bones.
        (.indexFingerMetacarpal, .index, .metacarpal),
        (.indexFingerKnuckle, .index, .knuckle),
        (.indexFingerIntermediateBase, .index, .intermediateBase),
        (.indexFingerIntermediateTip, .index, .intermediateTip),
        (.indexFingerTip, .index, .tip),

        // Define the middle-finger bones.
        (.middleFingerMetacarpal, .middle, .metacarpal),
        (.middleFingerKnuckle, .middle, .knuckle),
        (.middleFingerIntermediateBase, .middle, .intermediateBase),
        (.middleFingerIntermediateTip, .middle, .intermediateTip),
        (.middleFingerTip, .middle, .tip),

        // Define the ring-finger bones.
        (.ringFingerMetacarpal, .ring, .metacarpal),
        (.ringFingerKnuckle, .ring, .knuckle),
        (.ringFingerIntermediateBase, .ring, .intermediateBase),
        (.ringFingerIntermediateTip, .ring, .intermediateBase),
        (.ringFingerTip, .ring, .tip),

        // Define the little-finger bones.
        (.littleFingerMetacarpal, .little, .metacarpal),
        (.littleFingerKnuckle, .little, .knuckle),
        (.littleFingerIntermediateBase, .little, .intermediateBase),
        (.littleFingerIntermediateTip, .little, .intermediateTip),
        (.littleFingerTip, .little, .tip),

        // Define wrist and arm bones.
        (.forearmWrist, .forearm, .wrist),
        (.forearmArm, .forearm, .arm)
    ]
}

struct HandBone{
    static let jointMapping: [HandSkeleton.JointName : String] = [
        .wrist: "handWrist",

        .thumbKnuckle: "handThumbKnuckle",
        .thumbIntermediateBase: "handThumbIntermediateBase",
        .thumbIntermediateTip: "handThumbIntermediateTip",
        .thumbTip: "handThumbTip",
        
        .indexFingerMetacarpal: "handIndexFingerMetacarpal",
        .indexFingerKnuckle: "handIndexFingerKnuckle",
        .indexFingerIntermediateBase: "handIndexFingerIntermediateBase",
        .indexFingerIntermediateTip: "handIndexFingerIntermediateTip",
        
        .middleFingerMetacarpal: "handMiddleFingerMetacarpal",
        .middleFingerKnuckle: "handMiddleFingerKnuckle",
        .middleFingerIntermediateBase: "handMiddleFingerIntermediateBase",
        .middleFingerIntermediateTip: "handMiddleFingerIntermediateTip",
        
        .ringFingerMetacarpal: "handRingFingerMetacarpal",
        .ringFingerKnuckle: "handRingFingerKnuckle",
        .ringFingerIntermediateBase: "handRingFingerIntermediateBase",
        .ringFingerIntermediateTip: "handRingFingerIntermediateTip",
        
        .littleFingerMetacarpal: "handLittleFingerMetacarpal",
        .littleFingerKnuckle: "handLittleFingerKnuckle",
        .littleFingerIntermediateBase: "handLittleFingerIntermediateBase",
        .littleFingerIntermediateTip: "handLittleFingerIntermediateTip"
        
    ]
}
