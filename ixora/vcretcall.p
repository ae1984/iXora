/* vcretcall.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Процедура создания возвратного платежа с транзитного счета
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
        27/07/2009 galina
 * BASES
        BANK COMM
 * CHANGES
*/

{global.i}
{lgps.i}
def input parameter p-rmz as char.
def input parameter p-bank as char.
def shared var s-remtrz like remtrz.remtrz.
def shared var v-option as char.
define shared variable s-newrec as logical.
def var v-kbe as char no-undo.
def var v-kod as char no-undo.
def var v-knp as char no-undo.
def var v-reas as integer no-undo.
def var v-reasch as char no-undo.
def var v-cod as char no-undo.
def var v-errmes as char no-undo.
def var v-rnn as char  no-undo.
def var v-fiozer as char no-undo.
def var v-bn as char no-undo.
def var v-bnrnn as char no-undo.
def var r-cover as integer no-undo.
def var v-ret as logical.

def button bupd label 'Редактировать'.
def button brmz label 'Создать платеж'.
def button bexit label 'Выход'.

function chk_eknp returns char (p-cod as char).
def var v-res as char.  
  v-res = ''.
  v-errmes = ''.
  if p-cod  = '' then do:
    v-errmes = 'Введите значение!'.
    v-res = '**'.
  end.
  else do:  
      if substr(p-cod,1,1) <> '1' and substr(p-cod,1,1) <> '2' then do:
        v-errmes = 'Неверный признак резидентства!'.
        v-res = '**'.
      end. 
      else do:
        find codfr where codfr.codfr = 'secek' and codfr.code = substr(p-cod,2,1) no-lock no-error.
        if not avail codfr then v-errmes = 'Неверный код сектора экономики!'.
      end.
  end.
  return v-res.
end.

form
  v-kod label "КОд" format "99" validate(chk_eknp(v-kod) = '', v-errmes) 
  v-kbe label "КБе" format "99" validate(chk_eknp(v-kbe) = '', v-errmes) 
  v-knp label "КНП" format "999" validate(can-find (codfr where codfr.codfr = 'spnpl' and codfr.code = v-knp),'Неверный КНП') skip
  v-reas label "Причина возврата" format "9" validate(v-reas >= 0 and v-reas <= 2 , 'Введите причину возврата платежа!') help '1 - прошло 180 дней, 2 - на основании письма, 0 - ручной ввод причины' skip
  v-reasch label "Описание причины возврата" validate(trim(v-reasch) <> '', 'Введите описание причины возврата платежа!')  view-as editor size 60 by 4 skip
  
  bupd brmz bexit
with frame rmzparam  side-label row 3 width 90 centered title 'ПАРАМЕТРЫ ВОЗВРАТНОГО ПЛАТЕЖА'.


on help of v-knp in frame rmzparam do:
  run h-codfr ("spnpl", output v-cod).
end.
def var v-oldreas as integer.
on choose of bupd in frame rmzparam do:
  v-oldreas = v-reas.
  update v-kod v-kbe v-knp v-reas with frame rmzparam.
  if v-oldreas <> v-reas then run defvreasch.  
  update v-reasch with frame rmzparam. 
end.

on "return" of v-reas in frame rmzparam do:
   apply "go" to v-reas in frame rmzparam.
end.

on "return" of v-reasch in frame rmzparam do: 
   apply "go" to v-reasch in frame rmzparam.
end.

