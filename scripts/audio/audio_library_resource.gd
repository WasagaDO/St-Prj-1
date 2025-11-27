extends Resource
class_name AudioLibrary

@export_category("Music")
@export var music_entries: Array[AudioEntry] = []

@export_category("SFX")
@export var sfx_entries: Array[AudioEntry] = []


func _find_entry(list: Array[AudioEntry], id: StringName) -> AudioEntry:
	var key := String(id).to_lower()
	for entry in list:
		if entry.id != null and String(entry.id).to_lower() == key:
			return entry
	return null

# either gives a music or sfx
func get_audio(id: StringName) -> AudioEntry:
	var entry := _find_entry(music_entries, id)
	if entry != null:
		return entry
	entry = _find_entry(sfx_entries, id)
	if entry != null:
		return entry
	push_warning("AudioLibrary: id '%s' not found." % id)
	return null


func get_music(id: StringName) -> AudioStream:
	var entry := _find_entry(music_entries, id)
	if entry == null:
		push_warning("AudioLibrary: music id '%s' not found." % id)
		return null
	return entry.stream


func get_sfx(id: StringName) -> AudioStream:
	var entry := _find_entry(sfx_entries, id)
	if entry == null:
		push_warning("AudioLibrary: sfx id '%s' not found." % id)
		return null
	return entry.stream
