/* Lchelp.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Поиск корреспонденции по части номера
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
        18.10.2012 Lyubov
 * BASES
        BANK COMM
 * CHANGES
*/

{mainhead.i}

def shared var s-lc like LC.LC.
def shared var s-ourbank as char no-undo.
def shared var s-lcprod  as char.
def shared var s-lctype  as char.
/*{LC.f}*/

{itemlist.i
 &file    = "LC"
 &frame   = "row 6 centered scroll 1 10 down width 70 overlay "
 &where   = " lc.lc begins s-lcprod and LC.LC matches '*' + s-lc + '*' and LC.bank = s-ourbank and lc.lctype = s-lctype"
 &flddisp = " LC.LC label 'Reference Number' format 'x(15)' LC.LCsts label 'Credit status' format 'x(5)'"
 &chkey   = "LC"
 &index   = "lcrwhn"
 &end     = "if keyfunction(lastkey) = 'end-error' then return."
 }
  s-lc = LC.LC.
