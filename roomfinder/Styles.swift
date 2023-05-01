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
        overlayRenderer.fillColor = UIColor(named: "WalkwayFill")
        overlayRenderer.lineWidth = 2.0
    }
}

// defines color and linewidth for units based on their category
extension Unit: StylableFeature {
    // the different types of units that we use
    private enum StylableCategory: String {
        case bathroom

    }
    
    // specify the approprite fill color for the unit based on its category
    func configure(overlayRenderer: MKOverlayPathRenderer) {
        if let category = StylableCategory(rawValue: self.properties.category) {
            switch category {
            case .bathroom:
                overlayRenderer.fillColor = UIColor(named: "RestroomFill")
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
    private enum StylableCategory: String {
        //case exhibit
        case restroom
        case elevator
        case stairs
    }
    
    // define annotation colors for different categories of amenities
    func configure(annotationView: MKAnnotationView) {
        if let category = StylableCategory(rawValue: self.properties.category) {
            switch category {
            case .restroom:
                annotationView.backgroundColor = UIColor(named: "RestroomFill")
                annotationView.image = UIImage(systemName: "figure.dress.line.vertical.figure")
            case .elevator:
                annotationView.backgroundColor = UIColor(named: "RestroomFill")
                annotationView.image = UIImage(systemName: "arrow.up.arrow.down.square")
            case .stairs:
                annotationView.backgroundColor = UIColor(named: "RestroomFill")
                annotationView.image = UIImage(systemName: "stairs")
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
        case classroom
        case auditorium
        case lab
        case office
        case conference
        case library

    }

    // configure the annotation color for each type of occupant above
    func configure(annotationView: MKAnnotationView) {
        if let category = StylableCategory(rawValue: self.properties.category) {
            switch category {
            case .classroom:
                annotationView.backgroundColor = UIColor(named: "ClassroomFill")
            case .auditorium:
                annotationView.backgroundColor = UIColor(named: "AuditoriumFill")
            case .office:
                annotationView.backgroundColor = UIColor(named: "OfficeFill")
            case .lab:
                annotationView.backgroundColor = UIColor(named: "LabFill")
            case .conference:
                annotationView.backgroundColor = UIColor(named: "ConferenceFill")
            case .library:
                annotationView.backgroundColor = UIColor(named: "LibraryFill")

            }
        } else {
            annotationView.backgroundColor = UIColor(named: "DefaultAmenityFill")
        }

        // typically, occupants have higher priority than amenities
        annotationView.displayPriority = .defaultHigh
    }
}
