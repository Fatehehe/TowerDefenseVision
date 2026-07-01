import RealityKit
import ARKit
@preconcurrency import ILSHandTracking

public struct ArcherySystem: System {
    static let query = EntityQuery(where: .has(ArcheryPlayerComponent.self))
    // Query hand anchor entities that ILHandTrackingUpdateSystem populates each frame
    static let anchorQuery = EntityQuery(where: .has(ILHandAnchorComponent.self))
    
    public init(scene: RealityKit.Scene) {}
    
    public func update(context: SceneUpdateContext) {
        
        // Read hand data from ILHandAnchorComponent — written safely each frame by
        // ILHandTrackingUpdateSystem. This avoids the data race that occurs when
        // reading HandTrackingService.shared directly from the RealityKit background
        // thread while ARKit's Task.detached is writing the same HandAnchor concurrently.
        var leftAnchor: HandAnchor? = nil
        var rightAnchor: HandAnchor? = nil
        
        for entity in context.scene.performQuery(Self.anchorQuery) {
            guard let comp = entity.components[ILHandAnchorComponent.self] else { continue }
            if entity.name == "LeftHandAnchor" {
                leftAnchor = comp.leftHand
            } else if entity.name == "RightHandAnchor" {
                rightAnchor = comp.rightHand
            }
        }
        
        guard let leftHand = leftAnchor, leftHand.isTracked,
              let rightHand = rightAnchor, rightHand.isTracked,
              let leftSkeleton = leftHand.handSkeleton,
              let rightSkeleton = rightHand.handSkeleton else {
            return
        }
        
        let isBowPose = HandPoseDetector.detect(handSkeleton: leftSkeleton, thumb: false, index: false, mid: false, ring: false, little: false)
        let isArrowPose = HandPoseDetector.detect(handSkeleton: rightSkeleton, thumb: false, index: true, mid: true, ring: true, little: true)
        let isShootingPose = HandPoseDetector.detect(handSkeleton: rightSkeleton, thumb: false, index: false, mid: true, ring: true, little: true)
        
        let leftPos = leftHand.originFromAnchorTransform.columns.3
        let rightPos = rightHand.originFromAnchorTransform.columns.3
        
        let handDistance = simd_distance(
            simd_make_float3(leftPos.x, leftPos.y, leftPos.z),
            simd_make_float3(rightPos.x, rightPos.y, rightPos.z)
        )
        
        for entity in context.scene.performQuery(Self.query) {
            guard var playerComp = entity.components[ArcheryPlayerComponent.self] else { continue }
            
            // Check if we need to spawn a new arrow this frame
            if playerComp.needsNewArrow {
                playerComp.needsNewArrow = false
                entity.components.set(playerComp)
                
                if let rightHandEntity = playerComp.rightHandAnchor {
                    let templateEntity = playerComp.arrowTemplate
                    Task { @MainActor in
                        guard let template = templateEntity else { return }
                        let clonedArrow = template.clone(recursive: true)
                        clonedArrow.isEnabled = false
                        rightHandEntity.addChild(clonedArrow)
                        
                        if let manager = rightHandEntity.scene?.findEntity(named: "ArcheryManager") {
                            if var comp = manager.components[ArcheryPlayerComponent.self] {
                                comp.activeArrow = clonedArrow
                                manager.components.set(comp)
                            }
                        }
                    }
                }
                continue
            }
            
            guard let bow = playerComp.activeBow, let arrow = playerComp.activeArrow else { continue }
            
            switch playerComp.state {
            case .idle, .equipped:
                bow.isEnabled = isBowPose
                arrow.isEnabled = isArrowPose
                
                if isBowPose && isArrowPose {
                    if playerComp.state != .equipped { playerComp.state = .equipped }
                    if handDistance < 0.15 { playerComp.state = .nocked }
                } else {
                    playerComp.state = .idle
                }
                
            case .nocked:
                if !isArrowPose || !isBowPose {
                    playerComp.state = .idle
                } else if handDistance >= 0.15 {
                    playerComp.state = .drawn
                }
                
            case .drawn:
                if isShootingPose {
                    let worldTransform = arrow.transformMatrix(relativeTo: nil)
                    entity.addChild(arrow, preservingWorldTransform: true)
                    
                    let zAxis = worldTransform.columns.2
                    let fwd = simd_make_float3(zAxis.x, zAxis.y, zAxis.z)
                    let forwardDirection = simd_length(fwd) > 0.001 ? simd_normalize(fwd) : simd_make_float3(0, 0, -1)
                    
                    var arrowComp = arrow.components[ArrowComponent.self] ?? ArrowComponent()
                    arrowComp.isFlying = true
                    arrowComp.direction = forwardDirection
                    arrow.components.set(arrowComp)
                    
                    playerComp.needsNewArrow = true
                    playerComp.activeArrow = nil
                    playerComp.state = .idle
                }
            }
            
            entity.components[ArcheryPlayerComponent.self] = playerComp
        }
    }
}
