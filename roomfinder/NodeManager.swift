//
//  NodeManager.swift
//  roomfinder
//
//  Created by Cathryn Lyons on 4/15/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation
import MapKit


class NodeManager {
    
    struct Geodata: Codable {
        let type: String
        let features: [Feature]
    }

    struct Feature: Codable {
        let type: String
        let properties: Properties
        let geometry: Geometry
    }

    struct Geometry: Codable {
        let type: String
        let coordinates: [Double]
    }

    struct Properties: Codable {
        let level_id: UUID
        let name: String
    }
    
    func parse(){
        guard let jsonUrl = Bundle.main.url(forResource: "PathData/node", withExtension: "geojson") else {
            return
        }
        guard let jsonData = try? Data(contentsOf: jsonUrl) else { return }
        do {
           let nodeData = try JSONDecoder().decode(Geodata.self, from: jsonData)

        } catch {
           print("\(error)")
        }
    }
}
