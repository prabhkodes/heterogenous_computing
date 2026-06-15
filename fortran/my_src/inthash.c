/*
 * simple hash algorithm for integers for power of 2 size ranges
 *
 * multiply key with a large prime number that has bits set in every byte
 * and use the top N bits of the result.
 *
 * - size must be the next power of two from the desired hash range
 * - get hash quickly through bitshift and bitmask
 */

int inthash(int key, int size)
{
    int hash = key * 1103515249;
    int downshift = 0;
    int mask = size-1;

    for (int i=size; i > 1; i >>= 1)
        ++downshift;
    
    hash = (hash >> downshift) & mask;
    if (hash < 0) hash = 0;
    return hash;
}
