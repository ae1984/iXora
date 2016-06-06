/* lchelp5.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        помощь в поиске аккредитива
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
        19/01/2012 id00810
 * BASES
        BANK COMM
 * CHANGES
        05.03.2012 Lyubov - добавила временную таблицу для корректной сортировки дат
        12.03.2012 Lyubov - можно выбрать все продукты или только необходимые
*/

{mainhead.i}
def input parameter p-sts as char.
def input parameter p-lcprod as char.
def shared var s-lc      like lc.lc.
def shared var s-ourbank as char no-undo.

def temp-table t-lc
field bank like lc.bank
field lc like lc.lc
field cif like lc.cif
field lcsts like lc.lcsts
field prod as char
field rwhn like lc.rwhn
index i-lc is primary prod rwhn.

for each lc no-lock:
    create t-lc.
    t-lc.bank = lc.bank.
    t-lc.lc = lc.lc.
    t-lc.cif = lc.cif.
    t-lc.lcsts = lc.lcsts.
    t-lc.prod = substring(lc.lc,1,(index(lc.lc, "0")) - 1).
    t-lc.rwhn = lc.rwhn.
end.

{itemlist.i
 &file    = "t-lc"
 &frame   = "row 6 centered scroll 1 10 down width 70 overlay "
 &where   = " t-lc.bank = s-ourbank and lookup(t-lc.lcsts,p-sts) > 0 and can-do(p-lcprod,t-lc.prod) "
 &flddisp = " t-lc.lc label 'Reference Number' format 'x(15)'  t-lc.cif label 'Applicant Code' format 'x(6)' t-lc.lcsts label 'Credit status' format 'x(5)'"
 &chkey   = "lc"
 &index   = "i-lc"
 &end     = "if keyfunction(lastkey) = 'end-error' then return."
 }
  s-lc = t-lc.lc.
