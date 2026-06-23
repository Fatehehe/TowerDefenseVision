//
//  ArcheryComponent.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 23/06/26.
//

import RealityKit

public enum ArcheryState {
    case idle
    case equipped
    case nocked
    case drawn
}

public struct ArcheryPlayerComponent: Component {
    public var state: ArcheryState = .idle
    public weak var activeBow: Entity?
    public weak var activeArrow: Entity?
    public init() {}
}
