/* lcpay1.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        IMLC: payment (оплата)
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
        25/02/2011 id00810
 * CHANGES
*/

def new shared var s-lcprod as char initial 'IMLC'.
run imlcpay.