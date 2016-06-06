/* UpdMonList.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
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
        05.07.2013 dmitriy. ТЗ 1947
 * BASES
        BANK COMM
 * CHANGES
        15.07.2013 dmitriy - указал ширину fr1
*/

def var v-txb as char extent 17.
def var v-mon as char extent 17.
def var i as int.

def frame fr1
v-txb[1]    format  "x(18)"     no-label   v-mon[1]    format  "x(80)"      no-label    help "В качестве разделителя использовать | (верт.черта) без пробелов"   skip
v-txb[2]    format  "x(18)"     no-label   v-mon[2]    format  "x(80)"      no-label    help "В качестве разделителя использовать | (верт.черта) без пробелов"   skip
v-txb[3]    format  "x(18)"     no-label   v-mon[3]    format  "x(80)"      no-label    help "В качестве разделителя использовать | (верт.черта) без пробелов"   skip
v-txb[4]    format  "x(18)"     no-label   v-mon[4]    format  "x(80)"      no-label    help "В качестве разделителя использовать | (верт.черта) без пробелов"   skip
v-txb[5]    format  "x(18)"     no-label   v-mon[5]    format  "x(80)"      no-label    help "В качестве разделителя использовать | (верт.черта) без пробелов"   skip
v-txb[6]    format  "x(18)"     no-label   v-mon[6]    format  "x(80)"      no-label    help "В качестве разделителя использовать | (верт.черта) без пробелов"   skip
v-txb[7]    format  "x(18)"     no-label   v-mon[7]    format  "x(80)"      no-label    help "В качестве разделителя использовать | (верт.черта) без пробелов"   skip
v-txb[8]    format  "x(18)"     no-label   v-mon[8]    format  "x(80)"      no-label    help "В качестве разделителя использовать | (верт.черта) без пробелов"   skip
v-txb[9]    format  "x(18)"     no-label   v-mon[9]    format  "x(80)"      no-label    help "В качестве разделителя использовать | (верт.черта) без пробелов"   skip
v-txb[10]   format  "x(18)"     no-label   v-mon[10]   format  "x(80)"      no-label    help "В качестве разделителя использовать | (верт.черта) без пробелов"   skip
v-txb[11]   format  "x(18)"     no-label   v-mon[11]   format  "x(80)"      no-label    help "В качестве разделителя использовать | (верт.черта) без пробелов"   skip
v-txb[12]   format  "x(18)"     no-label   v-mon[12]   format  "x(80)"      no-label    help "В качестве разделителя использовать | (верт.черта) без пробелов"   skip
v-txb[13]   format  "x(18)"     no-label   v-mon[13]   format  "x(80)"      no-label    help "В качестве разделителя использовать | (верт.черта) без пробелов"   skip
v-txb[14]   format  "x(18)"     no-label   v-mon[14]   format  "x(80)"      no-label    help "В качестве разделителя использовать | (верт.черта) без пробелов"   skip
v-txb[15]   format  "x(18)"     no-label   v-mon[15]   format  "x(80)"      no-label    help "В качестве разделителя использовать | (верт.черта) без пробелов"   skip
v-txb[16]   format  "x(18)"     no-label   v-mon[16]   format  "x(80)"      no-label    help "В качестве разделителя использовать | (верт.черта) без пробелов"   skip
v-txb[17]   format  "x(18)"     no-label   v-mon[17]   format  "x(80)"      no-label    help "В качестве разделителя использовать | (верт.черта) без пробелов"   skip
with side-labels centered row 3 title "Список мониторов для видео-стены на филиалах" width 105.


i = 1.
for each comm.txb where comm.txb.consolid = yes no-lock:
    v-txb[i] = comm.txb.info.

    find first sysc where sysc.sysc = "vw_" + string(comm.txb.city, "99") no-lock no-error.
    if avail sysc then v-mon[i] = sysc.chval.
    i = i + 1.
end.

display v-txb v-mon with frame fr1.
update v-mon with frame fr1.

{r-branch.i &proc = "UpdMonList2 (v-mon)"}

message "Данные обновлены" view-as alert-box.
