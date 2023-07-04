{ lib
, stdenv
, fetchFromGitHub
, rocmUpdateScript
, cmake
, libxml2
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hipify";
  version = "5.6.0";

  src = fetchFromGitHub {
    owner = "ROCm-Developer-Tools";
    repo = "HIPIFY";
    rev = "rocm-${finalAttrs.version}";
    hash = "sha256-4BbRI4NBFPPPOMQKeE9jzmWxFX1eOuPa/P0X93Ljwc0=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ libxml2 ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace "\''${LLVM_TOOLS_BINARY_DIR}/clang" "${stdenv.cc}/bin/clang"
  '';

  passthru.updateScript = rocmUpdateScript {
    name = finalAttrs.pname;
    owner = finalAttrs.src.owner;
    repo = finalAttrs.src.repo;
  };

  # Fixup weird install paths
  postInstall = ''
    mkdir -p $out/bin
    mv $out/{*.sh,hipify-*} $out/bin
    cp -afs $out/bin $out/hip
  '';

  meta = with lib; {
    description = "Convert CUDA to Portable C++ Code";
    homepage = "https://github.com/ROCm-Developer-Tools/HIPIFY";
    license = with licenses; [ mit ];
    maintainers = teams.rocm.members;
    platforms = platforms.linux;
    broken = versions.minor finalAttrs.version != versions.minor stdenv.cc.version;
  };
})
