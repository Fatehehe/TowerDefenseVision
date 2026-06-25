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
        guard let model = ArcherySystem.appModel, model.currentGameState == .playing else { return }
        
        let currentTime = ProcessInfo.processInfo.systemUptime
        
        // Cari entitas Tower
        var activeTower: Entity? = nil
        for tower in context.scene.performQuery(Self.towerQuery) {
            activeTower = tower
            break
        }
        
        for entity in context.scene.performQuery(Self.portalQuery) {
            guard var portalComp = entity.components[PortalComponent.self] else { continue }
            
            if portalComp.spawnedCount < portalComp.maxEnemies {
                
                if currentTime - portalComp.lastSpawnTime >= portalComp.spawnInterval {
                    print("👾 [PortalSystem] Spawn Musuh ke-\(portalComp.spawnedCount + 1)!")
                    
                    let cubeMesh = MeshResource.generateBox(size: 0.2)
                    let cubeMaterial = SimpleMaterial(color: .red, isMetallic: false)
                    let enemyCube = ModelEntity(mesh: cubeMesh, materials: [cubeMaterial])
                    enemyCube.name = "EnemyCube"
                    
                    let enemyShape = ShapeResource.generateBox(size: [1, 1, 1])
                    enemyCube.components.set(CollisionComponent(shapes: [enemyShape]))
                    
//                    enemyCube.position = entity.position(relativeTo: nil)
                    enemyCube.setPosition(entity.position(relativeTo: nil), relativeTo: nil)
                    
                    if let towerEntity = activeTower {
                        var enemyComp = EnemyComponent()
                        enemyComp.targetTower = towerEntity
                        enemyCube.components.set(enemyComp)
                        
                        enemyCube.look(at: towerEntity.position(relativeTo: nil), from: enemyCube.position, upVector: [0, 1, 0], relativeTo: nil)
                    }
                    
                    entity.parent?.addChild(enemyCube)
                    
                    // 📈 UPDATE JUMLAH SPAWN DAN WAKTU
                    portalComp.spawnedCount += 1
                    portalComp.lastSpawnTime = currentTime
                    entity.components.set(portalComp)
                    
                    if portalComp.spawnedCount >= portalComp.maxEnemies {
                        print("[PortalSystem] Portal ini sudah mencapai batas maksimal spawn (\(portalComp.maxEnemies) musuh).")
                    }
                }
            }
        }
    }
}
