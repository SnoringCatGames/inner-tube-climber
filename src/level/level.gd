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
var tier_of_last_platform: Tier

var margin_left_color_tween: Tween
var margin_right_color_tween: Tween

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
var level_start_time := -INF
var tier_start_time := -INF

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
var falls_count_on_current_tier: int = 0
var lives_count: int
var score := 0.0
var finished_level := false
var three_looped_level := false
var reached_new_high_score := false
var new_unlocked_levels := []
var is_rate_app_screen_next := false

# Dictionary<int, float>
var time_spent_with_multiplier_levels := {}

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
    
    margin_left_color_tween = Tween.new()
    add_child(margin_left_color_tween)
    
    margin_right_color_tween = Tween.new()
    add_child(margin_right_color_tween)
    
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
    self.level_start_time = Time.elapsed_play_time_actual_sec
    visible = true
    lives_count = LevelConfig.get_level_config(level_id).lives_count
    falls_count = 0
    score = 0.0
    _start_new_tier( \
            tier_id, \
            Vector2.ZERO, \
            Audio.START_MUSIC_INDEX)
    Audio.cross_fade_music(Audio.current_music_player_index)
    score_boards.visible = !player.is_stuck
    pause_button.visible = !player.is_stuck
    cooldown_indicator.visible = \
            !player.is_stuck and \
            Global.is_multiplier_cooldown_indicator_shown
    _update_score_displays()
    
    SaveState.set_level_total_plays( \
            level_id, \
            SaveState.get_level_total_plays(level_id) + 1)
    Analytics.event( \
            "level", \
            "start", \
            LevelConfig.get_level_version_string(level_id))

func _physics_process(_delta_sec: float) -> void:
    _delta_sec *= Time.physics_framerate_multiplier
    
    if !is_game_playing or \
            player == null or \
            player.is_stuck:
        return
    
    # Keep track of player height.
    var next_tier_height: float = -next_tier.position.y + Constants.CELL_SIZE.y
    if _get_player_height() > next_tier_height - 0.1:
        call_deferred("_on_entered_new_tier")
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
        if tier_of_last_platform != current_tier:
            tier_of_last_platform = current_tier
            current_tier.on_landed_in_tier()
        Global.print( \
                "Platform height=%s" % player_latest_platform_height)
    display_height = \
            floor(player_max_platform_height / DISPLAY_HEIGHT_INTERVAL) as int
    
    cooldown_indicator.check_for_updates( \
            player_max_platform_height_on_current_life, \
            player_latest_platform_height, \
            !player.surface_state.is_touching_floor)
    max_height_indicator.check_for_updates(player_max_platform_height)
    max_height_on_current_height_indicator.check_for_updates( \
            player_max_platform_height_on_current_life)

func _process(delta_sec: float) -> void:
    delta_sec *= Time.physics_framerate_multiplier
    
    if !is_game_playing or player == null:
        return
    
    $FogScreenHandler.sync_to_player_position(player.position)
    
    if player.is_stuck:
        return
    
    $CameraHandler.sync_to_player_position( \
            delta_sec, \
            player.position, \
            _get_player_height())
    
    _update_score_displays()
    
    if !time_spent_with_multiplier_levels.has(cooldown_indicator.multiplier):
        time_spent_with_multiplier_levels[cooldown_indicator.multiplier] = 0
    time_spent_with_multiplier_levels[cooldown_indicator.multiplier] += \
            delta_sec
    
    # Check for game over.
    if _get_player_height() < $CameraHandler.fall_height:
        _fall()

func _update_score_displays() -> void:
    score_boards.set_tier_ratio(get_tier_ratio())
    score_boards.set_height(display_height)
    score_boards.set_score(score)
    score_boards.set_multiplier(cooldown_indicator.multiplier)
    score_boards.set_speed($CameraHandler.speed_index + 1)
    score_boards.set_lives(lives_count)

