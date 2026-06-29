//
//  PortalComponent.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 24/06/26.
//

import RealityKit
import Foundation

public struct PortalComponent: Component {
    public var spawnInterval: TimeInterval = 3.0
    public var lastSpawnTime: TimeInterval = 0.0
    public var spawnedCount: Int = 0
    public var enemy: Entity?
 
    public init() {}
}
