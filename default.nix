{
  niv ? import ./nix/sources.nix,
  nixpkgs ? niv.nixpkgs
}:
let
  # #ecursive scopedImport:
  # both the install- and installer-config use <nixpkgs/...> paths. In order
  # to not use the nixpkgs from the user's NIX_PATH env var but the pinned
  # nixpkgs that we have here, overload the __nixPath to use that.
  # Unfortunately, if we use `scopedImport` to import a nix file with that
  # adapted __nixPath, after the next import within that file, all __nixPath
  # changes will be forgotten again. For this reason we need to override the
  # import function recursively.
  # The recursive override takes another parameter `ps` to enable for
  # *appending* our fixed nixpath, because somewhere in nixpkgs, <nix> is added
  # to that path and we must not drop that.
  scopedImport = let f = ps: builtins.scopedImport {
    import = f __nixPath;
    __nixPath = [
      { path = nixpkgs; prefix = "nixpkgs"; }
      { path = niv.cbspkgs-public; prefix = "cbspkgs-public"; }
    ] ++ ps;
  }; in f [];
in scopedImport ./installer-iso.nix
