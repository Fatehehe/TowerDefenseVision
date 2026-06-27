//
//  EnemySystem.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 24/06/26.
//

import RealityKit
import SwiftUI

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
            
            if distance > 0.5 {
                let direction = simd_normalize(directionVector)
                let newWorldPos = enemyWorldPos + (direction * enemyComp.speed * deltaTime)
                
                entity.setPosition(newWorldPos, relativeTo: nil)
                entity.look(at: towerWorldPos, from: newWorldPos, upVector: [0, 1, 0], relativeTo: nil)
            } else {
                if var towerComp = tower.components[TowerComponent.self] {
                    towerComp.hp -= 10
                    print("Tower ditabrak monster! Sisa HP: \(towerComp.hp)")
                
                    if towerComp.hp <= 0 {
                        if let model = ArcherySystem.appModel {
                            DispatchQueue.main.async {
                                model.currentGameState = .lost
                            }
                        }
                    }
                    tower.components.set(towerComp)
                }
                
                entity.removeFromParent()
            }
        }
    }
}
