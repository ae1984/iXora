/* INKM_ps.p
 * MODULE
        Инкассовые распоряжения
 * DESCRIPTION
        Описание
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
        17/11/2008 alex
 * BASES
        BANK COMM
 * CHANGES
        27/11/2008 alex - вынес загрузку инкассовых в отдельную i-ку
        10.06.09 galina - добавила заргузку ОПВ и СО
*/

unix silent value ("rm -f /tmp/inc100in/*.*").
/*загрузка инкассовых распоряжений*/
run ink100in.

unix silent value ("rm -f /tmp/inc100in/*.*").
/* загружаем реестры */
run inkrgin.

unix silent value ("rm -f /tmp/inc100in/*.*").
/* загружаем отзывы */
run inkrecall.

unix silent value ("rm -f /tmp/inc100in/*.*").
/* загружаем ОПВ и СО */
run 102in. 

unix silent value ("rm -f /tmp/inc100in/*.*").
