{ pkgs, lib }:
let
  output = lib.evalText
    {
      inherit pkgs;
      cueFile = ./text.cue;
      expr = "rendered";
      input = {
        param1 = "test";
        param2 = 100;
        param3 = {
          "subparam1" = "test1";
        };
      };
      wrap = "data";
    };

  result = pkgs.runCommand "test.text"
    { }
    ''
      cmp "${./expected.txt}" "${output}"
      touch $out
    '';
in
result
