extends Node3D

@export var mat_off: StandardMaterial3D
@export var mat_on: StandardMaterial3D
@export var led_mesh: MeshInstance3D

@onready var radio_audio: AudioStreamPlayer = $"Walkie Talkie/AudioStreamPlayer"        
@onready var click_up: AudioStreamPlayer = $"Walkie Talkie/ClickAudioUp" 
@onready var click_down: AudioStreamPlayer = $"Walkie Talkie/ClickAudioDown"
@onready var anomaly_audio: AudioStreamPlayer = $"Walkie Talkie/AnomalyAudioPlayer" 
@onready var jangkrik_audio: AudioStreamPlayer = $JangkrikAudio

@export var anim_player: AnimationPlayer
@export var paper_anim_player: AnimationPlayer 

@export var heartbeat_audio: AudioStreamPlayer
@export var climax_bell_audio: AudioStreamPlayer

@export var camera_node: Camera3D 

@export var skeleton_ik_kanan: SkeletonIK3D
@export var skeleton_ik_kiri: SkeletonIK3D

@onready var label_kertas_catatan: Label = $CanvasLayer/PanelKertasMorse/LabelKertasCatatan
@onready var label_layar_radio: RichTextLabel = $CanvasLayer/LabelLayarRadio
@onready var label_misi_bawah: Label = $CanvasLayer/LabelMisiBawah
@onready var overlay_tutup_mata: ColorRect = $CanvasLayer/OverlayTutupMata
@onready var overlay_anomali_suara: TextureRect = $CanvasLayer/OverlayAnomaliSuara
@onready var overlay_vinyet_visual: ColorRect = $CanvasLayer/OverlayVinyetVisual

@export_category("Pengaturan Dinamis Tutup Mata")
@export var kecepatan_tutup_mata: float = 15.0  
@export var kecepatan_buka_mata: float = 12.0  

@export_category("UI Event Ranger")
@export var panel_event_ranger: Control
@export var label_pertanyaan_ranger: Label
@export var btn_pilihan_1: Button
@export var btn_pilihan_2: Button
@export var btn_pilihan_3: Button
@export var btn_pilihan_4: Button
@export var label_timer_event: Label

var daftar_arsip_misi: Array[Dictionary] = [
	{ "koordinat": "19.42.805", "target_kalimat": "MY CAR IS NEAR THE CLIFF" },
	{ "koordinat": "45.10.913", "target_kalimat": "I NEED HELP FROM SOMEONE" },
	{ "koordinat": "72.88.304", "target_kalimat": "SOMETHING IS WRONG HERE" },
	{ "koordinat": "31.55.670", "target_kalimat": "WESTWARDS FROM THE POST" },
	{ "koordinat": "88.03.149", "target_kalimat": "SEND ME HELP IMMEDIATELY" },
	{ "koordinat": "12.75.402", "target_kalimat": "IM SCARED SAVE ME RANGER" },
	{ "koordinat": "64.21.983", "target_kalimat": "I CANT MOVE MY WHOLE BODY" },
	{ "koordinat": "99.14.320", "target_kalimat": "COORDINATES HAVE BEEN SENT" },
	{ "koordinat": "23.90.511", "target_kalimat": "HURRY UP SOMETHING IS WEIRD OUT HERE" },
	{ "koordinat": "57.33.688", "target_kalimat": "OH MY GOD HURRY UP SIR" }
]

