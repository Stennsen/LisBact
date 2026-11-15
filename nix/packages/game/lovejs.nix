# love.js (https://github.com/Davidobot/love.js) CLI, run under node to render
# the web template and crunch the .love into game.data. The repo is pinned at
# a commit whose src/compat ships the LÖVE ${loveVersion} runtime (the
# published npm tarball only has 11.4); npm dependencies are pinned by
# registry integrity hash, so no template files are vendored in this repo.
{ pkgs, loveVersion, ... }:
let
  npmTarball =
    name: version: hash:
    pkgs.fetchurl {
      url = "https://registry.npmjs.org/${name}/-/${name}-${version}.tgz";
      inherit hash;
    };

  loveJsCommit = "c4f04e185033a7c9fbefa9be3bec88c41a90421b";
  loveJsSrc = pkgs.fetchurl {
    url = "https://codeload.github.com/Davidobot/love.js/tar.gz/${loveJsCommit}";
    hash = "sha256-tDEpaEqh+3tjMGTDeILSWngJ5ePE0Nk4iFvzldJOfRM=";
  };

  npmDeps = [
    {
      name = "commander";
      version = "2.20.3";
      hash = "sha512-GpVkmM8vF2vQUkj2LvZmD35JxeJOLCwJ9cUkugyk2nuhbv3+mJvpLYYt+0+USMxE+oj+ey/lJEnhZw75x/OMcQ==";
    }
    {
      name = "fs-extra";
      version = "3.0.1";
      hash = "sha512-V3Z3WZWVUYd8hoCL5xfXJCaHWYzmtwW5XWYSlLgERi8PWd8bx1kUHUk8L1BT57e49oKnDDD180mjfrHc1yA9rg==";
    }
    {
      name = "graceful-fs";
      version = "4.2.11";
      hash = "sha512-RbJ5/jmFcNNCcDV5o9eTnBLJ/HszWV0P73bc+Ff4nS/rJj+YaS6IGyiOL0VoBYX+l1Wrl3k63h/KrH+nhJ0XvQ==";
    }
    {
      name = "jsonfile";
      version = "2.4.0";
      hash = "sha512-PKllAqbgLgxHaj8TElYymKCAgrASebJrWpTnEkOaTowt23VKXXN0sUeriJ+eh7y6ufb/CC5ap11pz71/cM0hUw==";
    }
    {
      name = "klaw-sync";
      version = "2.1.0";
      hash = "sha512-lIxVCUMQIF7hfygFfdZgv4Z+e1smLroaYNQMUcf1TcJ5oqxj9m8qk19iIuMVl+tXQPr3CSE4V+4XjGEqmsth0Q==";
    }
    {
      name = "mustache";
      version = "2.3.2";
      hash = "sha512-KpMNwdQsYz3O/SBS1qJ/o3sqUJ5wSb8gb0pul8CO0S56b9Y2ALm8zCfsjPXsqGFfoNBkDwZuZIAjhsZI03gYVQ==";
    }
    {
      name = "universalify";
      version = "0.1.2";
      hash = "sha512-rBJeI5CXAlmy1pV+617WB9J63U6XcazHHF2f2dbJix4XzpUF0RS3Zbj0FGIOCAva5P/d/GBOYaACQ1w+0azUkg==";
    }
    {
      name = "uuid";
      version = "3.4.0";
      hash = "sha512-HjSDRw6gZE5JMggctHBcjVak08+KEVhSIiDzFnT9S9aegmp85S/bReBVTb4QTFaRNptJ9kuYaNhnbNEOkbKb/A==";
    }
  ];

  packages = [
    {
      name = "love.js";
      src = loveJsSrc;
    }
  ] ++ map (d: d // { src = npmTarball d.name d.version d.hash; }) npmDeps;
in
{
  loveJsCli = pkgs.runCommand "love.js-cli" { nativeBuildInputs = [ pkgs.gnutar pkgs.gzip ]; } (
    ''
      mkdir -p $out/node_modules
    ''
    + pkgs.lib.concatMapStringsSep "\n" (p: ''
      mkdir -p $out/node_modules/${p.name}
      tar xzf ${p.src} -C $out/node_modules/${p.name} --strip-components=1
    '') packages
  );
}
