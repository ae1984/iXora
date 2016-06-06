/* pkbdcrdm.p
 * MODULE
        Потребкредиты
 * DESCRIPTION
        Определение вида карты и кредитного лимиты по анкете БД
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
        11/09/2006 madiyar
 * BASES
        bank, comm, cards
 * CHANGES
*/

{global.i}
{pk.i}

if s-pkankln = 0 then return.

find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.ln = s-pkankln no-lock no-error.
if not avail pkanketa then do:
  message skip " Анкета N" s-pkankln "не найдена !" skip(1) view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

if pkanketa.sts <> '50' and pkanketa.sts <> '99' then do:
  message " Некорректный статус! " view-as alert-box error.
  return.
end.

def var v-crd as char no-undo.
def var v-crdlim as deci no-undo.
def var v-rem as char no-undo.
def var v-socrat as integer no-undo.
def var v-age as integer no-undo.
/*def var v-ankhis as integer no-undo.*/
def buffer b-pkanketa for pkanketa.

def var v-respr as integer no-undo.
def var v-numpr as integer no-undo.
def var v-maxpr as integer no-undo.
def var v-lnlast as integer no-undo.
def var v-allowed as integer no-undo.
def var crcard as logical no-undo.

define frame frres
  skip(1)
  v-crd format "x(40)" label " Вид карты" skip
  v-crdlim format ">>>,>>>,>>9.99" label " Кред. лимит" skip
  v-rem format "x(50)" label " Замеч." skip(1)
  with side-labels centered overlay row 7 title " Карта ".

/* выкидываем сотрудников */
find first cif where cif.cif = pkanketa.cif no-lock no-error.
if not avail cif or cif.mname = "EMP" then do:
  v-crd = " - ".
  v-crdlim = 0.
  v-rem = "Клиент не найден или является сотрудником банка".
  displ v-crd v-crdlim v-rem with frame frres.
  pause.
  return.
end.

/*
v-ankhis = -1.
for each b-pkanketa where b-pkanketa.bank = s-ourbank and b-pkanketa.rnn = pkanketa.rnn no-lock:
  if b-pkanketa.ln = s-pkankln then next.
  if b-pkanketa.sts = '99' and b-pkanketa.lon <> '' then do:
    find first lon where lon.lon = b-pkanketa.lon no-lock no-error.
    if avail lon and lon.opnamt > 0 then do:
      if v-ankhis < b-pkanketa.ln then v-ankhis = b-pkanketa.ln.
    end.
  end.
end.
*/

run pkdiscount(pkanketa.rnn, pkanketa.ln, no, output v-respr, output v-numpr, output v-maxpr, output v-lnlast).
if v-lnlast > 0 then do:
    if v-maxpr > 20 then v-allowed = 0.
    else
    if v-maxpr > 15 then v-allowed = 1.
    else
    if v-maxpr > 10 then v-allowed = 2.
    else
    if v-maxpr > 5 then v-allowed = 3.
    else v-allowed = 1000.
    
    if v-numpr > v-allowed then do:
        v-crd = " - ".
        v-crdlim = 0.
        v-rem = "Просрочки (Кол-во=" + string(v-numpr) + " МаксПр=" + string(v-maxpr) + ")".
        displ v-crd v-crdlim v-rem with frame frres.
        pause.
        return.
    end.
end.

/* если у клиента уже есть кредитная карта - пропускаем */
crcard = no.
for each card_status where card_status.rnn = pkanketa.rnn no-lock:
    if card_status.scheme_name matches "Cr*" and not(card_status.name matches "*Clos*") then do: crcard = yes. leave. end.
end.
if crcard = yes then do:
    v-crd = " - ".
    v-crdlim = 0.
    v-rem = "Клиент имеет кредитную карту".
    displ v-crd v-crdlim v-rem with frame frres.
    pause.
    return.
end.

/* определение вида карты */
v-socrat = 1. /* +1 за наличие кредита БД */

find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'bdt' no-lock no-error.
if avail pkanketh then do:
  v-age = (today - date(pkanketh.value1)) / 365.
  for each bookcod where bookcod.bookcod = "pkankag1" no-lock:
     if entry(3,bookcod.name," ") = "..." then do:
       if v-age >= integer(entry(1,bookcod.name," ")) then do:
         v-socrat = v-socrat + integer(bookcod.info[2]).
         leave.
       end.
     end.
     else do:
       if v-age >= integer(entry(1,bookcod.name," ")) and v-age <= integer(entry(3,bookcod.name," ")) then do:
         v-socrat = v-socrat + integer(bookcod.info[2]).
         leave.
       end.
     end.
  end.
end.

find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'drivenum' no-lock no-error.
if avail pkanketh and trim(pkanketh.value1) <> '' then v-socrat = v-socrat + 1.

find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'jobp' no-lock no-error.
if avail pkanketh and trim(pkanketh.value1) <> '' then do:
  find first bookcod where bookcod.bookcod = "pkankor1" and bookcod.code = trim(pkanketh.value1) no-lock no-error.
  if avail bookcod then v-socrat = v-socrat + integer(bookcod.info[2]).
end.

find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'jobs' no-lock no-error.
if avail pkanketh and trim(pkanketh.value1) <> '' then do:
  find first bookcod where bookcod.bookcod = "pkankkt1" and bookcod.code = trim(pkanketh.value1) no-lock no-error.
  if avail bookcod then v-socrat = v-socrat + integer(bookcod.info[2]).
end.

find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'jobt' no-lock no-error.
if avail pkanketh and trim(pkanketh.value1) <> '' then do:
  find first bookcod where bookcod.bookcod = "pkankwr1" and bookcod.code = trim(pkanketh.value1) no-lock no-error.
  if avail bookcod then v-socrat = v-socrat + integer(bookcod.info[2]).
end.

find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'nedvstreet' no-lock no-error.
if avail pkanketh and trim(pkanketh.value1) <> '' then v-socrat = v-socrat + 3.

find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'autoage' no-lock no-error.
if avail pkanketh and trim(pkanketh.value1) <> '' then do:
  find first bookcod where bookcod.bookcod = "pkankav1" and bookcod.code = trim(pkanketh.value1) no-lock no-error.
  if avail bookcod then v-socrat = v-socrat + integer(bookcod.info[2]).
end.

find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'ak31' no-lock no-error.
if avail pkanketh and trim(pkanketh.value1) <> '' then v-socrat = v-socrat + 2.

find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'ak32' no-lock no-error.
if avail pkanketh and trim(pkanketh.value1) <> '' then v-socrat = v-socrat + 1.

find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'ak33' no-lock no-error.
if avail pkanketh and trim(pkanketh.value1) <> '' then v-socrat = v-socrat + 2.

find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'acc1' no-lock no-error.
if avail pkanketh and trim(pkanketh.value1) <> '' then v-socrat = v-socrat + 1.

find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'acc2' no-lock no-error.
if avail pkanketh and trim(pkanketh.value1) <> '' then v-socrat = v-socrat + 1.

find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = 'almadolg' no-lock no-error.
if avail pkanketh and pkanketh.rating = 2 then v-socrat = v-socrat + 1.

if v-socrat >= 24 then v-crd = "VISA Gold".
else
if v-socrat >= 17 and v-socrat < 24 then v-crd = "VISA Classic".
else
if v-socrat >= 3 and v-socrat < 17 then v-crd = "VISA Electron/PLUS".

/* определение вида карты - end */

/* кредитный лимит */
v-crdlim = pkanketa.summa * 1.1.
v-rem = "".
displ v-crd v-crdlim v-rem with frame frres.
pause.



