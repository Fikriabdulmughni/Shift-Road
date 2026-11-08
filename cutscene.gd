extends Node3D

@export_file("res://game.tscn") var scene_game_tujuan: String

@onready var label_narasi: Label = $CanvasLayer/LabelNarasi
@onready var kamera_utama: Camera3D = $Camera3D
@onready var color_rect_fade: ColorRect = $CanvasLayer/ColorRectFade
@onready var audio_ketik: AudioStreamPlayer = $CanvasLayer/AudioKetik
@onready var animation_player: AnimationPlayer = $AnimationPlayer 

# Array Arsip Resource .tres
@export var arsip_cutscene: Array[Resource] = []

var indeks_langkah: int = 0
var sedang_transisi: bool = false
var cooldown_klik: float = 0.0 
var tween_teks: Tween
var tween_swing: Tween # BARU: Tween khusus untuk animasi swing/geser teks dari bawah

# Pengaturan potong audio (0.33 detik)
var timer_audio_crop: float = 0.0
const BATAS_DURASI_AUDIO: float = 0.33 

# Variabel untuk menyimpan posisi normal asal si label narasi di layar
var posisi_awal_label: Vector2

func _ready() -> void:
	if color_rect_fade: 
		color_rect_fade.modulate.a = 0.0
		
	if label_narasi:
		posisi_awal_label = label_narasi.position # Simpan posisi default aslinya
	
	indeks_langkah = 0
	print("[DEBUG CUTSCENE] Scene dimulai. Memuat arsip langkah ke: ", indeks_langkah)
	tampilkan_langkah_aktif()

func _process(delta: float) -> void:
	if cooldown_klik > 0.0:
		cooldown_klik -= delta
		
	# Looping audio ketik + batasi durasi potong (crop) otomatis di 0.33 detik
	if tween_teks and tween_teks.is_running() and audio_ketik:
		if not audio_ketik.playing:
			audio_ketik.play()
			timer_audio_crop = 0.0 
		else:
			timer_audio_crop += delta
			if timer_audio_crop >= BATAS_DURASI_AUDIO:
				audio_ketik.stop()

func _input(event: InputEvent) -> void:
	if sedang_transisi: return
	if cooldown_klik > 0.0: return 
	
	if (event is InputEventMouseButton or event is InputEventScreenTouch) and event.pressed:
		
		# Fitur Skip / Instant Ketik Teks
		if tween_teks and tween_teks.is_running():
			tween_teks.kill()
			if tween_swing and tween_swing.is_running():
				tween_swing.kill()
			# Paksa posisi dan alpha langsung ke normal kalau diskip
			label_narasi.position = posisi_awal_label
			label_narasi.modulate.a = 1.0
			label_narasi.visible_characters = -1
			
			if audio_ketik: audio_ketik.stop()
			cooldown_klik = 0.1
			return
		
		print("[DEBUG CUTSCENE] Layar diklik pada arsip langkah: ", indeks_langkah)
		
		indeks_langkah += 1
		cooldown_klik = 0.2 
		
		if arsip_cutscene.size() > 0 and indeks_langkah < arsip_cutscene.size():
			tampilkan_langkah_aktif()
		else:
			print("[DEBUG CUTSCENE] Cutscene selesai. Berpindah ke scene game utama.")
			selesai_cutscene()

