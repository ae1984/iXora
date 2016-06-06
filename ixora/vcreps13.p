/* vcreps13.p
 * MODULE
        Название Программного Модуля
        Валютный контроль 
 * DESCRIPTION
        Назначение программы, описание процедур и функций
   Приложение 13 - все платежи за месяц по контрактам, где есть рег. свид-ва - консолидированный
   выдача пойдет в Excel без некоторых полей

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
        04.11.2002 nadejda
 * CHANGES
 создан
	24.05.2003 nadejda - убраны параметры -H -S из коннекта 
        30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
*/

{mainhead.i VCREPK13}
{comm-txb.i}

def var v-ncrccod like ncrc.code.
def var v-sum like vcdocs.sum.
def new shared var v-god as integer format "9999".
def new shared var v-month as integer format "99".
def var v-name as char.
def new shared var s-vcourbank as char.

def new shared temp-table t-docs 
  field dndate like vcdocs.dndate
  field sum like vcdocs.sum
  field docs like vcdocs.docs
  field dnrslc like vcrslc.dnnum
  field name like cif.name
  field partner like vcpartners.name
  field knp like vcdocs.knp
  field codval as integer
  field ctnum like vccontrs.ctnum
  field ctdate like vccontrs.ctdate
  field rnn as char format "999999999999"
  field strsum as char
  index main is primary dndate sum docs.

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

/* коннект к нужному банку */
if connected ("ast") then disconnect "ast".
for each txb where txb.consolid = true no-lock:
  connect value(" -db " + txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld ast -U " + txb.login + " -P " + txb.password). 

  run vcrep13dat(txb.bank, 0).

  if connected ("ast") then disconnect "ast".
end.

run vcrep13out ("vcrep13.htm", false, "", false, "", false).

pause 0.


