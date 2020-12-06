extends Node2D
class_name Level

const MOBILE_CONTROL_UI_RESOURCE_PATH := "res://src/mobile_control_ui.tscn"
const SCORE_BOARDS_RESOURCE_PATH := "res://src/overlays/score_boards.tscn"
const PLAYER_RESOURCE_PATH := "res://src/player/tuber_player.tscn"
const TIER_RATIO_SIGN_RESOURCE_PATH := \
        "res://src/overlays/tier_ratio_sign.tscn"
const PAUSE_BUTTON_RESOURCE_PATH := "res://src/overlays/pause_button.tscn"

const START_TIER_ID := "0"

const INPUT_SIGN_POSITION := Vector2(0.0, 10.0)

const PLAYER_START_VELOCITY := Vector2(0.0, -300.0)

const NUMBER_OF_LEVELS_PER_MUSIC := 1

# How many pixels correspond to a single display-height unit. 
const DISPLAY_HEIGHT_INTERVAL := 32.0

const DEFAULT_WINDINESS := 1.0

const SCORE_PER_HEIGHT_PIXELS := 1.0 / DISPLAY_HEIGHT_INTERVAL
const _BASE_SCORE_FOR_TIER := 2048.0 * SCORE_PER_HEIGHT_PIXELS * 0.25
const SCORE_FOR_TIER_FOR_EASY_DIFFICULTY := _BASE_SCORE_FOR_TIER * 0.75
const SCORE_FOR_TIER_FOR_MODERATE_DIFFICULTY := _BASE_SCORE_FOR_TIER * 1.0
const SCORE_FOR_TIER_FOR_HARD_DIFFICULTY := _BASE_SCORE_FOR_TIER * 1.25

var previous_tier: Tier
var current_tier: Tier
var next_tier: Tier
var previous_tier_gap: TierGap
var next_tier_gap: TierGap
var current_tier_ratio_sign: TierRatioSign
var next_tier_ratio_sign: TierRatioSign

var windiness_tween: Tween

var mobile_control_ui: MobileControlUI
var score_boards: ScoreBoards
var cooldown_indicator: ScoreMultiplierCooldownIndicator
var max_height_indicator: MaxHeightIndicator
var max_height_on_current_height_indicator: MaxHeightIndicator
var pause_button: PauseButton

var level_id := ""
var start_tier_id := START_TIER_ID
var current_tier_id := START_TIER_ID
var current_tier_index := -1
var has_input_been_pressed := false
var is_game_playing := false
var tiers_count_since_falling := 0
var start_time := -INF

var player: TuberPlayer
var player_height: float setget ,_get_player_height
var player_max_height: float = 0.0
var player_max_height_on_current_life: float = 0.0
var player_latest_platform_height: float = 0.0
var player_max_platform_height: float = 0.0
var player_max_platform_height_on_current_life: float = 0.0
var tier_count: int = 0
var display_height: int = 0
var falls_count: int = 0
var lives_count: int = LevelConfig.DEFAULT_LIVES_COUNT
var score := 0.0
var windiness := DEFAULT_WINDINESS

func _enter_tree() -> void:
    Global.level = self
    
    score_boards = Utils.add_scene( \
            Global.canvas_layers.hud_layer, \
            SCORE_BOARDS_RESOURCE_PATH, \
            true, \
            false)
    
    cooldown_indicator = ScoreMultiplierCooldownIndicator.new()
    Global.canvas_layers.hud_layer.add_child(cooldown_indicator)
    cooldown_indicator.visible = Global.is_multiplier_cooldown_indicator_shown
    
    var extra_radius := 2.0
    var extra_distance_from_cone_end_point_to_circle_center := \
            extra_radius * 1.8
    var origin_offset := extra_distance_from_cone_end_point_to_circle_center
    
    max_height_on_current_height_indicator = MaxHeightIndicator.new( \
            Constants.INDICATOR_BLUE_COLOR, \
            extra_radius, \
            extra_distance_from_cone_end_point_to_circle_center, \
            0.0, \
            true)
    add_child(max_height_on_current_height_indicator)
    max_height_on_current_height_indicator.visible = \
            Global.is_height_indicator_shown
    
    max_height_indicator = MaxHeightIndicator.new( \
            Constants.INDICATOR_GREEN_COLOR, \
            0.0, \
            0.0, \
            origin_offset, \
            false)
    add_child(max_height_indicator)
    max_height_indicator.visible = Global.is_height_indicator_shown
    
    windiness_tween = Tween.new()
    add_child(windiness_tween)
    
    pause_button = Utils.add_scene( \
            Global.canvas_layers.hud_layer, \
            PAUSE_BUTTON_RESOURCE_PATH, \
            true, \
            true)

