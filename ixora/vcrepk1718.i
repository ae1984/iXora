/* vcrepk1718.i
 * MODULE
        Название Программного Модуля
        Валютный контроль
 * DESCRIPTION
        Назначение программы, описание процедур и функций
           Приложение 17, 18 - все платежи за месяц по контрактам по экспорту и/или импорту
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
   18.03.2003 nadejda - перенесен кусок из vcrepk17.p
   24.05.2003 nadejda - убраны параметры -H -S из коннекта 
        30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
*/



{comm-txb.i}

def var v-ncrccod like ncrc.code.
def var v-sum like vcdocs.sum.
def new shared var v-god as integer format "9999".
def new shared var v-month as integer format "99".
def var v-name as char.
def var v-depname as char.
def var i as integer.
def var v-depart as integer.
def new shared var s-vcourbank as char.

def new shared temp-table t-docs 
  field dndate as date
  field sum as decimal
  field payret as logical
  field docs as integer
  field cif as char
  field prefix as char
  field name as char
  field okpo as char
  field clnsts as char
  field ctnum as char
  field ctdate as date
  field cttype as char
  field partnprefix as char
  field partner as char
  field codval as char
  field info as char
  field strsum as char
  field bank as char
  field depart as char
  index main is primary cttype dndate payret sum docs.

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

{get-dep.i}
if {&depart} = 0 then do:
  v-depart = 0.
  v-depname = "".
end.
else do: 
  v-depart = get-dep(g-ofc, g-today).
  find ppoint where ppoint.depart = v-depart no-lock no-error.
  v-depname = ppoint.name.
end.


/* коннект к нужному банку */
if connected ("ast") then disconnect "ast".
for each txb where txb.consolid = true and ({&bank} = "all" or (txb.bank = s-vcourbank)) no-lock:
  connect value("-db " + txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld ast -U " + txb.login + " -P " + txb.password). 
  do i = 1 to num-entries("{&type}"):
    run vcrep1718dat (entry(i, "{&type}"), txb.bank, v-depart).
  end.
  if {&bank} <> "all" then v-name = txb.name.
                      else v-name = "". 
  disconnect "ast".
end.

hide message no-pause.


if "{&option}" = "rep" then
  run vcrep1718out (entry(1, "{&type}"), "vcrep1718" + entry(1, "{&type}") + ".htm", 
                    ({&bank} <> "all"), v-name, {&depart} <> 0, v-depname, true).
else
  run vcrep1718msg.

hide all no-pause.

pause 0.


