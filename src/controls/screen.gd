extends Node2D
class_name Screen

var type := ScreenType.UNKNOWN
var includes_standard_hierarchy: bool
var includes_nav_bar: bool
var includes_center_container: bool

var nav_bar: NavBar
var scroll_container: ScrollContainer
var inner_vbox: VBoxContainer

func _init( \
        type: int, \
        includes_standard_hierarchy: bool, \
        includes_nav_bar := true, \
        includes_center_container := true) -> void:
    self.type = type
    self.includes_standard_hierarchy = includes_standard_hierarchy
    self.includes_nav_bar = includes_nav_bar
    self.includes_center_container = includes_center_container

func _ready() -> void:
    _validate_node_hierarchy()

func _validate_node_hierarchy() -> void:
    if includes_standard_hierarchy:
        var outer_vbox: VBoxContainer = $FullScreenPanel/VBoxContainer
        outer_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        outer_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
        
        if includes_nav_bar:
            nav_bar = $FullScreenPanel/VBoxContainer/NavBar
        
        scroll_container = \
                $FullScreenPanel/VBoxContainer/CenteredPanel/ScrollContainer
        assert(scroll_container != null)
        scroll_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
        
        if includes_center_container:
            inner_vbox = $FullScreenPanel/VBoxContainer/CenteredPanel/ \
                    ScrollContainer/CenterContainer/VBoxContainer
            assert(inner_vbox != null)
            
            var center_container: CenterContainer = \
                    $FullScreenPanel/VBoxContainer/CenteredPanel/ \
                    ScrollContainer/CenterContainer
            center_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
            center_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
        else:
            inner_vbox = $FullScreenPanel/VBoxContainer/CenteredPanel/ \
                    ScrollContainer/VBoxContainer
            assert(inner_vbox != null)

func _on_activated() -> void:
    pass

func _on_deactivated() -> void:
    pass

func _scroll_to_top() -> void:
    if includes_standard_hierarchy:
        yield(get_tree(), "idle_frame")
        var scroll_bar := scroll_container.get_v_scrollbar()
        scroll_container.scroll_vertical = scroll_bar.min_value
        