func _ready() -> void:
    $FogScreenHandler.connect( \
            "updated", \
            self, \
            "_on_fog_screen_updated")

func _unhandled_input(event: InputEvent) -> void:
    if !has_input_been_pressed and \
            (event.is_action_pressed("jump") or \
            event.is_action_pressed("move_left") or \
            event.is_action_pressed("move_right") or \
            ((event is InputEventMouseButton or \
            event is InputEventScreenTouch) and \
            event.pressed)):
        has_input_been_pressed = true
        
        # Only instantiate the player once the user has pressed a movement
        # button.
        if is_game_playing and \
                player != null and \
                player.is_stuck:
            _release_player()
        
        if current_tier_id != "0":
            $CameraHandler.update_speed()

func start( \
        level_id: String, \
        tier_id := START_TIER_ID) -> void:
    self.level_id = level_id
    self.start_time = Time.elapsed_play_time_actual_sec
    visible = true
    lives_count = LevelConfig.LEVELS[level_id].lives_count
    falls_count = 0
    score = 0.0
    _start_new_tier( \
            tier_id, \
            Vector2.ZERO, \
            Audio.START_MUSIC_INDEX)
    Audio.cross_fade_music(Audio.current_music_player_index)
    score_boards.visible = true

func _physics_process(_delta_sec: float) -> void:
    _delta_sec *= Time.physics_framerate_multiplier
    
    if !is_game_playing or \
            player == null or \
            player.is_stuck:
        return
    
    # Keep track of player height.
    var next_tier_height: float = -next_tier.position.y + Constants.CELL_SIZE.y
    if _get_player_height() > next_tier_height - 0.1:
        _on_entered_new_tier()
    player_max_height = max(player_max_height, _get_player_height())
    player_max_height_on_current_life = \
            max(player_max_height_on_current_life, _get_player_height())
    if player.surface_state.just_touched_floor:
        player_latest_platform_height = -player.surface_state.touch_position.y
        var platform_height_delta := \
                player_latest_platform_height - player_max_platform_height if \
                player_latest_platform_height > \
                        player_max_platform_height else \
                0.0
        player_max_platform_height = \
                max(player_max_platform_height, _get_player_height())
        player_max_platform_height_on_current_life = max( \
                player_max_platform_height_on_current_life, \
                _get_player_height())
        _update_score_for_height_change(platform_height_delta)
        Global.debug_panel.add_message( \
                "Platform height=%s" % player_latest_platform_height)
    display_height = \
            floor(player_max_platform_height / DISPLAY_HEIGHT_INTERVAL) as int
    
    cooldown_indicator.check_for_updates( \
            player_max_platform_height_on_current_life, \
            player_latest_platform_height, \
            !player.surface_state.is_touching_a_surface)
    max_height_indicator.check_for_updates(player_max_platform_height)
    max_height_on_current_height_indicator.check_for_updates( \
            player_max_platform_height_on_current_life)

func _process(delta_sec: float) -> void:
    delta_sec *= Time.physics_framerate_multiplier
    
    if !is_game_playing:
        return
    
    $FogScreenHandler.sync_to_player_position(player.position)
    
    if player.is_stuck:
        return
    
    $CameraHandler.sync_to_player_position( \
            delta_sec, \
            player.position, \
            _get_player_height())
    
    # Update score displays.
    score_boards.set_tier_ratio( \
            current_tier_index + 1, \
            LevelConfig.LEVELS[level_id].tiers.size())
    score_boards.set_height(display_height)
    score_boards.set_score(score)
    score_boards.set_multiplier(cooldown_indicator.multiplier)
    score_boards.set_speed($CameraHandler.speed_index + 1)
    score_boards.set_lives(lives_count)
    
    # Check for game over.
    if _get_player_height() < $CameraHandler.fall_height:
        _fall()

