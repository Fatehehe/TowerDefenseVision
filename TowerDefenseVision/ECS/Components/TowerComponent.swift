//
//  TowerComponent.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 24/06/26.
//

import RealityKit

public struct TowerComponent: Component {
    public var hp: Int = 100
    public var maxHp: Int = 100
    public var isDestroyed: Bool = false
    
    public init() {}
}
