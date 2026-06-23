//
//  ArcherySpawner.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 23/06/26.
//

import RealityKit
import RealityKitContent

public struct ArcherySpawner {
    
    public static func spawnArcheryManager(leftHand: Entity, rightHand: Entity) async -> Entity? {
        let manager = Entity()
        manager.name = "ArcheryManager"
        var playerComp = ArcheryPlayerComponent()
        
        do {
            // 1. Load dari bundle RCP
            let bow = try await Entity(named: "Bow", in: realityKitContentBundle)
            let arrow = try await Entity(named: "Arrow", in: realityKitContentBundle)
            
            // --- ATUR SKALA ---
            // Ubah angka ini untuk memperbesar/memperkecil model (1.0 = ukuran asli)
            let bowScale: Float = 0.4  // Misal mau ukurannya 80%
            let arrowScale: Float = 1.0
            
            bow.transform.scale = SIMD3<Float>(repeating: bowScale)
            arrow.transform.scale = SIMD3<Float>(repeating: arrowScale)
            
            // --- ATUR POSISI (PIVOT OFFSET) ---
            // Satuan di RealityKit adalah Meter.
            // X: Kiri/Kanan | Y: Atas/Bawah | Z: Depan/Belakang
            
            // A. Atur posisi Bow (dipegang di ujung)
            // Kalau pivot asli bow ada di tengah, kita geser sumbu Y-nya agar ujungnya yang kena tangan
            let bowOffsetY: Float = 0.4 // Contoh: geser ke bawah 40cm
            bow.transform.translation = SIMD3<Float>(0.0, bowOffsetY, 0.0)
            let bowAngle: Float = .pi / 2 // 90 derajat
            let bowAxis = SIMD3<Float>(1, 0, 0) // Angka 1 di X, sisanya 0
            bow.transform.rotation = simd_quatf(angle: bowAngle, axis: bowAxis)
            
            // B. Atur posisi Arrow (dipegang di tengah)
            // Kalau pivot asli arrow ada di ujung mata panah, kita geser sumbu Z-nya ke depan/belakang
            let arrowOffsetZ: Float = 0.3 // Contoh: geser 30cm
            arrow.transform.translation = SIMD3<Float>(0.0, 0.0, arrowOffsetZ)
            
            // (Opsional) Kalau senjatanya miring saat digenggam, atur rotasinya di sini:
            // bow.transform.rotation = simd_quatf(angle: .pi/2, axis: SIMD3<Float>(1, 0, 0))
            
            // --- SETUP KOMPONEN & VISIBILITAS ---
            bow.components.set(BowComponent())
            arrow.components.set(ArrowComponent())
            
            bow.isEnabled = false
            arrow.isEnabled = false
            
            leftHand.addChild(bow)
            rightHand.addChild(arrow)
            
            playerComp.activeBow = bow
            playerComp.activeArrow = arrow
            manager.components.set(playerComp)
            
            print("✅ Step 1: Archery Spawner terpasang dengan custom scale/posisi.")
            return manager
            
        } catch {
            print("❌ Archery Spawner Error: \(error)")
            return nil
        }
    }
}
