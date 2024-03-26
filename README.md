# GGXXACPR Mod Tool
A tool that should make guilty modders lives easier
---

# What it does
As of 0.3.0, parse and separate the files inside the decrypted character binary into their own separated binaries
---

# How it works (technical)
1. Reads the first 32 bits of the binary file which are pointers to the objects stored within the character file.
2. Stores the pointer in an array then proceeds to read the next 32 bits of the binary file.
3. If those next 32 bits are not a separator (0xFFFFFFFF) it means it is another pointer, so repeat step 2.
4. Once it reaches a separator, it will go to the offsets pointed by each object pointer, starting by the first in the pointers array which is the character object.
5. The process is pretty much the same as the previous one, read 32 bits, store if is a pointer or read the next object if is a separator.
6. Now every next object is an "extra" object, except for the last one, which is (for whatever reason) the private sound effects for the character (which are unused in the steam port so we are ignoring those (they are also evil big-endian from the pointers to the files themselves)).
7. At this points all objects have their own arrays of pointers to their individual files, and as you might have already guessed, we must repeat the previous process once again, but only for the first 2 pointers in these arrays, those are for the "poses" and for the "sprites" respectively. Additionaly, the character object also store the palette file for all the objects in the file combined, so in its case, we also go through his last pointer (skipping the scripts as they are a single file).
8. With all the files now listed, we read them 32 bits by 32 bits until we reach a separator once again, however this time we'll write what we get to a separate binary, effectively separating them.
9. Now you should have a bunch of binaries at the specified location, which you can read (if you know how) or just use the sprite binaries in [XX Sprite Decode](https://github.com/WistfulHopes/xx_spritedecode) by [WistfulHopes](https://github.com/WistfulHopes)

Powered by Godot