func _fall() -> void:
    falls_count += 1
    lives_count -= 1
    tiers_count_since_falling = 0
    player_max_height_on_current_life = 0.0
    player_latest_platform_height = 0.0
    player_max_platform_height_on_current_life = 0.0
    Global.falls_count_since_reaching_level_end += 1
    cooldown_indicator.stop_cooldown()
    
    Audio.game_over_sfx_player.play()
    
    if lives_count > 0:
        var current_tier_position := current_tier.position
        
        _destroy_player()
        _destroy_tiers()
        
        # Reset state to replay the level at the latest tier.
        _start_new_tier( \
                current_tier_id, \
                current_tier_position, \
                Audio.current_music_player_index)
        
        # Match player and camera positions to the current tier height.
        player_max_height = max(player_max_height, _get_player_height())
        player_max_height_on_current_life = \
                max(player_max_height_on_current_life, _get_player_height())
        $CameraHandler.on_fall( \
                current_tier_position, \
                player.position, \
                _get_player_height())
    else:
        is_game_playing = false
        $CameraHandler.speed_index = 0
        score_boards.set_lives(0)
        $SignAllKeys.visible = false
        pause_button.visible = false
        Audio.on_cross_fade_music_finished()
        _destroy_player()
        var high_score := max( \
                int(score), \
                SaveState.get_high_score_for_level(level_id))
        SaveState.set_high_score_for_level( \
                level_id, \
                high_score)
        
        Audio.current_music_player.stop()
        Audio.game_over_sfx_player.connect( \
                "finished", \
                self, \
                "_on_game_over_sfx_finished")

func _on_game_over_sfx_finished() -> void:
    destroy()
    Audio.cross_fade_music(Audio.MAIN_MENU_MUSIC_PLAYER_INDEX)
    Audio.game_over_sfx_player.disconnect( \
            "finished", \
            self, \
            "_on_game_over_sfx_finished")
    Nav.set_screen_is_open( \
            ScreenType.MAIN_MENU, \
            true)
    Nav.screens[ScreenType.GAME].destroy_level()

func _add_player(is_base_tier := false) -> void:
    player = Utils.add_scene( \
            self, \
            PLAYER_RESOURCE_PATH, \
            true, \
            true)
    player.position = player.get_spawn_position_for_tier( \
            current_tier, \
            is_base_tier)
    player.position.y += current_tier.position.y
    player.velocity = PLAYER_START_VELOCITY
    player.is_stuck = is_base_tier
    player.on_new_tier()
    
    $CameraHandler.set_start_position( \
            player.position, \
            _get_player_height())
    $FogScreenHandler.set_start_state()
    if !is_base_tier:
        $CameraHandler.set_post_stuck_state(false)
        $FogScreenHandler.set_post_stuck_state(false)
    
    mobile_control_ui = MobileControlUI.new(Global.mobile_control_version)
    Global.canvas_layers.hud_layer.add_child(mobile_control_ui)
    mobile_control_ui.update_displays()

func _release_player() -> void:
    assert(player.is_stuck)
    player.is_stuck = false
    $CameraHandler.set_post_stuck_state(true)
    $FogScreenHandler.set_post_stuck_state(true)

func _destroy_player() -> void:
    if player != null:
        player.queue_free()
        remove_child(player)
        player = null
    if mobile_control_ui != null:
        mobile_control_ui.destroy()
        mobile_control_ui.queue_free()
        Global.canvas_layers.hud_layer.remove_child(mobile_control_ui)
        mobile_control_ui = null

func _destroy_tiers() -> void:
    if previous_tier != null:
        previous_tier.queue_free()
        remove_child(previous_tier)
    if current_tier != null:
        current_tier.queue_free()
        remove_child(current_tier)
    if next_tier != null:
        next_tier.queue_free()
        remove_child(next_tier)
    if previous_tier_gap != null:
        previous_tier_gap.queue_free()
        remove_child(previous_tier_gap)
    if next_tier_gap != null:
        next_tier_gap.queue_free()
        remove_child(next_tier_gap)

