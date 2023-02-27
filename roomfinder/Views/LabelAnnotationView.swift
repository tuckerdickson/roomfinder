/*
 
 LabelAnnotationView.swift
 roomfindr

 Displays points of interest with a label.

 Created on 2/25/23.
 
 */

import MapKit

/// Displays points of interest with a label.
class LabelAnnotationView: MKAnnotationView {
    
    var label: UILabel          // the label corresponding to the point of interest
    var bubble: UIView           // the bubble that pops up when a POI is clicked on
    
    override var annotation: MKAnnotation? {
        didSet {
            // update the label title to ensure it represents the current annotation
            if let title = annotation?.title {
                label.text = title
            } else {
                label.text = nil
            }
        }
    }
    
    /// Main initializer; sets stylistic constrains on label and bubble.
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        // call MKAnnotationView initializer
        label = UILabel(frame: .zero)
        bubble = UIView(frame: .zero)
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        // set label font
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        addSubview(label)
        
        // set label constriants
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        // bubble stylistic constraints
        let radius: CGFloat = 5.0
        bubble.layer.cornerRadius = radius
        bubble.layer.borderWidth = 1.0
        bubble.layer.borderColor = UIColor(named: "AnnotationBorder")?.cgColor
        self.addSubview(bubble)
        
        // set the bubble so that it is centered and above label
        bubble.translatesAutoresizingMaskIntoConstraints = false
        bubble.widthAnchor.constraint(equalToConstant: radius * 2).isActive = true
        bubble.heightAnchor.constraint(equalToConstant: radius * 2).isActive = true
        bubble.topAnchor.constraint(equalTo: topAnchor).isActive = true
        bubble.centerXAnchor.constraint(equalTo: label.centerXAnchor).isActive = true
        bubble.bottomAnchor.constraint(equalTo: label.topAnchor).isActive = true
        
        // set view's center offset so that it is anchored on the point
        // shift the callout (bubble) view to appear right above the point
        centerOffset = CGPoint(x: 0, y: label.font.lineHeight / 2 )
        calloutOffset = CGPoint(x: 0, y: -radius)
        canShowCallout = true
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    /// Required initializer.
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // the background color for the bubble
    override var backgroundColor: UIColor? {
        get {
            return bubble.backgroundColor
        }
        set {
            bubble.backgroundColor = newValue
        }
    }
}
