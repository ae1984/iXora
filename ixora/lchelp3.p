/* lchelp3.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        поиск аккредитива с определенным статусом с учетом филиала или по всем филиалам
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
        25/03/2011 id00810
 * BASES
        BANK COMM
 * CHANGES
    24/06/2011 id00810 - изменила условие поиска по статусу
    17/08/2011 id00810 - добавлено условие для события adjust
    15/02/2012 id00810 - изменила индекс
 */

{mainhead.i}
def input parameter p-sts as char.
def shared var s-lc      like lc.lc.
def shared var s-ourbank as char no-undo.
def shared var s-lcprod  as char.
def shared var s-event   as char.

{itemlist.i
 &file = "LC"
 &frame = "row 6 centered scroll 1 10 down width 70 overlay "
 &where = " lc.lc begins s-lcprod and lookup(lc.lcsts,p-sts) > 0 and can-do(if s-event ne 'extch' and s-event ne 'adjust' then s-ourbank else '*',lc.bank) "
 &flddisp = " LC.LC label 'Reference Number' format 'x(15)' LC.LCsts label 'Credit status' format 'x(5)' LC.cif label 'Applicant Code' format 'x(6)' lc.bank label 'Filial' format 'x(05)'"
 &chkey = "LC"
 &index  = "lcrwhn"
 &end = "if keyfunction(lastkey) = 'end-error' then return."
 }
  s-lc = lc.lc.
