#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

/*      Задание 1. 
 *      Выполнить запрос:
 *          Выдать число поставщиков, поставлявших детали для 
 *          изделий, собираемых в городе, где производят красные 
 *          детали.
 */
void query(){
    // Объявление собственных переменных.
    exec SQL begin declare section;
    int count;                          // Число-результат запроса.
    exec SQL end declare section;

    // Начало транзакции.  
    printf("Starting transaction.\n");
    exec SQL begin work;

    // Выполнение запроса.
    exec SQL select count(distinct spj.n_post)
    into :count
    from spj
    where spj.n_izd in
        (select j.n_izd
        from j
        where town in
            (select p.town
            from p
            where cvet='Красный'
            and cvet='Нету'));

    // Обработка ошибок при совершении запроса.
    if (sqlca.sqlcode < 0) {
        fprintf(stderr, 
            "Error: %s\n%s\n", 
            sqlca.sqlerrm.sqlerrmc,
            "Couldn't execute query.\nRollbacking transaction.");
        exec SQL rollback work;
        return;
    }

    // Вывод результата.
    printf("Successfully finished query! Query results:\n");
    printf("| %-9s |\n", "count");
    printf("| %-9d |\n", count);

    // Завершение транзакции.
    printf("Committing transaction.\n");
    exec SQL commit work;
}

int main()
{
    //  Объявление собственных переменных.
    EXEC SQL begin declare section;
    char database_name[50] = "students";    // имя базы данных
    char user_name[50] = "pmi-b1813";       // имя пользователя
    char password[50] = "xdCz95b0/";        // пароль
    EXEC SQL end declare section;

    // Попытка подключения к базе данных.
    printf("Trying to connect to database.\n");
    EXEC SQL connect to :database_name user :user_name using :password;

    // Обработка ошибок при подключении.
    if (sqlca.sqlcode < 0)
    {
        fprintf(stderr, "Error: %s\n%s\n", 
            sqlca.sqlerrm.sqlerrmc, 
            "Couldn't connect.");
        exit(EXIT_FAILURE);
    }
    else
        printf("Connected successfully!\n");

    // Установка схемы.
    printf("Setting database scheme search path.\n");
    exec SQL set search_path to pmib1813;

    // Обработка ошибок при установке схемы.
    if (sqlca.sqlcode < 0) {
        fprintf(stderr, "Error: %s\n%s\n", 
            sqlca.sqlerrm.sqlerrmc, 
            "Couldn't set database scheme.");
        exit(EXIT_FAILURE);
    }

    // Выполнение запроса.
    query();

    // Отключение от базы данных.
    printf("Disconnecting from database.\n");
    exec SQL disconnect;

    // Обработка ошибок при отключении.
    if (sqlca.sqlcode < 0){
        fprintf(stderr, "Error: %s\n%s\n", 
            sqlca.sqlerrm.sqlerrmc, 
            "Couldn't disconnect.");
        exit(EXIT_FAILURE);
        }
    else
        printf("Disconnected successfully.\n");
}