var daftar_event_ranger: Array[Dictionary] = [
	{
		"teks_ranger": "RANGER: ARE YOU SAFE OVER THERE? [... .- ..-. . ?]",
		"pilihan": [
			{"kode": ".-", "teks": "YES I AM SAFE", "benar": true},
			{"kode": "-...", "teks": "SOMETHING IS HERE", "benar": false},
			{"kode": "--.", "teks": "I HEAR FOOTSTEPS", "benar": false},
			{"kode": "-..", "teks": "HELP ME FAST", "benar": false}
		]
	},
	{
		"teks_ranger": "RANGER: CAN YOU HOLD THE LINE? [-.-. .- -. -.]",
		"pilihan": [
			{"kode": "..", "teks": "YES I CAN", "benar": false},
			{"kode": "---", "teks": "SIGNAL IS LOST", "benar": false},
			{"kode": ".-..", "teks": "HOLDING ON NOW", "benar": true},
			{"kode": "...-", "teks": "I WANT TO ESCAPE", "benar": false}
		]
	},
	{
		"teks_ranger": "RANGER: WHAT DO YOU SEE OUT THERE? [-.. ---]",
		"pilihan": [
			{"kode": ".----", "teks": "NOTHING AT ALL", "benar": false},
			{"kode": "..---", "teks": "A DARK FIGURE", "benar": true},
			{"kode": "...--", "teks": "JUST THE TREES", "benar": false},
			{"kode": "....-", "teks": "MY CAR LIGHTS", "benar": false}
		]
	},
	{
		"teks_ranger": "RANGER: WHERE IS YOUR POSITION NOW? [-.. ..- .]",
		"pilihan": [
			{"kode": "...---...", "teks": "NEAR THE OLD SHACK", "benar": true},
			{"kode": ".-.-.-", "teks": "DEEP IN THE WOODS", "benar": false},
			{"kode": "-..-.", "teks": "BY THE MAIN ROAD", "benar": false},
			{"kode": "..--..", "teks": "LOST IN THE FOG", "benar": false}
		]
	},
	{
		"teks_ranger": "RANGER: DO YOU COPY MY VOICE CLEARLY? (-. -.-.)",
		"pilihan": [
			{"kode": "--.-", "teks": "LOUD AND CLEAR", "benar": false},
			{"kode": "..-.", "teks": "STATIC IS TOO LOUD", "benar": true},
			{"kode": "-.-.", "teks": "VOICE IS MUTED", "benar": false},
			{"kode": "...-.", "teks": "SIGNAL DROPPING", "benar": false}
		]
	}
]

var misi_aktif: Dictionary = {}
var koordinat_target: String = ""
var target_kalimat: String = ""

var tahap_misi: int = 0
var indeks_karakter_aktif: int = 0
var target_morse_karakter_ini: String = ""

var kamus_morse: Dictionary = {
	"A": ".-", "B": "-...", "C": "-.-.", "D": "-..", "E": ".", "F": "..-.",
	"G": "--.", "H": "....", "I": "..", "J": ".---", "K": "-.-", "L": ".-..",
	"M": "--", "N": "-.", "O": "---", "P": ".--.", "Q": "--.-", "R": ".-.",
	"S": "...", "T": "-", "U": "..-", "V": "...-", "W": ".--", "X": "-..-",
	"Y": "-.--", "Z": "--..",
	"0": "-----", "1": ".----", "2": "..---", "3": "...--", "4": "....-",
	"5": ".....", "6": "-....", "7": "--...", "8": "---..", "9": "----."
}

var daftar_halaman_kertas: Array[String] = []
var indeks_halaman_aktif: int = 0

@export_category("Pengaturan Debug & Playtest")
@export var debug_god_mode: bool = false 
@export var debug_skip_to_climax: bool = false 
@export_enum("Easy (Santai)", "Normal (Standar)", "Hardcore (Tegang)", "Nightmare (Ekstrem)") var game_difficulty: int = 1

@export var anomaly_sound_list: Array[AudioStream] = []
@export_category("Pengaturan Audio Anomali")
@export var anomaly_volume_db: float = 0.0      
@export var anomaly_pitch_scale: float = 0.6    

@export_category("Pengaturan Anomali Visual")
@export var monster_node: Node3D                          
@export var monster_animation_player: AnimationPlayer      
@export var monster_poses: Array[String] = ["pose_1", "pose_2", "pose_3", "pose_4"]

