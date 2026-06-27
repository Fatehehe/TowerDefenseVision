//
//  EnemyComponent.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 24/06/26.
//

import RealityKit
import Foundation

public struct EnemyComponent: Component {
    public var speed: Float = 1
    public var hp: Int = 30
    public var targetTower: Entity?
    
    public init() {}
}
