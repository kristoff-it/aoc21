let
  nixpkgs = builtins.fetchTarball {
    # nixpkgs-unstable (2021-10-28)
    url = "https://github.com/NixOS/nixpkgs/archive/22a500a3f87bbce73bd8d777ef920b43a636f018.tar.gz";
    sha256 = "1rqp9nf45m03mfh4x972whw2gsaz5x44l3dy6p639ib565g24rmh";
  };
in
{ pkgs ? import nixpkgs { } }:

pkgs.mkShell {
  hardeningDisable = [ "all" ];
  shellHook = ''
    export PATH=/home/kristoff/zig-aoc/:/home/kristoff/bork/zig-out/bin/:$PATH
  '';
  buildInputs = with pkgs; [
    cmake
    gdb
    ninja
    qemu
    micro
  ] ++ (with llvmPackages_13; [
    clang
    clang-unwrapped
    lld
    llvm
    lldb
  ]);
}
