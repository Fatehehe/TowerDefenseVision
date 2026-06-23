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
        
        let isLeftFist = ThumbsUpPoseDetector.detect(handSkeleton: leftSkeleton)
        let isRightFist = ThumbsUpPoseDetector.detect(handSkeleton: rightSkeleton)
        
        for entity in context.scene.performQuery(Self.query) {
            guard var playerComp = entity.components[ArcheryPlayerComponent.self],
                  let bow = playerComp.activeBow,
                  let arrow = playerComp.activeArrow else { continue }
            
            // Logika Visibilitas Sederhana untuk Step 1
            if playerComp.state == .idle || playerComp.state == .equipped {
                
                // Nyalakan/Matikan berdasarkan kepalan
                bow.isEnabled = isLeftFist
                arrow.isEnabled = isRightFist
                
                // Update State
                if isLeftFist && isRightFist {
                    if playerComp.state != .equipped {
                        playerComp.state = .equipped
                        print("🏹 STATE: EQUIPPED")
                    }
                } else {
                    if playerComp.state != .idle {
                        playerComp.state = .idle
                        print("✋ STATE: IDLE")
                    }
                }
            }
            
            entity.components[ArcheryPlayerComponent.self] = playerComp
        }
    }
}
