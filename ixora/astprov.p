/* astprov.p
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


define new shared var v-god as integ format "zzz9".
define var otv as logical .
define var otv1 as logical .
define buffer b-astnal for astnal.


{mainhead.i}

      find last astnal /* where astnal.god  */ no-lock no-error.
      if available astnal then v-god =astnal.god.   


  update "ДЛЯ ПРОСМОТРА И РЕДАКТИР. НАЛОГОВОЙ АМОРТИЗАЦИИ ВВЕДИТЕ ГОД"
     v-god validate(v-god > "1997", "Проверьте год")
      WITH FRAME astg no-label row 7 centered . 


      find first astnal  where astnal.god = v-god no-lock no-error.
      if not available astnal then do:  
         message "Информация с " v-god " годом отсутствует!!Открыть новый год ?(Да/Нет)" update otv format "Да/Нет".   
         if  otv= false then undo,return.   
      end. 
     
      for each b-astnal where b-astnal.god = v-god - 1 no-lock:
        if b-astnal.stok  eq 0 then next.   

        find first astnal where astnal.god = v-god  
                            and  astnal.grup =b-astnal.grup
                            and astnal.ast = b-astnal.ast  no-lock no-error.
        
  
        if not available astnal  then do:   
           
          message "Создать в " + string(v-god) " году запись по группе " 
          + string(b-astnal.grup) + b-astnal.damn1 + "?" 
          update otv1 format "Да/Нет".  
           
           if otv1= false then next.
            
           else do:  
           
              create astnal. 
               astnal.god  = v-god. 
               astnal.ast  = b-astnal.ast.
               astnal.nrst = b-astnal.nrst.
               astnal.grup = b-astnal.grup.  
               astnal.dam4 = b-astnal.dam4.       
               astnal.amp  = b-astnal.amp.
               astnal.amn  = b-astnal.amn.  
               astnal.ston = b-astnal.stok.
               astnal.damn3[1]=b-astnal.damn3[1].
            { astnal.i 0}
           end.
          
        end.
        else  do:

           if astnal.ston <> b-astnal.stok then do: 
             message " Ст.баланс гр. " + string(astnal.grup) + 
             " на конец налог.года не равна ст.балансу на начало года!!". pause 7. 
           
           end.
        end.     
      end.     

def var pr as int.
       find first astnal  where astnal.god = v-god no-lock no-error.
       if available astnal then do:  
           pr=astnal.damn3[1].
       end.
       for each astnal where astnal.god = v-god no-lock:
           
          if astnal.sremk = 0 then next.  
          if astnal.damn3[1] ne pr then do:
           message "Факт.расходы на ремонт в вычеты: 1 стр.- "
                    pr " %; " astnal.nrst " стр. - " astnal.damn3[1] 
                   " % .     ИСПРАВЬТЕ " astnal.grup " гр.!!!" .
           pause.        
          end.
       end.

      run astnal.
