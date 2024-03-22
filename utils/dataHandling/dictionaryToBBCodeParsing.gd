extends Node

class_name dictionaryToBBCodeParser

################################################################################
#### CONSTANT DEFINITIONS ######################################################
################################################################################
const SECTION_LEVEL_LUT = {SECTION = 0, SUBSECTION = 1, SUBSUBSECTION = 2}

const SYMBOL_LUT : Dictionary = {
    "INDENT": "    ",
    "ITEM1" : "•",
    "ITEM2": "»",
    "QUOTE": "\""
}

const BBCODE_LUT : Dictionary = {
    "H1START" : "[font=res://themes/fonts/lmodern_bold_48px.tres]",
    "H1END": "[/font]",
    "H2START" : "[font=res://themes/fonts/lmodern_bold_32px.tres]",
    "H2END": "[/font]",
    "URLSTART": "",
    "URLEND": ""
}

const DESCRIPTOR_TO_FORMAT_STRING_OBJECT_LUT : Dictionary = {
    "HEADING": ["{h1start}{heading}{h1end}\n", "{h2start}{heading}{h2end}\n", "{h3start}{heading}{h3end}\n"],
    "ITEMIZE": ["{indent}{item1} ", "{indent}{indent}{item2} ", "{indent}{indent}{indent}{item3} "]
}

const ITEMIZE_LEVEL_OUT_OF_BOUNDS : int = -1

################################################################################
#### PRIVATE MEMBER VARIABLES ##################################################
################################################################################
var _inItemizeContext : bool = false
var _itemizeLevel : int = self.ITEMIZE_LEVEL_OUT_OF_BOUNDS

var _formatReplacements : Dictionary = {}

var _data : Array = []

var _calls = 0

################################################################################
#### PUBLIC MEMBER FUNCTIONS ###################################################
################################################################################
func parse_dictionary_to_bbcode_raw(data, itemizeLevel : int = self.ITEMIZE_LEVEL_OUT_OF_BOUNDS) -> String:
    _calls += 1
    var _parsedString : String = ""

    # DESCRIPTION: Parse data based upon data type
    if data is Dictionary:
        if data.has("section"):
            self._inItemizeContext = false
            itemizeLevel = self.ITEMIZE_LEVEL_OUT_OF_BOUNDS
            
            var _headingDepth : int = SECTION_LEVEL_LUT.SECTION
            var _tmp_sectionString : String = DESCRIPTOR_TO_FORMAT_STRING_OBJECT_LUT.HEADING[_headingDepth]

            _parsedString += _tmp_sectionString.format({"heading" : data["section"]["heading"]})
            _parsedString += parse_dictionary_to_bbcode_raw(data["section"]["content"], itemizeLevel)

        elif data.has("subsection"):
            self._inItemizeContext = false
            itemizeLevel = self.ITEMIZE_LEVEL_OUT_OF_BOUNDS

            var _headingDepth : int = SECTION_LEVEL_LUT.SUBSECTION
            var _tmp_sectionString : String = DESCRIPTOR_TO_FORMAT_STRING_OBJECT_LUT.HEADING[_headingDepth]

            _parsedString += _tmp_sectionString.format({"heading" : data["subsection"]["heading"]})
            _parsedString += parse_dictionary_to_bbcode_raw(data["subsection"]["content"], itemizeLevel)

        elif data.has("vspace"):
            for _i in range(0, data["vspace"]):
                _parsedString += "\n"

        elif data.has("itemize"):
            self._inItemizeContext = true
            _parsedString += parse_dictionary_to_bbcode_raw(data["itemize"]["content"], itemizeLevel + 1)

    elif data is Array:
        for element in data:
            _parsedString += parse_dictionary_to_bbcode_raw(element, itemizeLevel)

    elif data is String:
        if self._inItemizeContext:
            _parsedString += DESCRIPTOR_TO_FORMAT_STRING_OBJECT_LUT.ITEMIZE[itemizeLevel] 
            var _hspace : String = DESCRIPTOR_TO_FORMAT_STRING_OBJECT_LUT.ITEMIZE[itemizeLevel].replace("{item"+ str(itemizeLevel+1) +"}", "  ")
            data = data.replace("\n", "\n"+_hspace)
        
        _parsedString += data + "\n"

    return _parsedString

func format_raw_string(raw : String) -> String:
    return raw.format(self._formatReplacements)

func parse_dictionary_to_bbcode(data, itemizeLevel : int = self.ITEMIZE_LEVEL_OUT_OF_BOUNDS) -> String:
    var _rawString : String = self.parse_dictionary_to_bbcode_raw(data, itemizeLevel)
    var _formattedString : String = self.format_raw_string(_rawString)

    return _formattedString

################################################################################
#### GODOT LOADTIME FUNCTION OVERRIDES #########################################
################################################################################
func _init() -> void:
    # DESCRIPTION: Parse all the LUTs to create a complete format string 
    # replacement database
    for _key in SYMBOL_LUT.keys():
        self._formatReplacements[_key.to_lower()] = SYMBOL_LUT[_key]
    
    for _key in BBCODE_LUT.keys():
        self._formatReplacements[_key.to_lower()] = BBCODE_LUT[_key]

