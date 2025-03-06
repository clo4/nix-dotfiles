{ pkgs, ... }:
{
  # Notably, in my configuration, the *value* of this variable is never checked.
  # The only important thing is whether or not it's set at all.
  home.sessionVariables.IS_DARWIN = "";

  # On macOS, this is intended to suppress the login welcome message.
  home.file.".hushlogin".source = pkgs.emptyFile;
}
