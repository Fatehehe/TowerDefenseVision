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

public class HandVisualizationSystem: System {
    public static let query = EntityQuery(where: .has(HandVisualizationComponent.self))
        
    required public init(scene: RealityKit.Scene) {}
    
    public func update(context: SceneUpdateContext) {
        // Di sini `anchorEntity` adalah `rightHand` atau `leftHand` yang kita buat di Spawner
        for anchorEntity in context.entities(matching: Self.query, updatingSystemWhen: .rendering){
            
            guard let visualization = anchorEntity.components[HandVisualizationComponent.self] else { continue }
            
            // 🔥 1. Ambil model langsung dari child scene graph (BUKAN dari komponen)
            guard let gloveWrapper = anchorEntity.children.first else { continue }
            guard let gloveModel = findModelEntity(in: gloveWrapper) else { continue }

            // 🔥 2. Cek status tracking tangan
            let handAnchor = (visualization.chirality == .left) ?
                HandTrackingService.shared.latestLeftHand :
                HandTrackingService.shared.latestRightHand
            
            guard let trackedHand = handAnchor, trackedHand.isTracked, let skeleton = trackedHand.handSkeleton else {
                gloveWrapper.isEnabled = false
                continue
            }

            // 🔥 3. Aplikasikan posisi dan rotasi
            gloveWrapper.isEnabled = true
            gloveWrapper.transform = Transform(matrix: trackedHand.originFromAnchorTransform)

            let joints = skeleton.allJoints
            for (index, joint) in joints.enumerated() {
                if index < gloveModel.jointTransforms.count {
                    let jointTransform = skeleton.joint(joint.name).parentFromJointTransform
                    gloveModel.jointTransforms[index].rotation = simd_quatf(jointTransform)
                }
            }
        }
    }
    
    // Helper untuk mencari ModelEntity
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
