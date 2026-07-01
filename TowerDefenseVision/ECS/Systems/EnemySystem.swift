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
    static let towerQuery = EntityQuery(where: .has(TowerComponent.self))
    static var lastEnemyCount: Int = -1
    
    public init(scene: RealityKit.Scene) {}
    
    public func update(context: SceneUpdateContext) {
        guard GameStateTracker.isPlaying else {
            let enemies = context.scene.performQuery(Self.query)
            if Self.lastEnemyCount != 0 {
                // Collect first, then remove — never modify scene while iterating a query
                let toRemove = enemies.map { $0 }
                toRemove.forEach { $0.removeFromParent() }
                Self.lastEnemyCount = 0
            }
            return
        }
        
        let currentTime = ProcessInfo.processInfo.systemUptime
        let enemies = context.scene.performQuery(Self.query)
        
        let currentEnemyCount = enemies.reduce(0) { count, _ in count + 1 }
        Self.lastEnemyCount = currentEnemyCount
        
        var enemiesToRemove: [Entity] = []
        var gameOver = false
        
        for entity in enemies {
            guard var enemyComp = entity.components[EnemyComponent.self],
                  let tower = enemyComp.targetTower else { continue }
            
            let distance = simd_distance(tower.visualBounds(relativeTo: nil).center,
                                         entity.visualBounds(relativeTo: nil).center)
            
            if distance <= 5.8 {
                if currentTime - enemyComp.lastDamageTime >= enemyComp.damageInterval {
                    
                    if var towerComp = tower.components[TowerComponent.self] {
                        
                        towerComp.hp -= enemyComp.damageAmount
                        print("Menara diserang! Sisa HP: \(towerComp.hp)")
                        
                        tower.components.set(towerComp)
                        
                        if towerComp.hp <= 0 {
                            // Mark all enemies for removal — do NOT call removeFromParent inside loop
                            gameOver = true
                        }
                    }
                    
                    enemyComp.lastDamageTime = currentTime
                    entity.components.set(enemyComp)
                }
            }
        }
        
        // Remove AFTER all iterations to avoid iterator invalidation crashes
        if gameOver {
            context.scene.performQuery(Self.query).map { $0 }.forEach { $0.removeFromParent() }
        }
    }
}
