address.geojson:
desciption: An Address represents a postal address, of official or proprietary designation, associated with an element of a venue.
notes: this is just used to specify the address of the building
	not sure if the "id" attribute needs changed, if so how

amenity.geoson:
desciption: An Amenity models the physical presence and approximate point location of a pedestrian amenity that serves a utilitarian purpose or other convenience that serves to enhance the pedestrian “experience.”
notes: in the museum example, this places points at things like elevators, restrooms, exhibits, etc.
	could potentially use this for room numbers...
	again, not sure if we need to replace the "id" attributes for each feature

anchor.geojson:
description: An Anchor represents the curated Point used as the preferred display location of a specific Address OR non-addressable device, service, equipment or physical environment. In both cases, the record serves as the anchoring point from which another feature (i.e. Occupant) can derive, reference or inherit the Anchor's attribution.
notes: i think this is a collection of points that are used as reference locations for units; for example, if we try to search "1505", this is where the marker would be located for 1505
	again, not sure if we need to replace the "id" attributes for each feature
	each anchor also has "address_id" and "unit_id" attrbibutes, so maybe the "id"s in each geojson file don't matter, as long as they align across files

building.geojson:
desciption: A Building describes a physical building structure associated with a Venue.
notes: the "address_id" attribute matches the "id" in address.geojson
	
footprint.geojson:
desciption: A Footprint models the approximate physical extent of one or more referenced Buildings.
notes: the museum example has three features for "subterranian", "ground", and "arial"; not sure if we would also do this
	can probably reuse the geometries from level.geojson

level.geojson:
desciption: A Level models the presence, location and approximate physical extent of a floor area in:
		A physical building where the Level's extent is expected to be analogous to the surface (facade) of the physical building at the height where the floor is positioned
		An outdoor environment that is functionally inseparable from the physical Venue
notes: seems to be exactly what it sounds like; models the levels of the building
	this is probably the first thing that we would need to construct

manifest.json:
desciption:
notes:

occupant.geojson:
desciption: An Occupant models the presence and location (via Anchor) of a business entity that trades goods and/or services.
notes: in the musuem example this is used to label restaurants and shops, including hours of service
	we could either use this for room labels, or even put the courses that use each particular room and when (example: Engineering Math V 11:30-12:20 MWF)

opening.geojson:
desciption: With few exceptions, an Opening models the presence, location and physical extent (width) of an entrance. An entrance may be a physical presence such as a door that swings, slides or rotates, a gate/turnstile, or threshold.
notes: doors/entryways

unit.geojson:
desciption: A Unit models the presence, location and approximate extent of a space. Extent may be characterized by:
		A barrier, such as a wall	
		A physical boundary, not necessarily delimitted by a barrier, but beyond which traversal is not expected, such as the edge of a train platform
		A legal instrument, such as the description of a gross leasable area
notes: for our purposes, this will be rooms

venue.geojson:
desciption: A Venue models the presence, location and approximate extent of a place. A Venue is an abstract modeling concept whose only tangible elements are the associated descriptive properties, and the other feature types that lay within it which model physical items such as buildings, floors and rooms. Ideally, the polygonal geometry of a Venue feature represents a formal property boundary associated with the Venue.
notes: this seems to be one general boundary of the building, across all levels (property boundary perhaps)
	we could probably just use the geometry provided by apple maps already for this