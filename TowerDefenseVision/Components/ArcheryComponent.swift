//
//  ArcheryComponent.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 23/06/26.
//

import RealityKit

public enum ArcheryState: String {
    case idle = "Idle"
    case equipped = "Equipped"
    case nocked = "Nocked"
    case drawn = "Drawn"
//    case shoot = "Shoot"
}

public struct ArcheryPlayerComponent: Component {
    public var state: ArcheryState = .idle
    public weak var activeBow: Entity?
    public weak var activeArrow: Entity?
    
    // Tambahan untuk Reload Mekanik
    public var arrowTemplate: Entity?
    public weak var rightHandAnchor: Entity?
    
    public init() {}
}
