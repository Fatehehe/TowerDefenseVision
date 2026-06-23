//
//  HandVisualizationComponent.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 22/06/26.
//

import RealityKit

struct HandVisualizationComponent: Component{
    var modelEntity: ModelEntity
        
    init(modelEntity: ModelEntity) {
        self.modelEntity = modelEntity
    }
}
