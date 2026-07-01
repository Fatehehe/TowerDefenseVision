//
//  ArrowSystem.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 24/06/26.
//

import RealityKit

public struct ArrowSystem: System {
    static let query = EntityQuery(where: .has(ArrowComponent.self))
    
    public init(scene: RealityKit.Scene) {}
    
    public func update(context: SceneUpdateContext) {
        let deltaTime = Float(context.deltaTime)
        var toRemove: [Entity] = []
        
        for entity in context.scene.performQuery(Self.query) {
            guard let arrowComp = entity.components[ArrowComponent.self] else { continue }
            
            if arrowComp.isFlying {
                entity.position += arrowComp.direction * arrowComp.speed * deltaTime
                
                let distance = simd_length(entity.position)
                
                let maxDistance: Float = 20.0
                
                if distance > maxDistance {
                    toRemove.append(entity)
                    print("[ArrowSystem] Panah meleset terlalu jauh (> 20 meter) dan telah dihancurkan!")
                }
            }
        }
        
        // Remove AFTER the query loop to avoid iterator invalidation crashes
        for entity in toRemove {
            entity.removeFromParent()
        }
    }
}
