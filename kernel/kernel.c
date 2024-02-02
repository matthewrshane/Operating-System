#include "../drivers/headers/screen.h"

void start() {
    // Create a pointer to a char, and point it to the first text cell
    // of video memory (top-left of screen)
    char* video_memory = (char*) 0xb8000;

    // Dereference the video_memory pointer and store the character 'X'
    *video_memory = 'X';

    // Clear the screen
    clear_screen();

    // Create a string to print
    char msg[] = "Message.\n";

    // Print the string
    print(msg);
    print(msg);
}