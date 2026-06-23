//
//  HandPoseUtilites+Extension.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 22/06/26.
//

import ILSHandTracking
import ARKit

extension ILHandPoseUtilities{
    static func position(
        of joint: HandSkeleton.JointName,
        in skeleton: HandSkeleton
    ) -> SIMD3<Float> {
        let t = skeleton.joint(joint).anchorFromJointTransform
        return SIMD3<Float>(t.columns.3.x, t.columns.3.y, t.columns.3.z)
    }
    
    static func curlRatio(
        skeleton: HandSkeleton,
        tip: HandSkeleton.JointName,
        knuckle: HandSkeleton.JointName,
        wrist: HandSkeleton.JointName = .wrist
    ) -> Float {
        let tipPos = position(of: tip, in: skeleton)
        let knucklePos = position(of: knuckle, in: skeleton)
        let wristPos = position(of: wrist, in: skeleton)
        let tipDist = simd_distance(tipPos, wristPos)
        let knuckleDist = simd_distance(knucklePos, wristPos)
        guard knuckleDist > 0.001 else { return 1.0 }
        return tipDist / knuckleDist
    }
    
    static func thumbCurlRatio(skeleton: HandSkeleton) -> Float {
        let thumbTip = position(of: .thumbTip, in: skeleton)
        let palmCenter = position(of: .middleFingerKnuckle, in: skeleton)
        let wrist = position(of: .wrist, in: skeleton)
        let thumbDist = simd_distance(thumbTip, palmCenter)
        let handSize = simd_distance(wrist, palmCenter)
        guard handSize > 0.001 else { return 1.0 }
        return thumbDist / handSize
    }
    
    static func isFingerCurl(
        skeleton: HandSkeleton,
        tip: HandSkeleton.JointName,
        knuckle: HandSkeleton.JointName,
        wrist: HandSkeleton.JointName = .wrist,
        factor: Float = 1.10
    ) -> Bool {
        curlRatio(skeleton: skeleton, tip: tip, knuckle: knuckle, wrist: wrist) < factor
    }

    /// Returns `true` when the thumb is curled toward the palm.
    static func isThumbCurl(skeleton: HandSkeleton) -> Bool {
        thumbCurlRatio(skeleton: skeleton) < 0.75
    }

    /// Returns `true` when the thumb is extended away from the palm.
    static func isThumbExtended(skeleton: HandSkeleton) -> Bool {
        thumbCurlRatio(skeleton: skeleton) > 0.95
    }
    
    
}
