# JAVA_HOME is set automatically by mise activate in interactive shells.
# This fallback covers non-interactive contexts (scripts, IDE terminals).
if [ -z "$JAVA_HOME" ] && command -v mise &>/dev/null; then
  JAVA_HOME="$(mise where java 2>/dev/null)" && export JAVA_HOME
fi
