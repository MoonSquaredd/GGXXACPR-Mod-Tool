This file is supposed the give you the information you need to read the raw binary data in the decrypted character binaries (and maybe reconstruct the data yourself if you want) (MASSIVE WIP)

We'll be using the decrypted ab.bin file for references and HxD to read the .bin file

# Chapter 1: Directories
The very first kind of data you'll find when reading a character's binaries is a directory. Directories could be compared to folders in a file explorer for example, as they are basically a way of listing files. In our case, a directory is actually a list of relative pointers, each pointing to some offset withing the binary file, these offsets being either the start of a sub directory or an actuall file.

Upon opening ab.bin in HxD, you should notice the first 8 DWORDS are: 

[20 00 00 00] [A0 04 49 00] [70 9B 51 00] [90 20 52 00] [C0 A5 53 00] [FF FF FF FF] [FF FF FF FF] [FF FF FF FF]

However, since the byte order of this file is actually Little Endian, this means we should read the bytes in the opposite order, ending up with these sequences instead: 

[00 00 00 20] [00 49 04 A0] [00 51 9B 70] [00 52 20 90] [00 53 A5 C0] [FF FF FF FF] [FF FF FF FF] [FF FF FF FF]

Now, what does all that even mean? Those are what we call the object pointers, as they are each pointing to a specific game object directly related to the character who owns this binary, in this case, A.B.A. They are all one after the other, and the only way to tell there is no more relative pointers, is when you reach the 0xFFFFFFFF DWORD, as this is a separator used to determine the end of a data section (with a few exceptions down the road).

The first object pointer points to A.B.A's main object, containing all her sprites/hitboxes/palettes/data/etc... Which is located at the offset 0x00000020 in this case, relative to the beginning of the file.
If we go to the offset 0x00000020, we'll actually end up in another list of relative pointers, those now relative to that 0x00000020 offset, NOT the beginning of the file. Each pointer here is now pointing to a more specific kind of data, in the case of characters main objects, they will point respecively to: Poses (a directory containing pointers to each pose/hitbox of that object), Sprites (also a directory but containing pointers to each sprite of that object), Scripts/Play Data (which is actually a big section containing all the code for that object, as well as their own specific variables), and the Palettes (yet another directory but now with pointers pointing to arrays of colors)
