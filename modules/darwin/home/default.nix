{ mylib, ...}:
{
  imports = mylib.scanPaths ./.;
}