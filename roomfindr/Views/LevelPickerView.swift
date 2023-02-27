/*
 
 LevelPickerView.swift
 roomfindr

 This file specifies the styles for the level-picker apparatus on the main view.

 Created on 2/25/23.
 
 */

import UIKit

// a protocol defines an outline for methods that can be adopted by classes
// this protocol connects the level-picker to the selectedLevelDidChange function
@objc protocol LevelPickerDelegate: AnyObject {
    func selectedLevelDidChange(selectedIndex: Int)
}

/// Defines the style and function of the level-picker apparatus.
class LevelPickerView: UIView {
    @IBOutlet weak var delegate: LevelPickerDelegate?   // delegate for the level-picker; allows us to call selectedLevelDidChange
    @IBOutlet var backgroundView: UIVisualEffectView!   // connects to the level-picker background in main storyboard
    @IBOutlet var stackView: UIStackView!               // connects to the level-picker stack in main storyboard

    
    var levelNames: [String] = [] {                     // list of the (short) names of the levels
        didSet {
            // generates the stack view; also populates buttons var
            self.generateStackViewButtons()
        }
    }

    
    private var buttons: [UIButton] = []                // list of UIButton objects on the stack view
    var selectedIndex: Int? {                           // the index of the button which is currently selected
        didSet {
            // resets the color of a previously selected button to the default color
            if let oldIndex = oldValue {
                buttons[oldIndex].backgroundColor = nil
            }

            // sets the color of the currently selected button to a darker shade
            if let index = selectedIndex {
                buttons[index].backgroundColor = UIColor(named: "LevelPickerSelected")
                delegate?.selectedLevelDidChange(selectedIndex: index)
            }
        }
    }

    /// Initializer method; just calls the UIView initializer.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    /// From Apple's documentation: prepares the receiver for service after it has been loaded from an Interface Builder archive, or nib file.
    override func awakeFromNib() {
        backgroundView.layer.cornerRadius = 10
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowOpacity = 0.4
        self.layer.shadowRadius = 3.0

        super.awakeFromNib()
    }

    /// Generates a button for each level in the building, styles the buttons, and then adds them to a stack view.
    private func generateStackViewButtons() {
        // remove the existing stack view items
        let existingViews = stackView.arrangedSubviews
        for view in existingViews {
            stackView.removeArrangedSubview(view)
        }
        buttons.removeAll()

        // create a new stack by iterating through the levels and initializing buttons
        for (index, levelName) in levelNames.enumerated() {
            // create a button for the current level; set its title (level name), color, and height
            let levelButton = UIButton(type: .custom)
            levelButton.setTitle(levelName, for: .normal)
            levelButton.setTitleColor(.label, for: .normal)
            levelButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
            
            // associate the button with an index so that it can be easily referenced later
            levelButton.tag = index

            // add the button to the stack view
            stackView.addArrangedSubview(levelButton)
            levelButton.addTarget(self, action: #selector(levelSelected(sender:)), for: .primaryActionTriggered)

            // add a separator view between each button
            if index < levelNames.count - 1 {
                let separator = UIView()
                separator.backgroundColor = UIColor.separator
                separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
                stackView.addArrangedSubview(separator)
            }

            buttons.append(levelButton)
        }
    }
    
    /// This function gets called when a button in the level-picker is selected. It validates the selected index is in the correct bounds.
    /// - Parameter sender: The UIButton that initiated this function call
    @objc
    private func levelSelected(sender: UIButton) {
        let selectedIndex = sender.tag
        precondition(selectedIndex >= 0 && selectedIndex < levelNames.count)
        self.selectedIndex = selectedIndex
    }
}
