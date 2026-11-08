PSX Horror Enemies / GA024

Five MPFB human enemies in Standard. Lite contains the identical Lurcher and its eight actions.
GLB + FBX + editable Blender 5.2 source. One 128x128 PNG and one material per enemy.
Metres; Blender Z up, front -Y; exported GLB/FBX Y up.
Generic rigs, no Humanoid guarantee, controller, collision, gameplay AI, root motion, VFX or audio.
All five enemies use smooth skin weights (max four per vertex).
MPFB2 CC0 bundled base/targets used for all five enemies; no MPFB code or third-party assets included.

PLAYBACK
Select rig in Blender Action Editor; choose action and set its frame range.
NLA tracks are muted in Blend to avoid overlapping actions. All actions are in-place.
Source starts at frame 1, at 24fps. Loops: Idle, Walk, Chase. Other actions are one-shot.
Death holds its final pose with the full mesh remaining.
Idle: 49 frames, 2 seconds
Walk: 25 frames, 1 seconds
Chase: 17 frames, 0.666667 seconds
Attack: 25 frames, 1 seconds
Attack_Heavy: 37 frames, 1.5 seconds
Alert: 37 frames, 1.5 seconds
Hit: 13 frames, 0.5 seconds
Death: 49 frames, 2 seconds

PIXEL FILTERING
Unity: select the atlas Texture asset referenced by the model material Base Map; Filter Mode = Point.
For embedded images extract/select that imported Texture asset, then set Filter Mode = Point.
Godot 4: on the imported/extracted 3D material set BaseMaterial3D.texture_filter = TEXTURE_FILTER_NEAREST.
Apply this to the material whose albedo texture is the matching 128px PNG.
FBX importers can reset filtering; explicitly set Point/Nearest after import.
GLB/FBX round trips tested in Blender. Unity/Godot runtime import not tested.

CONTENTS AND MEASUREMENTS
lurcher: 2819 triangles, 18 bones, texture Textures/ga024-atlas.png
Rest width/depth/height: 0.6744m, 0.4886m, 1.6543m
Matching separate locations: GA002 Hospital, GA004 Surgical Wing, GA005 Abandoned Office, GA006 Motel, GA008 Psych Ward
  Alert max width/depth/height: 0.7129m, 0.5723m, 1.6703m
  Attack max width/depth/height: 0.6766m, 0.7589m, 1.6543m
  Root-relative attack XYZ envelope: [[-0.3551762104034424, -0.6436372995376587, 2.0090465113753453e-05], [0.36523446440696716, 0.11522113531827927, 1.6543086767196655]]
  Attack_Heavy max width/depth/height: 0.6744m, 0.8957m, 1.9180m
  Root-relative attack XYZ envelope: [[-0.3379752039909363, -0.780509352684021, 2.0090465113753453e-05], [0.33644598722457886, 0.11522113531827927, 1.9180176258087158]]
  Chase max width/depth/height: 0.6855m, 0.7809m, 1.5927m
  Death max width/depth/height: 0.6744m, 1.7142m, 1.6543m
  Hit max width/depth/height: 0.6744m, 0.4886m, 1.7058m
  Idle max width/depth/height: 0.6767m, 0.5006m, 1.6592m
  Walk max width/depth/height: 0.6842m, 0.6778m, 1.6227m

Previews are actual Blender renders. Each enemy has front/back/side/face and all-eight-action boards.
motion.gif demonstrates Lurcher Walk only (16 frames, 1 second).
Location review images are not environment assets. No location meshes/scenes are included.
Spindle has a single opaque shell. The other four wear shaped clothing with hidden body faces removed.
Commercial and non-commercial use allowed, credit optional. No asset redistribution/resale.
See LICENSE.txt for complete terms.
AI assisted script authoring; no image or 3D generative AI.
