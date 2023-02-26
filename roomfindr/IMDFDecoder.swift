/*
 
 IMDFDecoder.swift
 roomfindr

 This file defines the underlying framework for reading, decoding, and processing IMDF files.

 Created on 2/25/23.
 
 */

import Foundation
import MapKit

// a protocol defines an outline for methods that can be adopted by classes
// this protocol defines how to decode IMDF features
protocol IMDFDecodableFeature {
    init(feature: MKGeoJSONFeature) throws
}

// defines two errors relating to IMDF data processing
enum IMDFError: Error {
    case invalidType
    case invalidData
}

/// Defines the path to the collection of IMDF files & the different types they can take.
private struct IMDFArchive {
    let baseDirectory: URL              // path to the IMDF files
    
    /// IMDFArchive initializer
    /// - Parameter directory: A URL to the IMDF archive.
    /// - Returns: An IMDFArchive object.
    init(directory: URL) {
        baseDirectory = directory
    }
    
    // IMDF files can take on one of the following types
    enum File {
        case address
        case amenity
        case anchor
        case building
        case footprint
        case level
        case manifest
        case occupant
        case opening
        case unit
        case venue
        
        // returns the name of the file with ".geojson" attached
        var filename: String {
            return "\(self).geojson"
        }
    }
    
    /// Crafts the path to file by appending file's name to the archive directory.
    /// - Parameter file: The file for which the path should be retrieved.
    /// - Returns: The path to the file.
    func fileURL(for file: File) -> URL {
        return baseDirectory.appendingPathComponent(file.filename)
    }
}

/// This class is used to decode IMDF data into something that we can represent on the map.
class IMDFDecoder {
    private let geoJSONDecoder = MKGeoJSONDecoder()             // object that decodes GeoJSON
    
    /// Decodes an IMDF archive so that the features can be represented on the map.
    /// - Parameter imdfDirectory: The URL to the IMDF archive.
    /// - Returns: A Venue object representing the Venue feature in the archive.
    func decode(_ imdfDirectory: URL) throws -> Venue {
        let archive = IMDFArchive(directory: imdfDirectory)
        
        // decode each of the individual features
        let venues = try decodeFeatures(Venue.self, from: .venue, in: archive)
        let levels = try decodeFeatures(Level.self, from: .level, in: archive)
        let units = try decodeFeatures(Unit.self, from: .unit, in: archive)
        let openings = try decodeFeatures(Opening.self, from: .opening, in: archive)
        let amenities = try decodeFeatures(Amenity.self, from: .amenity, in: archive)
        let occupants = try decodeFeatures(Occupant.self, from: .occupant, in: archive)
        let anchors = try decodeFeatures(Anchor.self, from: .anchor, in: archive)
        
        // associate the different levels to the venue
        // there can only be one venue
        guard venues.count == 1 else {
            throw IMDFError.invalidData
        }
        let venue = venues[0]
        
        // order the levels by their ordinals (increasing)
        venue.levelsByOrdinal = Dictionary(grouping: levels, by: { $0.properties.ordinal })
        
        // levels contain units and openings; group the units and openings by their level identifier
        let unitsByLevel = Dictionary(grouping: units, by: { $0.properties.levelId })
        let openingsByLevel = Dictionary(grouping: openings, by: { $0.properties.levelId })

        // associate each level with its corresponding units and openings
        for level in levels {
            if let unitsInLevel = unitsByLevel[level.identifier] {
                level.units = unitsInLevel
            }
            if let openingsInLevel = openingsByLevel[level.identifier] {
                level.openings = openingsInLevel
            }
        }
        
        // units contain amenities
        let unitsById = units.reduce(into: [UUID: Unit]()) {
            $0[$1.identifier] = $1
        }

        // associate each amenity with its corresponding unit
        for amenity in amenities {
            // obtain geometry of the amenity
            guard let pointGeometry = amenity.geometry[0] as? MKPointAnnotation else {
                throw IMDFError.invalidData
            }
            amenity.coordinate = pointGeometry.coordinate
            
            // assign title (name) and subtitle (category)
            if let name = amenity.properties.name?.bestLocalizedValue {
                amenity.title = name
                amenity.subtitle = amenity.properties.category.capitalized
            } else {
                amenity.title = amenity.properties.category.capitalized
            }
            
            // associate this amenity with each corresponding unit
            for unitID in amenity.properties.unitIds {
                let unit = unitsById[unitID]
                unit?.amenities.append(amenity)
            }
        }
        
        // units also contain occupants; need to associate occupants with units
        // occupants don't themselves possess geomtry, they rely on anchors for this (see below)
        let anchorsById = anchors.reduce(into: [UUID: Anchor]()) {
            $0[$1.identifier] = $1
        }

        // associate each occupant with appropriate unit
        for occupant in occupants {
            guard let anchor = anchorsById[occupant.properties.anchorId] else {
                throw IMDFError.invalidData
            }
            
            // get the location of the occupant from corresponding anchor
            guard let pointGeometry = anchor.geometry[0] as? MKPointAnnotation else {
                throw IMDFError.invalidData
            }
            occupant.coordinate = pointGeometry.coordinate
            
            // assign title (name) and subtitle (category)
            if let name = occupant.properties.name.bestLocalizedValue {
                occupant.title = name
                occupant.subtitle = occupant.properties.category.capitalized
            } else {
                occupant.title = occupant.properties.category.capitalized
            }
            
            // guard against incorrect unit identifiers
            guard let unit = unitsById[anchor.properties.unitId] else {
                continue
            }
            
            // associate occupants to units and vice versa
            unit.occupants.append(occupant)
            occupant.unit = unit
        }
        
        return venue
    }
    
    /// Decodes a single IMDF file.
    /// - Parameter type: The type of feature to be decoded (Venue, Level, etc.).
    /// - Parameter file: The file to be decoded.
    /// - Parameter archive: The archive that the file resides in.
    /// - Returns: A list of IMDFDecodableFeatures.
    private func decodeFeatures<T: IMDFDecodableFeature>(_ type: T.Type, from file: IMDFArchive.File, in archive: IMDFArchive) throws -> [T] {
        // get the URL for the file to decode
        let fileURL = archive.fileURL(for: file)
        
        // read the contens of the file from disk
        let data = try Data(contentsOf: fileURL)
        
        // decode the data
        let geoJSONFeatures = try geoJSONDecoder.decode(data)
        
        // try to convert the list of MKGeoJSONObject returned from decode to a list of MKGeoJSONFeature
        guard let features = geoJSONFeatures as? [MKGeoJSONFeature] else {
            throw IMDFError.invalidType
        }
        
        // initialize instances of our model classes
        let imdfFeatures = try features.map { try type.init(feature: $0) }
        return imdfFeatures
    }
}

