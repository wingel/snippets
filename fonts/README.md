# Patched fonts

These files are slightly patched versions of the 6x13 font is
available as public domain from Marcus Kuhn here:

https://www.cl.cam.ac.uk/~mgk25/ucs-fonts.html

The files have then been converted to FontForge native .sfd files and
then exported as .otb files which can be used with modern Xorg.

To install the fonts, do this. It copies the font files themselves,
updates the font configuration so that the Fixed family of fonts can
be used (normally bitmap fonts are hidden on most modern Linux
distributions) and finally updates the font cache.

```
mkdir -p ~/.fonts
cp 6x13.otb 6x13B.otb ~/.fonts
mkdir -p ~/.config/fontconfig/conf.d
cp 69-fixed.conf ~/.config/fontconfig/conf.d/69-fixed.conf
fc-cache -f
```

It should now be possible to select the "Fixed" font in gnome-terminal
or xfce4-terminal.

A change was made to libvte a while go which makes the 6x13 font to be
renderedas a 6x15 font with two empty pixels between each line.

https://gitlab.gnome.org/GNOME/vte/-/issues/163

Part of this is seems to be due to a bug in the font itself, the "Typo
Line Gap" and "HHead Line Gap" fields are set to 90 which means that
the font actually asks a bit of extra spacing between each line.  But
even if these values are set to 0 the font will still be rendered as a
6x14 font.  This seems to be beacuse the "EM Size" in this font is
defined to be 1000 and since this isn't evenly divisible by 13,
somewhere deep in FreeType / Pango / Cairo / libvte a bit of rounding
is going on which causes the font height to become 14 instead of 13.

By changing the "EM Size" to 1300 in FontForge this seems to work
around this problem and the 6x13 font is again rendered as 6x13.
