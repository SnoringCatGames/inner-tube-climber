extends Node

const HEADERS := ["Content-Type: application/json"]

func record_recent_gestures() -> void:
    var recent_top_level_events_raw_str := ""
    var recent_control_events_raw_str := ""
    var recent_control_events_processed_str := ""
    
    if is_instance_valid(Global.gesture_record):
        var events: Array = Global.gesture_record \
                .recent_gesture_events_for_debugging
        for event in events:
            recent_top_level_events_raw_str += event.to_string()
    
    if is_instance_valid(Global.level):
        for event in Global.level.mobile_control_ui.mobile_control_input \
                .recent_gesture_events_for_debugging:
            recent_control_events_raw_str += event.to_string()
        
        for event in Global.level.mobile_control_ui.mobile_control_input \
                .recent_movement_events_for_debugging:
            recent_control_events_processed_str += event.to_string()
    
    var url: String = Utils.get_log_gestures_url()
    
    var body_object := {
        mobile_control_version = Global.mobile_control_version,
        recent_top_level_gesture_events = recent_top_level_events_raw_str,
        recent_control_level_gesture_events_raw = \
                recent_control_events_raw_str,
        recent_control_level_gesture_events_processed = \
                recent_control_events_processed_str,
    }
    var body_str := JSON.print(body_object)
    
    Global.print("Log.record_recent_gestures: %s" % url)
    
    if !Global.agreed_to_terms:
        # User hasn't agreed to data collection.
        Utils.error()
        return
    
    var request := HTTPRequest.new()
    request.use_threads = true
    request.connect( \
            "request_completed", \
            self, \
            "_on_record_recent_gestures_request_completed", \
            [request])
    add_child(request)
    
    var status: int = request.request( \
            url, \
            HEADERS, \
            true, \
            HTTPClient.METHOD_POST, \
            body_str)
    
    if status != OK:
        Utils.error( \
                "Log.record_recent_gestures failed: status=%d" % status, \
                false)

func _on_record_recent_gestures_request_completed( \
        result: int, \
        response_code: int, \
        headers: PoolStringArray, \
        body: PoolByteArray, \
        request: HTTPRequest) -> void:
    Global.print( \
            ("Log._on_record_recent_gestures_request_completed: " + \
            "result=%d, code=%d") % \
            [result, response_code])
    if result != HTTPRequest.RESULT_SUCCESS or \
            response_code < 200 or \
            response_code >= 300:
        Global.print("  Body:\n    " + body.get_string_from_utf8())
        Global.print("  Headers:\n    " + Utils.join(headers, ",\n    "))
    request.queue_free()
