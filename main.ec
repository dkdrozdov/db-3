#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

// EXEC SQL begin declare section;
$char database_name[50];
$char user_name[50];
$char password[50];
// EXEC SQL end declare section;

int main()
{
    strcpy(database_name, "students");
    strcpy(user_name, "pmi-b1813");
    strcpy(password, "xdCz95b0/");

    printf("Trying to connect to database.\n");
    EXEC SQL connect to $database_name user_name $user_name using $password;

    if (sqlca.sqlcode < 0)
    {
        fprintf(stderr, "Error: %s\n%s", sqlca.sqlerrm.sqlerrmc, "Couldn't connect.");
        exit(EXIT_FAILURE);
    }
    else
        printf("Connected successfully!\n");

    printf("Disconnecting from database.\n");
    exec SQL disconnect;

    if (sqlca.sqlcode < 0){
        fprintf(stderr, "Error: %s\n%s", sqlca.sqlerrm.sqlerrmc, "Couldn't disconnect.");
        exit(EXIT_FAILURE);
        }
    else
        printf("Отсоединение от базы данных выполнено.\n");
}
