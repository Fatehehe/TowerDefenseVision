//
//  CombatSystem.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 25/06/26.
//

import RealityKit
import Foundation
import Combine

public class CombatSystem: System {
    private var collisionSub: (any Cancellable)?
    
    public required init(scene: RealityKit.Scene) {
        // Berlangganan event tabrakan
        collisionSub = scene.subscribe(to: CollisionEvents.Began.self) { event in
            let entityA = event.entityA
            let entityB = event.entityB
            
            // Mencari panah dan musuh
            let arrow = entityA.components.has(ArrowComponent.self) ? entityA : (entityB.components.has(ArrowComponent.self) ? entityB : nil)
            let enemy = entityA.components.has(EnemyComponent.self) ? entityA : (entityB.components.has(EnemyComponent.self) ? entityB : nil)
            
            // Pastikan keduanya ada
            guard let hitArrow = arrow, let hitEnemy = enemy else { return }
            
            // PENGAMAN: Cek apakah musuh masih ada di dalam scene (masih aktif)
            guard hitEnemy.isEnabled, hitEnemy.parent != nil else { return }
            
            print("🎯 Hit! Panah mengenai musuh: \(hitEnemy.name)")
            
            // 1. Hapus panah dulu agar tidak memicu collision berkali-kali (double hit)
            hitArrow.removeFromParent()
            
            // 2. Logika pengurangan HP
            if var enemyComp = hitEnemy.components[EnemyComponent.self] {
                enemyComp.hp -= 30
                
                if enemyComp.hp <= 0 {
                    // Animasi/Efek kematian
                    hitEnemy.isEnabled = false // Nonaktifkan dulu sebelum hapus
                    hitEnemy.removeFromParent()
                    
                    Task { @MainActor in
                        NotificationCenter.default.post(name: .enemyDefeated, object: nil)
                    }
                } else {
                    hitEnemy.components.set(enemyComp)
                }
            }
        }
    }
    
    public func update(context: SceneUpdateContext) {
        // Tidak perlu melakukan apa-apa di sini jika semua logika ada di event collision
    }
}
