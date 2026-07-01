//
//  HandVisualizationSystem.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 22/06/26.
//

import RealityKit
import ARKit
import SwiftUI
@preconcurrency import ILSHandTracking

struct HandVisualizationSystem: System {
    static let query = EntityQuery(where: .has(HandVisualizationComponent.self) && .has(ILHandAnchorComponent.self))
        
    init(scene: RealityKit.Scene) {}
        
    func update(context: SceneUpdateContext) {
        for entity in context.scene.performQuery(Self.query) {
            guard let visualComp = entity.components[HandVisualizationComponent.self],
                  let anchorComp = entity.components[ILHandAnchorComponent.self] else { continue }
                  
            let modelEntity = visualComp.modelEntity

            if entity.name == "LeftHandAnchor" {
                // Read from ILHandAnchorComponent (thread-safe, written once per frame by ILHandTrackingUpdateSystem)
                if let hand = anchorComp.leftHand, hand.isTracked, let leftSkeleton = hand.handSkeleton {
                    entity.isEnabled = true
                    entity.transform = Transform(matrix: hand.originFromAnchorTransform)
                    updateJointRotations(for: modelEntity, using: leftSkeleton)
                } else {
                    entity.isEnabled = false
                }
            }
            else if entity.name == "RightHandAnchor" {
                if let hand = anchorComp.rightHand, hand.isTracked, let rightSkeleton = hand.handSkeleton {
                    entity.isEnabled = true
                    entity.transform = Transform(matrix: hand.originFromAnchorTransform)
                    updateJointRotations(for: modelEntity, using: rightSkeleton)
                } else {
                    entity.isEnabled = false
                }
            }
        }
    }
    
    private func updateJointRotations(for glove: ModelEntity, using handSkeleton: HandSkeleton) {
        let joints = handSkeleton.allJoints
        var transforms = glove.jointTransforms
        
        for (index, joint) in joints.enumerated() {
            guard index < transforms.count else { break }
            guard joint.isTracked else { continue }
            
            let jointTransform = handSkeleton.joint(joint.name).parentFromJointTransform
            
            // Protect against NaN matrices
            guard !jointTransform.columns.0.x.isNaN else { continue }
            
            // Protect against zero-scale matrices which cause simd_quatf to trap with EXC_BREAKPOINT!
            let col0 = jointTransform.columns.0
            let scaleSq = col0.x*col0.x + col0.y*col0.y + col0.z*col0.z
            guard scaleSq > 0.0001 else { continue }
            
            let rotation = simd_quatf(jointTransform)
            transforms[index].rotation = rotation
        }
        
        glove.jointTransforms = transforms
    }
}

//import RealityKit
//import ARKit
//import ILSHandTracking
//import Foundation
//import UIKit

public class HandOverlaySystem: System {
    public static let query = EntityQuery(where: .has(HandOverlayComponent.self))

    required public init(scene: RealityKit.Scene) {}

    public func update(context: SceneUpdateContext) {
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard var overlay = entity.components[HandOverlayComponent.self] else { continue }
            
            // glove model load
            guard let gloveWrapper = overlay.gloveWrapper else { continue }

            // Locate the ModelEntity from the loaded wrapper if we haven't yet
            if overlay.gloveModel == nil {
                overlay.gloveModel = findModelEntity(in: gloveWrapper)
            }

            // Get the latest hand anchor from HandTrackingService.shared based on chirality
            guard let handAnchor = (overlay.chirality == .left) ?
                HandTrackingService.shared.latestLeftHand :
                HandTrackingService.shared.latestRightHand
            else {
                // Hide glove root if anchor is not tracked or available
                gloveWrapper.isEnabled = false
                continue
            }

            guard handAnchor.isTracked, let skeleton = handAnchor.handSkeleton else {
                gloveWrapper.isEnabled = false
                continue
            }

            // Enable glove mesh
            gloveWrapper.isEnabled = true
            
            // Position the glove root at the hand anchor origin
            gloveWrapper.transform = Transform(matrix: handAnchor.originFromAnchorTransform)

            // Update joint rotations inside the ModelEntity using ARKit hand skeleton's index order
            if let gloveModel = overlay.gloveModel {
                let joints = skeleton.allJoints
                var transforms = gloveModel.jointTransforms
                for (index, joint) in joints.enumerated() {
                    if index < transforms.count {
                        guard joint.isTracked else { continue }
                        let jointTransform = skeleton.joint(joint.name).parentFromJointTransform
                        guard !jointTransform.columns.0.x.isNaN else { continue }
                        
                        let col0 = jointTransform.columns.0
                        let scaleSq = col0.x*col0.x + col0.y*col0.y + col0.z*col0.z
                        guard scaleSq > 0.0001 else { continue }
                        
                        transforms[index].rotation = simd_quatf(jointTransform)
                    }
                }
                gloveModel.jointTransforms = transforms
            }

            entity.components[HandOverlayComponent.self] = overlay
        }
    }

    private func findModelEntity(in entity: Entity) -> ModelEntity? {
        if let model = entity as? ModelEntity {
            return model
        }
        for child in entity.children {
            if let found = findModelEntity(in: child) {
                return found
            }
        }
        return nil
    }
}
