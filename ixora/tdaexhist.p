/* tdaexhist.p
 * MODULE
        Депозиты
 * DESCRIPTION
        Просмотр истории утсановки счету признака исключения по % ставки
 * RUN
        
 * CALLER
        tdainfo.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        1.1, 1.2, 10.7.3
 * AUTHOR
        20.05.2004 nadejda
 * CHANGES
        28.06.2004 nadejda - изменена сортировка - теперь просто по порядку в записи
*/

def input parameter p-aaa like aaa.aaa.
def shared var g-lang as char.
def var v-str as char           no-undo.
def var i as integer            no-undo.

def temp-table t-excl
    field num as integer
    field whn as date
    field who as char
    field rate as deci
    field oper as logical
    field des as char
    index num is primary unique num.

find aaa where aaa.aaa = p-aaa no-lock no-error.
if aaa.payfre = 0 then do:
   message skip " По счету не установлено исключение по процентной ставке ! " skip(1) view-as alert-box title "".
   return.
end.

if aaa.geo = "" then do:
   message skip " Нет сведений об установке исключения по процентной ставке ! " skip(1) view-as alert-box title "".
   return.
end.

do i = 1 to num-entries(aaa.geo, "|"):
   v-str = entry(i, aaa.geo, "|").
   create t-excl.
   t-excl.num = i.
   t-excl.who = entry (1, v-str, "^").
   find ofc where ofc.ofc = t-excl.who no-lock no-error.
   t-excl.who = "(" + t-excl.who + ")".
   if avail ofc then t-excl.who = t-excl.who + " " + ofc.name.
   if num-entries (v-str, "^") >= 2 then t-excl.whn = date (entry (2, v-str, "^")).
   if num-entries (v-str, "^") >= 3 then t-excl.rate = decimal (entry (3, v-str, "^")).
   if num-entries (v-str, "^") >= 4 then t-excl.oper = logical(entry (4, v-str, "^")).
   if num-entries (v-str, "^") >= 5 then t-excl.des = entry (5, v-str, "^").
end.

{jabro.i 
&start = " "
&head = "t-excl"
&headkey = "whn"
&where = " true "
&index = "num"
&formname = "tdaexhist"
&framename = "f-dat"
&addcon = "false"
&deletecon = "false"
&viewframe = " "
&predisplay = " "
&display = " t-excl.whn t-excl.who t-excl.rate t-excl.oper t-excl.des "
&highlight = " t-excl.whn "
&predelete = " "
&precreate = " "
&postadd = " "
&prechoose = " "
&postdelete = " "
&postkey = " "
&end = "hide frame f-dat. hide message."
}
