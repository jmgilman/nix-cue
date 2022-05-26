{ pkgs, lib }:
let
  output = lib.eval
    {
      inherit pkgs;
      inputFiles = [ ./pre-commit.cue ];
      outputFile = ".pre-commit-config.yaml";
      data = {
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
