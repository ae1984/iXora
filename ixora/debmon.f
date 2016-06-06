/* debmon.f
 * MODULE
        Дебиторы
 * DESCRIPTION
        Фреймы для всяких нужд при вводе счетов-фактур
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        PRAGMA
 * AUTHOR
        05/02/04 sasco
 * CHANGES
*/


define frame hdebname
    codfr.name[1] at 3 no-label
    with title "Выберите из списка, F4 - отмена" 
    side-labels centered row 3 overlay 7 down.
