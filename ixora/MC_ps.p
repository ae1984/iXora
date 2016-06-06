/* MC_ps.p
 * MODULE
        Название модуля
 * DESCRIPTION
        процесс запускается в конце месяца весь остаток с ГК 2870 филиала садит на ГК доходов – 460828 в ЦО
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
        20.03.2012 aigul
 * BASES
        BANK COMM
 * CHANGES
        04.05.2012 aigul - добавила Bases
        27/08/2013 Luiza - ТЗ 2002 добавила проверку, что календарная дата равна операционной дате
*/

{global.i}
def var vv-sum as decimal.
def var v-arp as char.
def var v-rnn as char.
define var s-target as date.
define var s-bday as log.
def var v-weekbeg as int. /*первый день недели*/
def var v-weekend as int. /*последний день недели*/
def var v-tim as int.
def var v-sysc as logi.
def var v-chk-sum as decimal.
/**находим первый день недели***************************************************************/
find sysc where sysc.sysc = "WKSTRT" no-lock no-error.
if available sysc then v-weekbeg = sysc.inval.
else v-weekbeg = 2.
/*******************************************************************************************/
/**находим последний день недели************************************************************/
find sysc where sysc.sysc = "WKEND" no-lock no-error.
if available sysc then v-weekend = sysc.inval.
else v-weekend = 6.
/*******************************************************************************************/

s-target = g-today + 1.

/**проверяем праздничный ли день************************************************************/
repeat while month(g-today) = month(s-target):
        find hol where hol.hol eq s-target no-lock no-error.
        if not available hol and weekday(s-target) ge v-weekbeg and weekday(s-target) le v-weekend then
                leave. /*если день рабочий, то продолжаем закрытие опер. дня*/
        else
                s-target = s-target + 1. /*если день праздничный то переключаемся на следующий день, пока не найдем первый рабочий*/
end.
/*******************************************************************************************/
find hol where hol.hol = g-today no-lock no-error.
if not available hol and  weekday(g-today) ge v-weekbeg and  weekday(g-today) le v-weekend then s-bday = true.
else s-bday = false.
find first sysc where sysc.sysc = "MC" no-lock no-error.
if avail sysc then v-sysc = sysc.loval.
for each jl where jl.jdt = g-today and jl.gl = 287082 no-lock:
    if jl.rem[1] = "Комиссия за выпуск электронной цифровой подписи (ЭЦП)" and jl.sts = 5 then
    v-chk-sum = v-chk-sum + jl.cam.
end.
if s-bday eq true and month(g-today) ne month(s-target) and v-sysc = no and time >= 68400 and g-today = today then do:
    find first txb where txb.bank = "TXB00" no-lock no-error.
    if avail txb then v-rnn =  entry(1,txb.params).
    find first arp where arp.gl = 287082 no-lock no-error.
    if avail arp then do:
        vv-sum = arp.cam[1] - arp.dam[1].
        v-arp = arp.arp.
    end.
    vv-sum = vv-sum - v-chk-sum.
    if vv-sum > 0 then do:
        find first sysc where sysc.sysc = "MC" exclusive-lock no-error.
        if avail sysc then sysc.loval = yes.
        find first cmp no-lock no-error.
        run rmzcre ( 1,
                 vv-sum , /*summa*/
                 v-arp, /*send acc*/
                 cmp.addr[2], /*send RNN*/
                 cmp.name, /*send FIO*/
                 "TXB00", /*rec bank*/
                 "KZ93470142870A034400", /*rec acc*/
                 "АО 'МЕТРОКОМБАНК'", /*rec fio*/
                 v-rnn, /*rec rnn*/
                 "", /*kbk*/
                 no,
                 "840", /*KNP*/
                 "14", /*kod*/
                 "14", /*kbe*/
                 "Комиссия за выпуск электронной цифровой подписи", /*Назначение платежа*/
                 '1P'     ,
                 1,
                 5,
                 g-today ).
    end.
end.
