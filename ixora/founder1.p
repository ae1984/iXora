/* founder1.p
 * MODULE
        Клиенты и счета
 * DESCRIPTION
        Просмотр учредителей
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        07/04/2010 galina
 * BASES
        BANK
 * CHANGES
        01.03.2011 ruslan - добавил поле Доля(%) founder.reschar[1]
        07.04.2011 ruslan - подправил отоборжение фреймов
*/
{global.i}
def var v-ftype as char no-undo.
def var v-sel as integer no-undo.
def var v-name as char no-undo.
def var v-sname as char no-undo.
def var v-mname as char no-undo.
def var v-fname as char no-undo.
def var v-pserial as char no-undo.
def var v-dtbth as date no-undo.
def var v-res as int no-undo.
def var v-country as char no-undo.
def var v-orgreg as char no-undo.
def var v-numreg as char no-undo.
def var v-dtreg as date no-undo.
def var v-bin as char no-undo.
/*def var v-rnn as char no-undo.*/
def var v-dolya as deci no-undo.

def var v-result as logi no-undo.
def shared var s-cif like cif.cif.
def var i as integer no-undo.
def buffer b-founder for founder.
def var v-rid as rowid.
def var v-choice as logi init no.
def buffer b-cif for cif.

{adres.f}

define query qfounder for founder.

define browse bfounder query qfounder
displ founder.ftype label "Тип" format "x(1)"
      founder.name label "Наименование" format "x(30)"
      founder.res label "Резидентство" format "9"
      founder.country label "Страна" format "x(2)"
      founder.reschar[1] label 'Доля(%)' format "x(3)"
      with 10 down  no-label no-box.

define frame ffounder bfounder  help "<Enter>-Просмотр"
 with centered width 70 row 7 overlay no-label title "".

form
  v-name label 'Название' colon 18 format "x(40)"  help "Наименование Юр.лица"
  v-res label 'Резидентство' format "9" validate(v-res = 0 or v-res = 1,'Неверное значение!') help "0-нерезидент; 1-резидент"
  v-country label 'Страна' format "x(2)" validate(can-find(codfr where codfr.codfr = 'iso3166' and codfr.code = v-country),'Неверное значение!')   help "F2-справочник" skip
  v-orgreg label 'Орган регистрации' colon 18 format "x(40)"  skip
  v-numreg label 'Номер регистрации' colon 18 format "x(20)"
  v-dtreg label 'Дата регистрации' colon 78 format "99/99/9999"  skip
  v-bin label 'БИН' colon 18 format "x(12)"  skip
  /*v-rnn label 'РНН' colon 18 format "x(12)"  skip*/
  v-adres label 'Юридический адрес' colon 18 format "x(50)" skip
  v-dolya label 'Доля(%)' colon 18 format ">>9.99" validate(v-dolya > 0 and v-dolya <= 100, 'Поле Доля(%) не может быть пустым') help "Заполните поле Доля(%)"

  with centered side-label row 8 width 100 overlay title 'Юридическое лицо' frame fur .

form
  v-sname label 'Фамилия'  colon 18 format "x(20)"
  v-fname label 'Имя' colon 45 format "x(20)"
  v-mname label 'Отчество' colon 75 format "x(20)" skip
  v-res label 'Резидентство'  colon 18 format "9" validate(v-res = 0 or v-res = 1,'Неверное значение!') help "0-нерезидент; 1-резидент"
  v-country label 'Страна' colon 45 format "x(2)" validate(can-find(codfr where codfr.codfr = 'iso3166' and codfr.code = v-country),'Неверное значение!')   help "F2-справочник"
  v-dtbth label 'Дата рождения' colon 75 format "99/99/9999"  skip
  '------------------------------------Паспортные данные------------------------------------' at 5  skip
  v-pserial label 'Серия'  colon 18 format "x(20)"
  v-numreg label 'Номер' colon 45 format "x(20)" skip
  v-orgreg label 'Кем выдан'  colon 18 format "x(40)" skip
  v-dtreg label 'Дата выдачи' colon 18 format "99/99/9999"  skip
  '-----------------------------------------------------------------------------------------' at 5 skip
  v-bin label 'ИИН' colon 18 format "x(12)" /*v-rnn label 'РНН' colon 45 format "x(12)"*/  skip
  v-adres label 'Юридический адрес' colon 18 format "x(50)" skip
  v-dolya label 'Доля(%)' colon 18 format ">>9.99" validate(v-dolya > 0 and v-dolya <= 100, 'Поле Доля(%) не может быть пустым') help "Заполните поле Доля(%)"


  with centered side-label row 8 width 100 overlay  title 'Физическое лицо' frame ffiz .



on "return" of bfounder in frame ffounder do:
   find current founder no-lock no-error.
   if not avail founder then return.
   if founder.ftype = 'B' then do:
      assign v-name = founder.name
             v-res = founder.res
             v-country = founder.country
             v-orgreg = founder.orgreg
             v-numreg = founder.numreg
             v-dtreg = founder.dtreg
             v-bin = founder.bin
             /*v-rnn = founder.rnn*/
             v-adres = founder.adress
             v-dolya = decimal(founder.reschar[1]) no-error.
      display v-name v-res v-country v-orgreg v-numreg v-dtreg v-bin /*v-rnn*/ v-adres v-dolya with frame fur.
      pause.
   end.
   else do:
      assign v-sname = founder.sname
             v-fname = founder.fname
             v-mname = founder.mname
             v-dtbth = founder.dtbth
             v-pserial = founder.pserial
             v-res = founder.res
             v-country = founder.country
             v-orgreg = founder.orgreg
             v-numreg = founder.numreg
             v-dtreg = founder.dtreg
             v-bin = founder.bin
             /*v-rnn = founder.rnn*/
             v-adres = founder.adress
             v-dolya = decimal(founder.reschar[1]) no-error.
      display v-sname v-fname v-mname v-res v-country v-dtbth v-pserial v-numreg v-orgreg v-dtreg v-bin /*v-rnn*/ v-adres v-dolya with frame ffiz.
      pause.
   end.
end.



find first b-cif where b-cif.cif = s-cif no-lock no-error.
if b-cif.type = 'P' or (b-cif.type = 'B' and b-cif.cgr = 403)then do:
  message "Учредители вводятся только для ЮЛ!" view-as alert-box title 'ВНИМАНИЕ'.
  return.
end.

open query qfounder for each founder where founder.cif = s-cif no-lock.
enable bfounder with frame ffounder.
wait-for window-close of current-window.
pause 0.


