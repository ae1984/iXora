/* tdagetrate.p
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
      22/08/03 nataly изменен substring(pri.pri,3,2) to substring(pri.pri,5,2)
                                 then cpri = "^" + string(vpri,"x(3)") + string(highvalue,"99").
                                 else cpri = "^" + string(vpri,"x(3)") + string(highterm,"99").
      20.05.2004 nadejda - добавлен параметр - номер счета, по нему смотрится признак исключения:
                           если исключение, то возвращается просто ставка на счете aaa.rate
      21.06.2004 nadejda - обработка случая, когда передан пустой счет - чтобы вернуть ставку по группе независимо от счета
      23.05.2011 evseev - убрал исключение aaa.payfre = 1 для A22 A23 A24
      31.05.2011 evseev - убрал исключение aaa.payfre = 1 для 478,479,480,481,482,483,A01,A02,A03,A04,A05,A06,A19,A20,A21
*/

def input parameter vaaa as char.
def input parameter vpri as char format "x(3)".
def input parameter vterm as inte.
def input parameter vuntil as date.
def input parameter vamt like jl.dam.
def output parameter vrate like aaa.rate.

def var highamount like jl.dam initial 999999999.99.
def var lowlowvalue as inte initial 0.
def var lowvalue as inte initial 1.
def var highhighvalue as inte initial 100.
def var highvalue as inte initial 99.
def var highterm as inte.
def var lowterm as inte.
def var cpri as char.
def var v-inc as inte.
def var v-min like jl.dam.
def var v-max like jl.dam.

find first aaa where aaa.aaa = vaaa no-lock no-error.

if avail aaa and aaa.payfre = 1 then do:
  /* счет с исключением по % ставке */
  if lookup (aaa.lgr, '478,479,480,481,482,483,A01,A02,A03,A04,A05,A06,A19,A20,A21,A22,A23,A24') = 0 then do:
     vrate = aaa.rate.
     return.
  end.
end.

if vamt > highamount then vamt = highamount.
if vterm < lowvalue then vterm = lowvalue.
if vterm > highvalue then vterm = highvalue.

highterm = highhighvalue.

for each pri where pri.pri begins "^" + vpri no-lock group by pri.pri desc:
   lowterm = integer(substring(pri.pri,5,2)).
   if vterm > lowterm and vterm <= highterm then leave.
   highterm = lowterm.
end.
if lowterm  = lowlowvalue and highterm = highhighvalue then do:
   find last prih where prih.pri = pri.pri and prih.until = vuntil
                        no-lock no-error.
   if available prih then vrate = prih.rat.
   else vrate = pri.rate.
   return.
end.
else if highterm = highhighvalue
then cpri = "^" + string(vpri,"x(3)") + string(highvalue,"99").
else cpri = "^" + string(vpri,"x(3)") + string(highterm,"99").

find pri where pri.pri = cpri no-lock no-error.
if not available pri then  return.
find last prih where prih.pri = pri.pri and prih.until <= vuntil
                     no-lock no-error.
if available prih then do:
  repeat v-inc = 6 to 1 by -1:
     v-max = prih.tlimit[v-inc].
     if v-inc gt 1 then v-min = prih.tlimit[v-inc - 1].
     else v-min = 0.
     if vamt > v-min and vamt <= v-max then do:
        vrate = prih.trate[v-inc].
        leave.
     end.
  end.
end.
else do:
  repeat v-inc = 6 to 1 by -1:
     v-max = pri.tlimit[v-inc].
     if v-inc gt 1 then v-min = pri.tlimit[v-inc - 1].
     else v-min = 0.
     if vamt > v-min and vamt <= v-max then do:
        vrate = pri.trate[v-inc].
        leave.
     end.
  end.
end.


