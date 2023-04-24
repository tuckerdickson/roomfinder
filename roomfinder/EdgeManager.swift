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
    
    //list of stairs on all 3 levels
    let stairList3 = [["1259", "2259", "3259"], ["1300", "2300", "3300"], ["1203", "2203", "3203"], ["1100", "2100", "3100"], ["151", "251", "335"], ["1233", "2233", "3233"]]
    //list of stairs on only floors 1 and 2
    let stairList2 = [["1126", "2126"], ["1400", "2400"]]
    //coordinates for a stair nodes
    var stairPoints : [Simple2DNode] = []
    
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
    
    //create connection between 2 nodes
    func createConnection(from source: Simple2DNode, to target: Simple2DNode) {
        source.connectedNodes.insert(target)
    }
    
    //parse the edge data to figure out where connections need to be made
    func parse(nodes: ([String], [Simple2DNode])){
        var edgeData : Geodata?
        
        //try to read in geojson file
        guard let jsonUrl = Bundle.main.url(forResource: "PathData/edge", withExtension: "geojson") else {
            return
        }
        guard let jsonData = try? Data(contentsOf: jsonUrl) else { return }
        do {
           edgeData = try JSONDecoder().decode(Geodata.self, from: jsonData)

        } catch {
           print("\(error)")
        }
        
        //make connections for stairList3
        for stairs in stairList3{
            let index1 = nodes.0.firstIndex(of: stairs[0])!
            let index2 = nodes.0.firstIndex(of: stairs[1])!
            let index3 = nodes.0.firstIndex(of: stairs[2])!
            
            stairPoints.append(nodes.1[index1])
            stairPoints.append(nodes.1[index2])
            stairPoints.append(nodes.1[index3])
            
            createConnection(from: nodes.1[index1], to: nodes.1[index2])
            createConnection(from: nodes.1[index2], to: nodes.1[index3])
            createConnection(from: nodes.1[index3], to: nodes.1[index2])
            createConnection(from: nodes.1[index2], to: nodes.1[index1])
        }
        //make connections for stairList2
        for stairs in stairList2{
            let index1 = nodes.0.firstIndex(of: stairs[0])!
            let index2 = nodes.0.firstIndex(of: stairs[1])!
            
            stairPoints.append(nodes.1[index1])
            stairPoints.append(nodes.1[index2])
            
            createConnection(from: nodes.1[index1], to: nodes.1[index2])
            createConnection(from: nodes.1[index2], to: nodes.1[index1])
        }
    
        //make rest of connections
        for edge in edgeData!.features{
            //print(edge.properties.nodes)
            let index1 = nodes.0.firstIndex(of: String(edge.properties.nodes[0]))!
            let index2 = nodes.0.firstIndex(of: String(edge.properties.nodes[1]))!

            createConnection(from: nodes.1[index1], to: nodes.1[index2])
            createConnection(from: nodes.1[index2], to: nodes.1[index1])
        }
        
    }
    
    //used to find path between 2 nodes
    func pathFind(to start: Simple2DNode, from end: Simple2DNode) -> [Simple2DNode]{
        let path = start.findPath(to: end)
        return path
    }
}