var visual_anomaly_timer: float = 0.0
var next_visual_anomaly_time: float = 20.0
var is_visual_anomaly_active: bool = false
var visual_reaction_timer: float = 0.0
var max_visual_reaction_time: float = 3.0 

var eye_closure_timer: float = 0.0
var required_eye_closure_time: float = 2.0

var camera_shake_duration: float = 0.0
var camera_shake_intensity: float = 0.0
var default_camera_fov: float = 75.0

enum State { SEARCHING, TRANSMITTING, CLIMAX_SURVIVE }
var current_state: State = State.SEARCHING

var current_frequency: float = 10.0
var target_frequency: float = 50.0 
var min_frequency: float = 10.0
var max_frequency: float = 100.0
var is_in_range: bool = false

var signal_hold_timer: float = 0.0
var required_hold_time: float = 3.0

var morse_progress: String = "" 

var disconnection_timer: float = 0.0
var next_disconnection_time: float = 6.0 

var climax_timer: float = 0.0
var max_climax_time: float = 40.0

var is_ranger_event_active: bool = false
var has_triggered_ranger_event: bool = false
var event_timer: float = 0.0
var max_event_time: float = 8.0 
var current_event_data: Dictionary = {}

var is_holding_radio: bool = false   
var is_eyes_closed: bool = false    
var is_paper_out: bool = false 

var is_virtual_up_pressed: bool = false
var is_virtual_down_pressed: bool = false
var is_virtual_morse_holding: bool = false
var virtual_morse_press_time: float = 0.0

var anomaly_timer: float = 0.0
var next_anomaly_time: float = 15.0 
var is_sound_anomaly_active: bool = false
var sound_reaction_timer: float = 0.0
var max_sound_reaction_time: float = 3.0 

func _ready() -> void:
	if skeleton_ik_kanan and not skeleton_ik_kanan.is_running(): skeleton_ik_kanan.start()
	if skeleton_ik_kiri and not skeleton_ik_kiri.is_running(): skeleton_ik_kiri.start()
			
	if camera_node: default_camera_fov = camera_node.fov

	misi_aktif = daftar_arsip_misi[randi() % daftar_arsip_misi.size()]
	koordinat_target = misi_aktif["koordinat"]
	target_kalimat = misi_aktif["target_kalimat"]
	
	tahap_misi = 0
	indeks_karakter_aktif = 0
	perbarui_target_karakter_morse()

	target_frequency = snappedf(randf_range(min_frequency, max_frequency) * 2.0, 1.0) / 2.0
	
	inisialisasi_halaman_kertas()
	perbarui_tampilan_kertas()
	update_led_state(false)
	
	if label_misi_bawah: label_misi_bawah.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	if panel_event_ranger: panel_event_ranger.visible = false
	if overlay_tutup_mata: overlay_tutup_mata.modulate.a = 0.0 
	if overlay_anomali_suara: overlay_anomali_suara.modulate.a = 0.0 
	if overlay_vinyet_visual: 
		overlay_vinyet_visual.modulate.a = 0.0
		if overlay_vinyet_visual.material is ShaderMaterial:
			overlay_vinyet_visual.material.set_shader_parameter("radius", 1.8)
	if monster_node: monster_node.visible = false

	if radio_audio:
		if not radio_audio.finished.is_connected(_on_audio_finished): radio_audio.finished.connect(_on_audio_finished)
		radio_audio.volume_db = -80.0 
		radio_audio.playing = true

	if anomaly_audio and not anomaly_audio.finished.is_connected(_on_anomaly_audio_finished):
		anomaly_audio.finished.connect(_on_anomaly_audio_finished)

	if jangkrik_audio:
		jangkrik_audio.volume_db = -5.0 
		jangkrik_audio.play()

	atur_parameter_kesulitan_awal()
	if debug_skip_to_climax: trigger_klimaks_misi()

