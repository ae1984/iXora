/* lclimhelp.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        Поиск лимита по клиенту
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        14-7-1-1
 * AUTHOR
        16/09/2011 id00810
 * BASES
        BANK COMM
 * CHANGES
*/

{mainhead.i}

def shared var s-cif     as char.
def shared var s-ourbank as char no-undo.
def shared var s-number  like lclimit.number.
def var i as int no-undo.
def temp-table t-lim no-undo like lclimit
    field id as int
    index ind1 id.

for each lclimit where lclimit.bank = s-ourbank and (if s-number <> 0 then lclimit.number = s-number else true) and (if s-cif <> '' then lclimit.cif = s-cif else true)  no-lock.
    i = i + 1.
    create t-lim.
    t-lim.id = i.
    buffer-copy lclimit to t-lim.
end.

{itemlist.i
 &file = "t-lim"
 &frame = "row 6 centered scroll 1 10 down width 70 overlay "
 &where = " true "
 &flddisp = "t-lim.id label 'N' format 'zz9' t-lim.cif label 'Client Code' format 'x(06)' t-lim.number label 'Number of Limit' format '>9' t-lim.sts label 'Limit status' format 'x(5)' "
 &chkey = "id"
 &chtype = "integer"
 &index  = "ind1"
 &end = "if keyfunction(lastkey) = 'end-error' then return."
 }
 assign s-cif    = t-lim.cif
        s-number = t-lim.number.
