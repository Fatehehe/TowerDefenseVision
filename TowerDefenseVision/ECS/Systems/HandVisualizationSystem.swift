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

public struct HandVisualizationSystem: System {
    public static let query = EntityQuery(where: .has(HandVisualizationComponent.self))
        
    public init(scene: RealityKit.Scene) {}
        
    public func update(context: SceneUpdateContext) {
        
        // Gunakan .rendering untuk sinkronisasi yang lebih baik dengan frame UI
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard let visualComp = entity.components[HandVisualizationComponent.self] else { continue }
            let modelEntity = visualComp.modelEntity
            
            // 1. Ambil data tangan yang sesuai dengan chirality komponen ini
            guard let handAnchor = (visualComp.chirality == .left) ?
                HandTrackingService.shared.latestLeftHand :
                HandTrackingService.shared.latestRightHand
            else {
                // Sembunyikan jika data tangan belum ada
                entity.isEnabled = false
                continue
            }
            
            // 2. Validasi apakah ARKit sedang melacak tangan tersebut
            guard handAnchor.isTracked, let skeleton = handAnchor.handSkeleton else {
                entity.isEnabled = false
                continue
            }
            
            // 3. Tangan valid! Tampilkan dan perbarui posisinya
            entity.isEnabled = true
            entity.transform = Transform(matrix: handAnchor.originFromAnchorTransform)
            
            // 4. Perbarui rotasi sendi (joints) ke ModelEntity
            updateJointRotations(for: modelEntity, using: skeleton)
            
//            if let gloveModel = modelEntity {
//                let joints = skeleton.allJoints
//                for (index, joint) in joints.enumerated() {
//                    if index < modelEntity.jointTransforms.count {
//                        let jointTransform = skeleton.joint(joint.name).parentFromJointTransform
//                        modelEntity.jointTransforms[index].rotation = simd_quatf(jointTransform)
//                    }
//                }
//            }
        }
    }
    
    private func updateJointRotations(for glove: ModelEntity, using handSkeleton: HandSkeleton) {
        let joints = handSkeleton.allJoints
        
        for (index, joint) in joints.enumerated() {
            // Pengaman 1: Pastikan index model 3D tidak melebihi jumlah transformasi
            guard index < glove.jointTransforms.count else { break }
            
            // Pengaman 2: Pastikan joint benar-benar ditemukan di skeleton
            // Kita gunakan akses langsung untuk menghindari kemungkinan crash pada fungsi .joint()
            let jointData = handSkeleton.joint(joint.name)
            
            // Pastikan transform-nya valid (tidak berisi angka NaN/Infinite yang menyebabkan EXC_BREAKPOINT)
            let jointTransform = jointData.parentFromJointTransform
            
            // Optional: Tambahkan validasi jika kamu curiga data transform-nya rusak
             if jointTransform.columns.3.x.isNaN { continue }

            glove.jointTransforms[index].rotation = simd_quatf(jointTransform)
        }
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
                for (index, joint) in joints.enumerated() {
                    if index < gloveModel.jointTransforms.count {
                        let jointTransform = skeleton.joint(joint.name).parentFromJointTransform
                        gloveModel.jointTransforms[index].rotation = simd_quatf(jointTransform)
                    }
                }
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
