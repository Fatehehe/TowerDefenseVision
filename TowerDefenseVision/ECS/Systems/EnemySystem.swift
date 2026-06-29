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
                enemies.forEach { $0.removeFromParent() }
                Self.lastEnemyCount = 0
            }
            return
        }
        
        let currentTime = ProcessInfo.processInfo.systemUptime
        let enemies = context.scene.performQuery(Self.query)
        
        let currentEnemyCount = enemies.reduce(0) { count, _ in count + 1 }
        Self.lastEnemyCount = currentEnemyCount
        
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
                        
                        let hp = towerComp.hp
                        Task { @MainActor in
                            NotificationCenter.default.post(name: .towerGetHit, object: hp)
                        }
                        
                        if towerComp.hp <= 0 {
                            Task { @MainActor in
                                NotificationCenter.default.post(name: .towerDestroyed, object: nil)
                            }
                            context.scene.performQuery(Self.query).forEach { $0.removeFromParent() }
                            return
                        }
                    }
                    
                    enemyComp.lastDamageTime = currentTime
                    entity.components.set(enemyComp)
                }
            }
        }
    }
}
