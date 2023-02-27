/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The base class for all IMDF Features.
*/

import Foundation
import MapKit

class Feature<Properties: Decodable>: NSObject, IMDFDecodableFeature {
    let identifier: UUID
    let properties: Properties
    let geometry: [MKShape & MKGeoJSONObject]
    
    required init(feature: MKGeoJSONFeature) throws {
        guard let uuidString = feature.identifier else {
            print("Feature:18")
            throw IMDFError.invalidData
        }
        
        if let identifier = UUID(uuidString: uuidString) {
            self.identifier = identifier
        } else {
            print("Feature:25")
            throw IMDFError.invalidData
        }
        
        if let propertiesData = feature.properties {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            properties = try decoder.decode(Properties.self, from: propertiesData)
        } else {
            print("Feature:34")
            throw IMDFError.invalidData
        }
        
        self.geometry = feature.geometry
        
        super.init()
    }
}

