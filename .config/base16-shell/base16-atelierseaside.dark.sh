#!/bin/sh
# Base16 Atelier Seaside - Console color setup script
# Bram de Haan (http://atelierbram.github.io/syntax-highlighting/atelier-schemes/seaside/)

color00="13/15/13" # Base 00 - Black
color01="e6/19/3c" # Base 08 - Red
color02="29/a3/29" # Base 0B - Green
color03="c3/c3/22" # Base 0A - Yellow
color04="3d/62/f5" # Base 0D - Blue
color05="ad/2b/ee" # Base 0E - Magenta
color06="19/99/b3" # Base 0C - Cyan
color07="8c/a6/8c" # Base 05 - White
color08="68/7d/68" # Base 03 - Bright Black
color09=$color01 # Base 08 - Bright Red
color10=$color02 # Base 0B - Bright Green
color11=$color03 # Base 0A - Bright Yellow
color12=$color04 # Base 0D - Bright Blue
color13=$color05 # Base 0E - Bright Magenta
color14=$color06 # Base 0C - Bright Cyan
color15="f0/ff/f0" # Base 07 - Bright White
color16="87/71/1d" # Base 09
color17="e6/19/c3" # Base 0F
color18="24/29/24" # Base 01
color19="5e/6e/5e" # Base 02
color20="80/99/80" # Base 04
color21="cf/e8/cf" # Base 06

if [ -n "$TMUX" ]; then
  # tell tmux to pass the escape sequences through
  # (Source: http://permalink.gmane.org/gmane.comp.terminal-emulators.tmux.user/1324)
  printf_template="\033Ptmux;\033\033]4;%d;rgb:%s\007\033\\"
elif [ "${TERM%%-*}" = "screen" ]; then
  # GNU screen (screen, screen-256color, screen-256color-bce)
  printf_template="\033P\033]4;%d;rgb:%s\007\033\\"
else
  printf_template="\033]4;%d;rgb:%s\033\\"
fi

# 16 color space
printf $printf_template 0  $color00
printf $printf_template 1  $color01
printf $printf_template 2  $color02
printf $printf_template 3  $color03
printf $printf_template 4  $color04
printf $printf_template 5  $color05
printf $printf_template 6  $color06
printf $printf_template 7  $color07
printf $printf_template 8  $color08
printf $printf_template 9  $color09
printf $printf_template 10 $color10
printf $printf_template 11 $color11
printf $printf_template 12 $color12
printf $printf_template 13 $color13
printf $printf_template 14 $color14
printf $printf_template 15 $color15

# 256 color space
if [ "$TERM" != linux ]; then
  printf $printf_template 16 $color16
  printf $printf_template 17 $color17
  printf $printf_template 18 $color18
  printf $printf_template 19 $color19
  printf $printf_template 20 $color20
  printf $printf_template 21 $color21
fi

# clean up
unset printf_template
unset color00
unset color01
unset color02
unset color03
unset color04
unset color05
unset color06
unset color07
unset color08
unset color09
unset color10
unset color11
unset color12
unset color13
unset color14
unset color15
unset color16
unset color17
unset color18
unset color19
unset color20
unset color21