func atur_parameter_kesulitan_awal() -> void:
	var diff_multiplier = [1.5, 1.0, 0.7, 0.4][game_difficulty]
	next_anomaly_time = randf_range(15.0, 25.0) * diff_multiplier
	next_visual_anomaly_time = randf_range(20.0, 35.0) * diff_multiplier
	max_sound_reaction_time = 3.0 * diff_multiplier
	max_visual_reaction_time = 3.0 * diff_multiplier

func _on_audio_finished() -> void:
	if radio_audio: radio_audio.play()

func fade_audio(player: AudioStreamPlayer, target_db: float, duration: float) -> void:
	if not player: return
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(player, "volume_db", target_db, duration)

func perbarui_target_karakter_morse() -> void:
	if tahap_misi == 0:
		while indeks_karakter_aktif < koordinat_target.length():
			if koordinat_target.substr(indeks_karakter_aktif, 1) == ".":
				indeks_karakter_aktif += 1
			else:
				target_morse_karakter_ini = kamus_morse.get(koordinat_target.substr(indeks_karakter_aktif, 1), "")
				return
		tahap_misi = 1
		indeks_karakter_aktif = 0
		perbarui_target_karakter_morse()
	elif tahap_misi == 1:
		while indeks_karakter_aktif < target_kalimat.length():
			if target_kalimat.substr(indeks_karakter_aktif, 1) == " ":
				indeks_karakter_aktif += 1
			else:
				target_morse_karakter_ini = kamus_morse.get(target_kalimat.substr(indeks_karakter_aktif, 1), "")
				return
		trigger_klimaks_misi()

func trigger_klimaks_misi() -> void:
	current_state = State.CLIMAX_SURVIVE
	climax_timer = 0.0
	has_triggered_ranger_event = false
	
	var climax_mult = [1.2, 1.0, 0.7, 0.5][game_difficulty]
	next_anomaly_time = 3.0 * climax_mult
	next_visual_anomaly_time = 5.0 * climax_mult
	
	if climax_bell_audio:
		climax_bell_audio.volume_db = 0.0
		climax_bell_audio.play()

func inisialisasi_halaman_kertas() -> void:
	daftar_halaman_kertas = [
		"FREQ TARGET: " + str(target_frequency) + " MHz\n\nNUMBERS:\n1: .----   6: -....\n2: ..---   7: --...\n3: ...--   8: ---..\n4: ....-   9: ----.\n5: .....   0: -----",
		"ALPHABET (A-M):\n\nA: .-     H: ....\nB: -...   I: ..\nC: -.-.   J: .---\nD: -..    K: -.-\nE: .      L: .-..\nF: ..-.   M: --\nG: --.",
		"ALPHABET (N-Z):\n\nN: -.     U: ..-\nO: ---    V: ...-\nP: .--.   W: .--\nQ: --.-   X: -..-\nR: .-.    Y: -.--\nS: ...    Z: --..\nT: -"
	]

func perbarui_tampilan_kertas() -> void:
	if label_kertas_catatan and not daftar_halaman_kertas.is_empty():
		label_kertas_catatan.text = daftar_halaman_kertas[indeks_halaman_aktif]

