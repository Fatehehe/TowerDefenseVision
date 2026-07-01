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
    static var lastEnemyCount: Int = -1
    
    public init(scene: RealityKit.Scene) {}
    
    public func update(context: SceneUpdateContext) {
        guard GameStateTracker.isPlaying else {
            // Materialize the query result into a plain array before removing
            // entities from it — mutating the scene graph while a QueryResult
            // for the same query is still "live" can corrupt its backing
            // storage mid-iteration and crash.
            let enemies = Array(context.scene.performQuery(Self.query))
            if Self.lastEnemyCount != 0 {
                enemies.forEach { $0.removeFromParent() }
                Self.lastEnemyCount = 0
            }
            return
        }

        let currentTime = ProcessInfo.processInfo.systemUptime
        let enemies = Array(context.scene.performQuery(Self.query))

        Self.lastEnemyCount = enemies.count

        var towerWasDestroyed = false

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
                            towerWasDestroyed = true
                            break
                        }
                    }

                    enemyComp.lastDamageTime = currentTime
                    entity.components.set(enemyComp)
                }
            }
        }

        // Remove entities only after the iteration above is fully done,
        // same safe pattern as ArrowSystem.
        if towerWasDestroyed {
            enemies.forEach { $0.removeFromParent() }
        }
    }
}
