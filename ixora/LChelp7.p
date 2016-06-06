/* Lchelp7.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        поиск аккредитива с определенным статусом по части номера
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        18/04/2013 Sayat(id01143) - ТЗ 1813 от 18/04/2013
 * BASES
        BANK COMM
 * CHANGES
*/

{mainhead.i}
def input parameter p-sts as char.
def input parameter p-tp  as char.
def shared var s-lc like LC.LC.
def shared var s-ourbank as char no-undo.
def shared var s-lcprod  as char.


{itemlist.i
 &file    = "LC"
 &frame   = "row 6 centered scroll 1 10 down width 70 overlay "
 &where   = " lc.lc begins s-lcprod and LC.bank = s-ourbank and lookup(lc.lcsts,p-sts) > 0 and (p-tp = '' or lookup(lc.lctype,p-tp) > 0) "
 &flddisp = " LC.LC label 'Reference Number' format 'x(15)' LC.LCsts label 'Credit status' format 'x(5)' LC.cif label 'Applicant Code' format 'x(6)'"
 &chkey   = "LC"
 &index   = "lcrwhn"
 &end     = "if keyfunction(lastkey) = 'end-error' then return."
 }
  s-lc = LC.LC.
