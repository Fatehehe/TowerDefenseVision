//
//  CombatSystem.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 25/06/26.
//

import RealityKit
import Foundation
import Combine

public class CombatSystem: System {
    private var collisionSub: (any Cancellable)?
    
    public required init(scene: RealityKit.Scene) {
        collisionSub = scene.subscribe(to: CollisionEvents.Began.self) { event in
            let entityA = event.entityA
            let entityB = event.entityB
            
            // Cari mana panah, mana musuh
            let arrow = entityA.components.has(ArrowComponent.self) ? entityA : (entityB.components.has(ArrowComponent.self) ? entityB : nil)
            let enemy = entityA.components.has(EnemyComponent.self) ? entityA : (entityB.components.has(EnemyComponent.self) ? entityB : nil)
            
            // 🎯 Safety Check: Pastikan keduanya ada dan masih di scene
            guard let hitArrow = arrow, let hitEnemy = enemy,
                  hitEnemy.parent != nil else { return }
            
            print("🎯 HEADSHOT! Panah mengenai musuh!")
            
            // Hapus panah segera agar tidak menabrak musuh lain dalam frame yang sama
            hitArrow.removeFromParent()
            
            if var enemyComp = hitEnemy.components[EnemyComponent.self] {
                enemyComp.hp -= 30
                
                if enemyComp.hp <= 0 {
                    // 🛡️ Bersihkan sebelum hapus
                    hitEnemy.stopAllAnimations()
                    hitEnemy.removeFromParent()
                    print("Musuh Hancur!")
                    
                    Task { @MainActor in
                        NotificationCenter.default.post(name: .enemyDefeated, object: nil)
                    }
                } else {
                    hitEnemy.components.set(enemyComp)
                }
            }
        }
    }
}
