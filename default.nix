{ pkgs, ... }:
{ root }:
let
  readPackageFile =
    file: builtins.filter (line: line != "") (pkgs.lib.splitString "\n" (builtins.readFile file));

  minimalPackages = readPackageFile (root + /PACKAGES_MINIMAL);

  fullPackages = minimalPackages ++ readPackageFile (root + /PACKAGES_OTHER);

  genSymlinks =
    dotfilePackages:
    let
      recursiveDotfiles = builtins.concatMap (
        key:
        builtins.filter (line: line != "") (
          pkgs.lib.splitString "\n" (
            builtins.readFile (
              pkgs.runCommand "find-dotfiles-${key}" { } ''
                cd ${root} || exit 1
                ${pkgs.findutils}/bin/find ${key} ! -type d > $out
              ''
            )
          )
        )
      ) dotfilePackages;
    in
    builtins.listToAttrs (
      builtins.map (key: {
        name = key;
        value = {
          source = root + "/${key}";
        };
      }) recursiveDotfiles
    );
in
{
  inherit root;
  symlinks = {
    minimal = genSymlinks minimalPackages;
    full = genSymlinks fullPackages;
  };
}