func _process(delta: float) -> void:
	if not is_ranger_event_active:
		handle_sound_anomaly_system(delta)
		handle_visual_anomaly_system(delta)
	else:
		handle_ranger_event_logic(delta)

	if is_virtual_morse_holding: virtual_morse_press_time += delta

	# Camera Shake yang Halus
	if camera_node:
		var time = Time.get_ticks_msec() * 0.01
		var current_shake = camera_shake_intensity * (camera_shake_duration / 0.8) if camera_shake_duration > 0.0 else 0.0
		var sway_x = sin(time * 3.5) * 0.0008 + randf_range(-current_shake, current_shake)
		var sway_y = cos(time * 4.0) * 0.0008 + randf_range(-current_shake, current_shake)
		
		if camera_shake_duration > 0.0: camera_shake_duration -= delta
		else: camera_shake_intensity = 0.0
		
		camera_node.h_offset = sway_x
		camera_node.v_offset = sway_y

	# UI Overlays & Labels
	if overlay_tutup_mata:
		overlay_tutup_mata.modulate.a = move_toward(overlay_tutup_mata.modulate.a, float(is_eyes_closed), delta * (kecepatan_tutup_mata if is_eyes_closed else kecepatan_buka_mata))
		
	# Efek Merah Berdenyut Organik saat Anomali Suara
	if overlay_anomali_suara:
		var pulse = abs(sin(Time.get_ticks_msec() * 0.01)) * 0.35 + 0.1
		var target_alpha = pulse if is_sound_anomaly_active else 0.0
		overlay_anomali_suara.modulate.a = move_toward(overlay_anomali_suara.modulate.a, target_alpha, delta * 8.0)

	# Animasi Vignet Menyebar (Fade In / Fade Out & Radius Lebar)
	if overlay_vinyet_visual:
		var target_vignette_alpha = 0.55 if is_visual_anomaly_active else 0.0
		overlay_vinyet_visual.modulate.a = move_toward(overlay_vinyet_visual.modulate.a, target_vignette_alpha, delta * 4.0)
		
		if overlay_vinyet_visual.material is ShaderMaterial:
			var target_radius = 1.0 if is_visual_anomaly_active else 1.8
			var current_radius = overlay_vinyet_visual.material.get_shader_parameter("radius")
			if current_radius != null:
				var new_radius = move_toward(current_radius, target_radius, delta * 2.5)
				overlay_vinyet_visual.material.set_shader_parameter("radius", new_radius)

	if camera_node:
		var target_fov = (default_camera_fov - 5.0) if is_visual_anomaly_active else default_camera_fov
		camera_node.fov = move_toward(camera_node.fov, target_fov, delta * 15.0)

	if label_layar_radio:
		if not is_holding_radio: label_layar_radio.text = "RADIO STORED"
		elif current_state == State.TRANSMITTING: label_layar_radio.text = "INPUT: [ " + morse_progress + " ]"
		elif current_state == State.CLIMAX_SURVIVE:
			label_layar_radio.text = "[color=red]HOLD YOUR RADIO![/color]" if not is_holding_radio else "SURVIVE: [color=red]" + str(snappedf(max(0.0, max_climax_time - climax_timer), 0.1)) + "s[/color]"
		else: label_layar_radio.text = "FREQ: " + str(snappedf(current_frequency, 0.1)) + " MHz"

	# Progres titik-titik pada teks misi bawah
	if label_misi_bawah and not misi_aktif.is_empty():
		var koord_tampilan = ""
		for i in range(koordinat_target.length()):
			var c = koordinat_target.substr(i, 1)
			if c == ".": koord_tampilan += "."
			elif tahap_misi > 0 or i < indeks_karakter_aktif: koord_tampilan += "."
			else: koord_tampilan += c

		var pesan_tampilan = ""
		if tahap_misi == 1:
			for i in range(target_kalimat.length()):
				var c = target_kalimat.substr(i, 1)
				if c == " ": pesan_tampilan += " "
				elif i < indeks_karakter_aktif: pesan_tampilan += "."
				else: pesan_tampilan += c
		else:
			pesan_tampilan = target_kalimat

		label_misi_bawah.text = koord_tampilan + "\n" + pesan_tampilan

	# Audio Volume Control Radio
	if radio_audio:
		var should_play_radio = is_holding_radio and not is_eyes_closed
		if not should_play_radio:
			fade_audio(radio_audio, -80.0, 0.3)
			if not is_holding_radio and is_sound_anomaly_active: 
				resolve_sound_anomaly()
		else:
			var target_vol = 0.0 if current_state != State.SEARCHING else remap(clampf(abs(current_frequency - target_frequency), 0.0, 20.0), 20.0, 0.0, -25.0, 0.0)
			fade_audio(radio_audio, target_vol, 0.1)

	if is_holding_radio:
		if current_state == State.SEARCHING: handle_frequency_search(delta)
		elif current_state == State.TRANSMITTING: handle_morse_input(delta)
		elif current_state == State.CLIMAX_SURVIVE: handle_climax_survive(delta)

