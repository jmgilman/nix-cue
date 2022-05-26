{ pkgs, inputFiles, outputFile, data ? { }, cue ? pkgs.cue, ... }@args:
with pkgs.lib;
let
  json = optionalString (data != { }) (builtins.toJSON data);

  defaultFlags = {
    outfile = "$out";
  };
  extraFlags = removeAttrs args [ "pkgs" "inputFiles" "outputFile" "data" "cue" ];

  allFlags = defaultFlags // extraFlags;
  allInputs = inputFiles ++ optionals (json != "") [ "json: $jsonPath" ];

  flagsToString = name: value: if (builtins.isBool value) then "--${name}" else ''--${name} "${value}"'';
  flagStr = builtins.concatStringsSep " " (attrValues (mapAttrs flagsToString allFlags));
  inputStr = builtins.concatStringsSep " " allInputs;
  cueEvalCmd = "cue eval ${flagStr} ${inputStr}";

  result = pkgs.runCommand outputFile
    ({
      inherit json;
      buildInputs = [ cue ];
      passAsFile = [ "json" ];
    } // optionalAttrs (json != "") { inherit json; passAsFile = [ "json" ]; })
    ''
      echo "nix-cue: Rendering output..."
      ${cueEvalCmd}
    '';
in
result

# { pkgs, inputs, output, data ? { }, cue ? pkgs.cue, ... }@flags:
# with pkgs.lib;
# let
#   # Converts flags to strings
#   flagsToString = name: value: if (builtins.isBool value) then "--${name}" else ''--${name} "${value}"'';

#   # It's common to set the input in a cue file to a named value (i.e. data: _)
#   # The wrap parameter is a helper to easily wrap the input to this named value
#   dataJSON = optionalString (data != { }) (builtins.toJSON data);
#   # json = if wrap != "" then builtins.toJSON { "${wrap}" = input; } else builtins.toJSON input;

#   allFlags = {
#     force = true;
#     out = output;
#     outfile = "$out";
#   } // flags;

#   allInputs = inputs ++ optional (dataJSON != "") [ "json:$jsonPath" ];

#   flagStr = builtins.concatStringsSep " " (attrValues (mapAttrs flagsToString allFlags));
#   inputStr = builtins.concatStringsSep " " (builtins.map (f: ''"${f}"'') allInputs);
#   cueEvalCmd = "cue eval ${flagStr} ${inputStr}";

#   result = pkgs.runCommand "cue.output"
#     {
#       buildInputs = [ cue ];
#     } // optionalAttrs (dataJSON != "") { json = dataJSON; passAsFile = [ "json" ]; }
#     ''
#       echo "nix-cue: Rendering output..."
#       ${cueEvalCmd}
#     '';
# in
# result
