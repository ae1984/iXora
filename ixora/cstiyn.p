/* cstiyn.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        31/12/99 pragma
 * BASES
        BANK COMM
 * CHANGES
                05/09/2012 Luiza  - изменила формирование param для транзакции
                            В случае округления в большую сторону Дт – 286010  Кт – 100500
                            В случае округления в меньшую сторону Дт – 100500  Кт – 186010
                06/09/2012 Luiza  - изменила формирование param для транзакции
                            В случае округления в большую сторону Дт – 100500  Кт – 286010
                            В случае округления в меньшую сторону Дт – 186010  Кт – 100500

*/

/*--------------------------------------------------------*/
/*                                                        */
/* Создает транзакции по всем тенговым операциям кассира  */
/* за текущий день, беря разницу в тиынах из кредитовой   */
/* части операции (ARP - kacca, kacca - ARP)              */
/*--------------------------------------------------------*/
{global.i}
{yes-no.i}
{keyord.i} /*Переход на новые и старые форматы ордеров*/

def var v-nomer like cslist.nomer no-undo.

define var v-dat as date label "ДАТА   ".

define variable v-tiyn   as decimal.               /* credit */
define variable crdec1  as decimal.

define variable drdec   as logical.
define variable prdec   as logical.
define variable yesno   as logical.

define variable mygl    as integer.                /*для подстановки значений*/
define variable myarp   as character.              /*из переменных 904car,dar*/

define variable vdel    as character initial "^".
define variable rcode   as integer.
define variable rdes    as character.
define variable vparam  as character.

define variable cgl     as integer.
define variable s-jh    as integer.
define variable v-arp    as character.
define variable darp    as character.
define variable carp    as character.

define variable dsum         as decimal init 0.0.
define variable csum         as decimal init 0.0.
define variable v-sumarp     as decimal init 0.0.
function GetCashOfc returns deci (input v-crc as int, input g-ofc as char, input dt as date).
   find first cashofc where cashofc.whn = dt and cashofc.ofc  = g-ofc and cashofc.sts = 2 and cashofc.crc = v-crc no-lock no-error.
   if avail cashofc then do:
      return cashofc.amt.
   end.
   else return 0.
end function.

find first ofc where ofc.ofc = g-ofc no-lock no-error.
find first csofc where csofc.ofc = g-ofc no-lock no-error.
if available csofc then v-nomer = csofc.nomer.
else do:
        message "Нет привязки к ЭК!" view-as alert-box error.
        return.
end.

/* Проверка - существуют ли шаблоны VNB 0086 */
find trxtmpl where trxtmpl.code eq "VNB0086" no-lock no-error.
if not avail trxtmpl
then do:
        message "Шаблон транзакции VNBN0086 не найден!".
        pause.
        return.
end.

/* Поиск констант - номеров счетов в SYSC */
find sysc where sysc.sysc eq "904car" no-lock no-error.
if not avail sysc
then do:
        message "В системном настроечном файле не найдена переменная 904car".
        pause.
        return.
end.
carp = trim (sysc.chval).
find sysc where sysc.sysc eq "904dar" no-lock no-error.
if not avail sysc
then do:
        message "В системном настроечном файле не найдена переменная 904dar".
        pause.
        return.
end.
darp = trim (sysc.chval).
v-sumarp = GetCashOfc(1,g-ofc,g-today).
run frac(ABSOLUTE (v-sumarp), output v-tiyn).
if v-tiyn = 0.00 then do:
    message "К УРЕГУЛИРОВАНИЮ = 0 ТИЫН. ПЕРЕВОД НЕ СОВЕРШЕН!" view-as alert-box error.
    return.
end.
v-arp = ''.
for each arp where arp.gl = 100500 and arp.crc = 1 no-lock.
    find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "arptype" and sub-cod.acc = arp.arp and sub-cod.ccode = v-nomer no-lock no-error.
    if avail sub-cod then v-arp = arp.arp.
end.
if v-arp = '' then do:
    message "Не настроен счет ЭК " + v-nomer + " в валюте KZT!" view-as alert-box title " ОШИБКА ! ".
    return.
end.
s-jh = 0.
if v-tiyn < 0.5 then do:
     vparam = string (v-tiyn) + vdel + "1" + vdel + darp
               + vdel + v-arp + vdel + "Урегулирование кассы 100500(" + ofc.name + ")".
     run trxgen ("VNB0086", vdel, vparam, "", "", output rcode, output rdes, input-output s-jh).

     if rcode ne 0 then
     do:
        message rcode rdes.
        return.
     end.
     csum = v-tiyn.
    message "Урегулирование завершено, номер транзакции " + string(s-jh) view-as alert-box.
end.
else do:
     vparam = string (1 - v-tiyn) + vdel + "1" + vdel + v-arp
               + vdel + carp + vdel + "Урегулирование кассы 100500(" + ofc.name + ")".
     run trxgen ("VNB0086", vdel, vparam, "", "", output rcode, output rdes, input-output s-jh).

     if rcode ne 0 then
     do:
        message rcode rdes.
        return.
     end.
     dsum = (1 - v-tiyn).
    message "Урегулирование завершено, номер транзакции " + string(s-jh) view-as alert-box.
end.

run trxsts (input s-jh, input 6, output rcode, output rdes).
if rcode ne 0 then do:
    message rdes.
    undo, return.
end.


/* Добавим запись в CASHOFC */
find cashofc where cashofc.whn eq g-today and
                cashofc.ofc eq g-ofc and
                cashofc.crc eq 1 and
                cashofc.sts eq 2
                no-error.
if avail cashofc then cashofc.amt = cashofc.amt + dsum - csum.
else do:
        create cashofc.
        cashofc.whn = g-today.
        cashofc.ofc = g-ofc.
        cashofc.who = g-ofc.
        cashofc.crc = 1.
        cashofc.sts = 2.
        cashofc.amt = cashofc.amt + dsum - csum.
end.

pause 0.


