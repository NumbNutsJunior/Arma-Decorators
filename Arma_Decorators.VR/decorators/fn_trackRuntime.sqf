[_fnc_scriptName, _thisScript] spawn {

    // Parameters
    params [["_fnc_scriptName", ""], ["_parentScript", scriptNull]];
    if (isNull _parentScript) exitWith {};

    // Create global list if it does not exist
    if (isNil "life_activeFunctions") then {life_activeFunctions = []};
    private _index = life_activeFunctions findIf {(_x select 0) isEqualTo _fnc_scriptName};
    if (_index isEqualTo -1) then {_index = life_activeFunctions pushBack [_fnc_scriptName, 0]};

    // Update instance count
    private _instances = (life_activeFunctions select _index) select 1;
    (life_activeFunctions select _index) set [1, _instances + 1];

    // Wait until parent script is done
    waitUntil {scriptDone _parentScript};

    // Clear the global list of all inactive functions
    _index = life_activeFunctions findIf {(_x select 0) isEqualTo _fnc_scriptName};

    // Update instance count
    private _instances = (life_activeFunctions select _index) select 1;
    (life_activeFunctions select _index) set [1, _instances - 1];

    // Clear list of any inactive functions
    life_activeFunctions = life_activeFunctions select {(_x select 1) > 0};
}; 