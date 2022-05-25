rec {
  eval = output: { pkgs, cueFile, input, expr ? "", wrap ? "", flags ? { }, cue ? pkgs.cue }:
    import ./eval.nix {
      inherit pkgs cueFile input output expr wrap flags cue;
    };
  evalBinary = eval "binary";
  evalCue = eval "cue";
  evalGo = eval "go";
  evalJSON = eval "json";
  evalJSONSchema = eval "jsonschema";
  evalOpenAPI = eval "openapi";
  evalProto = eval "proto";
  evalText = eval "text";
  evalTextProto = eval "textproto";
  evalYAML = eval "yaml";
}
