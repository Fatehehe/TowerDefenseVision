//
//  CombatSystem.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 25/06/26.
//

import RealityKit
import Foundation
import Combine

public struct CombatSystem: System {
    static let arrowQuery = EntityQuery(where: .has(ArrowComponent.self))
    static let enemyQuery = EntityQuery(where: .has(EnemyComponent.self))
    
    public init(scene: RealityKit.Scene) {}
    
    public func update(context: SceneUpdateContext) {
        let flyingArrows = context.scene.performQuery(Self.arrowQuery)
            .filter { $0.components[ArrowComponent.self]?.isFlying == true }
        
        guard !flyingArrows.isEmpty else { return }
        
        var arrowsToRemove: [Entity] = []
        var enemiesToRemove: [Entity] = []
        
        for enemy in context.scene.performQuery(Self.enemyQuery) {
            // Protect against checking already-killed enemies or processed arrows
            if enemiesToRemove.contains(enemy) { continue }
            
            for arrow in flyingArrows {
                if arrowsToRemove.contains(arrow) { continue }
                
                let enemyPos = enemy.position(relativeTo: nil)
                let arrowPos = arrow.position(relativeTo: nil)
                
                // If arrow is within 0.3 meters of enemy
                if simd_distance(enemyPos, arrowPos) < 0.3 {
                    print("🎯 HEADSHOT! Panah mengenai musuh!")
                    arrowsToRemove.append(arrow)
                    
                    // Safe guard — a freshly-spawned enemy may not have its
                    // EnemyComponent set yet if the Task hasn't flushed.
                    guard var enemyComp = enemy.components[EnemyComponent.self] else { continue }
                    enemyComp.hp -= 30
                    
                    if enemyComp.hp <= 0 {
                        print("Musuh Hancur!")
                        enemy.stopAllAnimations()
                        enemiesToRemove.append(enemy)
                        
                        // We track enemiesDefeated safely via GameStateTracker
                        GameStateTracker.enemiesDefeated += 1
                    } else {
                        enemy.components.set(enemyComp)
                    }
                }
            }
        }
        
        // Remove entities safely at the end of the update loop
        for arrow in arrowsToRemove {
            arrow.removeFromParent()
        }
        for enemy in enemiesToRemove {
            enemy.removeFromParent()
        }
    }
}
