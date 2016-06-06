/* print-dolg4.i
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
        28.02.2005 tsoy
 * CHANGES
        17/04/2009 galina - не берем комиссии за замену счета на 20-тизначный
        02/11/2009 galina - убрала услови на 02 ноября 2009 для 20ґтизначных счетов
        04.05.2010 marinav - ввод тарифа 023 за доп счет
        28.09.2010 marinav - учет исключений
*/


repeat on endkey undo,return:
     display dok2 with frame m2.
     choose field dok2 auto-return  with frame m2.

     V-sel=integer(substring(frame-value,1,2)).

    v-tar = '101'.
    if V-sel = 1 and is_IP     then v-tar = '020'.
    if V-sel = 1 and not is_IP then v-tar = '101'.
    if V-sel = 2               then v-tar = '023'.

       find first tarifex2 where tarifex2.aaa = s-aaa
                               and tarifex2.cif = s-cif
                               and tarifex2.str5 = v-tar
                               and tarifex2.stat = 'r' no-lock no-error.
       if avail tarifex2 then  assign v-rate = tarifex2.ost in_command = tarifex2.ost.
       else do:
            find first tarifex where tarifex.str5 = v-tar and tarifex.cif = s-cif
                                 and tarifex.stat = 'r' no-lock no-error.
            if avail tarifex then  assign v-rate = tarifex.ost in_command = tarifex.ost.
            else do:
                 find first tarif2 where tarif2.str5 = v-tar and tarif2.stat = 'r' no-lock no-error.
                 if avail tarif2 then  assign v-rate = tarif2.ost in_command = tarif2.ost.
            end.
       end. /* tarifex2 */

    find first tarif2 where tarif2.str5 = v-tar and tarif2.stat = 'r' no-lock no-error.

    If V-sel eq 4 or V-sel eq 5 then do :
      in_command = 0.
      find bxcif where bxcif.cif = cif.cif and bxcif.aaa = s-aaa and bxcif.type  = v-tar exclusive-lock no-error.
      if available bxcif then do:
           bxcif.crc = 1.
           bxcif.amount = in_command.
           bxcif.whn = g-today.
           bxcif.who = g-ofc.
           release bxcif.
      end.
      leave.
    end.
      

  if V-sel = 3  then  update " Введите сумму льготного тарифа :"  in_command 
     validate(in_command < v-rate and in_command > 0, "Льготный тариф  должен быть >0 и не превышать основной !") no-label.

      
  find bxcif where bxcif.cif = cif.cif and bxcif.aaa = s-aaa and bxcif.type  = v-tar exclusive-lock no-error.
  if not available bxcif then do:
        create bxcif.
        bxcif.cif = cif.cif.
        bxcif.type = v-tar.
        bxcif.aaa = s-aaa.
        bxcif.amount = in_command.
        bxcif.whn = g-today.
        bxcif.crc  = 1. assign bxcif.who = g-ofc.
        bxcif.rem = tarif2.pakalp + '  ' + string(g-today) +  '  Счет  ' +  s-aaa . 
   end.
   else do:
        bxcif.crc = 1.
        bxcif.amount = in_command.
        bxcif.whn = g-today.
        bxcif.who = g-ofc.
       release bxcif.
   end. 
       
   leave.
                                                                      
end.                        
hide all no-pause.  
   
pause 0.
