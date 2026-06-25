//
//  MedievalSceneSpawner.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 24/06/26.
//

import RealityKit
import RealityKitContent

public struct MedievalSceneSpawner {
    public static func spawnMedievalWorld(named sceneName: String = "MedievalScene") async -> Entity? {
        do {
            let rootWorld = try await Entity(named: sceneName, in: realityKitContentBundle)
            rootWorld.position = SIMD3<Float>(12, 0, -2)
            rootWorld.scale = SIMD3<Float>(repeating: 1.0)
            
            print("[MedievalSceneSpawner] Sukses memuat dunia: \(sceneName)")
            
            if let targetBullsEye = rootWorld.findEntity(named: "Tower") {
                var towerData = TowerComponent()
                towerData.hp = 100
                targetBullsEye.components.set(towerData)
            }
            
            if let blackHole = rootWorld.findEntity(named: "BlackHole") {
                var portalData = PortalComponent()
                portalData.spawnInterval = 3.0
                blackHole.components.set(portalData)
            }
            
            return rootWorld
            
        } catch {
            print("[MedievalSceneSpawner] Gagal memuat scene '\(sceneName)': \(error)")
            return nil
        }
    }
    
    public static func spawnPortalAsync(named entityName: String = "BlackHole") async -> Entity? {
        do {
            // 1. Ambil model portal dari RCP (misal bentuk gerbang/lingkaran)
            let portalEntity = try await Entity(named: entityName, in: realityKitContentBundle)
            
            // 2. Beri komponen Portal agar sistem mengenalinya
            var portalData = PortalComponent()
            portalData.spawnInterval = 3.0 // Atur jeda spawn di sini
            portalEntity.components.set(portalData)
        
            // 3. Atur posisi portal (misalnya 5 meter di depan pemain)
            portalEntity.position = SIMD3<Float>(-15, 1, -3)
            let portalAngle: Float = .pi / 2
            let portalAxis = SIMD3<Float>(0,1,0)
            portalEntity.transform.rotation = simd_quatf(angle: portalAngle, axis: portalAxis)
                
            print("[PortalSpawner] Sukses memuat Portal dari RCP!")
            return portalEntity
                
        } catch {
            print("[PortalSpawner] Gagal memuat Portal dari RCP: \(error)")
            return nil
        }
    }
}
