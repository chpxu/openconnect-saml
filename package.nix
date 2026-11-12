{
  lib,
  python3Packages,
  openconnect,
  qt6,
  withGui ? false,   # [gui]   Qt6 WebEngine browser
  withFido2 ? false, # [fido2] hardware-key support
  withTui ? false,   # [tui]   rich-based interactive TUI
}:

python3Packages.buildPythonApplication {
  pname = "openconnect-saml";
  version = "0.25.0";
  pyproject = true;

  src = lib.cleanSource ./.;

  build-system = with python3Packages; [ hatchling ];

  dependencies =
    with python3Packages;
    [
      attrs
      colorama
      keyring
      lxml
      prompt-toolkit
      pyotp
      pysocks
      pyxdg
      requests
      structlog
      toml
    ]
    ++ lib.optionals withGui [
      pyqt6
      pyqt6-webengine
    ]
    ++ lib.optional withFido2 fido2
    ++ lib.optional withTui rich;

  pythonRelaxDeps = [ "requests" ];

  nativeBuildInputs = lib.optionals withGui [ qt6.wrapQtAppsHook ];
  buildInputs = lib.optionals withGui [
    qt6.qtbase
    qt6.qtwebengine
  ];

  dontWrapQtApps = true;

  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [ openconnect ])
  ];

  preFixup = lib.optionalString withGui ''
    makeWrapperArgs+=("''${qtWrapperArgs[@]}")
  '';

  pythonImportsCheck = [ "openconnect_saml" ];

  doCheck = false;
  nativeCheckInputs = with python3Packages; [
    cryptography
    pytest-asyncio
    pytest-httpserver
    pytestCheckHook
  ];
  disabledTestMarks = [ "integration" ];

  meta = {
    homepage = "https://github.com/mschabhuettl/openconnect-saml";
    license = lib.licenses.gpl3Plus;
    mainProgram = "openconnect-saml";
    platforms = lib.platforms.linux;
  };
}
