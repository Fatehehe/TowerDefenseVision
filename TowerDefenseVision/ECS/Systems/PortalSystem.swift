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
        
        // 🎯 CEK STATUS GAME
        guard GameStateTracker.isPlaying else {
            // Jika game belum mulai, tahan timer portalnya!
            for entity in context.scene.performQuery(Self.portalQuery) {
                if var portalComp = entity.components[PortalComponent.self] {
                    portalComp.lastSpawnTime = currentTime
                    // Reset counter saat tidak main
                    portalComp.spawnedCount = 0
                    entity.components.set(portalComp)
                }
            }
            return
        }
        
        // --- LOGIKA DI BAWAH INI HANYA BERJALAN SAAT ISPLAYING == TRUE ---
        
        // Cari entitas Tower
        var activeTower: Entity? = nil
        for tower in context.scene.performQuery(Self.towerQuery) {
            activeTower = tower
            break
        }
        
        for entity in context.scene.performQuery(Self.portalQuery) {
            guard var portalComp = entity.components[PortalComponent.self] else { continue }
            
            // 🎯 ENDLESS SPAWN: Langsung cek interval waktu tanpa peduli batas maksimal
            if currentTime - portalComp.lastSpawnTime >= portalComp.spawnInterval {
                print("👾 [PortalSystem] Spawn Musuh ke-\(portalComp.spawnedCount + 1) (Endless)!")
                
                let cubeMesh = MeshResource.generateBox(size: 1)
                let cubeMaterial = SimpleMaterial(color: .red, isMetallic: false)
                let enemyCube = ModelEntity(mesh: cubeMesh, materials: [cubeMaterial])
                enemyCube.name = "EnemyCube"
                
                let enemyShape = ShapeResource.generateBox(size: [1, 1, 1])
                enemyCube.components.set(CollisionComponent(shapes: [enemyShape]))
                
                // Acak posisi kemunculan di sekitar portal
                let randomX = Float.random(in: -0.5...0.5)
                let randomZ = Float.random(in: -0.5...0.5)
                let basePosition = entity.position(relativeTo: nil)
                let randomizedSpawnPosition = basePosition + SIMD3<Float>(randomX, 0, randomZ)
                
                enemyCube.setPosition(randomizedSpawnPosition, relativeTo: nil)
                
                if let towerEntity = activeTower {
                    var enemyComp = EnemyComponent()
                    enemyComp.targetTower = towerEntity
                    
                    // Kecepatan diacak
                    enemyComp.speed = Float.random(in: 3...6)
                    enemyCube.components.set(enemyComp)
                    
                    enemyCube.look(at: towerEntity.position(relativeTo: nil), from: enemyCube.position, upVector: [0, 1, 0], relativeTo: nil)
                }
                
                entity.parent?.addChild(enemyCube)
                
                // 📈 UPDATE TRACKING
                portalComp.spawnedCount += 1
                portalComp.lastSpawnTime = currentTime
                
                // ⏱️ ACAK WAKTU SPAWN SELANJUTNYA (Antara 5 sampai 10 detik)
                portalComp.spawnInterval = TimeInterval.random(in: 5.0...10.0)
                
                // Simpan kembali data ke entitas portal
                entity.components.set(portalComp)
            }
        }
    }
}
