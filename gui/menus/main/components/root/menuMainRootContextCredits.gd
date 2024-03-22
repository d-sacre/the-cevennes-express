extends Control

# Old text:
# [u]Milatur[/u]:
# » Concept
# » Core Game Play Mechanics
# » C++ Architecture and Project Management Lead
# » CMake and Visual Studio Code Build Pipelines
# » Unit Testing
# » Windows Testing (native, Firefox, Opera, Edge)


# [u]dsacre[/u]:
# » Concept
# » Core Game Play Mechanics
# » Godot Architecture Lead
# » Python Build Tools
# » UI/UX Design
# » Asset Creation: (LaTeX/TikZ, Blender, GIMP, Krita,
#    Imagemagick, Audacity)
# » Linux Testing (native, Firefox, Chromium, Brave)


# [font=res://themes/fonts/lmodern_bold_64px.tres]Used Assets[/font]

# » [u]SFX:[/u]
# »» Kenney: "Interface Sounds",
#    license:  Creative Commons Zero  
#    https://opengameart.org/content/interface-sounds, 
#    »»» drop_003.ogg
#    »»» switch_005.ogg
# »» Robin Lamp: "UI Sound Effects (Button Clicks, User 
#    Feedback, Notifications)", 
#    license: Creative Commons Zero
#    source:
#    https://opengameart.org/content/ui-sound-effects
#    -button-clicks-user-feedback-notifications
#    »»» alarm.ogg
#    »»» ding_depp.ogg
# »» Versilian Studios: "VSCO 2"
#    license: Creative Commons Zero
#    source:
#    https://versilian-studios.com/vsco-community/
#    »»» wood_click_pp_1.wav
#    »»» ratchet1.wav / ratchet1.ogg
#    »»» snare3_rimshot_f_1.wav

# » [u]ART:[/u]
#    »» Appelmoesgezeefdzond​ertoegevoegdesuiker: 
#        Autorail Billard 213 du Chemin de fer du 
# 	   Vivarais, 
#        license: Creative Commons BY 2.0
#        source:
#        https://commons.wikimedia.org/wiki/
# 	   File:CFV_Billard_213.jpg
# 	»» Hexagon Tile by Joe Bustamante 
#          source:
#          https://github.com/josephmbustamante/
# 	     Godot-3D-Hex-Grid-Tutorial
# 	»» nicubunu: RPG map symbols: mountains
# 	    license: Creative Commons Zero
# 		source:
# 		https://openclipart.org/detail/9454/rpg-map
# 		-symbols-mountains
	
# » [u]FONTS:[/u]
#    »» Latin Modern Font by GUST, 
#       license: GUST-FONT-LICENSE
#       source:
#       https://www.gust.org.pl/projects/e-foundry/
# 	  latin-modern/download

var _bbcodeparser = dictionaryToBBCodeParser.new()

onready var _richtextLabel : RichTextLabel = $PanelContainer/creditsPopup_VBoxContainer/creditsContentRichTextLabel

func _ready() -> void:
	var _credits = JsonFio.load_json("res://gui/menus/main/components/root/credits.json")
	_richtextLabel.bbcode_enabled = true
	_richtextLabel.bbcode_text = _bbcodeparser.parse_dictionary_to_bbcode(_credits)
