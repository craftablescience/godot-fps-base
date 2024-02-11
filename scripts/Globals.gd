extends Node


# debug
var DEBUG := OS.is_debug_build()
var DEBUG_OPTS := {
	"start_windowed":  DEBUG && 1,
	"skip_intro":      1, # HACK - intro theme doesn't fit game
	"use_promo_menu":  DEBUG && 0,
	"can_sprint":      DEBUG && 1,
	"force_map":       "",
}


# default values
const UNKNOWN_NAME := "???"
const KNOWN_NAME := "Alex"


# settings that aren't signals yet
var invert_y := false
var field_of_view := 70.0


# utils
func get_weekday_string(weekday: int) -> String:
	match weekday:
		0: return "Sunday"
		1: return "Monday"
		2: return "Tuesday"
		3: return "Wednesday"
		4: return "Thursday"
		5: return "Friday"
		6: return "Saturday"
	return "Unknown"
