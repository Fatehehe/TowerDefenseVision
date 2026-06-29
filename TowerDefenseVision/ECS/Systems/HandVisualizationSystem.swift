//
//  HandVisualizationSystem.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 22/06/26.
//

import RealityKit
import ARKit
import SwiftUI
import ILSHandTracking

struct HandVisualizationSystem: System {
    static let query = EntityQuery(where: .has(HandVisualizationComponent.self))
        
    init(scene: RealityKit.Scene) {}
        
    func update(context: SceneUpdateContext) {
        updateHandGestures(context: context)
    }
        
    private func updateHandGestures(context: SceneUpdateContext) {
        let service = HandTrackingService.shared
            
        for entity in context.scene.performQuery(Self.query) {
            guard let visualComp = entity.components[HandVisualizationComponent.self] else { continue }
            let modelEntity = visualComp.modelEntity
                
            if entity.name == "LeftHandAnchor" {
                if let leftHand = service.latestLeftHand, let leftSkeleton = leftHand.handSkeleton {
                    entity.isEnabled = leftHand.isTracked
                    
                    if leftHand.isTracked {
                        entity.transform = Transform(matrix: leftHand.originFromAnchorTransform)
                        updateJointRotations(for: modelEntity, using: leftSkeleton)
                    }
                } else {
                    entity.isEnabled = false
                }
            }
            
            else if entity.name == "RightHandAnchor" {
                if let rightHand = service.latestRightHand, let rightSkeleton = rightHand.handSkeleton {
                    entity.isEnabled = rightHand.isTracked
                    
                    if rightHand.isTracked {
                        entity.transform = Transform(matrix: rightHand.originFromAnchorTransform)
                        updateJointRotations(for: modelEntity, using: rightSkeleton)
                    }
                } else {
                    entity.isEnabled = false
                }
            }
        }
    }
    
    private func updateJointRotations(for glove: ModelEntity, using handSkeleton: HandSkeleton) {
        let joints = handSkeleton.allJoints
        
        for (index, joint) in joints.enumerated() {
            let jointTransform = handSkeleton.joint(joint.name).parentFromJointTransform
            let rotation = simd_quatf(jointTransform)
            
            glove.jointTransforms[index].rotation = rotation
        }
    }
}
