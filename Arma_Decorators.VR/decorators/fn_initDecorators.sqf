
// Author: Pizza Man
// File: fn_initDecorators.sqf
// Description: Re-compile all function libraries, implementing decorator semantics and new meta data.

// NOTE: This is a function based highly off the game's default script compile function, 
//       and so changes to the game's function library system may break the script.

// Fetch mission config parameters
private _allowRecompile = !((getNumber (missionConfigFile >> "allowFunctionsRecompile")) isEqualTo 0);
private _compileFinal = !((getNumber (missionConfigFile >> "compileFinalFunctions")) isEqualTo 0);

// Functions cannot be recompiled
if !(_allowRecompile) exitWith {};

// Initialization parameters
params [["_initAttribute", ""], ["_didJIP", false]];

// Wait for all functions to be initalized
if (!canSuspend) exitWith {[] spawn (call compile _fnc_scriptName)};
if (_initAttribute isEqualTo "postInit") exitWith {[] spawn (call compile _fnc_scriptName)};
waitUntil {!isNil "bis_fnc_init"};

// Master configs and default decorator tag
private _configs = [configFile, campaignConfigFile, missionConfigFile];
private _decoraterTag = (_fnc_scriptName call BIS_fnc_functionMeta) select 6;

{

    // Init
    private _config = _x;
    private _functionLibrary = _config >> "CfgFunctions";

    // Iterate through the tags
    for "_tag" from 0 to ((count _functionLibrary) - 1) do {

        // Tag (used for composing the function name)
        private _tagClass = _functionLibrary select _tag;
        if (isClass _tagClass) then {

            //--- Init Tag
            private _tagClassName = configName _tagClass;
            private _tagClassTag = getText (_tagClass >> "tag");
            if (_tagClassTag isEqualTo "") then {_tagClassTag = _tagClassName};

            // Iterate through the categories
            for "_category" from 0 to ((count _tagClass) - 1) do {

                // Category
                private _categoryClass = _tagClass select _category;
                if (isClass _categoryClass) then {

                    // Iterate through the functions
                    for "_function" from 0 to ((count _categoryClass) - 1) do {

                        // Function
                        private _funcClass = _categoryClass select _function;
                        if (isClass _funcClass) then {

                            // Function not available in retail version
                            private _funcCheatsEnabled = getNumber (_funcClass >> "cheatsEnabled");
                            if ((_funcCheatsEnabled isEqualTo 0) || ((_funcCheatsEnabled > 0) && cheatsEnabled)) then {

                                //--- Read function
                                private _funcClassName = configName _funcClass;
                                private _funcVariable = format ["%1_fnc_%2", _tagClassTag, _funcClassName];
                                private _funcMetaData = (_funcVariable call BIS_fnc_functionMeta);
                                private _funcHeaderType = _funcMetaData select 2;
                                private _funcExtension = _funcMetaData select 1;
                                private _funcFilePath = _funcMetaData select 0;

                                // FSMs are already running
                                if (_funcExtension isEqualTo ".sqf") then {

                                    // Format decorators
                                    private _funcDecorators = getArray (_funcClass >> "decorators");
                                    _funcDecorators = _funcDecorators apply {_decoraterTag + "_fnc_" + _x};
                                    reverse _funcDecorators;

                                    // Compose function
                                    private _newLine = toString [13, 10];
                                    private _funcDefaultHeader = [_funcVariable, _funcHeaderType] call life_fnc_composeHeader;
                                    private _funcDecoratorHeader = format["    private _fnc_scriptDecorators = %1;", _funcDecorators];
                                    private _funcHeader = format ["%3%1%2", _funcDecoratorHeader, _funcDefaultHeader, _newLine];
                                    private _funcSourceCode = preprocessFile _funcFilePath;

                                    // Only implement if has a decorator
                                    if ((count _funcDecorators) >= 1) then {

                                        // Give each function its own scope to avoid ambiguity
                                        _funcSourceCode = format ["%2call {%2%1%2};%2", _funcSourceCode, _newline];

                                        {
                                            
                                            // Init
                                            private _decoratorVariable = _x;
                                            private _decoratorFilePath = _decoratorVariable call BIS_fnc_functionPath;
                                            private _decoratorSourceCode = preprocessFile _decoratorFilePath;

                                            // Implement decorators
                                            private _decoratorMagic = format["private _fnc_decoratorName = '%1';", _decoratorVariable];
                                            _funcSourceCode = (format ["%3call {%3%2%3%1%3};%3", _decoratorSourceCode, _decoratorMagic, _newline]) + _funcSourceCode;
                                        } forEach _funcDecorators;
                                    };

                                    //--- Save function
                                    _funcSourceCode = _funcHeader + _funcSourceCode;
                                    private _funcCompiled = if (_compileFinal) then {compileFinal _funcSourceCode} else {compile _funcSourceCode};
                                    missionNamespace setVariable [_funcVariable, _funcCompiled];
                                };
                            };
                        };
                    };
                };
            };
        };
    };
} forEach _configs;
