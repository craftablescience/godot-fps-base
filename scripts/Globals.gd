extends Node


# debug
var DEBUG := OS.is_debug_build()
var GLOBAL_OPTS := {
	"skip_seizure_warning": DEBUG && 1, # Skip seizure warning
	"start_windowed":       DEBUG && 1, # Start game windowed
	"use_promo_menu":       DEBUG && 0, # Show the menu designed for a promo image on a store page
	"show_debug_stats":     DEBUG && 1, # Show debug stats like FPS by default
	"start_map":            "Map",      # The first map to load the player into
	"player_can_jump":      true        # Player can jump
}


# settings
var invert_y := false
var field_of_view := 70.0
var mouse_sensitivity := 0.1
