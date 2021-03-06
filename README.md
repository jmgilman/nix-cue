# nix-cue

<p align="center">
    <a href="https://github.com/jmgilman/nix-cue/actions/workflows/ci.yml">
        <img src="https://github.com/jmgilman/nix-cue/actions/workflows/ci.yml/badge.svg"/>
    </a>
    <img src="https://img.shields.io/github/license/jmgilman/nix-cue"/>
    <a href="https://builtwithnix.org">
        <img src="https://img.shields.io/badge/-Built%20with%20Nix-green">
    </a>
</p>

> Validate and generate configuration files using [Nix][1] and [Cue][2].

## Features

- Specify configuration data using native Nix syntax
- Validate configuration data using the language features from [Cue][2]
- Generate configuration files in any of the [supported formats][3]
- All artifacts are placed in the Nix store

## Usage

Add the flake as an input:

```nix
{ #....
  inputs = {
    # ...
    nix-cue.url = "github:jmgilman/nix-cue";
  };
}
```

The flake provides a single function: `nix-cue.lib.${system}.eval`. The function
takes a few common parameters, for example:

```nix
{ # ...
  configFile = nix-cue.lib.${system}.eval {
      inherit pkgs;
      inputFiles = [ ./pre-commit.cue ]; # Input files to pass to `cue eval`
      outputFile = ".pre-commit-config.yaml"; # Output file to put in Nix store
      data = {
        # Concrete data to pass to `cue eval`
      };
  };
}
```

The full path to the output file in the Nix store will be returned (in the above
case, we are storing it in `configFile`). The `data` parameter is optional and
is used to pass a Nix set as concrete input to `cue`. The expression is
converted to JSON and added as an additional input file.

`cue` determines the output format by examining the output file extension. If
you need to output a specific format without a matching file extension, pass the
`output` flag with the desired format.

Flags can be passed to `cue eval` by appending them to the function arguments.
The format is `{ flag_name = flag_value; }`. For example, to force `cue` to
output JSON regardless of the output file extension:

```nix
{ # ...
  configFile = nix-cue.lib.${system}.eval {
      # ...
      output = "json"; # Equivalent to --output "json"
      # ...
  };
}
```

## Example

As an example, we can validate and generate a configuration file for
[pre-commit][4]. The first step is to define a cue file:

```cue
#Config: {
    default_install_hook_types?: [...string]
    default_language_version?: [string]: string
    default_stages?: [...string]
    files?: string
    exclude?: string
    fail_fast?: bool
    minimum_pre_commit_version?: string
    repos: [...#Repo]
}

#Hook: {
    additional_dependencies?: [...string]
    alias?: string
    always_run?: bool
    args?: [...string]
    exclude?: string
    exclude_types?: [...string]
    files?: string
    id: string
    language_version?: string
    log_file?: string
    name?: string
    stages?: [...string]
    types?: [...string]
    types_or?: [...string]
    verbose?: bool
}

#Repo: {
    repo: string
    rev?: string
    if repo != "local" {
        rev: string
    }
    hooks: [...#Hook]
}

{
    #Config
}
```

This validates against the schema described in the [official docs][5]. With the
Cue file, we can now define our input data and generate the YAML configuration:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    nix-cue.url = "github:jmgilman/nix-cue";
  };

  outputs = { self, nixpkgs, flake-utils, nix-cue }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        # Define our pre-commit configuration
        config = {
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

        # Validate the configuration and generate the output file
        configFile = nix-cue.lib.${system}.eval {
            inherit pkgs;
            inputFiles = [ ./pre-commit.cue ];
            outputFile = ".pre-commit-config.yaml";
            data = config;
        };
      in
      {
        lib = {
          mkConfig = import ./lib/pre-commit.nix;
        };

        devShell = pkgs.mkShell {
          shellHook = ''
            # Link the store output to our local directory
            unlink .pre-commit-config.yaml
            ln -s ${configFile} .pre-commit-config.yaml
          '';
        };
      }
    );
}
```

Running `nix develop` with the above flake will generate a
`.pre-commit-config.yaml` file in the store using the configuration given in
`config` and then link it to the local directory via the `shellHook`:

```yaml
repos:
  - hooks:
      - id: my-hook
    repo: https://github.com/test/repo
    rev: "1.0"
```

You can see more examples in the [tests](./tests) folder.

## Testing

Tests can be run with:

```shell
nix flake check
```

## Contributing

Check out the [issues][6] for items needing attention or submit your own and
then:

1. Fork the repo (<https://github.com/jmgilman/nix-cue/fork>)
2. Create your feature branch (git checkout -b feature/fooBar)
3. Commit your changes (git commit -am 'Add some fooBar')
4. Push to the branch (git push origin feature/fooBar)
5. Create a new Pull Request

[1]: https://nixos.org/
[2]: https://cuelang.org/
[3]: https://cuelang.org/docs/integrations/
[4]: https://pre-commit.com/
[5]: https://pre-commit.com/#adding-pre-commit-plugins-to-your-project
[6]: https://github.com/jmgilman/nix-cue/issues
