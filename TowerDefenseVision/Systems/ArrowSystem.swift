////
////  ArrowSystem.swift
////  TowerDefenseVision
////
////  Created by Fatakhillah Khaqo on 24/06/26.
////

import RealityKit

public struct ArrowSystem: System {
    static let query = EntityQuery(where: .has(ArrowComponent.self))
    
    public init(scene: RealityKit.Scene) {}
    
    public func update(context: SceneUpdateContext) {
        // Ambil delta waktu agar pergerakan panah mulus dan tidak terpengaruh frame rate
        let deltaTime = Float(context.deltaTime)
        
        for entity in context.scene.performQuery(Self.query) {
            guard let arrowComp = entity.components[ArrowComponent.self] else { continue }
            
            // Jika status panah sedang terbang, majukan posisinya!
            if arrowComp.isFlying {
                // Posisi Baru = Posisi Lama + (Arah * Kecepatan * Waktu)
                entity.position += arrowComp.direction * arrowComp.speed * deltaTime
            }
        }
    }
}
