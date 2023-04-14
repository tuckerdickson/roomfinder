//
//  pathfind.swift
//  roomfinder
//
//  Created by Abby Bright on 4/14/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation
import AStar
import MapKit


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


class createNodes{
    var coordinates: [Simple2DNode] = []
    
    //creates list of coordinates for only the floor you are currently on in app
    public func create(_ currentLevelAnnotations: [MKAnnotation]){
        print("here")
        print(currentLevelAnnotations)
        for unit in currentLevelAnnotations{
            let x = unit.coordinate.latitude
            let y = unit.coordinate.longitude
            coordinates.append(Simple2DNode(x: Float(x), y: Float(y)))
            print("Coordinates")
            print(x)
            print(y)
        }
    }

}