func _fall() -> void:
    falls_count += 1
    falls_count_on_current_tier += 1
    lives_count -= 1
    tiers_count_since_falling = 0
    player_max_height_on_current_life = 0.0
    player_latest_platform_height = 0.0
    player_max_platform_height_on_current_life = 0.0
    Global.falls_count_since_reaching_level_end += 1
    cooldown_indicator.stop_cooldown()
    
    Audio.play_sound(Sound.FALL)
    
    SaveState.set_level_total_falls( \
            level_id, \
            SaveState.get_level_total_falls(level_id) + 1)
    SaveState.set_level_total_falls_on_tier( \
            level_id, \
            current_tier_id, \
            SaveState.get_level_total_falls_on_tier( \
                    level_id, \
                    current_tier_id) + \
                    1)
    Analytics.event( \
            "level", \
            "fall", \
            LevelConfig.get_level_version_string(level_id), \
            player_max_platform_height_on_current_life)
    
    var was_last_life := lives_count == 0
    $CameraHandler.on_fall_before_new_tier(was_last_life)
    
    if !was_last_life:
        _destroy_player()
        Time.set_timeout( \
                funcref(self, "_start_new_tier_after_fall"), \
                1.0, \
                [current_tier.position])
    else:
        is_game_playing = false
        $CameraHandler.speed_index = 0
        score_boards.set_lives(0)
        $SignAllKeys.visible = false
        pause_button.visible = false
        Audio.on_cross_fade_music_finished()
        _destroy_player()
        
        var previous_high_score := SaveState.get_level_high_score(level_id)
        if score > previous_high_score:
            reached_new_high_score = true
            SaveState.set_level_high_score( \
                    level_id, \
                    int(score))
        
        var previous_high_tier := SaveState.get_level_high_tier(level_id)
        if tier_count > previous_high_tier:
            SaveState.set_level_high_tier( \
                    level_id, \
                    int(tier_count))
        
        var all_scores: Array = SaveState.get_level_all_scores(level_id)
        all_scores.push_back(score)
        SaveState.set_level_all_scores(level_id, all_scores)
        
        if finished_level:
            var all_finished_scores: Array = \
                    SaveState.get_level_all_finished_scores(level_id)
            all_finished_scores.push_back(score)
            SaveState.set_level_all_finished_scores( \
                    level_id, \
                    all_finished_scores)
        
        new_unlocked_levels = LevelConfig.get_new_unlocked_levels()
        SaveState.set_new_unlocked_levels(new_unlocked_levels)
        for other_level_id in new_unlocked_levels:
            SaveState.set_level_is_unlocked(other_level_id, true)
            Analytics.event( \
                    "level", \
                    "unlocked", \
                    LevelConfig.get_level_version_string(other_level_id), \
                    LevelConfig.get_level_config(level_id).number)
        
        if finished_level:
            SaveState.set_finished_level_streak( \
                    SaveState.get_finished_level_streak() + 1)
            SaveState.set_failed_level_streak(0)
        else:
            SaveState.set_finished_level_streak(0)
            SaveState.set_failed_level_streak( \
                    SaveState.get_failed_level_streak() + 1)
        
        var old_unlocked_levels: Array = LevelConfig.get_old_unlocked_levels()
        if !new_unlocked_levels.empty() and \
                ((new_unlocked_levels.size() + old_unlocked_levels.size()) % \
                Constants.LEVELS_COUNT_BEFORE_SHOWING_RATE_APP_SCREEN) == 0:
            is_rate_app_screen_next = true
        
        _set_game_over_state()
        
        Sound.MANIFEST[Sound.FALL].player.connect( \
                "finished", \
                self, \
                "_on_last_fall_sound_finished")
        
        Analytics.event( \
                "score", \
                "v" + Constants.SCORE_VERSION, \
                LevelConfig.get_level_version_string(level_id), \
                int(score))

