# Android SDK tools — hardcoded path because path.zsh loads before env.zsh
if [ -d "$HOME/Library/Android/sdk" ]; then
  export PATH="$HOME/Library/Android/sdk/cmdline-tools/latest/bin:$PATH"
  export PATH="$HOME/Library/Android/sdk/platform-tools:$PATH"
  export PATH="$HOME/Library/Android/sdk/emulator:$PATH"
fi
