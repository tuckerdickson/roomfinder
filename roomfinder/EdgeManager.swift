//
//  EdgeManager.swift
//  roomfinder
//
//  Created by Cathryn Lyons on 4/15/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation
import MapKit


class EdgeManager {
    
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
        let coordinates: [[Double]]
    }

    struct Properties: Codable {
        let level_id: UUID
        let nodes: [Int]
    }
    
    func createConnection(from source: Simple2DNode, to target: Simple2DNode) {
        source.connectedNodes.insert(target)
    }
    
    func parse(nodes: ([String], [Simple2DNode])){
        var edgeData : Geodata?
        
        guard let jsonUrl = Bundle.main.url(forResource: "PathData/edge", withExtension: "geojson") else {
            return
        }
        guard let jsonData = try? Data(contentsOf: jsonUrl) else { return }
        do {
           edgeData = try JSONDecoder().decode(Geodata.self, from: jsonData)

        } catch {
           print("\(error)")
        }
        
        for edge in edgeData!.features{
            //print(edge.properties.nodes)
            let index1 = nodes.0.firstIndex(of: String(edge.properties.nodes[0]))!
            let index2 = nodes.0.firstIndex(of: String(edge.properties.nodes[1]))!

            createConnection(from: nodes.1[index1], to: nodes.1[index2])
            createConnection(from: nodes.1[index2], to: nodes.1[index1])
        }
        
    }
    func pathFind(to start: Simple2DNode, from end: Simple2DNode) -> [Simple2DNode]{
        let path = start.findPath(to: end)
        print(type(of: path))
        return path
    }
}
