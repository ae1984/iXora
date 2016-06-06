/* founder.p
 * MODULE
        Клиенты и счета
 * DESCRIPTION
        Ввод учредителей
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
        25/02/2010 galina
 * BASES
        BANK
 * CHANGES
        07/03/2010 madiyar - отцентрировал фрейм, поменял код нерезидента с 2 на 0
        10/03/2010 galina - возможность выбора страны нерезидента
        15/03/2010 galina - возможность выбора страны нерезидента для ЮЛ
        01.03.2011 ruslan - добавил поле Доля(%) founder.reschar[1]
        07.04.2011 ruslan - подправил отоборжение фреймов
        24.05.2011 aigul - добавила срок действ УЛ
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
def var v-dtsrok as date no-undo.
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
{chk12_innbin.i}


{adres.f}

define query qfounder for founder.

define browse bfounder query qfounder
displ founder.ftype label "Тип" format "x(1)"
      founder.name label "Наименование" format "x(30)"
      founder.res label "Резидентство" format "9"
      founder.country label "Страна" format "x(2)"
      founder.reschar[1] label 'Доля(%)' format "x(3)"
      with 10 down  no-label no-box.
def var v-days as int.
define frame ffounder bfounder  help "<Enter>-Изменить, <Ins>-Ввод, <Ctrl-D>-Удалить, <F4>-Выход"
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
  v-dtsrok label 'Срок действ' colon 18 format "99/99/9999"  skip
  '-----------------------------------------------------------------------------------------' at 5 skip
  v-bin label 'ИИН' colon 18 format "x(12)" /*v-rnn label 'РНН' colon 45 format "x(12)"*/  skip
  v-adres label 'Юридический адрес' colon 18 format "x(50)" skip
  v-dolya label 'Доля(%)' colon 18 format ">>9.99" validate(v-dolya > 0 and v-dolya <= 100, 'Поле Доля(%) не может быть пустым') help "Заполните поле Доля(%)"


  with centered side-label row 8 width 100 overlay  title 'Физическое лицо' frame ffiz .

on "END-ERROR" of frame fur do:
  hide frame fur no-pause.

end.

on "END-ERROR" of frame ffiz do:
  hide frame ffiz no-pause.