func _start_new_tier_after_fall(current_tier_position: Vector2) -> void:
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
    $CameraHandler.on_new_tier_after_fall( \
            current_tier_position, \
            player.position, \
            _get_player_height())

func _set_game_over_state() -> void:
    var game_over_screen = Nav.screens[ScreenType.GAME_OVER]
    game_over_screen.level_id = level_id
    game_over_screen.score = str(int(score))
    game_over_screen.high_score = \
            str(SaveState.get_level_high_score(level_id))
    game_over_screen.tier_ratio = get_tier_ratio()
    game_over_screen.tiers_remaining_count = \
            (LevelConfig.get_level_config(level_id).tiers.size() - \
                    tier_count) + 1
    game_over_screen.difficulty = \
            DifficultyMode.get_type_string(Global.difficulty_mode)
    game_over_screen.time = Utils.get_time_string_from_seconds( \
            Time.elapsed_play_time_actual_sec - \
            level_start_time)
    game_over_screen.average_multiplier = "%.1f" % _get_average_multiplier()
    game_over_screen.finished_level = finished_level
    game_over_screen.three_looped_level = three_looped_level
    game_over_screen.reached_new_high_score = reached_new_high_score
    game_over_screen.rank = LevelConfig.get_level_rank( \
            level_id, \
            score, \
            finished_level)
    game_over_screen.new_unlocked_levels = new_unlocked_levels
    game_over_screen.finished_last_three_levels = \
            SaveState.get_finished_level_streak() >= 3
    game_over_screen.failed_last_three_levels = \
            SaveState.get_failed_level_streak() >= 3

func _get_average_multiplier() -> float:
    var total_time_sec := 0.0
    for time_sec in time_spent_with_multiplier_levels.values():
        total_time_sec += time_sec
    
    var average := 0.0
    for multiplier in time_spent_with_multiplier_levels:
        average += \
                multiplier * \
                time_spent_with_multiplier_levels[multiplier] / \
                total_time_sec
    
    return average

func _on_last_fall_sound_finished() -> void:
    Sound.MANIFEST[Sound.FALL].player.disconnect( \
            "finished", \
            self, \
            "_on_last_fall_sound_finished")
    Sound.MANIFEST[Sound.GAME_OVER_SUCCESS].player.connect( \
            "finished", \
            self, \
            "_on_game_over_sound_finished")
    Sound.MANIFEST[Sound.GAME_OVER_FAILURE].player.connect( \
            "finished", \
            self, \
            "_on_game_over_sound_finished")
    Audio.current_music_player.stop()
    if finished_level:
        Audio.play_sound(Sound.GAME_OVER_SUCCESS)
    else:
        Audio.play_sound(Sound.GAME_OVER_FAILURE)

func _on_game_over_sound_finished() -> void:
    Sound.MANIFEST[Sound.GAME_OVER_SUCCESS].player.disconnect( \
            "finished", \
            self, \
            "_on_game_over_sound_finished")
    Sound.MANIFEST[Sound.GAME_OVER_FAILURE].player.disconnect( \
            "finished", \
            self, \
            "_on_game_over_sound_finished")
    var next_screen_type := \
            ScreenType.RATE_APP if \
            is_rate_app_screen_next and \
                    !SaveState.get_gave_feedback() else \
            ScreenType.GAME_OVER
    Nav.open(next_screen_type, true)
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
    player.velocity = PLAYER_START_VELOCITY
    player.is_stuck = is_base_tier
    player.on_new_tier(current_tier)
    
    $CameraHandler.set_start_state( \
            player.position, \
            _get_player_height())
    $FogScreenHandler.set_start_state()
    $SnowScreenHandler.set_start_state()
    if !is_base_tier:
        $CameraHandler.set_post_stuck_state(false)
        $FogScreenHandler.set_post_stuck_state(false)
        $SnowScreenHandler.set_post_stuck_state(false)
    
    mobile_control_ui = MobileControlUI.new(Global.mobile_control_version)
    Global.canvas_layers.hud_layer.add_child(mobile_control_ui)
    mobile_control_ui.update_displays()

