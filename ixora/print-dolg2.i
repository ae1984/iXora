/* print-dolg2.i
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
        08.12.2004 saltanat - беруться тарифы со статусом "r" - рабочий.
        17/04/2009 galina - не берем комиссии за замену счета на 20-тизначный
        02/11/2009 galina - убрала услови на 02 ноября 2009 для 20ґтизначных счетов
*/


 Repeat on endkey undo,return:
     display dok with frame m.
     choose field dok auto-return  with frame m.
    v-sel=integer(substring(frame-value,1,2)).
    find tarif2 where tarif2.str5 = '101' and tarif2.stat = 'r' no-error. 

    If V-sel eq 3 or V-sel eq 4 then do :
           in_command = 0.
      find bxcif where bxcif.cif = cif.cif and bxcif.aaa = s-aaa 
       and bxcif.type  = '101' exclusive-lock no-error.
      if available bxcif then do:
       assign bxcif.crc = tarif2.crc.
       assign bxcif.amount = in_command.
       assign bxcif.whn = g-today.
       assign bxcif.who = g-ofc.
       release bxcif.
      end.
       leave.
    end.
      
  if V-sel = 2  then  update " Введите сумму льготного тарифа :"  in_command 
     VALIDATE(in_command < v-rate and in_command > 0, 
   "Льготный тариф  должен быть >0 и не превышать основной !") no-label.
 /* with frame c1 row 16 no-label  centered overlay*/
      
      find bxcif where bxcif.cif = cif.cif and bxcif.aaa = s-aaa 
       and bxcif.type  = '101' exclusive-lock no-error.
      if not available bxcif then do:
             create bxcif.
             assign bxcif.cif = cif.cif.
             assign bxcif.type = tarif2.str5.
             assign bxcif.aaa = s-aaa.
             assign bxcif.amount = in_command.
             assign bxcif.whn = g-today.
             assign bxcif.crc  = tarif2.crc. assign bxcif.who = g-ofc.
             assign bxcif.rem = tarif2.pakalp + '  ' + string(g-today) 
            +  '  Счет  ' +  s-aaa . 
        end.
      else do:
       assign bxcif.crc = tarif2.crc.
       assign bxcif.amount = in_command.
       assign bxcif.whn = g-today.
       assign bxcif.who = g-ofc.
       release bxcif.
      end. 
       
      leave.
 End.                                                                      
                        
   hide all no-pause.  
   
      pause 0.
