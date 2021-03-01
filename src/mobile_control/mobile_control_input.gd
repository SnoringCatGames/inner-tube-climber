extends Node2D
class_name MobileControlInput

# How many seconds worth of drag positions to buffer.
const GESTURE_RECENT_POSITIONS_BUFFER_DELAY_SEC := 0.1

var is_mobile_device := false

var is_mouse_down := false

var was_last_event_from_keyboard := true

# Array<PositionAndTime>
var recent_gesture_positions := []
var is_positions_buffer_dirty := false
var latest_gesture_position := Vector2.INF
var latest_leftward_position := Vector2.INF
var latest_rightward_position := Vector2.INF

var is_jump_pressed := false
var is_move_left_pressed := false
var is_move_right_pressed := false

func _init() -> void:
    self.is_mobile_device = Utils.get_is_mobile_device()

func destroy() -> void:
    if Input.is_action_pressed("jump"):
        var action := InputEventAction.new() 
        action.action = "jump"
        action.pressed = false
        Input.parse_input_event(action)
    
    if Input.is_action_pressed("move_left"):
        var action := InputEventAction.new() 
        action.action = "move_left"
        action.pressed = false
        Input.parse_input_event(action)
    
    if Input.is_action_pressed("move_right"):
        var action := InputEventAction.new() 
        action.action = "move_right"
        action.pressed = false
        Input.parse_input_event(action)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey:
        was_last_event_from_keyboard = true
    elif event is InputEventScreenTouch or \
            event is InputEventMouseButton:
        was_last_event_from_keyboard = false

func _physics_process(_delta_sec: float) -> void:
    # NOTE: Regarding sequencing:
    # -   We need to continually emit move-sideways actions each frame,
    #     regardless of whether there was any new unhandled input for that
    #     frame. This means that we need to emit actions from _process, rather
    #     than from _unhandled_input.
    # -   _unhandled_input is triggered after _process. Since we are handling
    #     actions in _process rather than _unhandled_input, this means that
    #     we're handling actions one frame later than we potentially could.
    # -   Touch events cannot be polled; they can only be captured through the
    #     _unhandled_input method.
    
    if was_last_event_from_keyboard:
        return
    
    var is_some_action_just_pressed := \
            !Input.is_action_pressed("jump") and is_jump_pressed or \
            !Input.is_action_pressed("move_left") and is_move_left_pressed or \
            !Input.is_action_pressed("move_right") and is_move_right_pressed
    if is_some_action_just_pressed:
        Global.vibrate()
    
    if Input.is_action_pressed("jump") != is_jump_pressed:
        var action := InputEventAction.new() 
        action.action = "jump"
        action.pressed = is_jump_pressed
        Input.parse_input_event(action)
    
    if Input.is_action_pressed("move_left") != is_move_left_pressed:
        var action := InputEventAction.new() 
        action.action = "move_left"
        action.pressed = is_move_left_pressed
        Input.parse_input_event(action)
    
    if Input.is_action_pressed("move_right") != is_move_right_pressed:
        var action := InputEventAction.new() 
        action.action = "move_right"
        action.pressed = is_move_right_pressed
        Input.parse_input_event(action)

func _get_event_type_and_position(event: InputEvent) -> Array:
    var pointer_position := Vector2.INF
    var event_type: int = PointerEventType.UNKNOWN
    
    if is_mobile_device:
        # Touch-up: Position selection.
        if event is InputEventScreenTouch and \
                !event.pressed:
            event_type = PointerEventType.UP
            pointer_position = event.position
            
        # Touch-down: Position pre-selection.
        elif event is InputEventScreenTouch and \
                event.pressed:
            event_type = PointerEventType.DOWN
            pointer_position = event.position
            
        # Touch-move: Position pre-selection.
        elif event is InputEventScreenDrag:
            event_type = PointerEventType.DRAG
            pointer_position = event.position
    else:
        # Mouse-up: Position selection.
        if event is InputEventMouseButton and \
                event.button_index == BUTTON_LEFT and \
                !event.pressed:
            event_type = PointerEventType.UP
            pointer_position = get_global_mouse_position()
            is_mouse_down = false
            
        # Mouse-down: Position pre-selection.
        elif event is InputEventMouseButton and \
                event.button_index == BUTTON_LEFT and \
                event.pressed:
            event_type = PointerEventType.DOWN
            pointer_position = get_global_mouse_position()
            is_mouse_down = true
            
        # Mouse-move: Position pre-selection.
        elif event is InputEventMouseMotion and \
                is_mouse_down:
            event_type = PointerEventType.DRAG
            pointer_position = get_global_mouse_position()
    
    return [
        event_type,
        pointer_position,
    ]

func _update_position_and_time_buffer(pointer_position: Vector2) -> void:
    var previous_gesture_position := latest_gesture_position
    latest_gesture_position = pointer_position
    
    # Record the new drag position and time.
    var drag_position_and_time := PositionAndTime.new( \
            pointer_position, \
            Time.elapsed_play_time_actual_sec)
    recent_gesture_positions.push_front(drag_position_and_time)
    
    # Pop any old drag positions and times that have become stale.
    while recent_gesture_positions.back().time_sec < \
            Time.elapsed_play_time_actual_sec - \
            GESTURE_RECENT_POSITIONS_BUFFER_DELAY_SEC:
        recent_gesture_positions.pop_back()
    
    if recent_gesture_positions.size() == 1 or \
            latest_gesture_position == Vector2.INF:
        # This is the start of a new gesture.
        latest_leftward_position = latest_gesture_position
        latest_rightward_position = latest_gesture_position
    elif latest_gesture_position.x - previous_gesture_position.x > 0:
        # Gesture is moving rightward.
        latest_rightward_position = latest_gesture_position
    else:
        # Gesture is moving leftward.
        latest_leftward_position = latest_gesture_position
    
    is_positions_buffer_dirty = true

func _get_velocity() -> Vector2:
    var oldest_drag_position: PositionAndTime = \
            recent_gesture_positions.back()
    var newest_drag_position: PositionAndTime = \
            recent_gesture_positions.front()
    var delta_position := \
            newest_drag_position.position - \
            oldest_drag_position.position
    var delta_time := \
            newest_drag_position.time_sec - \
            oldest_drag_position.time_sec
    return delta_position / delta_time if \
            delta_time > 0.0 else \
            Vector2.ZERO

func _get_displacement_since_other_direction() -> Vector2:
    if latest_gesture_position == latest_leftward_position:
        return latest_gesture_position - latest_rightward_position
    else:
        return latest_gesture_position - latest_leftward_position

func get_pointer_down_position_to_annotate() -> Vector2:
    return Vector2.INF
