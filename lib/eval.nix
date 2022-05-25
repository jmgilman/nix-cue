{ pkgs, cueFile, input, output, expr ? "", wrap ? "", flags ? { }, cue ? pkgs.cue }:
with pkgs.lib;
let
  # Converts flags to strings
  flagsToString = name: value: if (builtins.isBool value) then "--${name}" else ''--${name} "${value}"'';

  # It's common to set the input in a cue file to a named value (i.e. data: _)
  # The wrap parameter is a helper to easily wrap the input to this named value
  json = if wrap != "" then builtins.toJSON { "${wrap}" = input; } else builtins.toJSON input;

  # Default + optional flags + overrides
  allFlags = {
    force = true;
    out = output;
    outfile = "$out";
  } // optionalAttrs (expr != "") { expression = expr; } // flags;

  # Build eval command
  flagStr = builtins.concatStringsSep " " (attrValues (mapAttrs flagsToString allFlags));
  argStr = ''"${cueFile}" "$inputFile"'';
  cueEvalCmd = "cue eval ${flagStr} ${argStr}";

  result = pkgs.runCommand "cue.output"
    {
      inherit json;
      buildInputs = [ cue ];
      passAsFile = [ "json" ];
    }
    ''
      # Cue uses the file extensions to determine input format, so we must put
      # the passed JSON contents into a file with a .json extension
      inputFile="$NIX_BUILD_TOP/config.json"
      mv "$jsonPath" "$inputFile"

      # We first attempt to validate the input before generation
      echo "nix-cue: Validating input..."
      cue vet "$inputFile" "${cueFile}"

      # Then we generate the output
      echo "nix-cue: Rendering output..."
      ${cueEvalCmd}
    '';
in
result
