{ pkgs, lib }:
let
  output = lib.eval
    {
      inherit pkgs;
      inputFiles = [ ./json.cue ];
      outputFile = "out.json";
      data = {
        param1 = "test";
        param2 = 100;
        param3 = {
          "subparam1" = "test1";
        };
      };
    };

  result = pkgs.runCommand "test.json"
    { }
    ''
      cmp "${./expected.json}" "${output}"
      touch $out
    '';
in
result
