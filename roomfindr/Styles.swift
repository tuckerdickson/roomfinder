/*
 
 Styles.swift
 roomfindr

 This file defines the styles for all annotations and overlays.
 Side notes:
    - the various UIColor object referenced in this file are defined in the assets folder.
    - strokeColor defines the color of lines
    - fillColor defines the color of an area
    - backgroundColor defines the color of annotations (circular markers)

 Created on 2/25/23.
 
 */

import MapKit

// a protocol defines an outline for methods that can be adopted by classes
// this protocol defines a template for features which contain geometry, annotations, and overlays
protocol StylableFeature {
    var geometry: [MKShape & MKGeoJSONObject] { get }
    func configure(overlayRenderer: MKOverlayPathRenderer)
    func configure(annotationView: MKAnnotationView)
}

// default implementations for StylableFeature protocol methods.
extension StylableFeature {
    func configure(overlayRenderer: MKOverlayPathRenderer) {}
    func configure(annotationView: MKAnnotationView) {}
}

// defines the color and width of level lines
extension Level: StylableFeature {
    func configure(overlayRenderer: MKOverlayPathRenderer) {
        overlayRenderer.strokeColor = UIColor(named: "LevelStroke")
        overlayRenderer.lineWidth = 2.0
    }
}

// defines color and linewidth for units based on their category
extension Unit: StylableFeature {
    // the different types of units that we use
    private enum StylableCategory: String {
        case elevator
        case stairs
        case restroom
        case restroomMale = "restroom.male"
        case restroomFemale = "restroom.female"
        case room
        case walkway
    }
    
    // specify the approprite fill color for the unit based on its category
    func configure(overlayRenderer: MKOverlayPathRenderer) {
        if let category = StylableCategory(rawValue: self.properties.category) {
            switch category {
            case .elevator, .stairs:
                overlayRenderer.fillColor = UIColor(named: "ElevatorFill")
            case .restroom, .restroomMale, .restroomFemale:
                overlayRenderer.fillColor = UIColor(named: "RestroomFill")
            case .room:
                overlayRenderer.fillColor = UIColor(named: "RoomFill")
            case .walkway:
                overlayRenderer.fillColor = UIColor(named: "WalkwayFill")
            }
        } else {
            overlayRenderer.fillColor = UIColor(named: "DefaultUnitFill")
        }

        // line color and width is the same for all units
        overlayRenderer.strokeColor = UIColor(named: "UnitStroke")
        overlayRenderer.lineWidth = 1.3
    }
}

// defines the color and width of opening lines
extension Opening: StylableFeature {
    func configure(overlayRenderer: MKOverlayPathRenderer) {
        // set the line color of openings to match the walkway fill color
        // makes the opening lines "invisible"
        overlayRenderer.strokeColor = UIColor(named: "WalkwayFill")
        overlayRenderer.lineWidth = 2.0
    }
}

// defines color for differenty types of amenities
extension Amenity: StylableFeature {
    // the different types of amenities that we're insterested in
    // TODO: figure out if we have any cases to add here; if not, delete this
    private enum StylableCategory: String {
        case exhibit
    }
    
    // define annotation colors for different categories of amenities
    func configure(annotationView: MKAnnotationView) {
        if let category = StylableCategory(rawValue: self.properties.category) {
            switch category {
            case .exhibit:
                annotationView.backgroundColor = UIColor(named: "ExhibitFill")
            }
        } else {
            annotationView.backgroundColor = UIColor(named: "DefaultAmenityFill")
        }
        
        // most amenities have lower display priority than occupants
        annotationView.displayPriority = .defaultLow
    }
}

// defines the annotation color for different types of occupants
extension Occupant: StylableFeature {
    // the types of occupant that we're interested in
    private enum StylableCategory: String {
        case restaurant
        case shopping
    }

    // configure the annotation color for each type of occupant above
    func configure(annotationView: MKAnnotationView) {
        if let category = StylableCategory(rawValue: self.properties.category) {
            switch category {
            case .restaurant:
                annotationView.backgroundColor = UIColor(named: "RestaurantFill")
            case .shopping:
                annotationView.backgroundColor = UIColor(named: "ShoppingFill")
            }
        }

        // typically, occupants have higher priority than amenities
        annotationView.displayPriority = .defaultHigh
    }
}
