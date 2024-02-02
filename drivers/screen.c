#include "headers/screen.h"
#include "../kernel/headers/low_level.h"
#include "../kernel/headers/util.h"

/**
 * @brief Prints a null-terminated string at the cursor position.
 * 
 * @param message the null-terminated string to print
 */
void print(char* message) {
    print_at(message, -1, -1);
}

/**
 * @brief Prints a null-terminated string at a specific position
 * 
 * @param message the null-terminated string to print
 * @param col the zero-based column to print in (or negative for cursor position)
 * @param row the zero-based row to print in (or negative for cursor position)
 */
void print_at(char* message, int col, int row) {
    // Update the cursor if row and col are non-negative
    if(col >= 0 && row >= 0) set_cursor(get_screen_offset(col, row));

    // Loop through each char until null-terminator reached and
    // print at the cursor location
    int i = 0;
    while(message[i] != 0) {
        print_char(message[i++], -1, -1, WHITE_ON_BLACK);
    }
}

/**
 * @brief Prints a character on the screen.
 * 
 * @param character the character to print
 * @param col the zero-based column to print in (or negative for cursor position)
 * @param row the zero-based row to print in (or negative for cursor position)
 * @param atrribute_byte byte that defines attributes of the character
 */
void print_char(char character, int col, int row, char attribute_byte) {
    // Declare a byte (char) pointer to the start of video memory
    unsigned char* vidmem = (unsigned char*) VIDEO_ADDRESS;

    // If attribute_byte is zero, assume default
    if(!attribute_byte) attribute_byte = WHITE_ON_BLACK;

    // Get the video memory offset for the screen location
    // If row and col are non-negative, use for offset,
    // otherwise use the cursor position
    int offset = (col >= 0 && row >= 0) ? get_screen_offset(col, row) : get_cursor();

    // If the character to print is a newline character, set cursor
    // to the end of the current row so it will be updated to the
    // first column of the next row
    if(character == '\n') offset = get_screen_offset(MAX_COLS - 1, offset / (2 * MAX_COLS));

    // Otherwise, write the character and its attribute byte to
    // video memory at the calculated offset
    else {
        vidmem[offset] = character;
        vidmem[offset + 1] = attribute_byte;
    }

    // Update the offset to the next character cell, two bytes
    // ahead of the current cell
    offset += 2;

    // Make scrolling adjustment, if needed
    offset = handle_scrolling(offset);

    // Update the cursor position on the screen device
    set_cursor(offset);
}

/**
 * @brief Clears the screen, setting every position to blank chars.
 * 
 */
void clear_screen() {
    // Loop through each space on the screen and write blank chars
    for(int row = 0; row < MAX_ROWS; row++) {
        for(int col = 0; col < MAX_COLS; col++) {
            print_char(' ', col, row, WHITE_ON_BLACK);
        }
    }

    // Move the cursor to the top-left
    set_cursor(get_screen_offset(0, 0));
}

/**
 * @brief Scrolls the screen if needed.
 * 
 * @param offset the current screen offset of the cursor
 * @return the position of the cursor after scrolling if needed
 */
int handle_scrolling(int offset) {
    // If the cursor is within the screen, return it unmodified
    if(offset < MAX_ROWS * MAX_COLS * 2) return offset;

    // Otherwise, the cursor is off the screen, copy the screen
    // starting from the second row to the start of video memory
    mem_copy((char*)(get_screen_offset(0, 1) + VIDEO_ADDRESS),
             (char*)(get_screen_offset(0, 0) + VIDEO_ADDRESS),
             (MAX_ROWS - 1) * MAX_COLS * 2);
    
    // Blank the last line by zeroing its bytes
    mem_zero((char*)(get_screen_offset(0, MAX_ROWS - 1) + VIDEO_ADDRESS),
             MAX_COLS * 2);

    // Move the offset back one row (subtract one row of bytes)
    offset -= MAX_COLS * 2;

    // Return the updated offset
    return offset;
}

/**
 * @brief Calculate the screen offset based on a column and row number.
 * 
 * @param col the column [0, MAX_COLS - 1]
 * @param row the row [0, MAX_ROWS - 1]
 * @return the sequential offset from the start of video memory for this cell
 */
int get_screen_offset(int col, int row) {
    return 2 * ((row * MAX_COLS) + col);
}

/**
 * @brief Get the offset of the cursor.
 * 
 * @return the sequential offset from the start of video memory of the cursor
 */
int get_cursor() {
    // The device uses its control register as an index to select
    // internal registers, such as:
    // - reg 14: high byte of the cursor's offset
    // - reg 15: low byte of the cursor's offset
    // Once the register is selected, reading or writing to the data
    // register will read/write to the internal register selected

    // Select register 14, then read the high byte and left shift into place
    port_byte_out(REG_SCREEN_CTRL, 14);
    int offset = port_byte_in(REG_SCREEN_DATA) << 8;

    // Select register 15, then read the low byte in, adding to offset
    port_byte_out(REG_SCREEN_CTRL, 15);
    offset += port_byte_in(REG_SCREEN_DATA);

    // Since the cursor offset is in # of characters, multiply by
    // two to get the character cell offset
    return offset * 2;
}

/**
 * @brief Set the offset of the cursor.
 * 
 * @param offset the sequential offset from the start of video memory to set the cursor to
 */
void set_cursor(int offset) {
    // Convert from character cell offset in memory
    // to number of characters for the cursor
    offset /= 2;

    // The device uses its control register as an index to select
    // internal registers, such as:
    // - reg 14: high byte of the cursor's offset
    // - reg 15: low byte of the cursor's offset
    // Once the register is selected, reading or writing to the data
    // register will read/write to the internal register selected

    // Select register 14, then write the high byte
    port_byte_out(REG_SCREEN_CTRL, 14);
    port_byte_out(REG_SCREEN_DATA, (unsigned char)(offset >> 8));

    // Select register 15, then write the low byte
    port_byte_out(REG_SCREEN_CTRL, 15);
    port_byte_out(REG_SCREEN_DATA, (unsigned char)offset);

    // Select register 15, then write the low byte
    port_byte_out(REG_SCREEN_CTRL, 15);
    offset += port_byte_in(REG_SCREEN_DATA);
}