func _release_player() -> void:
    assert(player.is_stuck)
    player.is_stuck = false
    $CameraHandler.set_post_stuck_state(true)
    $FogScreenHandler.set_post_stuck_state(true)
    $SnowScreenHandler.set_post_stuck_state(true)
    score_boards.visible = true
    pause_button.visible = true
    cooldown_indicator.visible = Global.is_multiplier_cooldown_indicator_shown

func _destroy_player() -> void:
    if player != null:
        player.destroy()
        player.queue_free()
        player = null
    if mobile_control_ui != null:
        mobile_control_ui.destroy()
        mobile_control_ui.queue_free()
        mobile_control_ui = null

func _destroy_tiers() -> void:
    if previous_tier != null:
        previous_tier.queue_free()
    if current_tier != null:
        current_tier.queue_free()
    if next_tier != null:
        next_tier.queue_free()
    if previous_tier_gap != null:
        previous_tier_gap.queue_free()
    if next_tier_gap != null:
        next_tier_gap.queue_free()

func destroy() -> void:
    Global.level = null
    
    current_tier_id = ""
    current_tier_index = -1
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
    level_start_time = -INF
    tier_start_time = -INF
    falls_count = 0
    falls_count_on_current_tier = 0
    lives_count = 0
    score = 0
    finished_level = false
    three_looped_level = false
    reached_new_high_score = false
    new_unlocked_levels = []
    is_rate_app_screen_next = false
    time_spent_with_multiplier_levels.clear()
    
    _destroy_player()
    _destroy_tiers()
    
    cooldown_indicator.stop_cooldown()
    $SignAllKeys.visible = false
    Audio.on_cross_fade_music_finished()
    
    $CameraHandler.destroy()
    $FogScreenHandler.destroy()
    $SnowScreenHandler.destroy()
    
    if score_boards != null:
        score_boards.queue_free()
        score_boards = null
    
    if cooldown_indicator != null:
        cooldown_indicator.queue_free()
        cooldown_indicator = null
    
    if max_height_indicator != null:
        max_height_indicator.queue_free()
        max_height_indicator = null
    
    if max_height_on_current_height_indicator != null:
        max_height_on_current_height_indicator.queue_free()
        max_height_on_current_height_indicator = null
    
    if pause_button != null:
        pause_button.queue_free()
        pause_button = null

