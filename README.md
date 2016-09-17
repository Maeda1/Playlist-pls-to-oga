# Playlist-pls-to-oga.sh :

Script to copy lossy files (and convert .flac files to .oga) from playlist (.pls file)
This script can be executed several times (one per console) with same playslit and same destination, all will be parallelized and CPUs will be more active (destination device too)

It takes first file in folder (.jpg, .jpeg, .bmp or .png) and resize it to 300 pixels and copy it to folder destination, as folder.jpg (perfect fo Blackberry Bold 9900 or other for example).

It creates the same folder tree where the files are in the destination folder. The script asks if it have to omit some first folder (example : /home/login). If several path are present in the .pls file, you can add several folder path to filter all that match (for example, your music files are not in the same folder tree).

Test with a .pls with some files before using it with many files, as you can check what's will going on :)

Need :
- .flac filed need to be in 1.3.1 revision and playlist in .pls
- mediainfo, convert (from imagemagick) and oggenc (from vorbis-tools) packages installed

Usage :
- 1st argument = full path to playliste (.pls) file containing files to convert.
- 2nd argument = full path to destination device.

This script is in english or french when executed, depending in locale used.
This script comes with no warranty.


