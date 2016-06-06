/* vcrequest.f
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Форма документа по контракту
 * RUN
        верхнее меню контракта
 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        15-1
 * AUTHOR
        19.01.2011 aigul - на основе vcdndocs
 * BASES
        BANK COMM
 * CHANGES
        20.01.2011 aigul - записала в поля vcdocs.info[1] - Наименование УБ
                           vcdocs.info[2] - номер запроса (внутренний)
                           vcdocs.info[3] - кому (должность, ФИО)
                           vcdocs.info[4] - подписано от банка (должность, ФИО)
                           vcdocs.info[5] - телефон исполнителя
        24.02.2011 aigul - увеличила поля Уб и должности
*/


def shared var s-avail03 as logical.

def var v-dntypename as char.
def var v-to as char.
def var v-to2 as char.

def var v-to1 as char.

def var v-from as char.
def var v-from2 as char.

def var v-from1 as char.


def var v-ub as char.
def var v-ub1 as char.
def var v-ub2 as char.


def buffer b-vcdocs for vcdocs.
def var msg-err as char.

{vc-crosscurs.i}

function chk-forms return logical(p-dntype as char, p-forms as char).
def var l as logical init false.
  if lookup(p-dntype,'28,29') > 0 then do:
     find current vccontrs no-lock.
     if lookup(p-forms, vccontrs.ctformrs) > 0 then l = true.
  end.
  else l = true.
  return l.
end.

function chk-dntype returns logical (p-str as char).
  if p-str = "" then do:
    msg-err = " Введите тип документа!".
    return false.
  end.
  if not can-find(codfr where codfr.codfr = "vcdoc" and codfr.code = p-str and
      codfr.code <> "msc" and
      (lookup(p-str, s-vcdoctypes) > 0 and lookup(p-str,'28,29') > 0) no-lock) then do:
    msg-err = " Недопустимый тип документа!".
    return false.
  end.
  return true.
end.

function chk-dnnum returns logical (p-str as char).
  if p-str = "" then do:
    msg-err = " Введите номер запроса!".
    return false.
  end.
  if can-find(b-vcdocs where b-vcdocs.contract = s-contract and
         b-vcdocs.dntype = vcdocs.dntype and b-vcdocs.dnnum = p-str and
         b-vcdocs.dndate = vcdocs.dndate and b-vcdocs.docs <> vcdocs.docs no-lock) then do:
    msg-err = " Уже есть запрос с таким номером и датой!".
    return false.
  end.
  return true.
end.

form
  vcdocs.dntype colon 31 format "xx" validate(chk-dntype(vcdocs.dntype), msg-err)
  v-dntypename format "x(15)" no-label
  vcdocs.dnnum colon 31 format "x(31)" label "НОМЕР ЗАПРОСА" validate(chk-dnnum(vcdocs.dnnum), msg-err) skip
  vcdocs.dndate colon 31
  v-ub colon 31 format "x(31)" label "Наименование УБ" skip
  v-ub1 colon 31 format "x(31)" label "" skip
  v-ub2 colon 31 format "x(31)" label "" skip
  vcdocs.info[2] colon 31 format "x(31)" label "Номер запроса внутренний" skip
  v-to colon 31 format "x(31)" label "Кому - Должность" skip
  v-to2 colon 31 format "x(31)" label "" skip
  v-to1 colon 31 format "x(31)" label 'ФИО' skip
  v-from colon 31 format "x(31)" label "Подписано от банка - Должность" skip
  v-from2 colon 31 format "x(31)" label "" skip
  v-from1 colon 31 format "x(31)" label "ФИО" skip
  vcdocs.info[5] colon 31 format "x(31)" label "Телефон исполнителя" skip
  with row 4 width 66 overlay side-label title "КОНТРАКТ : " + v-contrnum frame vcrequest.

{vc-summf.i}

