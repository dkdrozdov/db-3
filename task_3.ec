#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

void print_sqlca()
{
    fprintf(stderr, "==== sqlca ====\n");
    fprintf(stderr, "sqlcode: %ld\n", sqlca.sqlcode);
    fprintf(stderr, "sqlerrm.sqlerrml: %d\n", sqlca.sqlerrm.sqlerrml);
    fprintf(stderr, "sqlerrm.sqlerrmc: %s\n", sqlca.sqlerrm.sqlerrmc);
    fprintf(stderr, "sqlerrd: %ld %ld %ld %ld %ld %ld\n", sqlca.sqlerrd[0],sqlca.sqlerrd[1],sqlca.sqlerrd[2],
                                                          sqlca.sqlerrd[3],sqlca.sqlerrd[4],sqlca.sqlerrd[5]);
    fprintf(stderr, "sqlwarn: %d %d %d %d %d %d %d %d\n", sqlca.sqlwarn[0], sqlca.sqlwarn[1], sqlca.sqlwarn[2],
                                                          sqlca.sqlwarn[3], sqlca.sqlwarn[4], sqlca.sqlwarn[5],
                                                          sqlca.sqlwarn[6], sqlca.sqlwarn[7]);
    fprintf(stderr, "sqlstate: %5s\n", sqlca.sqlstate);
    fprintf(stderr, "===============\n");
}

/*      Задание 3. 
 *      Выполнить запрос:
 *          Найти поставщиков, имеющих поставки, объем которых 
 *          меньше объема наименьшей поставки красных деталей,       
 *          сделанной этим поставщиком. Вывести номер поставщика,       
 *          объем поставки, минимальный объем поставки красных 
 *          деталей поставщиком.
 */
void query() {

    /* Объявление переменных для хранения результата запроса */
    exec SQL begin declare section;
    char n_izd[7];
    int pves;
    int mves;
    exec SQL end declare section;

    printf("Начало транзакции.\n");
    exec SQL begin work;
    printf("Определение курсора.\n");

    /* Запрос для определения курсора */
    exec SQL declare cursor3 cursor for
             select spj.n_izd, spj.kol*p.ves pves, b.mves
             from spj
             join p on p.n_det = spj.n_det
             join (select spj.n_izd, min(spj.kol*p.ves) mves
                   from spj
                   join p on p.n_det = spj.n_det
                   group by spj.n_izd
                  ) b on spj.n_izd = b.n_izd
             where spj.kol*p.ves > b.mves * 4
             order by 1, 2;

    /* Проверка успешности определения курсора */
    if (sqlca.sqlcode < 0) {
        Err(sqlca.sqlerrm.sqlerrmc, "Не удалось определить курсор.", false);
        exec SQL rollback work;
        return;
    }

    printf("Курсор определен.\n\n");

    /* Открытие курсора */
    exec SQL open cursor3;

    /* Проверка успешности открытия курсора */
    if (sqlca.sqlcode < 0) {
        Err(sqlca.sqlerrm.sqlerrmc, "Не удалось открыть курсор.", false);
        exec SQL rollback work;
        return;
    }

    bool dataexist = false;
    printf("Результат запроса:\n\n");

    /* Извлечение и вывод данных */
    while (1) {
        exec SQL fetch cursor3 INTO :n_izd, :pves, :mves;

        /* Проверка на конец выборки */
        if (sqlca.sqlcode == 100) break;

        /* Проверка на ошибку извлечения данных */
        if (sqlca.sqlcode < 0) {
            Err(sqlca.sqlerrm.sqlerrmc, "Не удалось получить данные.", false);
            exec SQL close cursor3;
            exec SQL rollback work;
            return;
        }

        /* Вывод заголовка таблицы */
        if (!dataexist) {
            printf("| %-7s | %-7s | %-7s |\n", "n_izd", "pves", "mves");
            dataexist = true;
        }

        /* Вывод данных */
        printf("| %-7s | %-7d | %-7d |\n", n_izd, pves, mves);
    }

    /* Проверка, что данные найдены */
    if (!dataexist) {
        printf("Данных не найдено.\n");
    }

    printf("\nВывод результата запроса завершен.\n");

    /* Закрытие курсора */
    exec SQL close cursor3;

    /* Проверка успешности закрытия курсора */
    if (sqlca.sqlcode < 0) {
        Err(sqlca.sqlerrm.sqlerrmc, "Не удалось закрыть курсор.", false);
        exec SQL rollback work;
        return;
    }

    printf("Завершение транзакции.\n\n");
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

    EXEC SQL WHENEVER SQLERROR CALL print_sqlca();

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

    return EXIT_SUCCESS;
}
