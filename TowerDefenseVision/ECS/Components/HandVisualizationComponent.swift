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

public struct HandOverlayComponent: Component {
    public let chirality: HandAnchor.Chirality
    
    // The top-level wrapper entity loaded from the bundle
    public var gloveWrapper: Entity? = nil
    
    // The actual ModelEntity containing the skinned mesh and jointTransforms
    public var gloveModel: ModelEntity? = nil

    public init(chirality: HandAnchor.Chirality) {
        self.chirality = chirality
    }
}
