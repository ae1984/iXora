/* bkupdabn.p
 * MODULE
        Пластиковые карточки
 * DESCRIPTION
        Изменение реквизитов клиента - формирование файла 
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
        12.01.06 marinav 
 * CHANGES
*/


{global.i}
{bknewcrd.i}

def var s_bank as char.
def var v_out as logical init false.

find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
  message " Нет записи OURBNK в таблице sysc !!".
  pause. 
  return.
end.
else s_bank = sysc.chval.


   for each bkcard where bkcard.bank = s_bank and bkcard.sta = 3 and bkcard.exec = yes and bkcard.point > 0 exclusive-lock.

      find first spr where spr.sprcod = 'bkpoint' and spr.code = string(bkcard.point) no-lock no-error.
      if not avail spr then next.
      ClientMType = '2'.
      ContractMType = '0'.
      CardMType = '00'.
      RBScode = string(bkcard.rbs).
      ShortName = bkcard.client.
      Name = bkcard.client.
      Surname = bkcard.client.
      PassType = 'ID'.
      Pass = bkcard.rbs. 
      Zipcode = spr.name.
      IsResident = yes.
      IsPrivate  = yes.
      IsCrc = '398'.
      CrLimit = 0.
      CrLimitSum = 0.
      SecName = 'security'.
      AccSch = "". 
      ServPack = "".
      /* City = 'Astana'.
      BaseAddress[1] = ''.  */
      run Put_application.
      bkcard.sta = 4. /* отправили инфо о бранче */
      v_out = yes. 
   end. 

   if v_out then do:
      run Put_footer.
      run Copyfile.
   end.
   else 
      message skip(1) " НЕТ ДАННЫХ ДЛЯ ОТПРАВЛКИ В ABN-AMRO !" skip(1) view-as alert-box title "О Т П Р А В К А".
