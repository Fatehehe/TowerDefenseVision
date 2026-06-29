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
        
        let service = HandTrackingService.shared
        guard let leftHand = service.latestLeftHand, let leftSkeleton = leftHand.handSkeleton, leftHand.isTracked,
              let rightHand = service.latestRightHand, let rightSkeleton = rightHand.handSkeleton, rightHand.isTracked else {
            return
        }
        
        let isBowPose = HandPoseDetector.detect(handSkeleton: leftSkeleton, thumb: false, index: false, mid: false, ring: false, little: false)
        let isArrowPose = HandPoseDetector.detect(handSkeleton: rightSkeleton, thumb: false, index: true, mid: true, ring: true, little: true)
        let isShootingPose = HandPoseDetector.detect(handSkeleton: rightSkeleton, thumb: false, index: false, mid: true, ring: true, little: true)
        
        print("isBowPose \(isBowPose), isArrowPose \(isArrowPose), isShootingPose \(isShootingPose)")
        
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
            
            let previousState = playerComp.state
            
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
            
            entity.components[ArcheryPlayerComponent.self] = playerComp
            
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
