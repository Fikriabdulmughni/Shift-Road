class_name ArsipAdegan
extends Resource

@export_multiline var teks_narasi: String
@export var target_marker: NodePath 
@export_enum("Slide (Mulus)", "Blink (Kedip Instan)", "Fade (Layar Gelap)") var tipe_transisi: int = 0

# Kontrol Kustom untuk AnimationPlayer
@export_enum("Diam / Abaikan", "Putar Animasi", "Berhenti (Stop)", "Jeda (Pause)") var aksi_animasi: int = 0
@export var nama_animasi: String = ""
