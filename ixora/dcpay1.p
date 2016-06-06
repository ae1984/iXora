/* dcpay1.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        ODC: payment (оплата)
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
        13/02/2012 id00810
 * CHANGES
*/

def new shared var s-lcprod as char initial 'ODC'.
run dcpay.