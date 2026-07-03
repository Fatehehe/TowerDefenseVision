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
    
    // Hanya simpan chirality, tidak ada Entity!
    public init(chirality: HandAnchor.Chirality) {
        self.chirality = chirality
    }
}
