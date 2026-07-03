//
//  ArrowComponent.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 23/06/26.
//

import RealityKit

public struct ArrowComponent: Component {
    public var isFlying: Bool = false
    public var direction: SIMD3<Float> = .zero
    public var speed: Float = 10.0
    
    public init() {}
}
