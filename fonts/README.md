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
