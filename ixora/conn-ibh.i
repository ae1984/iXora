/* conn-ibh.i
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

/* conn-ibh.i
Модуль:
            PRAGMA
Назначение: 
            Подключение к БД Интернет Офиса
Вызывается: 
            -
Пункты меню: 
            -
Автор: 
            -
Дата создания:
            -
Протокол изменений:
            29.07.2003 sasco Переделал подключение через переменную IBHOST в sysc
*/                                        


/* Соединение с базой инет офиса */
if not connected("ib") then do:
    find sysc where sysc.sysc = "IBHOST" no-lock no-error.
    if not avail sysc or sysc.chval = "" then do :
        message "Нет IBHOST записи в sysc файле !".
        return.
    end.
    connect value(sysc.chval) no-error.
end.
   
if not connected( 'ib' ) then do:
   message "Нет соединения с БД I-Office!".
   return.
end.


/* -sasco- за комментарием - старый вариант перед 29.07.2003 */
/*
if not connected("ib") then do:
    find sysc where sysc.sysc = "SYS1" no-lock no-error.
    if not avail sysc or sysc.chval = "" then do :
        message "Нет SYS1 записи в sysc файле !".
        return.
    end.
    connect value( '-db ib -ld ib -S ibdb -H bankonline -U inbank -P ' + ENTRY(3,sysc.chval) ) no-error.
end.
   
if not connected( 'ib' ) then do:
   message "Нет соединения с БД I-Office!".
   return.
end.
*/

