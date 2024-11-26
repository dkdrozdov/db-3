#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

/*      Задание 3. 
 *      Выполнить запрос:
 *          Найти поставщиков, имеющих поставки, объем которых 
 *          меньше объема наименьшей поставки красных деталей,       
 *          сделанной этим поставщиком. Вывести номер поставщика,       
 *          объем поставки, минимальный объем поставки красных 
 *          деталей поставщиком.
 */
void query(){
    // Объявление собственных переменных.
    exec SQL begin declare section;
    char n_post[7];                 // Результат-номер поставщика.
    int amount;                        // Результат-объем поставки.
    int min_amount;                    // Результат-минимальный объем
                                       поставки красных деталей
                                       поставщиком.
    exec SQL end declare section;

    // Начало транзакции.  
    printf("Starting transaction.\n");
    exec SQL begin work;

    // Выполнение запроса с объявлением курсора.
    printf("Trying to declare a cursor.\n");
    exec SQL declare result_cursor cursor for
        select spj.amount
        from spj;


    // Обработка ошибок при совершении запроса.
    if (sqlca.sqlcode < 0) {
        fprintf(stderr, 
            "Error: %s\n%s\n", 
            sqlca.sqlerrm.sqlerrmc,
            "Couldn't execute query.\nRollbacking transaction.");
        exec SQL rollback work;
        return;
    }

    // Открытие курсора.
    printf("Cursor declared successfully.\nTrying to open cursor.\n");
    exec SQL open result_cursor;

    // Обработка ошибок при открытии курсора.
    if (sqlca.sqlcode < 0) {
        fprintf(stderr, 
            "Error: %s\n%s\n", 
            sqlca.sqlerrm.sqlerrmc,
            "Couldn't open cursor.\nRollbacking transaction.");
        exec SQL rollback work;
        return;
    }

    // Вывод результата.
    printf("Cursor opened successfully.\n");
    printf("Successfully finished query!\nQuery results:\n");

    bool data_read = true;    // Получена ли хотя бы одна строка данных.

    exec SQL fetch result_cursor INTO :amount; // Извлечение данных из курсора.

    while(sqlca.sqlcode != SQLFOUND) // Проверка на достижение конца выборки.
    {
        // Обработка ошибок при открытии курсора.
        if (sqlca.sqlcode < 0) {
            fprintf(stderr, 
                "Error: %s\n%s\n", 
                sqlca.sqlerrm.sqlerrmc,
                "Couldn't get data.\nRollbacking transaction.");
            exec close result_cursor
            exec SQL rollback work;
            return;
        }

        // Вывод заголовка таблицы.
        if(!data_read) printf("| %-9s |\n", "amount");
        data_read = true;

        // Вывод данных
        printf("| %-9s |\n", amount);

        exec SQL fetch result_cursor into :amount  // Извлечение данных из курсора.
    }

    // Сообщение о пустом результате.
    if(!data_read) printf("No rows found.\n");

    // Закрытие курсора.
    exec SQL close result_cursor;

    // Обработка ошибок при закрытии курсора.
    if (sqlca.sqlcode < 0) {
        fprintf(stderr, 
            "Error: %s\n%s\n", 
            sqlca.sqlerrm.sqlerrmc,
            "Couldn't close cursor.\nRollbacking transaction.");
        exec SQL rollback work;
        return;
    }

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
