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
}

public struct ArcheryPlayerComponent: Component {
    public var state: ArcheryState = .idle
    public var activeBow: Entity?
    public var activeArrow: Entity?
    
    // 🎯 Titik tumpu yang akan di-update oleh matrix HandTrackingService
    public var bowPivot: Entity?
    public var arrowPivot: Entity?
    
    public var arrowTemplate: Entity?
    public var rightHandAnchor: Entity?
    public var needsNewArrow: Bool = false
    
    public init() {}
}

public struct ArcheryStatusEvent: Event {
    public let newAction: ArcheryState
}
