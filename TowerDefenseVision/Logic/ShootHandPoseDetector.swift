//
//  HandFistPoseUtilities.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 23/06/26.
//

import ARKit
import ILSHandTracking

enum ShootHandPoseDetector {
    static func detect(handSkeleton: HandSkeleton) -> Bool{
        let isThumbCurl = ILHandPoseUtilities.isThumbCurl(skeleton: handSkeleton)
        let isIndexCurl = ILHandPoseUtilities.isFingerCurl(skeleton: handSkeleton, tip: .indexFingerTip, knuckle: .indexFingerKnuckle)
        let isMiddleCurl = ILHandPoseUtilities.isFingerCurl(skeleton: handSkeleton, tip: .middleFingerTip, knuckle: .middleFingerKnuckle)
        let isRingCurl = ILHandPoseUtilities.isFingerCurl(skeleton: handSkeleton, tip: .ringFingerTip, knuckle: .ringFingerKnuckle)
        let isLittleCurl = ILHandPoseUtilities.isFingerCurl(skeleton: handSkeleton, tip: .littleFingerTip, knuckle: .littleFingerKnuckle)
        
        return !isThumbCurl && !isIndexCurl && isMiddleCurl && isRingCurl && isLittleCurl
    }
}