func trigger_camera_shake(duration: float, intensity: float) -> void:
	camera_shake_duration = duration
	camera_shake_intensity = intensity

func trigger_ranger_event() -> void:
	is_ranger_event_active = true
	has_triggered_ranger_event = true
	event_timer = 0.0
	max_event_time = [12.0, 8.0, 6.0, 4.0][game_difficulty]
	current_event_data = daftar_event_ranger[randi() % daftar_event_ranger.size()]
	
	if panel_event_ranger: panel_event_ranger.visible = true
	if label_pertanyaan_ranger: label_pertanyaan_ranger.text = current_event_data["teks_ranger"]
	
	for i in range(4):
		var btn = [btn_pilihan_1, btn_pilihan_2, btn_pilihan_3, btn_pilihan_4][i]
		if btn: btn.text = current_event_data["pilihan"][i]["kode"] + "  " + current_event_data["pilihan"][i]["teks"]

func handle_ranger_event_logic(delta: float) -> void:
	event_timer += delta
	if label_timer_event: label_timer_event.text = "TIME: " + str(snappedf(max(0.0, max_event_time - event_timer), 0.1)) + "s"
	if event_timer >= max_event_time:
		if debug_god_mode: selesaikan_ranger_event(true)
		else: trigger_game_over("KALAH: Terlambat menjawab pertanyaan event dari Ranger!") 

func eksekusi_jawaban(indeks: int) -> void:
	if is_ranger_event_active: selesaikan_ranger_event(current_event_data["pilihan"][indeks]["benar"])

func selesaikan_ranger_event(is_correct: bool) -> void:
	is_ranger_event_active = false
	if panel_event_ranger: panel_event_ranger.visible = false
	if not is_correct:
		climax_timer = maxf(0.0, climax_timer - [5.0, 10.0, 15.0, 25.0][game_difficulty])

func handle_climax_survive(delta: float) -> void:
	if not is_ranger_event_active and is_holding_radio:
		climax_timer += delta
		if climax_timer >= (max_climax_time * 0.5) and not has_triggered_ranger_event: trigger_ranger_event()
		if climax_timer >= max_climax_time: trigger_victory()

func toggle_radio_state() -> void:
	if anim_player and anim_player.is_playing(): return
	is_holding_radio = not is_holding_radio
	if anim_player:
		if is_holding_radio: anim_player.play("gerak_radio") 
		else: anim_player.play_backwards("gerak_radio") 
	if is_holding_radio and click_up: click_up.play()
	elif not is_holding_radio and click_down: click_down.play()

func toggle_paper_state() -> void:
	if paper_anim_player and paper_anim_player.is_playing(): return
	is_paper_out = not is_paper_out
	if paper_anim_player:
		if is_paper_out: paper_anim_player.play("gerak_kertas") 
		else: paper_anim_player.play_backwards("gerak_kertas") 

func _on_panel_kertas_morse_gui_input(_event: InputEvent) -> void:
	if (_event is InputEventMouseButton or _event is InputEventScreenTouch) and _event.pressed:
		toggle_paper_state()

func fade_heartbeat(target_db: float, duration: float) -> void:
	if not heartbeat_audio: return
	if target_db > -80.0 and not heartbeat_audio.playing:
		heartbeat_audio.volume_db = -80.0
		heartbeat_audio.play()
	var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(heartbeat_audio, "volume_db", target_db, duration)
	if target_db <= -79.0: tween.tween_callback(heartbeat_audio.stop)

func handle_sound_anomaly_system(delta: float) -> void:
	if not is_sound_anomaly_active:
		if anomaly_audio and not anomaly_audio.playing:
			anomaly_timer += delta
			if anomaly_timer >= next_anomaly_time: trigger_sound_anomaly()
	else:
		sound_reaction_timer += delta
		if sound_reaction_timer >= max_sound_reaction_time:
			if debug_god_mode: resolve_sound_anomaly()
			elif is_holding_radio: trigger_game_over("KALAH: Gagal merespon anomali suara!")

