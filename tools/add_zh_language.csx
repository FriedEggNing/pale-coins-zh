using System;
using System.IO;
using System.Linq;
using UndertaleModLib.Compiler;

EnsureDataLoaded();

CodeImportGroup importGroup = new(Data);

// 1) load_fonts (in scr_helper): add a "zh" font setup using the localization fallback font.
importGroup.QueueTrimmedLinesFindReplace("gml_GlobalScript_scr_helper",
@"{
    localization: ""ru"",
    font_scale: 0.8,
    font_name: font_name_fallback_all_localizations,
    font_name_main_menu: font_name_fallback_all_localizations
}];",
@"{
    localization: ""ru"",
    font_scale: 0.8,
    font_name: font_name_fallback_all_localizations,
    font_name_main_menu: font_name_fallback_all_localizations
},
{
    localization: ""zh"",
    font_scale: 0.8,
    font_name: font_name_fallback_all_localizations,
    font_name_main_menu: font_name_fallback_all_localizations
}];");

// 2) Options menu: add zh to the language selector list (raw substring replace).
importGroup.QueueFindReplace("gml_Object_obj_controller_game_options_game_Create_0",
"{\n    key: \"ru\",\n    text: lang(\"ui_options_menu_gameplay_language_ru\")\n}]",
"{\n    key: \"ru\",\n    text: lang(\"ui_options_menu_gameplay_language_ru\")\n}, \n{\n    key: \"zh\",\n    text: lang(\"ui_options_menu_gameplay_language_zh\")\n}]");

importGroup.Import();

// Verify both patches by decompiling and checking content.
GlobalDecompileContext gdc = new(Data);
var settings = Data.ToolInfo.DecompilerSettings;
string helper = new Underanalyzer.Decompiler.DecompileContext(gdc, Data.Code.First(c => c.Name.Content == "gml_GlobalScript_scr_helper"), settings).DecompileToString();
string options = new Underanalyzer.Decompiler.DecompileContext(gdc, Data.Code.First(c => c.Name.Content == "gml_Object_obj_controller_game_options_game_Create_0"), settings).DecompileToString();
bool fontOk = helper.Contains("localization: \"zh\"");
bool listOk = options.Contains("ui_options_menu_gameplay_language_zh");
ScriptMessage($"VERIFY font patch: {fontOk}, options list patch: {listOk}");
if (!fontOk || !listOk) throw new Exception("Patch verification failed!");
