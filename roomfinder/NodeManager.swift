//
//  NodeManager.swift
//  roomfinder
//
//  Created by Cathryn Lyons on 4/15/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation
import MapKit
import AStar

struct Point: Hashable {
    var x, y: Float
}

final class Simple2DNode: GraphNode {
    var position: Point
    var connectedNodes: Set<Simple2DNode>

    init(x: Float, y: Float, conncetions: Set<Simple2DNode> = []) {
        self.position = Point(x: x, y: y)
        connectedNodes = conncetions
    }
    
    func cost(to node: Simple2DNode) -> Float {
        return hypot((position.x - node.position.x), (position.y - node.position.y))
    }
    
    func estimatedCost(to node: Simple2DNode) -> Float {
        return cost(to: node)
    }

    static func == (lhs: Simple2DNode, rhs: Simple2DNode) -> Bool {
        return lhs === rhs
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(position)
    }
}

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
    
    //used to read in nodes from geojson file
    func parse() -> ([String], [Simple2DNode]){
        var nodeData : Geodata?
        
        //try to read in geojson file
        guard let jsonUrl = Bundle.main.url(forResource: "PathData/node", withExtension: "geojson") else {
            return ([],[])
        }
        guard let jsonData = try? Data(contentsOf: jsonUrl) else { return ([],[]) }
        do {
           nodeData = try JSONDecoder().decode(Geodata.self, from: jsonData)
        } catch {
           print("\(error)")
        }
        
        var coordinates: [Simple2DNode] = []
        var rooms: [String] = []
        
        for node in nodeData!.features{
            let x = node.geometry.coordinates[0]
            let y = node.geometry.coordinates[1]
            coordinates.append(Simple2DNode(x: Float(x), y: Float(y)))
            rooms.append(node.properties.name)
        }
        
        return(rooms, coordinates)
    }
}
