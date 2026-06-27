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
    nonisolated(unsafe) static var appModel: AppModel?
    
    static let query = EntityQuery(where: .has(ArcheryPlayerComponent.self))
    
    public init(scene: RealityKit.Scene) {}
    
    public func update(context: SceneUpdateContext) {
//        guard let model = Self.appModel else { return }
        
        // TETAP GUNAKAN GameStateTracker UNTUK MEMBACA STATE DEMI KEAMANAN
        guard GameStateTracker.isPlaying else { return }
        
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
            
            switch playerComp.state {
                
            case .idle, .equipped:
                bow.isEnabled = isLeftFist
                arrow.isEnabled = isRightFist
                
                if isLeftFist && isRightFist {
                    if playerComp.state != .equipped {
                        playerComp.state = .equipped
                        print("[ArcherySystem] STATE: EQUIPPED")
                    }
                    if handDistance < 0.15 {
                        playerComp.state = .nocked
                        print("[ArcherySystem] STATE: NOCKED")
                    }
                } else {
                    playerComp.state = .idle
                }
                
            case .nocked:
                if !isRightFist || !isLeftFist {
                    playerComp.state = .idle
                } else if handDistance >= 0.15 {
                    playerComp.state = .drawn
                    print("[ArcherySystem] STATE: DRAWN")
                }
                
            case .drawn:
                if isShooting {
                    print("[ArcherySystem] SHOOT!")
                    
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
            
            // 🎯 PERBAIKAN: Lakxukan update UI di Main Thread
            let newState = playerComp.state
            DispatchQueue.main.async {
                // Pastikan model masih ada
                guard let validModel = Self.appModel else { return }
                
                // Jangan update jika state tidak berubah untuk menghemat memori UI
                if validModel.arrowState != newState {
                    validModel.arrowState = newState
                }
                validModel.immersiveSpaceState = .open
            }
        }
    }
}
