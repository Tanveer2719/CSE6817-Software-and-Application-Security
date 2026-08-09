#include <stdio.h>
#include <string.h>

#define BUFFER_SIZE 32

/*
 * Experimental harness.
 *
 * The input originates outside this function and flows through
 * several functions before reaching the bounded destination.
 */
static void process_input(const char *input)
{
    char buffer[BUFFER_SIZE];

    /*
     * Safe stand-in for the vulnerable sink.
     * Use the corresponding Juliet CWE-121 testcase for the
     * actual vulnerability experiment.
     */
    snprintf(buffer, sizeof(buffer), "%s", input);

    printf("Processed: %s\n", buffer);
}

static void wrapper(const char *user_input)
{
    process_input(user_input);
}

int main(int argc, char *argv[])
{
    if (argc > 1) {
        wrapper(argv[1]);
    }

    return 0;
}
