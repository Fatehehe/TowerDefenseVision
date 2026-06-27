//
//  GameCoordinator.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 26/06/26.
//

//import SwiftUI
//
//@Observable
//public final class GameCoordinator{
//    public enum Route{
//        case menu
//        case game
//    }
//    
//    public var currentRoute: Route = .menu
//    
//    public init() {}
//    
//    public func startNewGame() {
//        currentRoute = .game
//    }
//    
//    public func returnToMenu() {
//        currentRoute = .menu
//    }
//}

import Foundation

// Struct ringan khusus untuk dibaca oleh RealityKit Systems
public struct GameStateTracker {
    public static var isPlaying: Bool = false
}
