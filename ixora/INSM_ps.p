/* INSM_ps.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Загрузка РПРО, отзывов, реестров
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        ink100in inkrgin inkrecall
 * MENU
        Пункт меню
 * AUTHOR
        08/12/2009 galina
 * BASES
        BANK COMM
 * CHANGES
*/

unix silent value ("rm -f /tmp/insin/*.*").
/*загрузка инкассовых распоряжений*/
run insin.

unix silent value ("rm -f /tmp/insin/*.*").
/* загружаем реестры */
run insregin.

unix silent value ("rm -f /tmp/insin/*.*").
/* загружаем отзывы */
run insrecall.
