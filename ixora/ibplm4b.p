/* ibplm4b.p
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
 * BASES
        BANK COMM IB
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

/* ibplm4.p
Модуль:
            Платежная система
Назначение: 
            Контроль кодового слова платежа Интернет-офиса
Вызывается: 
            er_3a_ps.p
Пункты меню: 
            5.2.8
Автор: 
            PRAGMA
Дата создания:
            PRAGMA
Протокол изменений:
            30.07.2003 sasco Переделал на вызов ibplm4a, где фраза подтянется сама
            06.08.03 marinav Добавлена проверка на льготного клиента t11074

*/                                        

/*
run connib.
run ibchkkey.
disconnect "ib".
*/

define new shared variable s-remtrz like remtrz.remtrz.

update s-remtrz label "Введите номер RMZ" with centered frame ggg.
hide frame ggg.

run connib.
run ibplm4b1.
disconnect "ib".

