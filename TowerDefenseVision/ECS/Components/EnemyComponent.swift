//
//  EnemyComponent.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 24/06/26.
//

import RealityKit
import Foundation

public struct EnemyComponent: Component {
    public var hp: Int = 30
    public var targetTower: Entity?
    
    // 🎯 Tambahan untuk sistem Hit Per Detik
    public var lastDamageTime: TimeInterval = 0.0
    public var damageInterval: TimeInterval = 1.0 // Serang setiap 1 detik
    public var damageAmount: Int = 10 // Jumlah damage per hit
    
    public init() {}
}
