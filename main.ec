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
    EXEC SQL connect to : database_name user_name : user_name using : password;

    if (sqlca.sqlcode < 0)
        Err(sqlca.sqlerrm.sqlerrmc, "Couldn't connect.", true);
    else
        printf("Connected successfully!\n");

    printf("Disconnecting from database.\n");
    exec SQL disconnect;

    if (sqlca.sqlcode < 0)
        Err(sqlca.sqlerrm.sqlerrmc, "Couldn't disconnect.", true);
    else
        printf("Отсоединение от базы данных выполнено.\n");
}