func destroy() -> void:
    Global.level = null
    
    current_tier_id = ""
    is_game_playing = false
    has_input_been_pressed = false
    player_max_height = 0.0
    player_max_height_on_current_life = 0.0
    player_latest_platform_height = 0.0
    player_max_platform_height = 0.0
    player_max_platform_height_on_current_life = 0.0
    display_height = 0
    tier_count = 0
    tiers_count_since_falling = 0
    
    _destroy_player()
    _destroy_tiers()
    
    $SignAllKeys.visible = false
    Audio.on_cross_fade_music_finished()
    
    $CameraHandler.destroy()
    $FogScreenHandler.destroy()
    
    if score_boards != null:
        Global.canvas_layers.hud_layer.remove_child(score_boards)
        score_boards.queue_free()
        score_boards = null
    
    if cooldown_indicator != null:
        Global.canvas_layers.hud_layer.remove_child(cooldown_indicator)
        cooldown_indicator.queue_free()
        cooldown_indicator = null
    
    if max_height_indicator != null:
        remove_child(max_height_indicator)
        max_height_indicator.queue_free()
        max_height_indicator = null
    
    if max_height_on_current_height_indicator != null:
        remove_child(max_height_on_current_height_indicator)
        max_height_on_current_height_indicator.queue_free()
        max_height_on_current_height_indicator = null
    
    if pause_button != null:
        remove_child(pause_button)
        pause_button.queue_free()
        pause_button = null

func _start_new_tier( \
        tier_id := START_TIER_ID, \
        tier_position := Vector2.ZERO, \
        music_player_index := Audio.START_MUSIC_INDEX) -> void:
    start_tier_id = tier_id
    current_tier_id = tier_id
    
    var level_config: Dictionary = LevelConfig.LEVELS[level_id]
    
    if current_tier_id == "0":
        current_tier_index = -1
    else:
        assert(level_config.tiers.has(current_tier_id))
        current_tier_index = level_config.tiers.find(current_tier_id)
    
    var next_tier_index: int = current_tier_index + 1
    if next_tier_index == level_config.tiers.size():
        # Loop back around, and skip the first/base tier.
        next_tier_index = 0
    var next_tier_id: String = level_config.tiers[next_tier_index]
    
    # Current tier.
    var current_tier_position := tier_position
    var current_tier_config: Dictionary = LevelConfig.TIERS[current_tier_id]
    current_tier = Utils.add_scene( \
            self, \
            current_tier_config.scene_path, \
            true, \
            true)
    assert(current_tier.openness_type != OpennessType.UNKNOWN)
    assert(current_tier_id == "0" or \
            LevelConfig.get_tier_size(current_tier).y / \
                    Constants.CELL_SIZE.y >= \
                    Global.LEVEL_MIN_HEIGHT_CELL_COUNT)
    current_tier.position = current_tier_position
    
    # Next tier.
    var next_tier_position: Vector2 = \
            LevelConfig.get_tier_top_position(current_tier)
    var next_tier_config: Dictionary = LevelConfig.TIERS[next_tier_id]
    next_tier = Utils.add_scene( \
            self, \
            next_tier_config.scene_path, \
            true, \
            true)
    assert(next_tier.openness_type != OpennessType.UNKNOWN)
    assert(LevelConfig.get_tier_size(next_tier).y / Constants.CELL_SIZE.y >= \
            Global.LEVEL_MIN_HEIGHT_CELL_COUNT)
    next_tier.position = next_tier_position
    
    # Next tier gap.
    var next_tier_gap_scene_path: String = \
            LevelConfig.get_tier_gap_scene_path( \
                    current_tier.openness_type, \
                    next_tier.openness_type)
    next_tier_gap = Utils.add_scene( \
            self, \
            next_tier_gap_scene_path, \
            true, \
            true)
    next_tier_gap.position = next_tier_position
    
    # Tier-ratio signs.
    if current_tier_ratio_sign != null:
        remove_child(current_tier_ratio_sign)
    if current_tier_id != "0":
        current_tier_ratio_sign = Utils.add_scene( \
                self, \
                TIER_RATIO_SIGN_RESOURCE_PATH, \
                true, \
                true)
        current_tier_ratio_sign.position = \
                current_tier_position - Vector2(0.0, Constants.CELL_SIZE.y)
        current_tier_ratio_sign.text = \
                "%s / %s" % [current_tier_index + 1, level_config.tiers.size()]
    if next_tier_ratio_sign != null:
        remove_child(next_tier_ratio_sign)
    next_tier_ratio_sign = Utils.add_scene( \
            self, \
            TIER_RATIO_SIGN_RESOURCE_PATH, \
            true, \
            true)
    next_tier_ratio_sign.position = \
            next_tier_position - Vector2(0.0, Constants.CELL_SIZE.y)
    next_tier_ratio_sign.text = \
            "%s / %s" % [next_tier_index + 1, level_config.tiers.size()]
    
    if current_tier_id != "0":
        var previous_tier_scene_path: String = \
                LevelConfig.TIER_BLANK_SCENE_PATH
        previous_tier = Utils.add_scene( \
                self, \
                previous_tier_scene_path, \
                true, \
                true)
        var previous_tier_position: Vector2 = \
                current_tier_position - \
                LevelConfig.get_tier_top_position(previous_tier)
        previous_tier.position = previous_tier_position
        
        var previous_tier_gap_scene_path: String = \
                LevelConfig.get_tier_gap_scene_path( \
                        OpennessType.WALLED, \
                        current_tier.openness_type)
        previous_tier_gap = Utils.add_scene( \
                self, \
                previous_tier_gap_scene_path, \
                true, \
                true)
        previous_tier_gap.position = current_tier_position
    
    $CameraHandler.update_for_current_tier( \
            level_id, \
            current_tier_id, \
            true)
    $FogScreenHandler.update_for_current_tier( \
            level_id, \
            current_tier_id)
    _update_windiness()
    
    # Render the basic input instructions sign.
    $SignAllKeys.visible = Global.are_keyboard_controls_shown
    $SignAllKeys.position = INPUT_SIGN_POSITION
    if current_tier_id != "0":
        $SignAllKeys.position.y -= Constants.CELL_SIZE.y
    
    Audio.current_music_player_index = music_player_index
    
    _add_player(tier_id == "0")
    
    has_input_been_pressed = false
    is_game_playing = true

