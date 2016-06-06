/* cifcod.f
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

/*   cifcod.f
   1.10.2002 nadejda - введено поле Форма собств - cif.prefix
   25.06.2003 nadejda - добавлено поле "категория клиента"
   11.04.2011 dmitriy -  убрал DBA, добавил Дата рождения ИП.
*/

def new shared var vpoint like point.point label "ПУНКТ".
def new shared var vdep like ppoint.dep label "ДЕПАРТАМЕНТ".
def var pname like point.name.
def var dname like ppoint.name.
DEF VAR APKAL1 as char format "x(8)".
DEF VAR APKAL2 as char format "x(8)".
def var regis1 as char format "x(60)".
def var regis2 as char format "x(60)".
def var msg-err as char.


function chk-prefix returns logical (p-value as char).
  if p-value = "" then do:
    message skip "Вы уверены, что у данного клиента ОТСУТСТВУЕТ организац.-правовая форма?" skip(1)
      view-as alert-box button yes-no title " ВНИМАНИЕ! " update v-ch as logical.
    if not v-ch then
      msg-err = "Введите организационно-правовую форму юридического лица !".
    return v-ch.
  end.
  if not can-find(codfr where codfr.codfr = "ownform" and codfr.code = p-value and
        codfr.code <> "msc" no-lock) then do:
    message skip
         " Введенное краткое название организационно-правовой формы " skip
         " НЕ НАЙДЕНО В СПРАВОЧНИКЕ !" skip(1)
         " Добавить в справочник новое значение ? " skip(1)
         view-as alert-box button yes-no title " ВНИМАНИЕ ! " update v-choice as logical.
    if v-choice then do:
      create codfr.
      codfr.codfr = "ownform".
      codfr.level = 1.
      codfr.code = p-value.
      codfr.tree-node  = "ownform" + caps(codfr.code).
      return true.
    end.
    else do:
      msg-err = "Нет такого кода в справочнике организационно-правовых форм !".
      return false.
    end.
  end.
  return true.
end.

form
cif.cif   label "КОД КЛИЕНТА  " colon 14
        cif.type colon 30 label "ТИП "
        cif.mname colon 40 label "КАТЕГ "
          help " Категория клиента (F2 - справочник)"
/*          validate (can-find(bookcod where bookcod.bookcod = "clnkateg" and bookcod.code = cif.mname no-lock), " Код категории клиента не найден !")*/
        cif.regdt colon 62 label "ДАТА РЕГ" format "99/99/9999" skip
vpoint format ">>9" colon 14
        pname format "x(25)" no-label
        cif.ofc colon 62     label "ЗАРЕГИСТР" skip
vdep format ">>9" colon 14
        dname format "x(25)" no-label
        cif.pres format "x(3)" label "ЛЬГОТА" colon 57
                  help " Вид льготного обслуживания клиента (F2 - справочник)"
                  validate(cif.pres = "" or (cif.pres <> "msc" and can-find(codfr where codfr.codfr = "clnlgot" and codfr.code = cif.pres no-lock)), " Вид льготного обслуживания не найден!")
        cif.legal colon 62 no-label format "x(15)"  skip
cif.prefix  label "ФОРМА СОБСТВ." FORMAT "x(20)" help " F2 - справочник организационно-правовых форм "
     validate(chk-prefix(cif.prefix), msg-err) colon 14
cif.cust-since colon 65 label "КОЛИЧ.СОТРУДНИКОВ" format ">>>>>>9"
     validate(cif.cust-since > 0, "Укажите количество сотрудников в организации!") skip
regis1     label 'ПОЛНОЕ------ ' FORMAT "x(60)" colon 14 skip
regis2     label 'НАИМЕНОВАНИЕ ' format "x(60)" colon 14 skip
wcif.sname LABEL 'КОРОТКОЕ НАИМ' colon 14 skip
wcif.addr[1] format "x(30)" LABEL '     AДРЕС-1 ' colon 14 skip
wcif.addr[2] format "x(30)" LABEL '     AДРЕС-2 ' colon 14
cif.whn         label 'ДАТА  ' COLON 65 format "99/99/9999" skip
wcif.addr[3] format "x(30)" LABEL '     AДРЕС-3 ' colon 14
cif.who         LABEL 'ПРАВИЛ' COLON 65 skip
wcif.coregdt   LABEL 'ДАТА РОЖД. ИП' colon 14 skip
wcif.pss     LABEL 'ИДЕНT. KAРТА 'colon 14
cif.geo     LABEL 'ГЕО-КОД  ' COLON 65 skip
wcif.tel   LABEL '   ТЕЛЕФОН-1 ' format "x(15)" colon 14
cif.cgr     LABEL '    ГРУППА' COLON 65 skip
wcif.tlx     LABEL '   ТЕЛЕФОН-2 ' format "x(15)" colon 14
apkal1     LABEL '   ОБСЛУЖ.' COLON 65 skip
wcif.fax       LABEL '       ФАКС  ' format "x(15)" COLON 14
apkal2       LABEL '   ОБСЛУЖ.' COLON 65 skip
wcif.attn label    ' ВНИМАНИЕ!!! '  format "x(30)" colon 14
cif.stn   label 'СТАТУС ' colon 65 skip
with side-label row 3 width 80 frame cifcod.