end.

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

      update  v-name v-res  with frame fur.

      if v-res = 0 then update v-country with frame fur.
      else do:
        v-country = 'KZ'.
        display v-country with frame fur.
      end.
      update v-orgreg v-numreg v-dtreg with frame fur.

      repeat on endkey undo, return:
        update v-bin with frame fur.
        if trim(v-bin) = '' then leave.
        if chk12_innbin(v-bin) = false then do:
           message "Неверный ключ БИН !".
        end.
        else leave.
      end.

      /*repeat on endkey undo, return:
        update v-rnn with frame fur.
        if trim(v-rnn) = '' then leave.
        v-result = no.
        run rnnchk( input v-rnn,output v-result).
        if v-result then do:
           message "Неверный ключ РНН !".
        end.
        else leave.
      end.*/

      /*редактируем адрес*/
      v-title = "Юридический адрес".
      {adres.i
      &hide = "hide frame fur no-pause."}

      display v-adres with frame fur.
      pause 2.
      hide frame fur.

        update v-dolya with frame fur.

      do transaction:
          find current founder exclusive-lock.
          assign founder.name = v-name
                 founder.res = v-res
                 founder.country = v-country
                 founder.orgreg = v-orgreg
                 founder.numreg = v-numreg
                 founder.dtreg = v-dtreg
                 founder.bin = v-bin
                 /*founder.rnn = v-rnn*/
                 founder.adress = v-adres
                 founder.reschar[1] = string(v-dolya).
         find current founder no-lock.
     end.

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
             v-dtsrok = founder.dtsrokul
             v-bin = founder.bin
             /*v-rnn = founder.rnn*/
             v-adres = founder.adress
             v-dolya = decimal(founder.reschar[1]) no-error.

      display v-sname v-fname v-mname v-res v-country v-dtbth v-pserial v-numreg v-orgreg v-dtreg v-dtsrok v-bin /*v-rnn*/ v-adres v-dolya with frame ffiz.

      update  v-sname v-fname v-mname v-res  with frame ffiz.

      if v-res = 0 then update v-country with frame ffiz.
      else do:
        v-country = 'KZ'.
        display v-country with frame ffiz.
      end.
      update v-dtbth v-pserial v-numreg v-orgreg v-dtreg v-dtsrok  with frame ffiz.
      v-days = v-dtsrok - today.
      if v-days <= 30 then message "Срок действия УЛ истекает в течении " v-days " дней!" view-as alert-box.
      repeat on endkey undo, return:
        update v-bin with frame ffiz.
        if trim(v-bin) = '' then leave.
        if chk12_innbin(v-bin) = false then do:
           message "Неверный ключ БИН !".
        end.
        else leave.
      end.

      /*repeat on endkey undo, return:
        update v-rnn with frame ffiz.
        if trim(v-rnn) = '' then leave.
        v-result = no.
        run rnnchk( input v-rnn,output v-result).
        if v-result then do:
           message "Неверный ключ РНН !".
        end.
        else leave.
      end.*/

      /*редактируем адрес*/
      v-title = "Юридический адрес".
      {adres.i
      &hide = "hide frame ffiz no-pause."}

      display v-adres with frame ffiz.
      pause 2.
      hide frame ffiz.

        update v-dolya with frame ffiz.

      do transaction:
          find current founder exclusive-lock.
          assign founder.sname = v-sname
                 founder.fname = v-fname
                 founder.mname = v-mname
                 founder.dtbth = v-dtbth
                 founder.pserial = v-pserial
                 founder.res = v-res
                 founder.country = v-country
                 founder.orgreg = v-orgreg
                 founder.numreg  = v-numreg
                 founder.dtreg  = v-dtreg
                 founder.dtsrokul  = v-dtsrok
                 founder.bin = v-bin
                 /*founder.rnn = v-rnn*/
                 founder.adress = v-adres
                 founder.reschar[1] = string(v-dolya).

                 if trim(v-sname) <> '' then founder.name = trim(v-sname).
                 if trim(v-fname) <> '' then founder.name = founder.name  + ' ' + trim(v-fname).
                 if trim(v-mname) <> '' then founder.name = founder.name  + ' ' + trim(v-mname).
         find current founder no-lock.

     end.
   end.
   open query qacc for each founder where founder.cif = s-cif  no-lock.
   find first founder where founder.cif = s-cif no-lock no-error.
   if avail founder then bfounder:refresh().
end.

on "insert-mode" of bfounder in frame ffounder do:
    run sel2('ТИП УЧРЕДИТЕЛЯ',' Юридическое лицо | Физическое лицо', output v-sel).
    if v-sel  = 0 then return.
    if v-sel = 1 then v-ftype = 'B'.
    else v-ftype = 'P'.
    find last b-founder use-index fid no-lock no-error.
    create founder.
    if avail b-founder then founder.fid = b-founder.fid + 1.
    else founder.fid = 1.
    assign founder.cif = s-cif
           founder.who = g-ofc
           founder.whn = g-today
           founder.ftype = v-ftype
           founder.tim = time
           founder.res = 1
           founder.reschar[1] = string(v-dolya).

    bfounder:set-repositioned-row(bfounder:focused-row, "always").
    v-rid = rowid(founder).
    open query qfounder for each founder where founder.cif = s-cif no-lock.
    reposition qfounder to rowid v-rid no-error.
    find first founder where founder.cif = s-cif no-lock no-error.
    if avail founder then bfounder:refresh().

     apply "return" to bfounder in frame ffounder.
end.

on "delete-line" of bfounder in frame ffounder do:
    find first b-founder where b-founder.cif = s-cif no-lock no-error.
    if not avail b-founder then return.
    MESSAGE skip " Удалить запись?" skip(1)
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
    TITLE "Учредители" UPDATE v-choice.
    if v-choice then do:
        bfounder:set-repositioned-row(bfounder:focused-row, "always").
        find current founder exclusive-lock.
        delete founder.
        open query qfounder for each founder where founder.cif = s-cif no-lock.
        find first founder where founder.cif = s-cif no-lock no-error.
        if avail founder then bfounder:refresh().
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
