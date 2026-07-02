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
    // 1. Pisahkan query untuk Pemain dan Hand Anchor
    static let playerQuery = EntityQuery(where: .has(ArcheryPlayerComponent.self))
    static let anchorQuery = EntityQuery(where: .has(ILHandAnchorComponent.self))
    
    // Must run after hand tracking data is written and after glove transforms
    // are updated, since this system reparents the bow/arrow entities that
    // hang off the glove anchor entities — doing that concurrently with
    // HandVisualizationSystem writing those same entities' transforms is unsafe.
    public static var dependencies: [SystemDependency] {
        [.after(ILHandTrackingUpdateSystem.self), .after(HandVisualizationSystem.self)]
    }

    public init(scene: RealityKit.Scene) {}

    public func update(context: SceneUpdateContext) {
            
            // ==========================================
            // FASE 1: AMBIL DATA TRACKING (Fase Rendering)
            // ==========================================
            var currentAnchorComp: ILHandAnchorComponent? = nil
            
            // KEMBALIKAN KE: updatingSystemWhen: .rendering
            let anchorEntities = context.entities(matching: Self.anchorQuery, updatingSystemWhen: .rendering)
            
            for anchorEntity in anchorEntities {
                if let comp = anchorEntity.components[ILHandAnchorComponent.self] {
                    currentAnchorComp = comp
                    break
                }
            }
            
            guard let anchorComp = currentAnchorComp,
                  let leftHand = anchorComp.leftHand,
                  let rightHand = anchorComp.rightHand,
                  let leftSkeleton = leftHand.handSkeleton,
                  let rightSkeleton = rightHand.handSkeleton,
                  leftHand.isTracked,
                  rightHand.isTracked else {
                return
            }
            
            // Kalkulasi Pose
            let isBowPose = HandPoseDetector.detect(handSkeleton: leftSkeleton, thumb: false, index: false, mid: false, ring: false, little: false)
            let isArrowPose = HandPoseDetector.detect(handSkeleton: rightSkeleton, thumb: false, index: true, mid: true, ring: true, little: true)
            let isShootingPose = HandPoseDetector.detect(handSkeleton: rightSkeleton, thumb: false, index: false, mid: true, ring: true, little: true)
             
            let leftPos = leftHand.originFromAnchorTransform.columns.3
            let rightPos = rightHand.originFromAnchorTransform.columns.3
            
            let handDistance = simd_distance(
                simd_make_float3(leftPos.x, leftPos.y, leftPos.z),
                simd_make_float3(rightPos.x, rightPos.y, rightPos.z)
            )
            
            // ==========================================
            // FASE 2: UPDATE LOGIKA ARCHERY
            // ==========================================
            // KEMBALIKAN KE: updatingSystemWhen: .rendering
            let playerEntities = context.entities(matching: Self.playerQuery, updatingSystemWhen: .rendering)
            
            for entity in playerEntities {
                guard var playerComp = entity.components[ArcheryPlayerComponent.self],
                      let bow = playerComp.activeBow,
                      let arrow = playerComp.activeArrow else { continue }
                
                let previousState = playerComp.state
                
                // ... (Isi Switch Statement kamu tetap sama persis seperti sebelumnya) ...
                switch playerComp.state {
                case .idle, .equipped:
                    bow.isEnabled = isBowPose
                    arrow.isEnabled = isArrowPose
                    
                    if isBowPose && isArrowPose {
                        if playerComp.state != .equipped { playerComp.state = .equipped }
                        if handDistance < 0.15 { playerComp.state = .nocked }
                    } else {
                        playerComp.state = .idle
                    }
                    
                case .nocked:
                    if !isArrowPose || !isBowPose {
                        playerComp.state = .idle
                    } else if handDistance >= 0.15 {
                        playerComp.state = .drawn
                    }
                    
                case .drawn:
                    if isShootingPose {
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
                // ... (Batas Switch Statement) ...
                
                entity.components.set(playerComp)
                
                if playerComp.state != previousState {
                    let newState = playerComp.state
                    
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
