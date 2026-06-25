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
    static let query = EntityQuery(where: .has(PortalComponent.self))
    
    public init(scene: RealityKit.Scene) {}
    
    public func update(context: SceneUpdateContext) {
        // Hanya spawn jika state game sudah 'playing'
        guard let model = ArcherySystem.appModel, model.currentGameState == .playing else { return }
        
        let currentTime = ProcessInfo.processInfo.systemUptime
        
        for entity in context.scene.performQuery(Self.query) {
            guard var portalComp = entity.components[PortalComponent.self] else { continue }
            
            if currentTime - portalComp.lastSpawnTime >= portalComp.spawnInterval {
                print("👾 [PortalSystem] Spawn Musuh (Kotak Merah)!")
                
                // --- 1. BUAT KOTAK MUSUH PROSEDURAL ---
                let cubeMesh = MeshResource.generateBox(size: 0.2)
                let cubeMaterial = SimpleMaterial(color: .red, isMetallic: false)
                let enemyCube = ModelEntity(mesh: cubeMesh, materials: [cubeMaterial])
                enemyCube.name = "EnemyCube"
                
                // 💥 2. TAMBAHKAN COLLISION COMPONENT DI SINI
                // Ukurannya harus sama dengan mesh kotak (0.2)
                let enemyShape = ShapeResource.generateBox(size: [0.2, 0.2, 0.2])
                enemyCube.components.set(CollisionComponent(shapes: [enemyShape]))
                
                // 3. Set posisi kotak tepat di koordinat portal berada
                enemyCube.position = entity.position(relativeTo: nil)
                
                // 4. Cari Tower dan set target
                if let sceneRoot = entity.parent, let towerEntity = sceneRoot.findEntity(named: "Tower") {
                    var enemyComp = EnemyComponent()
                    enemyComp.targetTower = towerEntity
                    enemyCube.components.set(enemyComp)
                    
                    // Hadapkan kotak ke arah tower
                    enemyCube.look(at: towerEntity.position(relativeTo: nil), from: enemyCube.position, upVector: [0, 1, 0], relativeTo: nil)
                }
                
                // 5. Masukkan kotak musuh ke dalam scene
                entity.parent?.addChild(enemyCube)
                
                // 6. Update waktu spawn
                portalComp.lastSpawnTime = currentTime
                entity.components.set(portalComp)
            }
        }
    }
}
