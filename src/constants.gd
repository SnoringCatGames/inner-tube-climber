extends Node

const GOOGLE_ANALYTICS_ID := "UA-186405125-1"

const APP_NAME := "Inner-Tube Climber"
const APP_ID := "dev.levi.inner_tube_climber"
const APP_VERSION := "0.1.0"
const SCORE_VERSION := "0.1.0"

const LEVI_URL := "https://levi.dev"
const GODOT_URL := "https://godotengine.org"
const TERMS_AND_CONDITIONS_URL := "https://docs.google.com/document/d/1g1W4F2nJqJsIPKOwRGlFJi4IGj5q1ae7upYOTnVtfyI/preview"
const PRIVACY_POLICY_URL := "https://docs.google.com/document/d/1kH48Xn62wFnZuy8wFmrsr4lKJ-k3wU-MnqFpYdhwBCc/preview"
# FIXME:
const ANDROID_APP_STORE_URL := "http://"
const IOS_APP_STORE_URL := "https://"
const SUPPORT_EMAIL := "support@levi.dev"

const MAIN_FONT_NORMAL: Font = \
        preload("res://assets/fonts/main_font_normal.tres")

const CELL_SIZE := Vector2(32.0, 32.0)

const PLAYER_SIZE_MULTIPLIER := 1.5

const GROUP_NAME_TIER_TILE_MAPS := "tier_tilemaps"

const ASPECT_RATIO_MAX := 1.0 / 1.0
const ASPECT_RATIO_MIN := 1.0 / 1.75
const LEVEL_BASE_PLATFORM_WIDTH_CELL_COUNT := 12.0
const LEVEL_VISIBLE_WIDTH_CELL_COUNT := 15.0
const LEVEL_MIN_HEIGHT_CELL_COUNT := \
        LEVEL_VISIBLE_WIDTH_CELL_COUNT / ASPECT_RATIO_MIN

const INPUT_VIBRATE_DURATION_SEC := 0.01

const DISPLAY_RESIZE_THROTTLE_INTERVAL_SEC := 0.1

const PLAYER_CAPSULE_RADIUS_DEFAULT := 12.106 * PLAYER_SIZE_MULTIPLIER
const PLAYER_CAPSULE_HEIGHT_DEFAULT := 7.747 * PLAYER_SIZE_MULTIPLIER
const PLAYER_HALF_HEIGHT_DEFAULT := \
        PLAYER_CAPSULE_RADIUS_DEFAULT + PLAYER_CAPSULE_HEIGHT_DEFAULT * 0.5

#586e9a
var WALL_COLOR := Color.from_hsv(0.611, 0.43, 0.6, 1.0)
#273149
var BACKGROUND_DARKEST_COLOR := Color.from_hsv(0.617, 0.47, 0.29, 1.0)
#146363
var BUTTON_COLOR := Color.from_hsv(0.5, 0.8, 0.39, 1.0)
#273149
var SCREEN_BACKGROUND_COLOR := Color.from_hsv(0.617, 0.47, 0.29, 1.0)
var KEY_VALUE_EVEN_ROW_COLOR := Color.from_hsv( \
        SCREEN_BACKGROUND_COLOR.h, 0.1, 0.9, 0.05)

var INDICATOR_GREEN_COLOR := Color.from_hsv(0.569, 0.78, 0.68, 1.0)
var INDICATOR_BLUE_COLOR := Color.from_hsv(0.472, 0.40, 0.77, 1.0)
var PLAYER_JACKET_YELLOW_COLOR := Color.from_hsv(0.1583, 1.0, 1.0, 1.0)
var PLAYER_PANTS_BLUE_COLOR := Color.from_hsv(0.6083, 0.68, 0.95, 1.0)

var JUMP_COLOR := Color.from_hsv(0.45, 1.0, 0.9, 1.0)
var MOVE_LEFT_COLOR := Color.from_hsv(0.117, 1.0, 0.9, 1.0)
var MOVE_RIGHT_COLOR := Color.from_hsv(0.783, 1.0, 0.9, 1.0)
var UNKNOWN_COLOR := Color.from_hsv(0.0, 0.0, 0.8, 1.0)

const TRANSITION_TO_POST_STUCK_DURATION_SEC := 0.5
