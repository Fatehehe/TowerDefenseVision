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
}
