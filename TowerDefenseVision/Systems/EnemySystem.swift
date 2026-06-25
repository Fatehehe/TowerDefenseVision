//
//  EnemySystem.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 24/06/26.
//

import RealityKit

public struct EnemySystem: System {
    static let query = EntityQuery(where: .has(EnemyComponent.self))
    
    public init(scene: RealityKit.Scene) {}
    
    public func update(context: SceneUpdateContext) {
        let deltaTime = Float(context.deltaTime)
        
        for entity in context.scene.performQuery(Self.query) {
            guard let enemyComp = entity.components[EnemyComponent.self],
                  let tower = enemyComp.targetTower else { continue }
            
            // 1. Hitung jarak monster ke tower
            let directionVector = tower.position - entity.position
            let distance = simd_length(directionVector)
            
            // 2. Jika jaraknya masih lebih dari 50 cm, terus berjalan maju
            if distance > 0.5 {
                let direction = simd_normalize(directionVector)
                entity.position += direction * enemyComp.speed * deltaTime
                
                // Selalu menghadap tower saat berjalan
                entity.look(at: tower.position, from: entity.position, upVector: [0, 1, 0], relativeTo: nil)
            } else {
                // 3. Monster MENABRAK TOWER! Kurangi HP Tower
                if var towerComp = tower.components[TowerComponent.self] {
                    towerComp.hp -= 10 // Kurangi darah tower sebanyak 10
                    print("💥 Tower ditabrak monster! Sisa HP: \(towerComp.hp)")
                    tower.components.set(towerComp)
                }
                
                // Hapus monster dari dunia karena sudah meledak/menyerang tower
                entity.removeFromParent()
            }
        }
    }
}
