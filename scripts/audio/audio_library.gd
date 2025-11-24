# audio_library.gd
extends Resource
class_name AudioLibrary

@export_category("Music")
@export var music: Dictionary = {}      # key: StringName, value: AudioStream

@export_category("SFX")
@export var sfx: Dictionary = {}        # key: StringName, value: AudioStream


# returns any type of audio : a music or sfx
func get_audio(id: StringName) -> AudioStream:
	var audio : AudioStream = get_music(id)
	if audio == null:
		audio = get_sfx(id)
	return audio

func get_music(id: StringName) -> AudioStream:
	var key := String(id).to_lower()
	for k in music.keys():
		if String(k).to_lower() == key:
			return music[k]
	push_warning("AudioLibrary: music id '%s' not found." % id)
	return null


func get_sfx(id: StringName) -> AudioStream:
	var key := String(id).to_lower()
	for k in sfx.keys():
		if String(k).to_lower() == key:
			return sfx[k]
	push_warning("AudioLibrary: sfx id '%s' not found." % id)
	return null