func trigger_sound_anomaly() -> void:
	is_sound_anomaly_active = true
	sound_reaction_timer = 0.0
	trigger_camera_shake(0.3, 0.005) 
	if anomaly_sound_list.size() > 0 and anomaly_audio:
		anomaly_audio.stream = anomaly_sound_list[randi() % anomaly_sound_list.size()]
		anomaly_audio.volume_db = -80.0 
		anomaly_audio.pitch_scale = anomaly_pitch_scale
		anomaly_audio.play()
		fade_audio(anomaly_audio, anomaly_volume_db, 0.2)

func _on_anomaly_audio_finished() -> void:
	if is_sound_anomaly_active: resolve_sound_anomaly()

func resolve_sound_anomaly() -> void:
	is_sound_anomaly_active = false
	anomaly_timer = 0.0
	sound_reaction_timer = 0.0
	var ranges = [[3.0, 5.0], [2.0, 4.0], [1.5, 3.0], [0.8, 1.8]] if current_state == State.CLIMAX_SURVIVE else [[20.0, 35.0], [15.0, 25.0], [10.0, 18.0], [5.0, 10.0]]
	next_anomaly_time = randf_range(ranges[game_difficulty][0], ranges[game_difficulty][1])

func handle_visual_anomaly_system(delta: float) -> void:
	if not is_visual_anomaly_active:
		visual_anomaly_timer += delta
		if visual_anomaly_timer >= next_visual_anomaly_time: trigger_visual_anomaly()
	else:
		visual_reaction_timer += delta
		if is_eyes_closed:
			eye_closure_timer += delta
			if eye_closure_timer >= required_eye_closure_time: resolve_visual_anomaly()
		else:
			eye_closure_timer = 0.0
			if visual_reaction_timer >= max_visual_reaction_time:
				if debug_god_mode: resolve_visual_anomaly()
				else: trigger_game_over("KALAH: Terkena serangan anomali visual!")

func trigger_visual_anomaly() -> void:
	is_visual_anomaly_active = true
	visual_reaction_timer = 0.0
	eye_closure_timer = 0.0 
	trigger_camera_shake(0.5, 0.008) 
	fade_heartbeat(0.0, 0.8)
	
	if monster_node and monster_animation_player and not monster_poses.is_empty():
		monster_animation_player.stop()
		monster_node.visible = true
		monster_animation_player.play(monster_poses[randi() % monster_poses.size()], -1.0, 1.0, false)
		monster_animation_player.seek(0.0, true)

func resolve_visual_anomaly() -> void:
	is_visual_anomaly_active = false
	visual_anomaly_timer = 0.0
	visual_reaction_timer = 0.0
	eye_closure_timer = 0.0
	fade_heartbeat(-80.0, 0.5)
	
	var ranges = [[4.0, 6.0], [3.0, 5.0], [2.0, 4.0], [1.2, 2.5]] if current_state == State.CLIMAX_SURVIVE else [[30.0, 45.0], [20.0, 35.0], [15.0, 25.0], [8.0, 14.0]]
	next_visual_anomaly_time = randf_range(ranges[game_difficulty][0], ranges[game_difficulty][1])
	if monster_node: monster_node.visible = false

func trigger_game_over(alasan: String = "KALAH") -> void:
	print("GAME OVER: ", alasan)
	fade_heartbeat(-80.0, 0.2)
	get_tree().reload_current_scene()

func trigger_victory() -> void:
	fade_heartbeat(-80.0, 1.0)
	get_tree().change_scene_to_file("res://cutscene.tscn")

