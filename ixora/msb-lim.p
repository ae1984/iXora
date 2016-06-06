/* msb-lim.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Ввод СК, определение процента резервирования по пулам Прочие однородные МСБ и Однородные МСБ
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        3.6.1
 * AUTHOR
        28/04/2012 dmitriy
 * BASES
        BANK
 * CHANGES
*/

{global.i}

def new shared var v-od1 as deci extent 2 no-undo.
def new shared var v-od7 as deci extent 2 no-undo.
def new shared var v-od13 as deci extent 2 no-undo.

def new shared var v-sum1 as deci extent 2 no-undo.
def new shared var v-sum7 as deci extent 2 no-undo.
def new shared var v-sum13 as deci extent 2 no-undo.

def new shared var v-rezprc as deci extent 2 no-undo.

def new shared var s-lim as deci no-undo.
def new shared var add_pr as integer no-undo.
def new shared var v-dt as date.
def new shared var v-%sk as deci no-undo. /* пороговое значение = 0,02% от СК */
def new shared var v-sum_msb as deci no-undo.

def var v-ja as logi.
def var nm as integer no-undo.
def var ny as integer no-undo.
def var v-dtold as date.
def var v-sk_old as deci.
def var v-dt_old as date.
def new shared var v-today as date.

def var v-perc as deci no-undo.

v-today = g-today.

define frame f-sk
    v-sk_old   label "Ранее введенный СК" format "zzz,zzz,zzz,zz9.99"
    v-dt_old   label "  за дату" format "99/99/9999" skip
     "------------------------------------------------------------" skip
    v-sum_msb  label "Ввод текущего СК  " format "zzz,zzz,zzz,zz9.99"
with centered row 10 side-labels.

define frame f-limmsb
    v-dt        label "Дата СК................ " format "99/99/9999" ' ' skip
    v-sum_msb   label "СК..................... " format "zzz,zzz,zzz,zz9.99" ' ' skip
    v-%sk       label "0,02% от СК............ " format "zzz,zzz,zzz,zz9.99" ' ' skip
    "   ---------------------------------" skip
    "   Портфель 'Однородные МСБ'" skip
    "   ---------------------------------" skip
    v-sum1[1] label " Всего ОД.............. " format "zzz,zzz,zzz,zz9.99" ' ' skip
    v-sum13[1]     label " Всего списано ОД...... " format "zzz,zzz,zzz,zz9.99" ' ' skip
    v-sum7[1]     label " ОД, просрочка c 15 дня " format "zzz,zzz,zzz,zz9.99" ' ' skip
    v-rezprc[1]    label " % резерва............. " format "zz9.99"  skip
    "   ---------------------------------" skip
    "   Портфель 'Прочие однородные МСБ'" skip
    "   ---------------------------------" skip
    v-sum1[2] label " Всего ОД.............. " format "zzz,zzz,zzz,zz9.99" ' ' skip
    v-sum13[2] label " Всего списано ОД...... " format "zzz,zzz,zzz,zz9.99" ' ' skip
    v-sum7[2]   label " ОД, просрочка c 15 дня " format "zzz,zzz,zzz,zz9.99" ' ' skip
    v-rezprc[2]  label " % резерва............. " format "zz9.99"
with centered row 3 side-labels.

find first sysc where sysc.sysc = "MSB%REZ" no-lock no-error.
if avail sysc then do:
    v-sk_old = sysc.deval / 0.0002.
    v-dt_old = sysc.daval.
end.

nm = month(g-today) + 1.
ny = year(g-today).
if nm = 13 then assign nm = 1 ny = ny + 1.
v-dt = date(nm,1,ny).
displ " Дата: " v-dt no-label with centered row 13 frame frd.
update v-dt validate (day(v-dt) = 1,"Число не 1-е!") format "99/99/9999" no-label with centered row 13 frame frd.
hide frame frd.

display v-sk_old v-dt_old v-sum_msb with frame f-sk.
update v-sum_msb with frame f-sk.
hide frame f-sk.

v-%sk = round(v-sum_msb * 0.0002, 2). /* 0.02% от суммы */

v-sum1[1] = 0. v-sum7[1] = 0. v-sum13[1] = 0.
v-sum1[2] = 0. v-sum7[2] = 0. v-sum13[2] = 0.

for each comm.txb where comm.txb.consolid no-lock:
    if connected ("txb") then disconnect "txb".
    connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
    run lnodnor4(1). /* данные для % резервирования */
end.
if connected ("txb") then disconnect "txb".

v-rezprc[1] = round( ((v-sum7[1] + v-sum13[1]) / (v-sum1[1] + v-sum13[1])) * 100, 2). /* % резервирования по однородным МСБ */
v-rezprc[2] = round( ((v-sum7[2] + v-sum13[2]) / (v-sum1[2] + v-sum13[2])) * 100, 2). /* % резервирования по прочим однородным МСБ */

display v-dt v-sum_msb v-%sk   v-sum1[1] v-sum13[1] v-sum7[1] v-rezprc[1]   v-sum1[2] v-sum13[2] v-sum7[2] v-rezprc[2]    with frame f-limmsb.

for each comm.txb where comm.txb.consolid no-lock:
    if connected ("txb") then disconnect "txb".
    connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
    run lnodnor4(2).  /* запись результата в sysc */
end.
if connected ("txb") then disconnect "txb".


