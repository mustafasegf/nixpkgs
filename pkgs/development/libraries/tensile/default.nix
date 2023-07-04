{ lib
, stdenv
, fetchFromGitHub
, rocmUpdateScript
, buildPythonPackage
, pyyaml
, msgpack
, pandas
}:

buildPythonPackage rec {
  pname = "tensile";
  version = "5.6.0";

  src = fetchFromGitHub {
    owner = "ROCmSoftwarePlatform";
    repo = "Tensile";
    rev = "rocm-${version}";
    hash = "sha256-elCe9I1qdxSL8DKTf9PGU75a85/oa5Hy0KJ5cAuuTug=";
  };

  buildInputs = [
    pyyaml
    msgpack
    pandas
  ];

  passthru.updateScript = rocmUpdateScript {
    name = pname;
    owner = src.owner;
    repo = src.repo;
  };

  meta = with lib; {
    description = "GEMMs and tensor contractions";
    homepage = "https://github.com/ROCmSoftwarePlatform/Tensile";
    license = with licenses; [ mit ];
    maintainers = teams.rocm.members;
    platforms = platforms.linux;
    broken = versions.minor version != versions.minor stdenv.cc.version;
  };
}
