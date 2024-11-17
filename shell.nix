{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/7995cae3ad60e3d6931283d650d7f43d31aaa5c7.tar.gz") {}
}:

pkgs.mkShell {
  buildInputs = with pkgs; [
    circt # 1.62.0
    gmp
    ncurses
  ];
}

