/* vcrep14msg.p
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
 * CHANGES
*/

/* vcrep14msg.p Валютный контроль
   Сообщение МТ-104 - копируется в каталог на L:\CAPITAL

   14.01.2003 nadejda
*/

{vc.i}

{global.i}

def shared temp-table t-rep14
  field kodstr as integer
  field expsum as deci
  field expsumkzt as deci
  field impsum as deci
  field impsumkzt as deci
  index kodstr is primary unique kodstr.

def shared var v-god as integer format "9999".
def shared var v-month as integer format "99".
def shared var v-dtcurs as date.
def shared var v-cursusd as deci.
def var v-sum as deci.
def var i as integer.
def var v-kurname as char.
def var v-kurpos as char.
def var v-depname as char.
def var v-deppos as char.

def var v-mt104-r as integer.
def var v-mt104-crc as integer.
def var v-mt104-mp as char.


find vcparams where vcparams.parcode = "mt104-r" no-lock no-error.
if not avail vcparams then do:
  message skip " Не найден параметр mt104-r !"
          skip(1) view-as alert-box button ok title " ОШИБКА ! ".
  return.
end.
v-mt104-r = vcparams.valinte.

find vcparams where vcparams.parcode = "mt104-c" no-lock no-error.
if not avail vcparams then do:
  message skip " Не найден параметр mt104-c !"
          skip(1) view-as alert-box button ok title " ОШИБКА ! ".
  return.
end.
v-mt104-crc = vcparams.valinte.

find vcparams where vcparams.parcode = "mt104-mp" no-lock no-error.
if not avail vcparams then do:
  message skip " Не найден параметр mt104-mp !"
          skip(1) view-as alert-box button ok title " ОШИБКА ! ".
  return.
end.
v-mt104-mp = vcparams.valchar.


/* формирование телеграммы */

{vctstparam.i &msg = "104"}

function sum2str returns char (p-kod as integer, p-value as decimal).
  def var v-sumstr as char.
  if p-kod = 1 then v-sumstr = trim(string(integer(p-value), ">>>>>>>>>>>>>>9")).
  else do:
    if lookup(string(p-kod), v-mt104-mp) = 0 then v-sumstr = trim(string(p-value, ">>>>>>>>>>>>>>9.99")).
    else 
    if p-value >= 0 then v-sumstr = v-plus + trim(string(p-value, ">>>>>>>>>>>>>>9.99")).
                    else v-sumstr = v-minus + trim(string(- p-value, ">>>>>>>>>>>>>>9.99")).
  end.

  v-sumstr = replace(v-sumstr, ".", ",").
  return v-sumstr.
end.


v-text = "/REPORTDATE/" + string(v-month, "99") + string(v-god, "9999").
put stream rpt unformatted v-text skip.

find first cmp no-lock no-error.
v-text = "/BANKOKPO/" + trim(cmp.addr[3]).
put stream rpt unformatted v-text skip.

find ncrc where ncrc.crc = v-mt104-crc no-lock no-error.
v-text = "/UNIT/" + ncrc.code + string(v-mt104-r).
put stream rpt unformatted v-text skip.

for each t-rep14:
  put stream rpt unformatted 
      "/" + string(t-rep14.kodstr, "99") + "G/EXPORT/"
      /*if t-rep14.kodstr = 4 then "" else*/
      sum2str(t-rep14.kodstr, t-rep14.expsum) + "/" + sum2str(t-rep14.kodstr, t-rep14.expsumkzt) skip
      "//" + string(t-rep14.kodstr, "99") + "G/IMPORT/"
      /*if t-rep14.kodstr = 4 then "" else*/
      sum2str(t-rep14.kodstr, t-rep14.impsum) + "/" + sum2str(t-rep14.kodstr, t-rep14.impsumkzt) skip.
end.

{vctstend.i &msg = "104"}


