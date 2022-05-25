{ pkgs, lib }:
let
  output = lib.evalYAML
    {
      inherit pkgs;
      cueFile = ./pre-commit.cue;
      input = {
        repos = [
          {
            repo = "https://github.com/test/repo";
            rev = "1.0";
            hooks = [
              {
                id = "my-hook";
              }
            ];
          }
        ];
      };
    };

  result = pkgs.runCommand "test.pre-commit"
    { }
    ''
      cat "${output}"
      cmp "${./expected.yml}" "${output}"
      touch $out
    '';
in
result
