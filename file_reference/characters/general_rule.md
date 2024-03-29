This file is supposed the give you the information you need to read the raw binary data in the decrypted character binaries (and maybe reconstruct the data yourself if you want)

# Directories (also known as pointers)
Each character binary starts with a variable amount of Little Endian DWORDS (4 bytes reversed sequence) which are pointers to different objects directories stored within the character file.
Those objects are the character itself, objects related to that same character (mostly effects/special moves) and an unused sound effects section that you should not worry about, as these are stored in a completely different and standalone location.
After those pointers there will be a 0xFFFFFFFF (or 255 255 255 255) separator that tells us the pointers section has ended.

Before we continue, the way separators work is there will be an amount of them based on the offset of the last element of the previous section, ranging from 1 to 4 separators.
The file ensures data starts at the first 4 bytes of an offset and separators ends at the last 4 bytes of an offset, so if the previous data section ends at the last 4 bytes of an offset, the next 4 DWORDS will be separators, otherwise, the remaining DWORDS without data left in the offset become separators.

The very first pointer points of course to our character directory, the next pointers except for the last one points to extra related objects directories, and the last one points to the unused sound effects section.

WIP
