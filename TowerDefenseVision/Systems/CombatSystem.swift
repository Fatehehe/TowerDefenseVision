//
//  CombatSystem.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 25/06/26.
//

import RealityKit

public class CombatSystem: System {
    // 1. Wajib menyimpan subscription agar event listener tidak terhapus dari memori
    private var collisionSub: EventSubscription?
    
    // 2. Akses scene tersedia secara langsung di init
    public required init(scene: RealityKit.Scene) {
        
        // 3. Pasang pendengar event di sini
        collisionSub = scene.subscribe(to: CollisionEvents.Began.self) { event in
            let entityA = event.entityA
            let entityB = event.entityB
            
            let hasArrowA = entityA.components.has(ArrowComponent.self)
            let hasEnemyB = entityB.components.has(EnemyComponent.self)
            
            let hasArrowB = entityB.components.has(ArrowComponent.self)
            let hasEnemyA = entityA.components.has(EnemyComponent.self)
            
            var arrow: Entity? = nil
            var enemy: Entity? = nil
            
            if hasArrowA && hasEnemyB {
                arrow = entityA
                enemy = entityB
            } else if hasArrowB && hasEnemyA {
                arrow = entityB
                enemy = entityA
            }
            
            // Logika "Hit" dipindahkan ke sini
            if let hitArrow = arrow, let hitEnemy = enemy {
                print("🎯 HEADSHOT! Panah mengenai musuh!")
                
                if var enemyComp = hitEnemy.components[EnemyComponent.self] {
                    enemyComp.hp -= 30
                    
                    if enemyComp.hp <= 0 {
                        hitEnemy.removeFromParent()
                        print("💀 Musuh Hancur!")
                    } else {
                        hitEnemy.components.set(enemyComp)
                    }
                }
                
                hitArrow.removeFromParent()
            }
        }
    }
    
    // Fungsi update wajib ada untuk System, tapi biarkan kosong
    // karena kita menangani logic berbasis Event (bukan per frame)
    public func update(context: SceneUpdateContext) { }
}
