extends Node

const AUDIO_LIBRARY_PATH: String = "res://resources/audio_library.tres"
const STANDALONE_PLAYER_PREFAB_PATH: String = "res://scenes/audio/standalone_audio_player.tscn"

var audio_library: AudioLibrary = preload(AUDIO_LIBRARY_PATH)
var standalone_player_prefab: PackedScene = preload(STANDALONE_PLAYER_PREFAB_PATH)


# scroll sounds system
const SCROLL_SOUND_ID: StringName = "Scrollbar"
const SCROLL_SOUND_BUFFER: float = 0.15
var _scroll_player: StandaloneAudioPlayer = null
var _scroll_buffer_time: float = 0.0
var _scroll_last_position: float = 0.0



# ---------- PUBLIC API ----------
func play_music(id: StringName, fade_in_duration: float = 0.0, volume_db: float = 0.0, pitch_scale: float = 1.0, survive_scene_change: bool = false) -> StandaloneAudioPlayer:
	return _play(id, "Music", volume_db, pitch_scale, fade_in_duration, survive_scene_change, false)


func play_sfx(id: StringName, fade_in_duration: float = 0.0, volume_db: float = 0.0, pitch_scale: float = 1.0, survive_scene_change: bool = false) -> StandaloneAudioPlayer:
	return _play(id, "SFX", volume_db, pitch_scale, fade_in_duration, survive_scene_change, true)


# ---------- CORE UNIFIED LOGIC ----------

func _process(delta: float) -> void:
	manage_scroll(delta)

func _play(id: StringName, bus_name: StringName, volume_db: float, pitch_scale: float, fade_in_duration: float, survive_scene_change: bool, destroy_on_finish: bool) -> StandaloneAudioPlayer:
	if audio_library == null:
		push_error("AudioManager: audio_library is not set.")
		return null

	var entry := audio_library.get_audio(id)
	if entry == null:
		return null
	var stream = entry.stream
	if stream == null:
		push_warning("AudioManager: AudioEntry '%s' has no stream." % id)
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

	var final_volume_db := entry.base_volume_db + volume_db

	if fade_in_duration > 0.0:
		player.volume_db = -80.0
		player.play()
		var tween := player.create_tween()
		tween.tween_property(player, "volume_db", final_volume_db, fade_in_duration).from(-80.0)
	else:
		player.volume_db = final_volume_db
		player.play()

	return player

# ----- SCROLL SYSTEM -----




func manage_scroll(delta: float):
	if _scroll_buffer_time > 0.0:
		_scroll_buffer_time -= delta
		if _scroll_buffer_time <= 0.0:
			_stop_scroll_sound()


func _stop_scroll_sound() -> void:
	if _scroll_player == null:
		return
	# remember the sound position for the next time we play it
	_scroll_last_position = _scroll_player.get_playback_position()
	_scroll_player.kill_audio(0.1) # small fade
	_scroll_player = null


func notify_inventory_scroll_moved() -> void:
	print("notify_inventory_scroll_moved()")
	_scroll_buffer_time = SCROLL_SOUND_BUFFER
	if _scroll_player != null and _scroll_player.playing:
		print("scroll player already exists, extending it")
		# a scroll player is already playing, we have nothing to do
		# except reset the timer
		return
	# no scroll player is playing
	print("no scroll player, creating one")
	var entry := audio_library.get_audio(SCROLL_SOUND_ID)
	if entry == null:
		push_warning("AudioManager: scroll sound '%s' not found in AudioLibrary." % SCROLL_SOUND_ID)
		return
	var stream = entry.stream
	if stream == null:
		push_warning("AudioManager: scroll sound '%s' has no stream." % SCROLL_SOUND_ID)
		return
	var player: StandaloneAudioPlayer = null
	if standalone_player_prefab != null:
		player = standalone_player_prefab.instantiate() as StandaloneAudioPlayer
	else:
		push_warning("Standalone Audio Player scene isn't set")
		return

	player.stream = stream
	player.pitch_scale = 1.0
	player.destroy_on_finish = true

	var bus_idx := AudioServer.get_bus_index("SFX")
	if bus_idx != -1:
		player.bus = "SFX"

	var scene_root := get_tree().current_scene
	if scene_root == null:
		scene_root = get_tree().root
	scene_root.add_child(player)

	player.volume_db = entry.base_volume_db
	player.play(_scroll_last_position)
	_scroll_player = player




# ---------- OPTIONAL VOLUME HELPERS ----------
func set_master_volume_db(volume_db: float) -> void:
	var bus := AudioServer.get_bus_index("Master")
	if bus != -1:
		AudioServer.set_bus_volume_db(bus, volume_db)


func set_bus_volume_db(bus_name: StringName, volume_db: float) -> void:
	var bus := AudioServer.get_bus_index(bus_name)
	if bus != -1:
		AudioServer.set_bus_volume_db(bus, volume_db)
