/* 
CWE121_experiment_base.c 
* * Experimental stand-in for a CWE-121 Juliet-style testcase. 
* Stack based buffer overflow. 
*/ 

#include <stdio.h>
#include <string.h>

#define DEST_SIZE 50
#define SOURCE_SIZE 100

void CWE121_Stack_Based_Buffer_Overflow_bad() {
    char data_buffer[SOURCE_SIZE];
    char dest[DEST_SIZE];
    
    /* Fill source buffer completely */
    memset(data_buffer, 'A', SOURCE_SIZE - 1);
    data_buffer[SOURCE_SIZE - 1] = '\0';

    /* POTENTIAL FLAW: Copying 100 bytes into a 50-byte stack buffer */
    strcpy(dest, data_buffer);
    printf("%s\n", dest);
}

int main() {
    CWE121_Stack_Based_Buffer_Overflow_bad();
    return 0;
}
