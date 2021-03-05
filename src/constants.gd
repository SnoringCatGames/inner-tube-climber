extends Node

# TODO: Remember to reset these when creating releases.
var DEBUG := OS.is_debug_build()
#var DEBUG := false
var PLAYTEST := true
var ARE_ALL_LEVELS_UNLOCKED := false
var DEBUG_TIER := ""

const RECENT_GESTURE_EVENTS_FOR_DEBUGGING_BUFFER_SIZE := 1000

const GOOGLE_ANALYTICS_ID := "UA-186405125-1"

const APP_NAME := "Inner-Tube Climber"
const APP_ID := "games.snoringcat.inner_tube_climber"
const APP_VERSION := "0.9.0"
const SCORE_VERSION := "1.0.1"

const SNORING_CAT_GAMES_URL := "https://snoringcat.games"
const GODOT_URL := "https://godotengine.org"
const TERMS_AND_CONDITIONS_URL := "https://snoringcat.games/inner-tube-climber/terms-and-conditions"
const PRIVACY_POLICY_URL := "https://snoringcat.games/inner-tube-climber/privacy-policy"
const ANDROID_APP_STORE_URL := "market://details?id=dev.levi.inner_tube_climber"
# FIXME
const IOS_APP_STORE_URL := "itms-apps://apps.apple.com/us/app/inner-tube-climber/id1553158659"
#const IOS_APP_STORE_URL := "itms-apps://apps.apple.com/us/app/id1553158659"
#const IOS_APP_STORE_URL := "itms-apps://itunes.apple.com/app/apple-store/id1553158659?mt=8"
#const IOS_APP_STORE_URL := "https://apps.apple.com/us/app/inner-tube-climber/id1553158659"
const SUPPORT_URL_BASE := "https://snoringcat.games/support"
const LOG_GESTURES_URL := "https://snoringcat.games/log/gestures"

var GODOT_SPLASH_SCREEN_DURATION_SEC := 0.8 if !DEBUG else 0.0
var SNORING_CAT_SPLASH_SCREEN_DURATION_SEC := 1.0 if !DEBUG else 0.0
const LEVELS_COUNT_BEFORE_SHOWING_RATE_APP_SCREEN := 3

const MAIN_FONT_NORMAL: Font = \
        preload("res://assets/fonts/main_font_normal.tres")
const MAIN_FONT_LARGE: Font = \
        preload("res://assets/fonts/main_font_l.tres")
const MAIN_FONT_XL: Font = \
        preload("res://assets/fonts/main_font_xl.tres")

const CELL_SIZE := Vector2(32.0, 32.0)

const PLAYER_SIZE_MULTIPLIER := 1.0

const GROUP_NAME_TIER_TILE_MAPS := "tier_tilemaps"
const GROUP_NAME_ONE_UPS := "one_ups"

const ASPECT_RATIO_MAX := 1.0 / 1.0
const ASPECT_RATIO_MIN := 1.0 / 1.3
#const ASPECT_RATIO_MIN := 1.0 / 1.75
const LEVEL_BASE_PLATFORM_WIDTH_CELL_COUNT := 12.0
const LEVEL_VISIBLE_WIDTH_CELL_COUNT := 15.0
const LEVEL_MIN_HEIGHT_CELL_COUNT := \
        LEVEL_VISIBLE_WIDTH_CELL_COUNT / ASPECT_RATIO_MIN

const INPUT_VIBRATE_DURATION_SEC := 0.01

const DISPLAY_RESIZE_THROTTLE_INTERVAL_SEC := 0.1

const PLAYER_CAPSULE_RADIUS_DEFAULT := 15.66 * PLAYER_SIZE_MULTIPLIER
const PLAYER_CAPSULE_HEIGHT_DEFAULT := 14.12 * PLAYER_SIZE_MULTIPLIER
const PLAYER_HALF_WIDTH_DEFAULT := PLAYER_CAPSULE_RADIUS_DEFAULT
const PLAYER_HALF_HEIGHT_DEFAULT := \
        PLAYER_CAPSULE_RADIUS_DEFAULT + PLAYER_CAPSULE_HEIGHT_DEFAULT * 0.5
#const PLAYER_HALF_WIDTH_DEFAULT := 15.5 * PLAYER_SIZE_MULTIPLIER
#const PLAYER_HALF_HEIGHT_DEFAULT := 24.0 * PLAYER_SIZE_MULTIPLIER

#586e9a
var WALL_COLOR := Color.from_hsv(0.611, 0.43, 0.6, 1.0)
#273149
var BACKGROUND_DARKEST_COLOR := Color.from_hsv(0.617, 0.47, 0.29, 1.0)
#576d99
var BUTTON_COLOR_NORMAL := Color.from_hsv(0.6111, 0.43, 0.6, 1.0)
#89b4f0
var BUTTON_COLOR_HOVER := Color.from_hsv(0.597, 0.43, 0.94, 1.0)
#3a446e
var BUTTON_COLOR_PRESSED := Color.from_hsv(0.633, 0.47, 0.43, 1.0)
#273149
var SCREEN_BACKGROUND_COLOR := Color.from_hsv(0.617, 0.47, 0.29, 1.0)
#313b52
var KEY_VALUE_EVEN_ROW_COLOR := Color.from_hsv( \
        SCREEN_BACKGROUND_COLOR.h, 0.4, 0.32, 1.0)
#313b52
var DROPDOWN_PANEL_BACKGROUND_COLOR := KEY_VALUE_EVEN_ROW_COLOR

var OPTION_BUTTON_COLOR_NORMAL := SCREEN_BACKGROUND_COLOR
#3e4c6f
var OPTION_BUTTON_COLOR_HOVER := Color.from_hsv(0.619, 0.44, 0.44, 1.0)
#1b2235
var OPTION_BUTTON_COLOR_PRESSED := Color.from_hsv(0.622, 0.49, 0.21, 1.0)

var INDICATOR_GREEN_COLOR := Color.from_hsv(0.569, 0.78, 0.68, 1.0)
var INDICATOR_BLUE_COLOR := Color.from_hsv(0.472, 0.40, 0.77, 1.0)
var PLAYER_JACKET_YELLOW_COLOR := Color.from_hsv(0.1583, 1.0, 1.0, 1.0)
var PLAYER_PANTS_BLUE_COLOR := Color.from_hsv(0.6083, 0.68, 0.95, 1.0)

var JUMP_COLOR := Color.from_hsv(0.45, 1.0, 0.9, 1.0)
var MOVE_LEFT_COLOR := Color.from_hsv(0.117, 1.0, 0.9, 1.0)
var MOVE_RIGHT_COLOR := Color.from_hsv(0.783, 1.0, 0.9, 1.0)
var UNKNOWN_COLOR := Color.from_hsv(0.0, 0.0, 0.8, 1.0)

const TRANSITION_TO_POST_STUCK_DURATION_SEC := 0.5
