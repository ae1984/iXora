/* vcrepk14.i
 * MODULE
        Название Программного Модуля
        Валютный контроль
 * DESCRIPTION
        Назначение программы, описание процедур и функций
           Тело выдачи Приложения 14
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
	 14.01.2003 nadejda - вырезан кусок из vcrepk14.p
	 24.05.2003 nadejda - убраны параметры -H -S из коннекта 
         06.07.2004 saltanat - добавлена глоб. переменная v-contrtype для вызова процедуры: vcrep14out.p, vcrep14dat.i
         04.11.2004 saltanat - вместо shared v-contrtype сделала input parameter p-contrtype 
         30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
*/



{comm-txb.i}

def new shared var v-god as integer format "9999".
def new shared var v-month as integer format "99".
def new shared var v-dtb as date.
def new shared var v-dte as date.
def new shared var s-vcourbank as char.
def new shared var v-dtcurs as date.
def new shared var v-cursusd as deci.


def var v-i as integer.

def new shared temp-table t-docs 
  field kodstr as integer init 0
  field e-all as deci extent 30
  field i-all as deci extent 30.

s-vcourbank = comm-txb().

{vc-defdt.i}

update skip(1) 
   v-month label "     Месяц " skip 
   v-god label   "       Год " skip(1) 
   with side-label centered row 5 title " ВВЕДИТЕ ПЕРИОД ОТЧЕТА : ".

message "  Формируется отчет...".

do v-i = 1 to 14:
  create t-docs.
  t-docs.kodstr = v-i.
end.

/* найти курс USD на отчетную дату */
v-dtcurs = v-dte + 1.
find last ncrchis where ncrchis.crc = 2 and ncrchis.rdt <= v-dtcurs no-lock no-error. 
v-cursusd = ncrchis.rate[1].

/* коннект к нужному банку */
if connected ("ast") then disconnect "ast".
for each txb where txb.consolid = true no-lock:
  connect value("-db " + txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld ast -U " + txb.login + " -P " + txb.password). 
  run vcrep14dat (txb.bank, 0, '1,5').
  disconnect "ast".
end.

if g-fname = "vcrepk14" then
  run vcrep14out ("vcrep14.htm", false, "", false, "", '1,5').
else
  run vcrep14msg.p.

pause 0.


