{ pkgs, lib }:
let
  output = lib.eval
    {
      inherit pkgs;
      inputFiles = [ ./text.cue ];
      outputFile = "test.txt";
      expression = "rendered";
      data = {
        data = {
          param1 = "test";
          param2 = 100;
          param3 = {
            "subparam1" = "test1";
          };
        };
      };
    };

  result = pkgs.runCommand "test.text"
    { }
    ''
      cmp "${./expected.txt}" "${output}"
      touch $out
    '';
in
result
