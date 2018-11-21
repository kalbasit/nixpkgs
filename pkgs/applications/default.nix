{ pkgs }:

with pkgs;

{
  archiver = callPackage ./misc/archiver { };
}
