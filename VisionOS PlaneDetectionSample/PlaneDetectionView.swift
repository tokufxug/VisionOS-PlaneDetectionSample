//
//  PlaneDetectionView.swift
//  VisionOS PlaneDetectionSample
//
//  Created by Sadao Tokuyama on 2/14/24.
//

import SwiftUI
import RealityKit
import ARKit

struct PlaneDetectionView: View {
    
    let session = ARKitSession()
    let planeData = PlaneDetectionProvider(alignments: [.horizontal, .vertical])
    @State var rootEntity = Entity()
    @State var planeAnchors: [UUID: PlaneAnchor] = [:]
    @State var entityMap: [UUID: Entity] = [:]
    
    var body: some View {
        VStack {
            Text("Plane Detection")
            RealityView { content in
                content.add(rootEntity)
            }
        }.onAppear {
            planeDetection()
        }
    }
    
    func planeDetection() {
        Task {
            try await session.run([planeData])
            for await update in planeData.anchorUpdates {
                if update.anchor.classification == .window {
                    continue
                }
                switch update.event {
                case .added, .updated:
                    await updatePlane(update.anchor)
                case .removed:
                    await removePlane(update.anchor)
                }
            }
        }
    }
    
    @MainActor
    func updatePlane(_ anchor: PlaneAnchor) {
        if planeAnchors[anchor.id] == nil {
            let entity = Entity()
            
            let planeMaterial = UnlitMaterial(color: placeColor(classification: anchor.classification))
            let planeEntity = ModelEntity(mesh: .generatePlane(width: anchor.geometry.extent.width, height: anchor.geometry.extent.height), materials: [planeMaterial])
            planeEntity.transform = Transform(matrix: anchor.geometry.extent.anchorFromExtentTransform)
            
            let planeTextMaterial = UnlitMaterial(color: .white)
            let planeText = ModelEntity(mesh: .generateText(anchor.classification.description, extrusionDepth: 0.002, font: .boldSystemFont(ofSize: 0.04), containerFrame: .zero, alignment: .center, lineBreakMode: .byWordWrapping), materials: [planeTextMaterial])
            planeEntity.addChild(planeText)
            
            entity.addChild(planeEntity)
            entityMap[anchor.id] = entity
            rootEntity.addChild(entity)
        }
        entityMap[anchor.id]?.transform = Transform(matrix: anchor.originFromAnchorTransform)
    }
    
    @MainActor
    func removePlane(_ anchor: PlaneAnchor) {
        entityMap[anchor.id]?.removeFromParent()
        entityMap.removeValue(forKey: anchor.id)
        planeAnchors.removeValue(forKey: anchor.id)
    }
    
    func placeColor(classification: PlaneAnchor.Classification) -> UIColor {
        switch(classification) {
            case .wall:
            return .red
        case .notAvailable:
            return .clear
        case .undetermined:
            return .white
        case .unknown:
            return .black
        case .floor:
            return .blue
        case .ceiling:
            return .cyan
        case .table:
            return .brown
        case .seat:
            return .orange
        case .window:
            return .darkGray
        case .door:
            return .green
        @unknown default:
            return .gray
        }
    }
}
