extends Node2D
class_name Level

const MUSIC_STREAM := preload("res://assets/music/on_a_quest.ogg")

var music_player: AudioStreamPlayer

func _enter_tree() -> void:
    Global.current_level = self
    
    music_player = AudioStreamPlayer.new()
    add_child(music_player)

func _ready() -> void:
    _start_music()
    
    Global.is_level_ready = true

func _start_music() -> void:
    music_player.stream = MUSIC_STREAM
    music_player.play()