func _start_new_tier( \
        tier_id := START_TIER_ID, \
        tier_position := Vector2.ZERO, \
        music_player_index := Audio.START_MUSIC_INDEX) -> void:
    tier_start_time = Time.elapsed_play_time_actual_sec
    falls_count_on_current_tier = 0
    start_tier_id = tier_id
    current_tier_id = tier_id
    
    var level_config: Dictionary = LevelConfig.get_level_config(level_id)
    
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
    var current_tier_config: Dictionary = \
            LevelConfig.get_tier_config(current_tier_id)
    current_tier = Utils.add_scene( \
            self, \
            current_tier_config.scene_path, \
            true, \
            true)
    current_tier.setup( \
            tier_position, \
            current_tier_index, \
            level_config.tiers.size())
    
    # Next tier.
    var next_tier_config: Dictionary = \
            LevelConfig.get_tier_config(next_tier_id)
    next_tier = Utils.add_scene( \
            self, \
            next_tier_config.scene_path, \
            true, \
            true)
    next_tier.setup( \
            current_tier, \
            next_tier_index, \
            level_config.tiers.size())
    
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
    next_tier_gap.sync_position_to_previous_tier(current_tier)
    
    if current_tier_id != "0":
        var previous_tier_scene_path: String
        var previous_tier_index := current_tier_index - 1
        if previous_tier_index < 0:
            previous_tier_index = level_config.tiers.size() - 1
            previous_tier_scene_path = \
                    LevelConfig.TIER_EMPTY_WALLED_SCENE_PATH
        else:
            var previous_tier_id: String = \
                    level_config.tiers[previous_tier_index]
            var previous_tier_config: Dictionary = \
                    LevelConfig.get_tier_config(previous_tier_id)
            previous_tier = Utils.add_scene( \
                    self, \
                    previous_tier_config.scene_path, \
                    false, \
                    false)
            match previous_tier.openness_type:
                OpennessType.OPEN_WITH_HORIZONTAL_PAN, \
                OpennessType.OPEN_WITHOUT_HORIZONTAL_PAN:
                    previous_tier_scene_path = \
                            LevelConfig.TIER_EMPTY_OPEN_SCENE_PATH
                OpennessType.WALLED:
                    previous_tier_scene_path = \
                            LevelConfig.TIER_EMPTY_WALLED_SCENE_PATH
                OpennessType.WALLED_LEFT:
                    previous_tier_scene_path = \
                            LevelConfig.TIER_EMPTY_WALLED_LEFT_SCENE_PATH
                OpennessType.WALLED_RIGHT:
                    previous_tier_scene_path = \
                            LevelConfig.TIER_EMPTY_WALLED_RIGHT_SCENE_PATH
                _:
                    Utils.error()
        if previous_tier != null:
            previous_tier.queue_free()
        previous_tier = Utils.add_scene( \
                self, \
                previous_tier_scene_path, \
                true, \
                true)
        var previous_tier_position: Vector2 = \
                current_tier.position + \
                Vector2(0.0, previous_tier.size.y)
        previous_tier.setup(previous_tier_position)
        
        var previous_tier_gap_scene_path: String = \
                LevelConfig.get_tier_gap_scene_path( \
                        previous_tier.openness_type, \
                        current_tier.openness_type)
        previous_tier_gap = Utils.add_scene( \
                self, \
                previous_tier_gap_scene_path, \
                true, \
                true)
        previous_tier_gap.sync_position_to_previous_tier(previous_tier)
    
    _add_player(tier_id == "0")
    
    current_tier.on_entered_tier(true)
    $CameraHandler.update_for_current_tier( \
            level_id, \
            current_tier_id, \
            true)
    $FogScreenHandler.update_for_current_tier( \
            level_id, \
            current_tier_id)
    $SnowScreenHandler.update_for_current_tier( \
            level_id, \
            current_tier_id, \
            true)
    _update_margin_color()
    
    # Render the basic input instructions sign.
    $SignAllKeys.visible = Global.are_keyboard_controls_shown
    $SignAllKeys.position = INPUT_SIGN_POSITION
    if current_tier_id != "0":
        $SignAllKeys.position.y -= Constants.CELL_SIZE.y
    
    Audio.current_music_player_index = music_player_index
    
    has_input_been_pressed = false
    is_game_playing = true