func tampilkan_langkah_aktif() -> void:
	print("[DEBUG CUTSCENE] Memproses arsip langkah ke-", indeks_langkah)
	
	if not arsip_cutscene[indeks_langkah]: return
	var data_adegan = arsip_cutscene[indeks_langkah] as ArsipAdegan
	if not data_adegan: return
	
	# 1. Tampilkan Teks dengan Efek Swing (Dari bawah ke atas) & Typewriter
	if label_narasi:
		var teks_tujuan = data_adegan.teks_narasi
		label_narasi.text = teks_tujuan
		label_narasi.visible_characters = 0
		
		if tween_teks and tween_teks.is_running():
			tween_teks.kill()
		if tween_swing and tween_swing.is_running():
			tween_swing.kill()
		
		# --- EFEK SWING / SLIDE-UP DARI BAWAH ---
		# Set posisi awal label sedikit di bawah posisi aslinya (+40 piksel) dan transparan (alpha 0)
		label_narasi.position = posisi_awal_label + Vector2(0, 40)
		label_narasi.modulate.a = 0.0
		
		# Jalankan Tween untuk mengangkat teks ke atas sambil dimunculkan
		tween_swing = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween_swing.tween_property(label_narasi, "position", posisi_awal_label, 0.4) # Durasi swing 0.4 detik
		tween_swing.tween_property(label_narasi, "modulate:a", 1.0, 0.3)
		# ----------------------------------------
		
		# Efek Mengetik Teks (Typewriter)
		var total_karakter = teks_tujuan.length()
		var durasi_ketik = total_karakter * 0.03 
		
		tween_teks = create_tween()
		tween_teks.tween_property(label_narasi, "visible_characters", total_karakter, durasi_ketik)
		
		if audio_ketik and not audio_ketik.playing:
			audio_ketik.play()
			timer_audio_crop = 0.0
			
		tween_teks.tween_callback(func():
			if audio_ketik: audio_ketik.stop()
		)
	
	# 2. Pindahkan Kamera jika Target Marker diisi
	if not data_adegan.target_marker.is_empty():
		var target_marker = get_node_or_null(data_adegan.target_marker) as Marker3D
		if target_marker:
			print("[DEBUG CUTSCENE] Kamera berpindah ke marker | Tipe Transisi: ", data_adegan.tipe_transisi)
			eksekusi_transisi_kamera(target_marker, data_adegan.tipe_transisi)

	# 3. Kontrol Kustom AnimationPlayer Berdasarkan Arsip .tres
	if animation_player:
		match data_adegan.aksi_animasi:
			0: # Diam / Abaikan
				pass
			1: # Putar Animasi
				if data_adegan.nama_animasi != "" and animation_player.has_animation(data_adegan.nama_animasi):
					print("[CUTSCENE] Memutar animasi: ", data_adegan.nama_animasi)
					animation_player.play(data_adegan.nama_animasi)
			2: # Berhenti (Stop)
				print("[CUTSCENE] Menghentikan animasi (Stop).")
				animation_player.stop()
			3: # Jeda (Pause)
				print("[CUTSCENE] Menjeda animasi (Pause).")
				animation_player.pause()

func eksekusi_transisi_kamera(target_marker: Marker3D, jenis: int) -> void:
	if not target_marker or not kamera_utama: return
	
	match jenis:
		0: # SLIDE
			var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			tween.tween_property(kamera_utama, "global_position", target_marker.global_position, 1.2)
			tween.tween_property(kamera_utama, "global_rotation_degrees", target_marker.global_rotation_degrees, 1.2)
			
		1: # BLINK
			kamera_utama.global_position = target_marker.global_position
			kamera_utama.global_rotation_degrees = target_marker.global_rotation_degrees
			
		2: # FADE
			sedang_transisi = true 
			var tween = create_tween()
			tween.tween_property(color_rect_fade, "modulate:a", 1.0, 0.3)
			tween.tween_callback(func():
				kamera_utama.global_position = target_marker.global_position
				kamera_utama.global_rotation_degrees = target_marker.global_rotation_degrees
			)
			tween.tween_property(color_rect_fade, "modulate:a", 0.0, 0.3)
			tween.tween_callback(func(): sedang_transisi = false)

func selesai_cutscene() -> void:
	sedang_transisi = true
	if audio_ketik: audio_ketik.stop()
	if color_rect_fade:
		var tween = create_tween()
		tween.tween_property(color_rect_fade, "modulate:a", 1.0, 1.0)
		tween.tween_callback(func(): get_tree().change_scene_to_file(scene_game_tujuan))
	else:
		get_tree().change_scene_to_file(scene_game_tujuan)
