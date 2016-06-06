/* cif.f
 * MODULE
        Клиентская база
 * DESCRIPTION
        Форма сведений о клиенте
 * RUN

 * CALLER
        cifedt.p, cifedtot.p, cifedtc.p, cifchk.p, s-cif.p, s-cifot.p, s-cifcod.p, s-cifchk.p, vccln.p, vcclns.p
 * SCRIPT

 * INHERIT

 * MENU
        1-1, 1-2, 1-11, 15-1
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        01.10.2002 nadejda - введено поле Форма собств - cif.prefix
        30.10.2002 nadejda - сделано добавление новой формы собственности в справочник прямо при проверке
        ...05.2003 nataly  - добавлены поля "дата рождения/регистрации", "место рег/должность"
        25.06.2003 nadejda - добавлено поле "категория клиента"
        05.08.2003 sasco - поменял местами поля в форме и снял комментарий на validate cif.mname
        03.06.2004 dpuchkov - добавил дату регистрации нерезидента
        18.06.2004 dpuchkov - убрал поле "обслуживает"
        25/02/2010  galina - расширила фрейм и поля адресов, добавила поле место рождения
        11.04.2011 dmitriy -  убрал DBA, добавил Дата рождения ИП.
        24.05.2011 aigul - добавила срок действия УЛ
        20.01.2012 aigul - «Дата рег/Дата рож» изменено на «Дата выдачи свидетельства/Дата рож»
        30.01.2013 evseev - tz-1646
*/


def new shared var vpoint like point.point label "      ПУНКТ  ".
def new shared var vdep like ppoint.dep label    "ДЕПАРТАМЕНТ  ".
def var pname like point.name.
def var dname like ppoint.name.
DEF VAR APKAL1 as char format "x(8)".
DEF VAR APKAL2 as char format "x(8)".
def var regis1 as char format "x(60)".
def var regis2 as char format "x(60)".
def var v-crgwho as char init "".
def var v-crgwhn as date.
def var msg-err as char.

def var rezdate as date .

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

def  new shared var c1 as char init '444'.

form
cif.cif   label "КОД КЛИЕНТА  " colon 14
        cif.type colon 35  label "ТИП "
        cif.mname colon 45 label "КАТЕГ"
          help " Категория клиента (F2 - справочник)"
/*          validate (can-find(bookcod where bookcod.bookcod = "clnkateg" and bookcod.code = cif.mname no-lock), " Код категории клиента не найден !")
*/        cif.regdt colon 87 label "ДАТА РЕГ" format "99/99/9999" skip
vpoint format ">>9" colon 14
        pname format "x(25)" no-label
        cif.ofc colon 87     label "ЗАРЕГИСТР" skip
vdep format ">>9" colon 14
        dname format "x(25)" no-label
        cif.pres format "x(3)" label "ЛЬГОТА" colon 72
                  help " Вид льготного обслуживания клиента (F2 - справочник)"
                  validate(cif.pres = "" or (cif.pres <> "msc" and can-find(codfr where codfr.codfr = "clnlgot" and codfr.code = cif.pres no-lock)), " Вид льготного обслуживания не найден!")
        cif.legal colon 87 no-label format "x(15)"  skip
cif.prefix label "ФОРМА СОБСТВ." FORMAT "x(20)" help " F2 - справочник организационно-правовых форм "
     validate(chk-prefix(cif.prefix), msg-err) colon 14
        cif.cust-since colon 87 label "КОЛИЧ.СОТРУД" format ">>>>>>9"
                validate(cif.cust-since >0, "Укажите количество сотрудников в организации!") skip
regis1     label "ПОЛНОЕ------ " FORMAT "x(60)" colon 14 skip
regis2     label "НАИМЕНОВАНИЕ " format "x(60)" colon 14 skip
cif.sname  LABEL "КОРОТКОЕ Н.  " colon 14
        cif.stn   label "СТАТУС" colon 87 skip

cif.ref[8] label "РЕГ.СВ./МЕСТО" colon 14 format "x(60)" help "Введите N регистрац св-ва (для ЮЛ) или МЕСТО РАБОТЫ (для ФЛ)"
                  validate(cif.ref[8] <> "" , " Необходимо заполнить N регистрац св-ва (для ЮЛ) или МЕСТО РАБОТЫ (для ФЛ)!")
skip
cif.sufix label "МЕСТО РЕГ/ДОЛ" colon 14 format "x(25)" help "Введите Место рег-ии св-ва (для ЮЛ) или ДОЛЖНОСТЬ (для ФЛ)"
                  validate(cif.sufix <> "" , " Необходимо заполнить Место рег-ии свидетельства (для ЮЛ) или ДОЛЖНОСТЬ (для ФЛ)!")
cif.expdt label "Дата выдачи свидетельства/Дата рож " colon 87 format "99/99/9999" help "Введите дату рег-ии (для ЮЛ) или ДАТУ РОЖ-ИЯ (для ФЛ)"
                  validate(cif.expdt <> ? and cif.expdt < g-today, " Необходимо заполнить ДАТУ РЕГИСТРАЦИИ (для ЮЛ) или ДАТУ РОЖ-ИЯ (для ФЛ)!")
cif.bplace label "МЕСТО РОЖ. " colon 14 format "x(60)" help "Введите место рождения ФЛ"
                  validate(trim(cif.bplace) <> '', " Необходимо заполнить МЕСТО РОЖ-ИЯ (для ФЛ)!")

skip
cif.addr[1] format "x(60)" LABEL "     АДРЕС-1 " colon 14           v-crgwhn  label "ДАТА "  colon 87 format "99/99/9999" skip
cif.addr[2] format "x(60)" LABEL "     АДРЕС-2 " colon 14   v-crgwho colon 87 label "КОНТРОЛЬ" skip
/*cif.addr[3] format "x(30)" LABEL "     АДРЕС-3 " colon 14
cif.who         LABEL "ПРАВИЛ" COLON 87 skip   */
cif.coregdt   LABEL "ДАТА РОЖД. ИП" colon 14 format "99/99/9999"     cif.whn         label " ДАТА " COLON 87 format "99/99/9999" skip
cif.pss     LABEL "ПАСПОРТ/УДОС "colon 14 format 'x(30)'          cif.who         LABEL "ПРАВИЛ" COLON 87
cif.dtsrokul     LABEL "Срок дейст УЛ" colon 14 format '99/99/9999' skip
cif.doctype LABEL "Тип документа" validate(lookup(cif.doctype,"01,02,04,05") > 0, " Не верен тип документа!") skip
cif.tel   LABEL "  ТЕЛЕФОН-1 " colon 14 format "x(15)"            cif.geo     LABEL "  ГЕО-КОД"  COLON 87 skip
cif.tlx   LABEL "  ТЕЛЕФОН-2 " colon 14 format "x(15)"         cif.cgr     LABEL "    ГРУППА" COLON 87 skip
cif.fax   LABEL " ФАКС (МОБ) " COLON 14 format "x(15)"        apkal1     LABEL "ОБСЛУЖИВАЕТ" COLON 87 skip
cif.attn label    " ВНИМАНИЕ!!! "  format "x(30)" colon 14    rezdate LABEL    "ДАТА РЕГ.НЕР." COLON 87 format "99/99/9999"  help " Введите дату регистрации нерезидента если ГЕО-КОД 022 "  skip
/*apkal1       LABEL "ОБСЛУЖИВАЕТ" COLON 87 skip */


with side-label row 3 width 105 frame cif.


