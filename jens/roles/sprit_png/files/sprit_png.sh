#!/bin/bash

curl -s -o /tmp/a100.data https://www.spritmonitor.de/de/detailansicht/924986.html
curl -s -o /tmp/charger.data https://www.spritmonitor.de/de/detailansicht/442963.html
curl -s -o /tmp/mb400.data https://www.spritmonitor.de/de/detailansicht/1053137.html
#curl -s -o /tmp/x5.data https://www.spritmonitor.de/de/detailansicht/935396.html
curl -s -o /tmp/ltd.data https://www.spritmonitor.de/de/detailansicht/1115586.html
curl -s -o /tmp/baron.data https://www.spritmonitor.de/de/detailansicht/1205963.html

a100_raw=`grep "strong> l/100km" /tmp/a100.data`
charger_raw=`grep "strong> l/100km" /tmp/charger.data`
mb400_raw=`grep "strong> l/100km" /tmp/mb400.data`
#x5_raw=`grep "strong> l/100km" /tmp/x5.data`
ltd_raw=`grep "strong> l/100km" /tmp/ltd.data`
baron_raw=`grep "strong> l/100km" /tmp/baron.data`

a100_r1=${a100_raw#*\<td\>\<strong\>}
a100_sprit=${a100_r1%\<\/strong\> l*}
if [ -z "$a100_sprit" ]
then
  a100_gall=$a100_sprit
else
  a100_gall=`awk "BEGIN {printf \"%.1f\n\", 235.4/${a100_sprit/,/.}}"`" mls/g"
  a100_sprit=" - $a100_sprit l/100km - "
fi

charger_r1=${charger_raw#*\<td\>\<strong\>}
charger_sprit=${charger_r1%\<\/strong\> l*}
if [ -z "$charger_sprit" ]
then
  charger_gall=$charger_sprit
else
  charger_gall=`awk "BEGIN {printf \"%.1f\n\", 235.4/${charger_sprit/,/.}}"`" mls/g"
  charger_sprit=" - $charger_sprit l/100km - "
fi

mb400_r1=${mb400_raw#*\<td\>\<strong\>}
mb400_sprit=${mb400_r1%\<\/strong\> l*}
if [ -z "$mb400_sprit" ]
then
  mb400_gall=$mb400_sprit
else
  mb400_gall=`awk "BEGIN {printf \"%.1f\n\", 235.4/${mb400_sprit/,/.}}"`" mls/g"
  mb400_sprit=" - $mb400_sprit l/100km - "
fi

ltd_r1=${ltd_raw#*\<td\>\<strong\>}
ltd_sprit=${ltd_r1%\<\/strong\> l*}
if [ -z "$ltd_sprit" ]
then
  ltd_sprit=$ltd_gall
else
  ltd_gall=`awk "BEGIN {printf \"%.1f\n\", 235.4/${ltd_sprit/,/.}}"`" mls/g"
  ltd_sprit=" - $ltd_sprit l/100km - "
fi

baron_r1=${baron_raw#*\<td\>\<strong\>}
baron_sprit=${baron_r1%\<\/strong\> l*}
if [ -z "$baron_sprit" ]
then
  baron_sprit=$baron_gall
else
  baron_gall=`awk "BEGIN {printf \"%.1f\n\", 235.4/${baron_sprit/,/.}}"`" mls/g"
  baron_sprit=" - $baron_sprit l/100km - "
fi

#x5_r1=${x5_raw#*\<td\>\<strong\>}
#x5_sprit=${x5_r1%\<\/strong\> l*}
#if [ -z "$x5_sprit" ]
#then
#  x5_gall=$x5_sprit
#else
#  x5_gall=`awk "BEGIN {printf \"%.1f\n\", 235.4/${x5_sprit/,/.}}"`" mls/g"
#  x5_sprit=" - $x5_sprit l/100km - "
#fi

row_charger="'69er Charger - 383 2bbl, 727, 2.76$charger_sprit$charger_gall"
row_a100="'69er A100 - 318 2bbl, 727, 3.23$a100_sprit$a100_gall"
row_mb400="'79er MB400 KMC Maxi 700 - 360 4bbl, 727, 4.10 Dana 60, 145"" wb$mb400_sprit$mb400_gall"
row_baron="'79er Chrysler LeBaron Medallion Coupe - 318 4bbl, 904, 2.45$baron_sprit$baron_gall"
row_ltd="'88er Ford LTD Crown Victoria LX$ltd_sprit$ltd_gall"
#row_x5="'18er X5 x40e$x5_sprit$x5_gall"

txt="$row_charger\n$row_a100\n$row_mb400\n$row_baron\n$row_ltd"

echo -e text 0,12 \"$txt\" > /tmp/sprit.txt

convert -size 480x80 xc:transparent -font DejaVu-Sans-Condensed -pointsize 11 -fill black -draw @/tmp/sprit.txt /srv/nginx_for_nedoc.gecius.de\,nedoc1.gecius.de/html/sprit.png
