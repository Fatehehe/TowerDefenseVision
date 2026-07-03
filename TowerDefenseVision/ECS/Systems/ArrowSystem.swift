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
        
        // 1. Siapkan keranjang penampung sampah
        var arrowsToRemove: [Entity] = []
        
        for entity in context.scene.performQuery(Self.query) {
            guard let arrowComp = entity.components[ArrowComponent.self] else { continue }
            
            if arrowComp.isFlying {
                entity.position += arrowComp.direction * arrowComp.speed * deltaTime
                
                // 2. Gunakan posisi relatif ke dunia (nil) agar akurat
                let worldPosition = entity.position(relativeTo: nil)
                let distance = simd_length(worldPosition)
                
                let maxDistance: Float = 20.0
                
                if distance > maxDistance {
                    // Masukkan ke keranjang, jangan langsung dihapus!
                    arrowsToRemove.append(entity)
                }
            }
        }
        
        // 3. Eksekusi penghapusan dengan aman di luar loop query
        for arrow in arrowsToRemove {
            arrow.removeFromParent()
            print("[ArrowSystem] Panah meleset terlalu jauh (> 20 meter) dan telah dihancurkan!")
        }
    }
}
