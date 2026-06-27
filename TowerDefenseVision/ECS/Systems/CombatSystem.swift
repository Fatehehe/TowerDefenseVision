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
            
            let hasArrowA = entityA.components.has(ArrowComponent.self)
            let hasEnemyB = entityB.components.has(EnemyComponent.self)
            
            let hasArrowB = entityB.components.has(ArrowComponent.self)
            let hasEnemyA = entityA.components.has(EnemyComponent.self)
            
            var arrow: Entity? = nil
            var enemy: Entity? = nil
            
            if hasArrowA && hasEnemyB {
                arrow = entityA
                enemy = entityB
            } else if hasArrowB && hasEnemyA {
                arrow = entityB
                enemy = entityA
            }
            
            if let hitArrow = arrow, let hitEnemy = enemy {
                print("🎯 HEADSHOT! Panah mengenai musuh!")
                
                if var enemyComp = hitEnemy.components[EnemyComponent.self] {
                    enemyComp.hp -= 30
                    
                    if enemyComp.hp <= 0 {
                        hitEnemy.removeFromParent() // Hancurkan Musuh
                        print("Musuh Hancur!")
                        
                        Task { @MainActor in
                            NotificationCenter.default.post(
                                name: .enemyDefeated,
                                object: nil
                            )
                        }
                    } else {
                        hitEnemy.components.set(enemyComp)
                    }
                }
                hitArrow.removeFromParent()
            }
        }
    }
}