func _on_entered_new_tier() -> void:
    tier_count += 1
    tiers_count_since_falling += 1
    
    # Destory the old previous tier.
    if previous_tier != null:
        remove_child(previous_tier)
        previous_tier.queue_free()
    if previous_tier_gap != null:
        remove_child(previous_tier_gap)
        previous_tier_gap.queue_free()
    
    previous_tier = current_tier
    current_tier = next_tier
    previous_tier_gap = next_tier_gap
    
    var level_config: Dictionary = LevelConfig.LEVELS[level_id]
    
    var was_final_tier_completed := false
    current_tier_index += 1
    if current_tier_index == level_config.tiers.size():
        # Loop back around, and skip the first/base tier.
        was_final_tier_completed = true
        current_tier_index = 0
    current_tier_id = level_config.tiers[current_tier_index]
    var next_tier_index := current_tier_index + 1
    if next_tier_index == level_config.tiers.size():
        # Loop back around, and skip the first/base tier.
        next_tier_index = 0
    var next_tier_id: String = level_config.tiers[next_tier_index]
    
    var current_tier_config: Dictionary = LevelConfig.TIERS[current_tier_id]
    
    # Next tier.
    var next_tier_position: Vector2 = \
            LevelConfig.get_tier_top_position(current_tier)
    var next_tier_config: Dictionary = LevelConfig.TIERS[next_tier_id]
    next_tier = Utils.add_scene( \
            self, \
            next_tier_config.scene_path, \
            true, \
            true)
    assert(LevelConfig.get_tier_size(next_tier).y / Constants.CELL_SIZE.y >= \
            Global.LEVEL_MIN_HEIGHT_CELL_COUNT)
    next_tier.position = next_tier_position
    
    # Next tier gap.
    var next_tier_gap_scene_path: String = \
            LevelConfig.get_tier_gap_scene_path( \
                    current_tier.openness_type, \
                    next_tier.openness_type)
    next_tier_gap = Utils.add_scene( \
            self, \
            next_tier_gap_scene_path, \
            true, \
            true)
    next_tier_gap.position = next_tier_position
    
    # Update tier-ratio signs.
    if current_tier_ratio_sign != null:
        remove_child(current_tier_ratio_sign)
    current_tier_ratio_sign = next_tier_ratio_sign
    next_tier_ratio_sign = Utils.add_scene( \
            self, \
            TIER_RATIO_SIGN_RESOURCE_PATH, \
            true, \
            true)
    next_tier_ratio_sign.position = \
            next_tier_position - Vector2(0.0, Constants.CELL_SIZE.y)
    next_tier_ratio_sign.text = \
            "%s / %s" % [next_tier_index + 1, level_config.tiers.size()]
    
    # Maybe play new music.
    if (start_tier_id != "0" or \
            tier_count != 1) and \
            tier_count % NUMBER_OF_LEVELS_PER_MUSIC == 0:
        Audio.current_music_player_index = \
                (Audio.current_music_player_index + 1) % \
                Audio.MUSIC_PLAYERS.size()
        Audio.cross_fade_music(Audio.current_music_player_index)
    
    $CameraHandler.update_for_current_tier( \
            level_id, \
            current_tier_id, \
            false)
    $FogScreenHandler.update_for_current_tier( \
            level_id, \
            current_tier_id)
    _update_windiness()
    
    Audio.new_tier_sfx_player.play()
    
    if was_final_tier_completed:
        _on_final_tier_completed()
    
    _update_score_for_tier_change()
    
    player.on_new_tier()