func handle_frequency_search(delta: float) -> void:
	if not is_holding_radio or is_eyes_closed:
		is_virtual_up_pressed = false
		is_virtual_down_pressed = false
		return

	if is_virtual_up_pressed:
		current_frequency += 10.0 * delta
		if click_up and not click_up.playing: click_up.play()
	if is_virtual_down_pressed:
		current_frequency -= 10.0 * delta
		if click_down and not click_down.playing: click_down.play()

	current_frequency = clampf(current_frequency, min_frequency, max_frequency)
	if abs(current_frequency - target_frequency) <= 0.3:
		if not is_in_range: is_in_range = true
		signal_hold_timer += delta
		update_led_state(true) 
		if signal_hold_timer >= required_hold_time:
			current_state = State.TRANSMITTING
			disconnection_timer = 0.0
			next_disconnection_time = [12.0, 6.0, 4.0, 2.5][game_difficulty]
	else:
		if is_in_range:
			is_in_range = false
			signal_hold_timer = 0.0
			update_led_state(false)

func handle_morse_input(delta: float) -> void:
	if not is_holding_radio: return
	if abs(current_frequency - target_frequency) > 0.3:
		current_state = State.SEARCHING
		signal_hold_timer = 0.0
		is_in_range = false
		morse_progress = ""
		update_led_state(false)
		return

	if not debug_god_mode:
		disconnection_timer += delta
		if disconnection_timer >= next_disconnection_time:
			current_state = State.SEARCHING 
			signal_hold_timer = 0.0
			is_in_range = false
			morse_progress = "" 
			update_led_state(false) 
			current_frequency = snappedf(randf_range(min_frequency, max_frequency) * 2.0, 1.0) / 2.0
			disconnection_timer = 0.0

func check_morse_completion() -> void:
	if morse_progress == target_morse_karakter_ini:
		morse_progress = ""
		indeks_karakter_aktif += 1
		perbarui_target_karakter_morse()
	elif morse_progress.length() >= target_morse_karakter_ini.length():
		morse_progress = ""

func update_led_state(turned_on: bool) -> void:
	if led_mesh:
		led_mesh.material_override = mat_on if turned_on else mat_off

func _on_btn_next_page_pressed() -> void:
	indeks_halaman_aktif = posmod(indeks_halaman_aktif + 1, daftar_halaman_kertas.size())
	perbarui_tampilan_kertas()

func _on_btn_prev_page_pressed() -> void:
	indeks_halaman_aktif = posmod(indeks_halaman_aktif - 1, daftar_halaman_kertas.size())
	perbarui_tampilan_kertas()

func _on_btn_radio_pressed() -> void: toggle_radio_state()
func _on_btn_eyes_button_down() -> void: is_eyes_closed = true
func _on_btn_eyes_button_up() -> void: is_eyes_closed = false
func _on_btn_up_button_down() -> void: is_virtual_up_pressed = true
func _on_btn_up_button_up() -> void: is_virtual_up_pressed = false
func _on_btn_down_button_down() -> void: is_virtual_down_pressed = true
func _on_btn_down_button_up() -> void: is_virtual_down_pressed = false

func _on_btn_morse_button_down() -> void: 
	if is_holding_radio and current_state == State.TRANSMITTING:
		is_virtual_morse_holding = true
		virtual_morse_press_time = 0.0

func _on_btn_morse_button_up() -> void:
	if is_holding_radio and current_state == State.TRANSMITTING and is_virtual_morse_holding:
		is_virtual_morse_holding = false
		morse_progress += "." if virtual_morse_press_time < 0.3 else "-"
		check_morse_completion()
	else:
		is_virtual_morse_holding = false
	virtual_morse_press_time = 0.0

func _on_btn_clear_morse_pressed() -> void:
	if is_holding_radio and morse_progress.length() > 0:
		morse_progress = morse_progress.substr(0, morse_progress.length() - 1)

func _on_btn_pilihan_1_pressed() -> void: eksekusi_jawaban(0)
func _on_btn_pilihan_2_pressed() -> void: eksekusi_jawaban(1)
func _on_btnpilihan_3_pressed() -> void: eksekusi_jawaban(2)
func _on_btn_pilihan_4_pressed() -> void: eksekusi_jawaban(3)
