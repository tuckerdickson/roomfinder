/*
 
 PointAnnotationView.swift
 roomfindr

 Displays annotations on the map view.

 Created on 2/25/23.
 
 */

import MapKit

/// Displays annotations on the map view.
class PointAnnotationView: MKAnnotationView {
    /// Main initializer; displays annotation on the map view.
    /// - Parameter annotation: The MKAnnotation to display.
    /// - Parameter reuseIdentifier: If you plan to reuse the annotation view for similar types of annotations, pass a string to identify it (or nil if you don't).
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        // make call to MKAnnotationView initializer
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        // style the mnew annotation
        self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: 10, height: 10)
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor(named: "AnnotationBorder")?.cgColor
        self.canShowCallout = true
    }
    
    /// Required initializer.
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
