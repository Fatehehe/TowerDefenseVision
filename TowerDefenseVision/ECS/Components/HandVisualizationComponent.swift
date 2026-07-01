//
//  HandVisualizationComponent.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 22/06/26.
//

import RealityKit
import ARKit

public struct HandVisualizationComponent: Component {
    public let chirality: HandAnchor.Chirality
    public var modelEntity: ModelEntity
    
    public init(chirality: HandAnchor.Chirality, modelEntity: ModelEntity) {
        self.chirality = chirality
        self.modelEntity = modelEntity
    }
}
