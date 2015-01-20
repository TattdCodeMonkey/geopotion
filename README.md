GeoPotion
=========
[![Build Status](https://travis-ci.org/TattdCodeMonkey/geopotion.png?branch=master)](https://travis-ci.org/TattdCodeMonkey/geopotion)

*** WIP ***

This is an Elixir module for dealing with geo spatial data. 

Angle    - stores an angle in either decimal degrees or radians. has functions for normalizing and conversions

Distance - stores a distance value in a subset of supported units of measure. has functions for converting between units

Position - simple structure for holding a latitude, longitude and altitude. Values are decimal degrees and meters HAE for altitude
	   * this module is a work in progress.

Vector   - module used to calculate vectors between two geo positions. uses vincenty formula
	   * this module is a work in progress