on choose of brmz in frame rmzparam do:
  if trim(v-kod) = '' then update v-kod with frame rmzparam.
  if trim(v-kbe) = '' then update v-kbe with frame rmzparam.
  if trim(v-knp) = '' then update v-knp with frame rmzparam.
  
  if trim(v-reasch) = '' then do:
    update v-reas with frame rmzparam.
    run defvreasch.
    update v-reasch with frame rmzparam.
  end.
  if trim(v-kod) <> '' and trim(v-kbe) <> '' and trim(v-knp) <> '' and trim(v-reasch) <> '' then do:
      find first remtrz where remtrz.remtrz = p-rmz no-lock no-error.
      find first vcblock where vcblock.bank = p-bank and vcblock.remtrz = p-rmz no-lock no-error.
      find first crc where crc.crc = remtrz.tcrc no-lock no-error.
      if avail remtrz and avail vcblock then do:  
         MESSAGE skip " Сформировать возвратный патеж на сумму" trim(string(remtrz.amt,'>>>>>>>>>>>>>>9.99')) " " crc.code "?" skip(1)
         VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO 
         TITLE " ВАЛЮТНЫЙ КОНТРОЛЬ - ВОЗВРАТ "  UPDATE v-ret.
         if v-ret then do:
             v-rnn = entry(3,remtrz.bn[1] + remtrz.bn[2] + remtrz.bn[3],'/').
             v-fiozer = entry(1,remtrz.bn[1] + remtrz.bn[2] + remtrz.bn[3],'/').
             v-bn = entry(1,remtrz.ord, '/').
             v-bnrnn = entry(3,remtrz.ord, '/').
             if vcblock.crc = 1 then m_pid = 'P'.
             else m_pid = 'O'.
             /*m_pid = v-pid.*/
             s-remtrz = ''.
             if remtrz.amt > 5000000 then r-cover = 2.
             else do:
               if time < 51300 then r-cover = 1. /* SCLEAR00 */
               else r-cover = 2. /* SGROSS00 */
             end.  

             run vcrmzcre('б/н',remtrz.amt,vcblock.arp,v-rnn,v-fiozer,remtrz.sbank,remtrz.sacc,v-bn, v-bnrnn,v-knp,v-kod,v-kbe,v-reasch,/*v-pid,*/ r-cover, g-today).
             
             if s-remtrz <> '' then do:
                 v-option = 'vcretrmz'.
                 run vcrmzshow.
                 apply 'choose' to bexit in frame rmzparam.
             end.  
         end.
      end.
  end.
end.


find first vcblock where vcblock.bank = p-bank and vcblock.remtrz = p-rmz no-lock no-error.
if not avail vcblock then do:
  message "Не найдена запись в таблице vcblock!" view-as alert-box.
  return.
end.  
else do:
  find first remtrz where remtrz.remtrz = vcblock.remtrz no-lock no-error.
  if not avail remtrz then do:
    message "Не найден платеж в таблице remtrz!" view-as alert-box.
    return.
  end.
  find sub-cod where sub-cod.acc = remtrz.remtrz and sub-cod.sub = 'rmz'and sub-cod.d-cod = 'eknp'and sub-cod.ccode = 'eknp' and sub-cod.rcode ne ' ' no-lock no-error.
  v-kod = entry(2,sub-cod.rcode,',').
  v-kbe = entry(1,sub-cod.rcode,',').
  v-knp = entry(3,sub-cod.rcode,',').

  display v-kod v-kbe v-knp v-reas v-reasch with frame rmzparam.
  apply 'choose' to bupd in frame rmzparam. 
  enable bupd brmz bexit with frame rmzparam.
  wait-for choose of bexit or window-close of current-window.
end.


procedure defvreasch.
  case v-reas:
      when 1 then v-reasch = "Возврат платежа № " + trim(entry(1,substr(remtrz.sqn,19),'.')) + " от " + string(remtrz.rdt,'99/99/9999') + " в связи непредставлением получателем документов для идентификации полученной суммы в течение 180 дней.".
      when 2 then do:
        v-reasch = "Возврат платежа № " + trim(entry(1,substr(remtrz.sqn,19),'.')) + " от " + string(remtrz.rdt,'99/99/9999') + " на основании письма " .
        find first cif where cif.cif = vcblock.cif no-lock no-error.
        if avail cif  then v-reasch = v-reasch + cif.prefix + ' ' + cif.name.
        else v-reasch = v-reasch + vcblock.remname.
        v-reasch = v-reasch + '№ (номер письма) от (дата письма), как ошибочный платеж'.
      end.  
      otherwise v-reasch = ''.
  end.
  display v-reasch with frame rmzparam.
end.