func _on_entered_new_tier() -> void:
    Analytics.event( \
            "level", \
            "tier-end", \
            LevelConfig.get_level_tier_version_string( \
                    level_id, \
                    current_tier_id), \
            Time.elapsed_play_time_actual_sec - tier_start_time)
    if tier_count > 0:
        var previous_high_tier := SaveState.get_level_high_tier(level_id)
        if tier_count >= previous_high_tier:
            var total_falls_on_tier := \
                    SaveState.get_level_total_falls_on_tier( \
                            level_id, \
                            current_tier_id)
            Analytics.event( \
                    "level", \
                    "falls-before-first-tier-finish", \
                    LevelConfig.get_level_tier_version_string( \
                            level_id, \
                            current_tier_id), \
                    total_falls_on_tier)
    
    tier_start_time = Time.elapsed_play_time_actual_sec
    falls_count_on_current_tier = 0
    tier_count += 1
    tiers_count_since_falling += 1
    
    # Destroy the previous tier.
    if previous_tier != null:
        previous_tier.queue_free()
    if previous_tier_gap != null:
        previous_tier_gap.queue_free()
    
    previous_tier = current_tier
    current_tier = next_tier
    previous_tier_gap = next_tier_gap
    
    var level_config: Dictionary = LevelConfig.get_level_config(level_id)
    
    current_tier_index += 1
    if current_tier_index == level_config.tiers.size():
        # Loop back around, and skip the first/base tier.
        current_tier_index = 0
    current_tier_id = level_config.tiers[current_tier_index]
    var next_tier_index := current_tier_index + 1
    if next_tier_index == level_config.tiers.size():
        # Loop back around, and skip the first/base tier.
        next_tier_index = 0
    var next_tier_id: String = level_config.tiers[next_tier_index]
    
    var current_tier_config: Dictionary = \
            LevelConfig.get_tier_config(current_tier_id)
    
    # Next tier.
    var next_tier_config: Dictionary = \
            LevelConfig.get_tier_config(next_tier_id)
    next_tier = Utils.add_scene( \
            self, \
            next_tier_config.scene_path, \
            true, \
            true)
    next_tier.setup( \
            current_tier, \
            next_tier_index, \
            level_config.tiers.size())
    
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
    next_tier_gap.sync_position_to_previous_tier(current_tier)
    
    # Maybe play new music.
    if (start_tier_id != "0" or \
            tier_count != 1) and \
            tier_count % NUMBER_OF_LEVELS_PER_MUSIC == 0:
        Audio.current_music_player_index = \
                (Audio.current_music_player_index + 1) % \
                Audio.MUSIC_PLAYERS.size()
        Audio.cross_fade_music(Audio.current_music_player_index)
    
    current_tier.on_entered_tier(false)
    $CameraHandler.update_for_current_tier( \
            level_id, \
            current_tier_id, \
            false)
    $FogScreenHandler.update_for_current_tier( \
            level_id, \
            current_tier_id)
    $SnowScreenHandler.update_for_current_tier( \
            level_id, \
            current_tier_id, \
            false)
    _update_margin_color()
    
    if tier_count == level_config.tiers.size() * 3 + 1:
        three_looped_level = true
        SaveState.set_level_has_three_looped(level_id, true)
        Analytics.event( \
                "level", \
                "three-looped", \
                LevelConfig.get_level_version_string(level_id), \
                int(score))
    
    var was_final_tier_completed_first_time: bool = \
            tier_count - 1 == level_config.tiers.size()
    var was_final_tier_completed_third_time: bool = \
            tier_count - 1 == level_config.tiers.size() * 3
    if was_final_tier_completed_first_time or \
            was_final_tier_completed_third_time:
        Time.set_timeout( \
                funcref(Audio, "play_sound"), \
                0.8, \
                [Sound.ACHIEVEMENT])
        Global.falls_count_since_reaching_level_end = 0
        var is_first_time_finishing := \
                !SaveState.get_level_has_finished(level_id)
        finished_level = true
        SaveState.set_level_has_finished(level_id, true)
        if is_first_time_finishing:
            var total_falls := SaveState.get_level_total_falls(level_id)
            Analytics.event( \
                    "level", \
                    "falls-before-first-level-finish", \
                    LevelConfig.get_level_version_string(level_id), \
                    total_falls)
        Analytics.event( \
                "level", \
                "finish", \
                LevelConfig.get_level_version_string(level_id), \
                Time.elapsed_play_time_actual_sec - level_start_time)
    else:
        pass
#        Audio.play_sound(Sound.TIER_COMPLETE)
    
    _update_score_for_tier_change()
    
    player.on_new_tier(current_tier)

