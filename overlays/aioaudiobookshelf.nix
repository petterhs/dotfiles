self: super: {
  python3Packages = super.python3Packages // {
    aioaudiobookshelf = super.python3Packages.aioaudiobookshelf.overridePythonAttrs (old: rec {
      version = "0.1.13";
      src = super.fetchFromGitHub {
        owner = "music-assistant";
        repo = "aioaudiobookshelf";
        rev = version;
        sha256 = "0bcxr8rc7msz8gaasxbfxblxqbnqgsmx30bwcq5dhqsphfh2lx7b";
      };
    });
  };

  python3 = super.python3.override {
    packageOverrides = _pySelf: _pySuper: {
      aioaudiobookshelf = self.python3Packages.aioaudiobookshelf;
    };
  };

  # Force music-assistant to use our python3 (with bumped aioaudiobookshelf)
  music-assistant = super.music-assistant.override { python3 = self.python3; };
}
