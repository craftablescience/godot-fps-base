extends Node


# debug
var DEBUG := OS.is_debug_build()
var DEBUG_OPTS := {
	"start_windowed":  DEBUG && 1, # Start game windowed
	"use_promo_menu":  DEBUG && 0, # Show the menu designed for a promo image on a store page
	"can_sprint":      DEBUG && 1, # Player character can sprint faster
	"force_map":       "",         # If this string has a value, will load the specified map instead of the starting map
}


# settings that aren't signals yet
var invert_y := false
var field_of_view := 70.0
