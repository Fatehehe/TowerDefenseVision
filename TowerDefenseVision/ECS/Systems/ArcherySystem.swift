//
//  ArcherySystem.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 23/06/26.
//

import RealityKit
import ARKit
import ILSHandTracking

public struct ArcherySystem: System {
    static let query = EntityQuery(where: .has(ArcheryPlayerComponent.self))
    
    public init(scene: RealityKit.Scene) {}
    
    public func update(context: SceneUpdateContext) {
//        guard GameStateTracker.isPlaying else { return }
        
        let service = HandTrackingService.shared
        guard let leftHand = service.latestLeftHand, let leftSkeleton = leftHand.handSkeleton, leftHand.isTracked,
              let rightHand = service.latestRightHand, let rightSkeleton = rightHand.handSkeleton, rightHand.isTracked else {
            return
        }
        
        let isLeftFist = BowHandPoseDetector.detect(handSkeleton: leftSkeleton)
        let isRightFist = ArrowHandPoseDetector.detect(handSkeleton: rightSkeleton)
        let isShooting = ShootHandPoseDetector.detect(handSkeleton: rightSkeleton)
        
        let leftPos = leftHand.originFromAnchorTransform.columns.3
        let rightPos = rightHand.originFromAnchorTransform.columns.3
        let handDistance = simd_distance(
            simd_make_float3(leftPos.x, leftPos.y, leftPos.z),
            simd_make_float3(rightPos.x, rightPos.y, rightPos.z)
        )
        
        for entity in context.scene.performQuery(Self.query) {
            guard var playerComp = entity.components[ArcheryPlayerComponent.self],
                  let bow = playerComp.activeBow,
                  let arrow = playerComp.activeArrow else { continue }
            
            // 1. Simpan state sebelum proses frame ini dimulai
            let previousState = playerComp.state
            
            // 2. Evaluasi logika game
            switch playerComp.state {
            case .idle, .equipped:
                bow.isEnabled = isLeftFist
                arrow.isEnabled = isRightFist
                
                if isLeftFist && isRightFist {
                    if playerComp.state != .equipped { playerComp.state = .equipped }
                    if handDistance < 0.15 { playerComp.state = .nocked }
                } else {
                    playerComp.state = .idle
                }
                
            case .nocked:
                if !isRightFist || !isLeftFist {
                    playerComp.state = .idle
                } else if handDistance >= 0.15 {
                    playerComp.state = .drawn
                }
                
            case .drawn:
                if isShooting {
                    let worldTransform = arrow.transformMatrix(relativeTo: nil)
                    entity.addChild(arrow, preservingWorldTransform: true)
                    
                    let zAxis = worldTransform.columns.1
                    let forwardDirection = simd_normalize(simd_make_float3(zAxis.x, zAxis.y, zAxis.z))
                    
                    var arrowComp = arrow.components[ArrowComponent.self] ?? ArrowComponent()
                    arrowComp.isFlying = true
                    arrowComp.direction = forwardDirection
                    arrow.components.set(arrowComp)
                    
                    if let template = playerComp.arrowTemplate,
                       let rightHandEntity = playerComp.rightHandAnchor {
                        
                        let clonedArrow = template.clone(recursive: true)
                        clonedArrow.isEnabled = false
                        rightHandEntity.addChild(clonedArrow)
                        playerComp.activeArrow = clonedArrow
                    }
                    
                    playerComp.state = .idle
                }
            }
            
            // 3. Terapkan komponen yang sudah di-update kembali ke entitas
            entity.components[ArcheryPlayerComponent.self] = playerComp
            
            // 4. NOTIFICATION: Evaluasi apakah state berubah
            // Jika berubah, delegasikan pengiriman notifikasi ke Main Actor agar thread-safe
            if playerComp.state != previousState {
                let newState = playerComp.state // Tangkap variabel untuk menghindari data race
                
                Task { @MainActor in
                    NotificationCenter.default.post(
                        name: .archeryStateDidChange,
                        object: newState
                    )
                }
            }
        }
    }
}
