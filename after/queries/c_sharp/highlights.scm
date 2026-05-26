; Custom overrides on top of the upstream C# highlights query.
; Treesitter concatenates query files across runtimepath, with later matches
; over the same range winning, so this only needs to contain the deltas.
;
; Use :Inspect to confirm capture names after editing; use :InspectTree to
; explore which parent nodes / field names are available.

; ---- Parameters: distinguish the type from the name. ----
; e.g. `int receiverPort`  -> `int` is type, `receiverPort` is the parameter name.
(parameter
  type: (_) @type
  name: (identifier) @variable.parameter)

; ---- Method declarations: type vs. method name. ----
; e.g. `public InitPulse CreateInitPulse(...)` -> InitPulse is type, CreateInitPulse is the method.
(method_declaration
  type: (_) @type
  name: (identifier) @function.method)

; ---- Local variable declarations: type vs. variable name. ----
; e.g. `string _machineIP = ...` -> string is type, _machineIP is the variable.
(variable_declaration
  type: (_) @type)
(variable_declarator
  name: (identifier) @variable)

; ---- Property declarations: type vs. property name. ----
(property_declaration
  type: (_) @type
  name: (identifier) @property)
