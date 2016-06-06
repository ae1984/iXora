/* vcrepk13.i
 * MODULE
        Название Программного Модуля
        Валютный контроль 
 * DESCRIPTION
        Назначение программы, описание процедур и функций
        Приложение 13
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
	20.03.2003 nadejda - перенесен кусок из vcrepk13.p
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
def var v-depart as integer.
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
for each txb where txb.consolid = true  and ({&bank} = "all" or (txb.bank = s-vcourbank))no-lock:
  connect value("-db " + txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld ast -U " + txb.login + " -P " + txb.password). 
  run vcrep13dat(txb.bank, v-depart).
  if {&bank} <> "all" then v-name = txb.name.
                      else v-name = "". 
  disconnect "ast".
end.

hide message no-pause.

def var v-reptype as integer init 1.

if {&bank} = "all" then do:
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
  run vcrep13out ("vcrep13.htm", ({&bank} <> "all"), v-name, {&depart} <> 0, v-depname, true).
else
  run vcrep13out ("vcrep13.htm", false, "", false, "", false).

pause 0.



