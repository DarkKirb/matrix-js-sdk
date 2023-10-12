let pkgs = import <nixpkgs> {};
in with pkgs; pkgs.mkShell {
    nativeBuildInputs = [
        nodejs yarn
    ];
}
