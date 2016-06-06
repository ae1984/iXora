/* ibplm5.p
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

/*
    14.08.2000
    ibplm5.p
    Поиск клиента ИО по счету - запускающая из меню...
    Пропер С.В.
*/
/*               
def var nConn as int init 0.
                
    run conn-ib( input-output nConn, 0 ).
    run ibfn-usac.
    run conn-ib( input-output nConn, 0 ).
*/
/***/

run connib.
run ibfn-usac.
disconnect "ib".