func _update_margin_color() -> void:
    var previous_left_margin_color: Color
    var previous_right_margin_color: Color
    var previous := \
            previous_tier if \
            previous_tier != null else \
            current_tier
    match previous.openness_type:
        OpennessType.WALLED:
            previous_left_margin_color = Constants.WALL_COLOR
            previous_right_margin_color = Constants.WALL_COLOR
        OpennessType.WALLED_LEFT:
            previous_left_margin_color = Constants.WALL_COLOR
            previous_right_margin_color = Constants.BACKGROUND_DARKEST_COLOR
        OpennessType.WALLED_RIGHT:
            previous_left_margin_color = Constants.BACKGROUND_DARKEST_COLOR
            previous_right_margin_color = Constants.WALL_COLOR
        OpennessType.OPEN_WITHOUT_HORIZONTAL_PAN, \
        OpennessType.OPEN_WITH_HORIZONTAL_PAN:
            previous_left_margin_color = Constants.BACKGROUND_DARKEST_COLOR
            previous_right_margin_color = Constants.BACKGROUND_DARKEST_COLOR
        _:
            Utils.error()
    
    var next_left_margin_color: Color
    var next_right_margin_color: Color
    match current_tier.openness_type:
        OpennessType.WALLED:
            next_left_margin_color = Constants.WALL_COLOR
            next_right_margin_color = Constants.WALL_COLOR
        OpennessType.WALLED_LEFT:
            next_left_margin_color = Constants.WALL_COLOR
            next_right_margin_color = Constants.BACKGROUND_DARKEST_COLORcurrent_tier
        OpennessType.WALLED_RIGHT:
            next_left_margin_color = Constants.BACKGROUND_DARKEST_COLOR
            next_right_margin_color = Constants.WALL_COLOR
        OpennessType.OPEN_WITHOUT_HORIZONTAL_PAN, \
        OpennessType.OPEN_WITH_HORIZONTAL_PAN:
            next_left_margin_color = Constants.BACKGROUND_DARKEST_COLOR
            next_right_margin_color = Constants.BACKGROUND_DARKEST_COLOR
        _:
            Utils.error()
    
    margin_left_color_tween.stop(self)
    margin_left_color_tween.interpolate_method( \
            self, \
            "_interpolate_margin_left_color", \
            previous_left_margin_color, \
            next_left_margin_color, \
            CameraController.ZOOM_ANIMATION_DURATION_SEC, \
            Tween.TRANS_QUAD, \
            Tween.EASE_IN_OUT)
    margin_left_color_tween.start()
    
    margin_right_color_tween.stop(self)
    margin_right_color_tween.interpolate_method( \
            self, \
            "_interpolate_margin_right_color", \
            previous_right_margin_color, \
            next_right_margin_color, \
            CameraController.ZOOM_ANIMATION_DURATION_SEC, \
            Tween.TRANS_QUAD, \
            Tween.EASE_IN_OUT)
    margin_right_color_tween.start()

func _interpolate_margin_left_color(color: Color) -> void:
    Nav.screens[ScreenType.GAME] \
            .get_node("PanelContainer") \
            .get("custom_styles/panel") \
            .bg_color = color

func _interpolate_margin_right_color(color: Color) -> void:
    Nav.screens[ScreenType.GAME] \
            .get_node("PanelContainer") \
            .get("custom_styles/panel") \
            .bg_color = color

func _on_fog_screen_updated() -> void:
    player.update_light( \
            $FogScreenHandler.peep_hole_size, \
            $FogScreenHandler.light_energy)
    
    $SnowScreenHandler.update_windiness($FogScreenHandler.windiness)
    player.windiness = $FogScreenHandler.windiness
    current_tier.windiness = $FogScreenHandler.windiness
    next_tier.windiness = $FogScreenHandler.windiness

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
    return -player.position.y - Constants.PLAYER_HALF_HEIGHT_DEFAULT if \
            player != null else \
            0.0

func get_tier_ratio() -> String:
    return "%s / %s" % [
        tier_count, \
        LevelConfig.get_level_config(level_id).tiers.size(),
    ]

func add_life() -> void:
    lives_count += 1
