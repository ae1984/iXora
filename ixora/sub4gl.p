/* sub4gl.p
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

/* sub4gl.p
   Список счетов по заданному сабледжеру и счету ГК с остатками - попадающие в период хоть как-нибудь

   18.02.2003 nadejda
*/

{mainhead.i REPBYGL}
{name2sort.i}

def var v-sub as char.
def var v-gl like gl.gl.
def var v-gllev1 like gl.gl.
def var v-dtb as date.
def var v-dte as date.

update skip(1) v-gl  label "       СЧЕТ Г/К"
       skip
       v-dtb label " НАЧАЛЬНАЯ ДАТА"
       skip
       v-dte label "  КОНЕЧНАЯ ДАТА" skip(1)
  with centered side-label row 4 title " ПАРАМЕТРЫ ОТЧЕТА " frame f-param.


find gl where gl.gl = v-gl no-lock no-error.
if gl.sub = "" then do:
  message "no sub!" view-as alert-box button ok.
  return.
end.

v-sub = gl.sub.
   
if gl.lev = 1 then v-gllev1 = v-gl.
else do:
  find trxlevgl where trxlevgl.glr = gl.gl and trxlevgl.lev = gl.lev no-lock no-error.
  v-gllev1 = trxlevgl.gl.
end.

def temp-table t-accs
  field acc as char format "x(10)" label "СЧЕТ"
  field cif as char format "x(6)" label "КОД КЛ"
  field name as char format "x(50)" label "НАИМЕНОВАНИЕ"
  field namesort as char format "x(40)" label ""
  field rnn as char format "x(12)" label "РНН"
  field gl like gl.gl format "999999" label "СЧЕТ Г/К"
  field rdt as date format "99/99/9999" label "ДАТА НАЧ"
  field expdt as date format "99/99/9999" label "ДАТА КОНЕЧ"
  field crccode as char format "x(3)" label "ВАЛЮТА"
  field rate as decimal format ">>>,>>9.99" label "%СТАВКА"
  field type as char format "x(1)" label "ТИП КЛ"
  index main is primary namesort acc.

case v-sub:
when "cif" then do:
  for each aaa no-lock where aaa.gl = v-gllev1 and ((aaa.regdt <= v-dtb and aaa.expdt >= v-dtb) or 
       (aaa.regdt >= v-dtb and aaa.expdt <= v-dte) or
       (aaa.regdt <= v-dte and aaa.expdt >= v-dte)), 
      each cif where cif.cif = aaa.cif no-lock:

    create t-accs.
    assign t-accs.acc = aaa.aaa
           t-accs.cif = aaa.cif
           t-accs.gl = aaa.gl
           t-accs.rdt = aaa.regdt
           t-accs.expdt = aaa.expdt
           t-accs.rate = aaa.rate
           t-accs.rnn = cif.jss
           t-accs.type = caps(cif.type).

    t-accs.name = trim(trim(cif.prefix) + " " + trim(cif.name)).
    t-accs.namesort = name2sort(t-accs.name).

    find crc where crc.crc = aaa.crc no-lock no-error.
    t-accs.crccode = crc.code.
  end.
end.
end case.

output to sub4gl.txt.

find first cmp no-lock no-error.

put cmp.name "  " g-today " " g-ofc skip(1) 
    "СПИСОК СЧЕТОВ ПО СЧЕТУ Г/К" skip(1)
    "СЧЕТ Г/К : " v-gl " " gl.des skip
    "САБЛЕДЖЕР : " v-sub skip(1) 
    "С " v-dtb " ПО " v-dte skip(1).

for each t-accs :
  displ t-accs.cif t-accs.name t-accs.acc t-accs.type t-accs.rnn t-accs.crccode t-accs.rdt t-accs.expdt t-accs.rate with width 150.
end.

output close.

run menu-prt ("sub4gl.txt").

pause 0.

hide all no-pause.