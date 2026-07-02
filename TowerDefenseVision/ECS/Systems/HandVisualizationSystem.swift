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

    // Without this, RealityKit has no ordering guarantee between systems and
    // may run them concurrently. This system writes transform/isEnabled on the
    // glove anchor entities every frame, and ArcherySystem reparents children
    // of those same entities — running both at once corrupts the scene graph.
    public static var dependencies: [SystemDependency] {
        [.after(ILHandTrackingUpdateSystem.self)]
    }

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
