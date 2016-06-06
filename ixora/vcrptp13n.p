/* vcrptp13n.p
 * MODULE
        Валютный контроль 
 * DESCRIPTION
        Приложение 13 - Отчет о движении средств
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        10.4.1.12
 * AUTHOR
        10.02.06 u00600
 * CHANGES
        06/06/2006 u00600 - добавила поле rmztmp_ncrcK в таблицу rmztmp
        30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам         
*/


{vc.i}
{global.i}
{comm-txb.i}

def input parameter p-bank as char.
def input parameter p-depart as integer.

def new shared var s-vcourbank as char.
def new shared var v-god as integer format "9999".
def new shared var v-month as integer format "99".
def new shared var v-dtb as date.
def new shared var v-dte as date.

def var v-name as char no-undo.
def var v-depname as char no-undo.
def var vi as integer no-undo.

def new shared temp-table rmztmp 
    field rmztmp_name   as char      /* отправитель */
    field rmztmp_bn     as char      /* бенефициар */
    field rmztmp_dt     as date format "99/99/9999"     /* дата платежа */
    field rmztmp_ncrc   as char      /* валюта платежа */
    field rmztmp_ncrcK  as integer    /* код валюты платежа */
    field rmztmp_summ   as deci      /* сумма платежа */
    field rmztmp_knp    as char      /* назначение платежа */
    field rmztmp_rnn    as char
    field rmztmp_str    as char
    field rmztmp_pr1    as char      /* примечание */
    field rmztmp_pr2    as char
    field rmztmp_pr3    as char
    field rmztmp_pr4    as char
    field rmztmp_pr5    as char.

s-vcourbank = comm-txb().

v-god = year(g-today).
v-month = month(g-today).
if v-month = 1 then do:
  v-month = 12.
  v-god = v-god - 1.
end.
else v-month = v-month - 1.

update skip(1) 
   v-month label "     Месяц " skip 
   v-god label   "       Год " skip(1) 
   with side-label centered row 5 title " ВВЕДИТЕ ПЕРИОД ОТЧЕТА : ".

message "  Формируется отчет...".

v-dtb = date(v-month, 1, v-god).

case v-month:
  when 1 or when 3 or when 5 or when 7 or when 8 or when 10 or when 12 then vi = 31.
  when 4 or when 6 or when 9 or when 11 then vi = 30.
  when 2 then do:
    if v-god mod 4 = 0 then vi = 29.
    else vi = 28.
  end.
end case.
v-dte = date(v-month, vi, v-god).

if p-bank = "all" then p-depart = 0.

{get-dep.i}
if p-depart <> 0 then do:
  p-depart = get-dep(g-ofc, g-today).
  find ppoint where ppoint.depart = p-depart no-lock no-error.
  v-depname = ppoint.name.
end.
v-name = "".

/* коннект к нужному банку */
if connected ("txb") then disconnect "txb".
for each txb where txb.consolid = true and (p-bank = "all" or (txb.bank = s-vcourbank)) no-lock:
  connect value(" -db " + txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld txb -U " + txb.login + " -P " + txb.password). 
  run vcrpt13ndat.p (txb.bank, p-depart).
  if p-bank <> "all" then v-name = txb.name.
  disconnect "txb".
end.

hide message no-pause.

def var v-reptype as integer init 1.

if p-bank = "all" then do:
  DEF BUTTON but-htm LABEL "    Просмотр отчета    ".
  DEF BUTTON but-msg LABEL "  Файл для статистики  ".

  def frame butframe
    skip(1) 
    but-htm skip 
    but-msg skip(1) 
  with centered row 6 title "ВЫБЕРИТЕ ВАРИАНТ ОТЧЕТА:".

  ON CHOOSE OF but-htm, but-msg do:
    case self:label :
      when "Просмотр отчета" then v-reptype = 1.
      when "Файл для статистики" then v-reptype = 2.
    end case.
  END.
  enable all with frame butframe.

  WAIT-FOR CHOOSE OF but-htm, but-msg.
  hide frame butframe no-pause.
end.

if v-reptype = 1 then
  run vcrpt13nout.p ("vcrep13n.htm", (p-bank <> "all"), v-name, (p-depart <> 0), v-depname, true).
else
  run vcrpt13nout.p ("vcrep13n.htm", false, "", false, "", false).

pause 0.

