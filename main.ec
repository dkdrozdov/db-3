#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

void task_1(){
    exec SQL begin declare section;
    int count;
    exec SQL end declare section;
    
    printf("Starting transaction.\n");
    exec SQL begin work;
    
    exec SQL select count(distinct spj.n_izd)
        into :count
        from spj;

    if (sqlca.sqlcode < 0) {
        fprintf(stderr, 
            "Error: %s\s\n", 
            sqlca.sqlerrm.sqlerrmc,
            "Couldn't execute request.\nRollbacking transaction.");
        exec SQL rollback work;
        return;
    }

    printf("Committing transaction.\n");
    exec SQL commit work;
}

void menu(){
    printf("Choose the task number (1-5): ");

    int option = 0;
    if(scanf("%d", &option) == 1 && option <= 5 && option >= 1){
        printf("Task %d is chosen.\n", option);
    }

    switch(option){
        case 1:
            task_1();
            break;
        case 2:
            task_1();
            break;
        case 3:
            task_1();
            break;
        case 4:
            task_1();
            break;
        case 5:
            task_1();
            break;
        default:
            printf("This task doesn't exist.\n");
    }
}

int main()
{
    EXEC SQL begin declare section;
    char database_name[50] = "students";
    char user_name[50] = "pmi-b1813";
    char password[50] = "xdCz95b0/";
    EXEC SQL end declare section;

    //strcpy(database_name, "students");
    //strcpy(user_name, "pmi-b1813");
    //strcpy(password, "xdCz95b0/");

    printf("Trying to connect to database.\n");
    EXEC SQL connect to :database_name user :user_name using :password;

    if (sqlca.sqlcode < 0)
    {
        fprintf(stderr, "Error: %s\n%s\n", 
            sqlca.sqlerrm.sqlerrmc, 
            "Couldn't connect.");
        exit(EXIT_FAILURE);
    }
    else
        printf("Connected successfully!\n");

    printf("Setting database scheme search path.\n");
    exec SQL set search_path to pmib1813;

    if (sqlca.sqlcode < 0) {
        fprintf(stderr, "Error: %s\n%s\n", 
            sqlca.sqlerrm.sqlerrmc, 
            "Couldn't set database scheme.");
        exit(EXIT_FAILURE);
    }

    menu();

    printf("Disconnecting from database.\n");
    exec SQL disconnect;

    if (sqlca.sqlcode < 0){
        fprintf(stderr, "Error: %s\n%s\n", 
            sqlca.sqlerrm.sqlerrmc, 
            "Couldn't disconnect.");
        exit(EXIT_FAILURE);
        }
    else
        printf("Disconnected successfully.\n");
}