func _update_windiness() -> void:
    var level_config: Dictionary = LevelConfig.LEVELS[level_id]
    var tier_config: Dictionary = LevelConfig.TIERS[current_tier_id]
    var previous_windiness := windiness
    var next_windiness: float = \
            DEFAULT_WINDINESS * \
            level_config.windiness_multiplier * \
            tier_config.windiness_multiplier
    
    windiness_tween.stop(self)
    windiness_tween.interpolate_property( \
            self, \
            "windiness", \
            previous_windiness, \
            next_windiness, \
            CameraController.ZOOM_ANIMATION_DURATION_SEC, \
            Tween.TRANS_QUAD, \
            Tween.EASE_IN_OUT)
    windiness_tween.start()
    
    # FIXME: -------------------------------- Update snow and fires

func _on_fog_screen_updated() -> void:
    player.update_light_size($FogScreenHandler.peep_hole_size)

func _update_score_for_height_change(height_delta_pixels: float) -> void:
    score += \
            height_delta_pixels * \
            SCORE_PER_HEIGHT_PIXELS * \
            cooldown_indicator.multiplier

func _update_score_for_tier_change() -> void:
    var tier_score_for_difficulty := 0.0
    match Global.difficulty_mode:
        DifficultyMode.EASY:
            tier_score_for_difficulty = SCORE_FOR_TIER_FOR_EASY_DIFFICULTY
        DifficultyMode.MODERATE:
            tier_score_for_difficulty = SCORE_FOR_TIER_FOR_MODERATE_DIFFICULTY
        DifficultyMode.HARD:
            tier_score_for_difficulty = SCORE_FOR_TIER_FOR_HARD_DIFFICULTY
        _:
            Utils.error()
    score += tier_score_for_difficulty * cooldown_indicator.multiplier

func _on_final_tier_completed() -> void:
    Global.falls_count_since_reaching_level_end = 0
    # FIXME: ------------------

func update_displays() -> void:
    Global.debug_panel.visible = Global.is_debug_panel_shown
    mobile_control_ui.update_displays()
    $SignAllKeys.visible = Global.are_keyboard_controls_shown
    cooldown_indicator.visible = Global.is_multiplier_cooldown_indicator_shown
    max_height_on_current_height_indicator.visible = \
            Global.is_height_indicator_shown
    max_height_indicator.visible = Global.is_height_indicator_shown
    score_boards.update_displays()

func _get_player_height() -> float:
    return -player.position.y - player.get_player_half_height() if \
            player != null else \
            0.0
