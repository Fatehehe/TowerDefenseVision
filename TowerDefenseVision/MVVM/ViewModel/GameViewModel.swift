//
//  GameViewModel.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 26/06/26.
//

import SwiftUI

@Observable
public final class GameViewModel{
    public var isGameOver: Bool = false
    public var arrowState: ArcheryState = .idle
    public init() {}
}
