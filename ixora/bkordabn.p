/* bkordabn.p
 * MODULE
        Пластиковые карточки
 * DESCRIPTION
        Заказ в АБН безымянных карточек для БД - формирование файла и заявки
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
        17.12.05 marinav 
 * CHANGES
*/

{global.i}
{bknewcrd.i}

def var s_nom as inte.
def var s_bank as char.
def var i as inte.
def var s_cli as char.
def var s_client as char.
def var s_count as inte.
def var v-sel as char.

define variable vparam  as character.
define variable vdel    as character initial "^".
define variable rcode   as integer.
define variable rdes    as character.
def new shared var s-jh like jh.jh.

find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
  message " Нет записи OURBNK в таблице sysc !!".
  pause. 
  return.
end.
else s_bank = sysc.chval.

repeat:
  run sel (" Заказ платежных карт :", 
           " 1. Отправка заказа | 2. Получение ответа | 3. Выход").
  v-sel = return-value.

  case v-sel:
    when '1' then  run outabn . /* отправка заказа на карты */
    when '2' then  run inabn.   /* получение файла ответа с номерами выпускаемых карт */
    when '3' then return.
    otherwise return.
  end case.
end.


procedure outabn.

/*  bkcard.nom > 0 and bkcard.exec = yes  - заказ ушел в АБН, номер следующего берется из сиквенса
    bkcard.nom > 0 and bkcard.exec = no   - заказ сделан (присвоен номер заказа), но файл в АБН не сформировали. В этом случае
                                            всем картам без номера присваивается номер последнего заказа, который не ушел в АБН  
 */

find first bkorder where bkorder.bank = s_bank and bkorder.exec = no no-lock no-error.
if not avail bkorder then do:
   message skip(1) "НЕВЫПОЛНЕННЫХ ЗАКАЗОВ НЕТ !" skip(1) view-as alert-box title "З А К А З".
   return.
end.

  find last bkcard where bkcard.bank = s_bank and bkcard.nom > 0 and bkcard.exec = no no-lock no-error.
  if avail bkcard then s_nom = bkcard.nom.
                else s_nom =  next-value(idnom).

  for each bkorder where bkorder.bank = s_bank and bkorder.nom = 0 and bkorder.point = 0 no-lock.
    repeat i = 1 to bkorder.counts:
       /* displ bkorder.nominal counts  i.*/
        create bkcard.
        assign bkcard.rbs = string(next-value(idrbs))
               bkcard.bank = s_bank
               bkcard.nominal = bkorder.nominal
               bkcard.who = g-ofc
               bkcard.whn = g-today
               bkcard.nom = s_nom.
        bkcard.client = 'Client' + bkcard.rbs.
        bkcard.pas    = 'ID-' + bkcard.rbs. 
    end.
  end.

  for each bkorder where bkorder.bank = s_bank and bkorder.nom = 0 exclusive-lock.
      bkorder.nom = s_nom. 
  end.

  output to ord1.html.

  {html-title.i 
   &stream = " "
   &title = " "
   &size-add = "x-"
  }

    put unformatted  "<br><P align=""left"" style=""font:bold"">Заявка N " s_nom format '>>>>>>' " сформирована </P>" skip.

    put  unformatted "<TABLE cellspacing=""0"" cellpadding=""5"" border=""1"">" skip
                    "<TR align=""center"" style=""font:bold"" bgcolor=""#C0C0C0"">" skip
                    "<td rowspan=2 align=center>Номинал карты</td>"
                    "<td rowspan=2 colspan=2 align=center>Количество</td>"
                    "<td rowspan=2 align=center width=""415"" > Список </td>"
                  "</tr><tr></tr>" skip.

  for each bkcard where bkcard.bank = s_bank and bkcard.nom = s_nom and bkcard.exec = no break by bkcard.nominal by bkcard.rbs.

  if s_client = '' then s_client = bkcard.client. 
                   else s_client = s_client + ',' + bkcard.client.
  s_count = s_count + 1.
  if first-of (bkcard.nominal) then s_cli = bkcard.client.
  if last-of  (bkcard.nominal) then do:
      put unformatted 
        "<TR><TD >" bkcard.nominal "</TD>" 
            "<TD >" s_count "</TD >"
            "<TD >" s_cli " - " bkcard.client "</TD>" 
            "<TD >" s_client "</TD >"
        "</TR>" skip.
      s_cli = ''.
      s_client = ''. 
      s_count = 0.
  end.
  end.

put unformatted "</table>" skip.
put unformatted "</table></body></html>" skip.
output close.
unix silent cptwin ord1.html excel.exe.


MESSAGE skip "Сформировать заявку в OpenWay на выпуск карт?"
    VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO
    TITLE "ЗАКАЗ НА КАРТУ" UPDATE choice as logical.

