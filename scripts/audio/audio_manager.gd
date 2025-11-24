extends Node

const AUDIO_LIBRARY_PATH: String = "res://resources/audio_library.tres"
const STANDALONE_PLAYER_PREFAB_PATH: String = "res://scenes/audio/standalone_audio_player.tscn"

var audio_library: AudioLibrary = preload(AUDIO_LIBRARY_PATH)
var standalone_player_prefab: PackedScene = preload(STANDALONE_PLAYER_PREFAB_PATH)


# ---------- PUBLIC API ----------
func play_music(id: StringName, fade_in_duration: float = 0.0, volume_db: float = 0.0, pitch_scale: float = 1.0, survive_scene_change: bool = false) -> StandaloneAudioPlayer:
	return _play(id, "Music", volume_db, pitch_scale, fade_in_duration, survive_scene_change, false)


func play_sfx(id: StringName, fade_in_duration: float = 0.0, volume_db: float = 0.0, pitch_scale: float = 1.0, survive_scene_change: bool = false) -> StandaloneAudioPlayer:
	return _play(id, "SFX", volume_db, pitch_scale, fade_in_duration, survive_scene_change, true)


# ---------- CORE UNIFIED LOGIC ----------
func _play(id: StringName, bus_name: StringName, volume_db: float, pitch_scale: float, fade_in_duration: float, survive_scene_change: bool, destroy_on_finish: bool) -> StandaloneAudioPlayer:
	if audio_library == null:
		push_error("AudioManager: audio_library is not set.")
		return null

	var stream := audio_library.get_audio(id)
	if stream == null:
		return null

	var player: StandaloneAudioPlayer = standalone_player_prefab.instantiate() as StandaloneAudioPlayer
	if standalone_player_prefab == null:
		player = StandaloneAudioPlayer.new()

	player.stream = stream
	player.pitch_scale = pitch_scale
	player.destroy_on_finish = destroy_on_finish

	var bus_idx := AudioServer.get_bus_index(bus_name)
	if bus_idx != -1:
		player.bus = bus_name

	if survive_scene_change:
		get_tree().get_root().add_child(player)
	else:
		var scene_root := get_tree().current_scene
		if scene_root == null:
			scene_root = get_tree().root
		scene_root.add_child(player)

	if fade_in_duration > 0.0:
		player.volume_db = -80.0
		player.play()
		var tween := player.create_tween()
		tween.tween_property(player, "volume_db", volume_db, fade_in_duration).from(-80.0)
	else:
		player.volume_db = volume_db
		player.play()

	return player


# ---------- OPTIONAL VOLUME HELPERS ----------
func set_master_volume_db(volume_db: float) -> void:
	var bus := AudioServer.get_bus_index("Master")
	if bus != -1:
		AudioServer.set_bus_volume_db(bus, volume_db)


func set_bus_volume_db(bus_name: StringName, volume_db: float) -> void:
	var bus := AudioServer.get_bus_index(bus_name)
	if bus != -1:
		AudioServer.set_bus_volume_db(bus, volume_db)
