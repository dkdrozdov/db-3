#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

//void task_1(){
//
//}

EXEC SQL begin declare section;
char database_name[50] = "students";
char user_name[50] = "pmi-b1813";
char password[50] = "xdCz95b0/";
EXEC SQL end declare section;

enum success_code{
    SUCCESS, FAILURE
}

int connect(){
    int success = SUCCESS;

    printf("Trying to connect to database.\n");
    EXEC SQL connect to :database_name user :user_name using :password;

    if (sqlca.sqlcode < 0)
    {
        fprintf(stderr, "Error: %s\n%s", sqlca.sqlerrm.sqlerrmc, "Couldn't connect.");
        success = FAILURE;
    }
    else
        printf("Connected successfully!\n");

    return success;
}

int disconnect(){

}

int main()
{
    if(connect()!=SUCCESS)
        exit(EXIT_FAILURE);

    printf("Disconnecting from database.\n");
    exec SQL disconnect;

    if (sqlca.sqlcode < 0){
        fprintf(stderr, "Error: %s\n%s", sqlca.sqlerrm.sqlerrmc, "Couldn't disconnect.");
        exit(EXIT_FAILURE);
        }
    else
        printf("Disconnected successfully.\n");
}
