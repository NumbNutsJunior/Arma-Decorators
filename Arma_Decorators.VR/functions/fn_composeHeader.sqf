params [["_functionVariable", ""], ["_headerType", 0]];
if (_functionVariable isEqualTo "") exitWith {""};

private _headerNoDebug = "
    private _fnc_scriptNameParent = if (isNil '_fnc_scriptName') then {'%1'} else {_fnc_scriptName};
    private _fnc_scriptName = '%1';
    scriptName _fnc_scriptName;
";

private _headerSaveScriptMap = "
    private _fnc_scriptMap = if (isNil '_fnc_scriptMap') then {[_fnc_scriptName]} else {_fnc_scriptMap + [_fnc_scriptName]};
";

private _headerLogScriptMap = "
    textLogFormat ['%1 : %2', _fnc_scriptMap joinString ' >> ', _this];
";

private _headerSystem = "
    private _fnc_scriptNameParent = if (isNil '_fnc_scriptName') then {'%1'} else {_fnc_scriptName};
    scriptName '%1';
";

// -- Init function meta data
(_functionVariable call BIS_fnc_functionMeta) params [["_path", ""]];

//--- Extend error report by including name of the function responsible
private _debugHeaderExtended = format ["%4%1line 1 ""%2 [%3]""%4", "#", _path, _functionVariable, toString [13,10]]; 
private _debugMessage = "Log: [Functions]%1 | %2";

//--- Compose headers based on current debug mode
private _debugMode = uiNamespace getVariable ["bis_fnc_initFunctions_debugMode", 0];
private _headerDefault = switch _debugMode do {

    //--- 0 - Debug mode off
    default {_headerNoDebug};

    //--- 1 - Save script map (order of executed functions) to '_fnc_scriptMap' variable
    case 1: {_headerNoDebug + _headerSaveScriptMap};

    //--- 2 - Save script map and log it
    case 2: {_headerNoDebug + _headerSaveScriptMap + _headerLogScriptMap};
};

private _header = switch (_headerType) do {

    //--- No header (used in low-level functions, like 'fired' event handlers for every weapon)
    case -1: {""};

    //--- System functions' header (rewrite default header based on debug mode)
    case 1: {_headerSystem};

    //--- Full header
    default {_headerDefault};
};

// Return header
(format [_header, _functionVariable, _debugMessage]) + _debugHeaderExtended;