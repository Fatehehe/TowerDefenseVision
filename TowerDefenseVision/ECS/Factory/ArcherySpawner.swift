//
//  ArcherySpawner.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 23/06/26.
//

import RealityKit
import RealityKitContent

public struct ArcherySpawner {
    public static func spawnArcheryManager(leftHand: Entity, rightHand: Entity) async -> Entity? {
        let manager = Entity()
        manager.name = "ArcheryManager"
        var playerComp = ArcheryPlayerComponent()
        
        do {
            let bow = try await Entity(named: "Bow", in: realityKitContentBundle)
            let arrow = try await Entity(named: "Arrow", in: realityKitContentBundle)
            
            let bowScale: Float = 1.0
            let arrowScale: Float = 1.0
            
            bow.transform.scale = SIMD3<Float>(repeating: bowScale)
            arrow.transform.scale = SIMD3<Float>(repeating: arrowScale)
            
            let bowOffsetX: Float = 0.06
            let bowOffsetY: Float = 0.04
            let bowOffsetZ: Float = -0.04
            bow.transform.translation = SIMD3<Float>(bowOffsetX, bowOffsetY, bowOffsetZ)
            
            let bowAngle: Float = .pi / 2
            let bowAxis = SIMD3<Float>(1, 0, 0)
            bow.transform.rotation = simd_quatf(angle: bowAngle, axis: bowAxis)
            
            let arrowOffsetX: Float = 0.0
            let arrowOffsetY: Float = -0.03
            let arrowOffsetZ: Float = 0.045
            arrow.transform.translation = SIMD3<Float>(arrowOffsetX, arrowOffsetY, arrowOffsetZ)
            
            let arrowAngle: Float = .pi / 2
            let arrowAxis = SIMD3<Float>(0,0,1)
            arrow.transform.rotation = simd_quatf(angle: arrowAngle, axis: arrowAxis)
            
            bow.components.set(BowComponent())
            arrow.components.set(ArrowComponent())
            
            let arrowShape = ShapeResource.generateBox(size: [0.05, 0.05, 0.5])
            arrow.components.set(CollisionComponent(shapes: [arrowShape]))
            
            playerComp.rightHandAnchor = rightHand
            
            playerComp.arrowTemplate = arrow.clone(recursive: true)
            
            bow.isEnabled = false
            arrow.isEnabled = false
            
            leftHand.addChild(bow)
            rightHand.addChild(arrow)
            
            playerComp.activeBow = bow
            playerComp.activeArrow = arrow
            manager.components.set(playerComp)
            
            return manager
            
        } catch {
            return nil
        }
    }
}
