//
//  GameEvent.swift
//  TowerDefenseVision
//
//  Created by Fatakhillah Khaqo on 27/06/26.
//

import Foundation

extension Notification.Name {
    // Event khusus untuk perubahan state panahan
    static let archeryStateDidChange = Notification.Name("archeryStateDidChange")
    static let enemyDefeated = Notification.Name("enemyDefeated")
    static let towerDestroyed = Notification.Name("towerDestroyed")
}
