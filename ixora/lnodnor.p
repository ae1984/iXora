/* lnodnor.p
 * MODULE
        Кредиты
 * DESCRIPTION
        Расчет % резерва по однородным кредитам
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
        25/01/2011 madiyar
 * BASES
        BANK COMM
 * CHANGES
        26/08/2013 Sayat(id01143) - ТЗ 1850 от 17/05/2013 "Изменения в расчет однородных кредитов по АФН"
*/

{mainhead.i}

def new shared var s-full_od as deci no-undo extent 6.
def new shared var s-pr_od as deci no-undo extent 6.
def new shared var s-full_prc as deci no-undo extent 6.
def new shared var s-pr_prc as deci no-undo extent 6.
def new shared var v-rezprc as deci no-undo extent 6.

def new shared var s-rates as deci no-undo extent 3.
for each crc where crc.crc >= 1 and crc.crc <= 3 no-lock:
    s-rates[crc.crc] = crc.rate[1].
end.

def new shared var s-lim as deci no-undo.
find first pksysc where pksysc.credtype = '0' and pksysc.sysc = "lnodnor" no-lock no-error.
if avail pksysc then s-lim = pksysc.deval.
else do:
    message " Не найдено справочное значение пороговой суммы для отнесения к портфелю однородных кредитов!" view-as alert-box error.
    return.
end.

def var v-ja as logi no-undo.

/*
def frame fr
    skip(1)
    "   Портфель 'Однородные Метрокредит'" skip
    "   ---------------------------------" skip
    s-full_od[1]  label " Всего ОД................" format "zzz,zzz,zzz,zz9.99" ' ' skip
    s-full_prc[1] label " Всего %%................" format "zzz,zzz,zzz,zz9.99" ' ' skip(1)
    s-pr_od[1]    label " ОД, просрочка от 15 дней" format "zzz,zzz,zzz,zz9.99" ' ' skip
    s-pr_prc[1]   label " %%, просрочка от 15 дней" format "zzz,zzz,zzz,zz9.99" ' ' skip(1)
    v-rezprc[1]   label " % резерва..............." format "zz9.99" skip(2)
    "   Портфель 'Однородные Сотрудники'" skip
    "   ---------------------------------" skip
    s-full_od[2]  label " Всего ОД................" format "zzz,zzz,zzz,zz9.99" ' ' skip
    s-full_prc[2] label " Всего %%................" format "zzz,zzz,zzz,zz9.99" ' ' skip(1)
    s-pr_od[2]    label " ОД, просрочка от 15 дней" format "zzz,zzz,zzz,zz9.99" ' ' skip
    s-pr_prc[2]   label " %%, просрочка от 15 дней" format "zzz,zzz,zzz,zz9.99" ' ' skip(1)
    v-rezprc[2]   label " % резерва..............." format "zz9.99" skip(1)
    v-ja label " Проставить ставку по филиалам?" skip(1)
with centered row 5 side-labels.
*/

def frame fr
    "------------------------------------------------------------------------------" skip
    "Портфель                     Всего ОД            ОД, проср. от 15 дн % резерва"  skip
    "------------------------------------------------------------------------------" skip
    "Однородные Метрокредит      " s-full_od[1] format "-zzz,zzz,zzz,zz9.99" no-label s-pr_od[1] format "-zzz,zzz,zzz,zz9.99" no-label v-rezprc[1] format "-z,zz9.99" no-label skip
    "Однородные Сотрудники       " s-full_od[2] format "-zzz,zzz,zzz,zz9.99" no-label s-pr_od[2] format "-zzz,zzz,zzz,zz9.99" no-label v-rezprc[2] format "-z,zz9.99" no-label skip
    "Ипотечные займы             " s-full_od[3] format "-zzz,zzz,zzz,zz9.99" no-label s-pr_od[3] format "-zzz,zzz,zzz,zz9.99" no-label v-rezprc[3] format "-z,zz9.99" no-label skip
    "Потребительские обеспеченные" s-full_od[4] format "-zzz,zzz,zzz,zz9.99" no-label s-pr_od[4] format "-zzz,zzz,zzz,zz9.99" no-label v-rezprc[4] format "-z,zz9.99" no-label skip
    "Факторинг, овердрафт        " s-full_od[5] format "-zzz,zzz,zzz,zz9.99" no-label s-pr_od[5] format "-zzz,zzz,zzz,zz9.99" no-label v-rezprc[5] format "-z,zz9.99" no-label skip
    "Астана-бонус                " s-full_od[6] format "-zzz,zzz,zzz,zz9.99" no-label s-pr_od[6] format "-zzz,zzz,zzz,zz9.99" no-label v-rezprc[6] format "-z,zz9.99" no-label skip
    "------------------------------------------------------------------------------" skip(1)
    v-ja label " Проставить ставку по филиалам?" skip(1)
with centered width 80 row 5 side-labels.

v-ja = no.
message "Произвести расчет % резерва по портфелям однородных кредитов?" update v-ja.
if not v-ja then return.

def var s-maindt as date no-undo.
def new shared var add_pr as integer no-undo.
def var i as integer no-undo.
def var j as integer no-undo.
def var n as integer no-undo.

i = month(g-today).
j = year(g-today).
i = i + 1.
if i = 13 then do: i = 1. j = j + 1. end.
s-maindt = date(i,1,j) - 1.
update s-maindt label "Дата опер. дня запуска боевой классификации" format "99/99/9999"
    with centered row 13 frame frdat.
hide frame frdat.

add_pr = s-maindt - g-today.

for each comm.txb where comm.txb.consolid no-lock:
    if connected ("txb") then disconnect "txb".
    connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
    run lnodnor2.
end.
if connected ("txb") then disconnect "txb".

/*
v-rezprc[1] = round((s-pr_od[1] + s-pr_prc[1]) / (s-full_od[1] + s-full_prc[1]) * 100,2).
v-rezprc[2] = round((s-pr_od[2] + s-pr_prc[2]) / (s-full_od[2] + s-full_prc[2]) * 100,2).
*/

do n = 1 to 6:
    if s-full_od[n] = 0 then v-rezprc[n] = 0.
    else v-rezprc[n] = round(s-pr_od[n] / s-full_od[n] * 100,2).
end.

v-ja = no.
displ s-full_od[1] s-pr_od[1] v-rezprc[1] s-full_od[2] s-pr_od[2] v-rezprc[2]
s-full_od[3] s-pr_od[3] v-rezprc[3] s-full_od[4] s-pr_od[4] v-rezprc[4]
s-full_od[5] s-pr_od[5] v-rezprc[5] s-full_od[6] s-pr_od[6] v-rezprc[6]
v-ja with frame fr.
update v-ja with frame fr.

if v-ja then do:
    for each comm.txb where comm.txb.consolid no-lock:
        if connected ("txb") then disconnect "txb".
        connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
        run lnodnor3.
    end.
    if connected ("txb") then disconnect "txb".
    message "Ставка проставлена!" view-as alert-box.
end.