if choice = false then return.
if choice = true then do :
   s_count = 0.
   IsResident = yes.
   IsPrivate  = yes.
   IsCrc = '398'.
   CrLimit = 0.
   CrLimitSum = 0.
   SecName = 'security'.
   ContInfo = 'InsCardCon'.
   for each bkcard where bkcard.bank = s_bank and bkcard.nom = s_nom and bkcard.exec = no break by bkcard.rbs.
      RBScode = string(bkcard.rbs).
      ClientMType = '1'.
      ContractMType = '1'.
      CardMType = '00'.
      ShortName = bkcard.client.
      PassType = 'ID'.
      Pass = string(bkcard.rbs). 
      Dep = ''.
      NameEmb = ''.
      SurnameEmb = ''.
      Name = bkcard.client.
      Surname = bkcard.client.
      AccSch = "A05343". 
      ServPack = "S08956".
      run Put_application.

      ClientMType = '0'.
      ContractMType = '2'.
      CardMType = '03'.
      Dep = 'TKB'.
      NameEmb = 'CLIENT'.
      SurnameEmb = 'CARD'.
      AccSch = "      ". 
      ServPack = "S21882".
      ConType = "V05063".
      run Put_application.

      bkcard.exec = yes. bkcard.sta = 1.
      s_count = s_count + 1.
   end.
   run Put_footer.
   for each bkorder where bkorder.bank = s_bank and bkorder.nom = s_nom exclusive-lock.
       bkorder.execute = yes.
       if bkorder.point = 0 then bkorder.info1 = file-name.
   end.

   run Copyfile.


/* комиссия за выпуск карт  */
/*
   find sysc where sysc.sysc = "CRDCMM" no-lock no-error .
   if available sysc then do:
      vparam = string (sysc.deval * s_count) + vdel + '1' + vdel +
               string (entry(1, sysc.chval)) + vdel + 
               string (460717) + vdel +  
               "Комиссия за выпуск карт , кол " + string(s_count) + 
               vdel + '1' + vdel + '9' + vdel + '890'.
      s-jh = 0.
      
      run trxgen ("uni0003", vdel, vparam, "", "", output rcode, output rdes, input-output s-jh).
          if rcode <> 0 then do: message rcode rdes. pause 100.  return.  end. 
      run jou.
      run vou_bank(1).
   end.
   else message "КОМИССИЯ ЗА ВЫПУСК НЕ СНЯЛАСЬ. НЕТ ДАННЫХ В НАСРОЙКАХ SYSC !"   skip(1) view-as alert-box title "К О М И С С И Я".
*/

end.

end.


procedure inabn.
    /* прием файла из АБН в ответ на наш файл с заказом карт - проставляем соответствие выпускаемых карт нашим RBS-кодам */
    def var f-name as char.
    def var tmp1 as char.
    def var v-rbs as char.
    def var v-accn as char.
    def var v-cont as char.

    find last bkorder where bkorder.bank = s_bank and bkorder.point = 0 and bkorder.execute = yes and bkorder.info2 = '' no-lock use-index banknome no-error .
    if not avail bkorder then do:
        message "Файл в ABN-AMRO не посылался или уже был принят" view-as alert-box title "ВНИМАНИЕ".
        return.
    end.
    
    f-name = 'r' + substr(bkorder.info1,2).
    find first bookcod where bookcod = 'cardaccs' and bookcod.code = 'bwxdiro' no-lock no-error.
      if avail bookcod then bwxdir = TRIM(bookcod.name).
      else message "Не найден код BWXDIRO в справочнике CARDACCS пункт 4.6.1" view-as alert-box title "П Р Е Д У П Р Е Ж Д Е Н И Е".
      rcd = unix_s("rcp " + replace(bwxdir + f-name,'\\','\\\\') + " ./" ).

        FILE-INFO:FILE-NAME = f-name.
        IF FILE-INFO:FILE-TYPE = ? THEN do:
          message skip "Файл ответа " + f-name + " из ABN не пришел" skip(1) 
           view-as alert-box button Ok title "Внимание!".
          return.
        end.
    
  INPUT FROM VALUE(f-name).
  i = 0.
  repeat on error undo, leave:
    import unformatted tmp1 no-error.
    i = i + 1.
    if tmp1 begins "RD" then do:
       v-rbs = trim(substr(tmp1, 17, 10)).
       if trim(substr(tmp1, 129, 4)) = "0000" then do:
          v-accn = trim(substr(tmp1,28,16)).
          if v-accn begins '005' then do:
              find first bkcard where bkcard.rbs = trim(v-rbs) exclusive-lock no-error.
              if avail bkcard then assign bkcard.rbs = v-rbs bkcard.account_number = v-accn bkcard.sta = 2.
                              else message 'Не найден контракт :' + v-rbs view-as alert-box title "П Р Е Д У П Р Е Ж Д Е Н И Е".
          end.
          else do:
              find first bkcard where bkcard.rbs = trim(v-rbs) exclusive-lock no-error.
              if avail bkcard then assign bkcard.rbs = v-rbs bkcard.contract_number = v-accn bkcard.sta = 2.
                              else message 'Не найден контракт :' + v-rbs view-as alert-box title "П Р Е Д У П Р Е Ж Д Е Н И Е".
          end.
       end.
       else message 'Ошибка :' + v-rbs + trim(substr(tmp1,28,30)) view-as alert-box title "П Р Е Д У П Р Е Ж Д Е Н И Е".      
    end.
  end.
  input close.

  for each bkorder where bkorder.bank = s_bank and bkorder.point = 0 and bkorder.execute = yes and bkorder.info1 = 'a' + substr(f-name,2) exclusive-lock. 
       bkorder.info2 = f-name.
  end.

  run savelog( "cards", 'Импорт ответа АБН : ' + f-name + ' ' + string(today,'99.99.9999') + ' ' + string(time,"hh:mm")).
  unix silent value ("rm -f " + f-name).
  message "Файл " + f-name + " принят" view-as alert-box title "ВНИМАНИЕ".

end.
