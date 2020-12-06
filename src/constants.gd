extends Node

const MAIN_FONT_NORMAL: Font = \
        preload("res://assets/fonts/main_font_normal.tres")

const CELL_SIZE := Vector2(32.0, 32.0)

#586e9a
var WALL_COLOR := Color.from_hsv(0.611, 0.43, 0.6, 1.0)
#273149
var BACKGROUND_DARKEST_COLOR := Color.from_hsv(0.617, 0.47, 0.29, 1.0)
#146363
var BUTTON_COLOR := Color.from_hsv(0.5, 0.8, 0.39, 1.0) 

var INDICATOR_GREEN_COLOR := Color.from_hsv(0.569, 0.78, 0.68, 1.0)
var INDICATOR_BLUE_COLOR := Color.from_hsv(0.472, 0.40, 0.77, 1.0)
var PLAYER_JACKET_YELLOW_COLOR := Color.from_hsv(0.1583, 1.0, 1.0, 1.0)
var PLAYER_PANTS_BLUE_COLOR := Color.from_hsv(0.6083, 0.68, 0.95, 1.0)

var JUMP_COLOR := Color.from_hsv(0.45, 1.0, 0.9, 1.0)
var MOVE_LEFT_COLOR := Color.from_hsv(0.117, 1.0, 0.9, 1.0)
var MOVE_RIGHT_COLOR := Color.from_hsv(0.783, 1.0, 0.9, 1.0)
var UNKNOWN_COLOR := Color.from_hsv(0.0, 0.0, 0.8, 1.0)

const TRANSITION_TO_POST_STUCK_DURATION_SEC := 0.5
