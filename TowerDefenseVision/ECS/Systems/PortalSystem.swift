//
//  PortalSystem.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 24/06/26.
//

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
            for entity in context.scene.performQuery(Self.portalQuery) {
                if var portalComp = entity.components[PortalComponent.self] {
                    portalComp.lastSpawnTime = currentTime
                    portalComp.spawnedCount = 0
                    entity.components.set(portalComp)
                }
            }
            return
        }
        
        // --- CARI TOWER ---
        var activeTower: Entity? = nil
        for tower in context.scene.performQuery(Self.towerQuery) {
            activeTower = tower
            break
        }
        
        // --- PROSES PORTAL ---
        for entity in context.scene.performQuery(Self.portalQuery) {
            guard var portalComp = entity.components[PortalComponent.self] else { continue }
            
            if currentTime - portalComp.lastSpawnTime >= portalComp.spawnInterval {
                print("👾 [PortalSystem] Spawn Musuh ke-\(portalComp.spawnedCount + 1) via Timeline!")
                
                // 🎯 1. CLONE MODEL DARI COMPONENT
                if let enemyTemplate = portalComp.enemy {
                    let spawnedEnemy = enemyTemplate.clone(recursive: true)
                    spawnedEnemy.name = "GoblinEnemy"
                    
                    spawnedEnemy.generateCollisionShapes(recursive: true)
                    
                    // 🎯 2. ACAK POSISI SPAWN
                    let randomX = Float.random(in: -0.5...0.5)
                                        let randomZ = Float.random(in: -0.5...0.5)
                                        let basePosition = entity.position(relativeTo: nil)
                                        let randomizedSpawnPosition = basePosition + SIMD3<Float>(randomX, 0, randomZ)
                                        
                                        spawnedEnemy.setPosition(randomizedSpawnPosition, relativeTo: nil)
                                        
                                        // 🎯 2.5 ROTATE ENEMY 90 DERAJAT
                                        // Jika musuh membelakangi arah yang benar, ubah nilainya menjadi minus (-Float.pi / 2)
                                        let rotationAngle: Float = .pi / 2
                                        let rotationAxis = SIMD3<Float>(0, 1, 0) // Rotasi pada sumbu Y (menghadap kiri/kanan)
                                        
                                        // Kalikan rotasi saat ini dengan rotasi tambahan 90 derajat
                                        spawnedEnemy.transform.rotation *= simd_quatf(angle: rotationAngle, axis: rotationAxis)

                    
                    // 🎯 3. BERI KOMPONEN MUSUH (Tanpa speed, karena dikendalikan Timeline)
                    if let towerEntity = activeTower {
                        var enemyComp = EnemyComponent()
                        enemyComp.targetTower = towerEntity
                        // ❌ enemyComp.speed dihapus karena tidak dipakai lagi
                        spawnedEnemy.components.set(enemyComp)
                        
                        // ❌ spawnedEnemy.look(at:) dihapus, biarkan RCP yang mengatur arah hadapnya!
                    }
                    
                    // 🎯 4. MASUKKAN KE SCENE
                    entity.parent?.addChild(spawnedEnemy)
                    
                    // 🎯 5. MAINKAN TIMELINE
                    // RealityKit membaca Timeline dari RCP sebagai 'availableAnimations'
//                    if let timelineAnimation = spawnedEnemy.availableAnimations.first {
//                        // Gunakan .repeat() jika timeline-nya adalah animasi jalan berulang
//                        // Atau biarkan tanpa .repeat() jika timeline-nya adalah rute pasti (titik A ke B)
//                        spawnedEnemy.playAnimation(timelineAnimation)
//                    }
                }
                
                // 📈 UPDATE TRACKING PORTAL
                portalComp.spawnedCount += 1
                portalComp.lastSpawnTime = currentTime
                
                // Interval random (5 - 10 detik)
                portalComp.spawnInterval = TimeInterval.random(in: 5.0...10.0)
                entity.components.set(portalComp)
            }
        }
    }
}
