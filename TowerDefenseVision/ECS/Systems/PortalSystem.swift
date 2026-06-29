//
//  PortalSystem.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 24/06/26.
//

import RealityKit
import Foundation
internal import UIKit

public struct PortalSystem: System {
    static let portalQuery = EntityQuery(where: .has(PortalComponent.self))
    static let towerQuery = EntityQuery(where: .has(TowerComponent.self))
    
    public init(scene: RealityKit.Scene) {}
    
    public func update(context: SceneUpdateContext) {
        let currentTime = ProcessInfo.processInfo.systemUptime
        
        guard GameStateTracker.isPlaying else {
            for entity in context.scene.performQuery(Self.portalQuery) {
                if var portalComp = entity.components[PortalComponent.self] {
                    portalComp.lastSpawnTime = currentTime
                    portalComp.spawnedCount = 0
                    entity.components.set(portalComp)
                }
            }
            return
        }
        
        var activeTower: Entity? = nil
        for tower in context.scene.performQuery(Self.towerQuery) {
            activeTower = tower
            break
        }

        for entity in context.scene.performQuery(Self.portalQuery) {
            guard var portalComp = entity.components[PortalComponent.self] else { continue }
            
            if currentTime - portalComp.lastSpawnTime >= portalComp.spawnInterval {
                print("[PortalSystem] Spawn Musuh ke-\(portalComp.spawnedCount + 1) via Timeline!")
                
                if let enemyTemplate = portalComp.enemy {
                    let spawnedEnemy = enemyTemplate.clone(recursive: true)
                    spawnedEnemy.name = "GoblinEnemy"
                    
                    spawnedEnemy.generateCollisionShapes(recursive: true)
                    
                    let randomX = Float.random(in: -0.5...0.5)
                    let randomZ = Float.random(in: -0.5...0.5)
                    let basePosition = entity.position(relativeTo: nil)
                    let randomizedSpawnPosition = basePosition + SIMD3<Float>(randomX, 0, randomZ)
                                        
                    spawnedEnemy.setPosition(randomizedSpawnPosition, relativeTo: nil)
                                
                    let rotationAngle: Float = .pi / 2
                    let rotationAxis = SIMD3<Float>(0, 1, 0)
                    
                    spawnedEnemy.transform.rotation *= simd_quatf(angle: rotationAngle, axis: rotationAxis)

                    if let towerEntity = activeTower {
                        var enemyComp = EnemyComponent()
                        enemyComp.targetTower = towerEntity
                        spawnedEnemy.components.set(enemyComp)
                    }
                    
                    entity.parent?.addChild(spawnedEnemy)
        
                }
                
                portalComp.spawnedCount += 1
                portalComp.lastSpawnTime = currentTime
                
                portalComp.spawnInterval = TimeInterval.random(in: 5.0...10.0)
                entity.components.set(portalComp)
            }
        }
    }
}
