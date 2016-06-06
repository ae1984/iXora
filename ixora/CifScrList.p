/* CifScrList.p
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
*/

def var v-txb as char extent 17.
def var v-logi as logi extent 17 format "Да/Нет".
def var i as int.
def var str as char.

def frame fr1
v-txb[1]    format  "x(20)"     no-label   v-logi[1]    no-label    skip
v-txb[2]    format  "x(20)"     no-label   v-logi[2]    no-label    skip
v-txb[3]    format  "x(20)"     no-label   v-logi[3]    no-label    skip
v-txb[4]    format  "x(20)"     no-label   v-logi[4]    no-label    skip
v-txb[5]    format  "x(20)"     no-label   v-logi[5]    no-label    skip
v-txb[6]    format  "x(20)"     no-label   v-logi[6]    no-label    skip
v-txb[7]    format  "x(20)"     no-label   v-logi[7]    no-label    skip
v-txb[8]    format  "x(20)"     no-label   v-logi[8]    no-label    skip
v-txb[9]    format  "x(20)"     no-label   v-logi[9]    no-label    skip
v-txb[10]   format  "x(20)"     no-label   v-logi[10]   no-label    skip
v-txb[11]   format  "x(20)"     no-label   v-logi[11]   no-label    skip
v-txb[12]   format  "x(20)"     no-label   v-logi[12]   no-label    skip
v-txb[13]   format  "x(20)"     no-label   v-logi[13]   no-label    skip
v-txb[14]   format  "x(20)"     no-label   v-logi[14]   no-label    skip
v-txb[15]   format  "x(20)"     no-label   v-logi[15]   no-label    skip
v-txb[16]   format  "x(20)"     no-label   v-logi[16]   no-label    skip
v-txb[17]   format  "x(20)"     no-label   v-logi[17]   no-label    skip
with side-labels centered row 3 title "Филиалы с подключенным экраном клиента".

find first sysc where sysc.sysc = "CifScr" no-lock no-error.
if avail sysc then str = sysc.chval.

i = 1.
for each comm.txb where comm.txb.consolid = yes no-lock:
    v-txb[i] = comm.txb.info.

    if lookup(substr(comm.txb.bank, 4), str, "|") > 0 then v-logi[i] = yes.
    else v-logi[i] = no.

    i = i + 1.
end.

display v-txb v-logi with frame fr1.
update v-logi with frame fr1.

str = "".
for each comm.txb where comm.txb.consolid = yes no-lock:
    if v-logi[int(substr(comm.txb.bank,4)) + 1] = yes then str = str + substr(comm.txb.bank,4) + "|".
end.

{r-branch.i &proc = "CifScrList2 (str)"}

message "Данные обновлены" view-as alert-box.
