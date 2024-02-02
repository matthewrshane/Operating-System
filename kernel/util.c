
/**
 * @brief Copies a section of memory from one location to another.
 * 
 * @param source pointer to the first byte of the section to copy from
 * @param dest pointer to the first byte of the section to copy to
 * @param num_bytes the number of bytes of memory to copy
 */
void mem_copy(char* source, char* dest, int num_bytes) {
    // Loop through each byte and copy from source offset to dest offset
    for(int i = 0; i < num_bytes; i++) {
        *(dest + i) = *(source + i);
    }
}

/**
 * @brief Zeroes a section of memory.
 * 
 * @param start pointer to the first byte of the section to zero
 * @param num_bytes the number of bytes of memory to zero
 */
void mem_zero(char* start, int num_bytes) {
    // Loop through each byte and set to zero
    for(int i = 0; i < num_bytes; i++) {
        *(start + i) = 0x0;
    }
}