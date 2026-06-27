//
//  EnemySystem.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 24/06/26.
//

import RealityKit
import Foundation

public struct EnemySystem: System {
    static let query = EntityQuery(where: .has(EnemyComponent.self))
    
    public init(scene: RealityKit.Scene) {}
    
    public func update(context: SceneUpdateContext) {
        let deltaTime = Float(context.deltaTime)
        
        for entity in context.scene.performQuery(Self.query) {
            guard let enemyComp = entity.components[EnemyComponent.self],
                  let tower = enemyComp.targetTower else { continue }
            
            let towerWorldPos = tower.position(relativeTo: nil)
            let enemyWorldPos = entity.position(relativeTo: nil)
            
            let directionVector = towerWorldPos - enemyWorldPos
            let distance = simd_length(directionVector)
            
            // Jarak > 0.5 meter, musuh terus maju
            if distance > 0.5 {
                let direction = simd_normalize(directionVector)
                let newWorldPos = enemyWorldPos + (direction * enemyComp.speed * deltaTime)
                
                entity.setPosition(newWorldPos, relativeTo: nil)
                entity.look(at: towerWorldPos, from: newWorldPos, upVector: [0, 1, 0], relativeTo: nil)
                
            } else {
                // Musuh mencapai tower (Jarak <= 0.5)
                if var towerComp = tower.components[TowerComponent.self] {
                    towerComp.hp -= 10
                    let currentHP = towerComp.hp // Simpan di variabel lokal agar aman dibawa ke dalam Task
                    
                    print("🏰 Tower ditabrak monster! Sisa HP: \(currentHP)")
                    
                    // 🎯 PERBAIKAN: Kirim event towerGetHit beserta sisa HP-nya
                    Task { @MainActor in
                        NotificationCenter.default.post(
                            name: .towerGetHit,
                            object: currentHP
                        )
                    }
                    
                    if currentHP <= 0 {
                        // 🎉 Delegasikan event kekalahan ke Main Thread
                        Task { @MainActor in
                            NotificationCenter.default.post(
                                name: .towerDestroyed,
                                object: nil
                            )
                        }
                    }
                    // Simpan kembali HP terbaru ke entitas tower
                    tower.components.set(towerComp)
                }
                
                // Musuh mati/hilang setelah menabrak tower
                entity.removeFromParent()
            }
        }
    }
}
