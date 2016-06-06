/* vccheckp.i
 * MODULE
        Платежная система
 * DESCRIPTION
        Процесс, который обрабатывает документы Интернет Офиса - создание внешнего платежа
 * RUN
        
 * CALLER
        
 * SCRIPT
    psroup.p
    psroup-2.p
            
 * INHERIT
        
 * MENU
        5-1
 * AUTHOR
        10.05.04 tsoy
 * CHANGES
        20.12.2005 nataly убрала проверку на сумму свыше 10 000 $ и более одного платежа с одного ФЛ
        22.12.2005 nataly убрана проверка на ФЛ
*/     

     /*
      * tsoy проверку для валютного контороля на 1 платеж в 
      * день и на сумму не больше 10 000 $ 
      */


if m_pid = "O" then do:
/*     if  remtrz.outcode = 1 then do:
     
          run vccheckp (trim(v-reg5), remtrz.remtrz, remtrz.fcrc, output v-chksts).
          
             if v-chksts = 1 then do:
                l-ans = no.
                run yn(""," Платеж от физ.лица ? ","","", output l-ans). 
                if l-ans then  do:  
                 message " Платеж превышает экв. 10 000 $  " view-as alert-box title "Предупреждение". 
                 undo, retry. 
                end.
             end.

             if v-chksts = 2 then do:
                l-ans = no.
                run yn(""," Платеж от физ.лица ? ","","", output l-ans). 
                if l-ans then  do:  
                 message " Платеж с данным РНН сегодня уже был" return-value view-as alert-box title "Предупреждение". 
                 undo, retry. 
                end.
             end.
            
      end.  */

     if  remtrz.outcode = 3  or remtrz.outcode = 1 then do:
          /* Если физ лицо то контролируем  */
       if v-pnp:screen-value <> "" then  find first d-aaa where d-aaa.aaa = v-pnp:screen-value no-lock no-error.
           if avail d-aaa or v-pnp:screen-value = "" then do:
             if v-pnp:screen-value <> "" then find first d-cif where d-cif.cif = d-aaa.cif and d-cif.type = "p" no-lock no-error.
               if avail d-cif or v-pnp:screen-value = ""  then do:

              /*   run vccheckp (trim(v-reg5), remtrz.remtrz, remtrz.fcrc, output v-chksts).
                 if v-chksts = 1 then do:*/
                 l-ans = no.
/*                 run yn(""," Перевод превышает в экв. 10 000 $\nЕсть Документ Основание ? ","","", output l-ans). */
                run yn(""," Есть Документ Основание ? ","","", output l-ans).   
                     if l-ans then do:
                               /* Автоматически проставим признак */
                               find first sub-cod where sub-cod.sub       = 'rmz' 
                                                        and sub-cod.acc   = remtrz.remtrz 
                                                        and sub-cod.d-cod = 'zdcavail' exclusive-lock  no-error.
                               if avail sub-cod then do:
                                         sub-cod.acc      = remtrz.remtrz.       
                                         sub-cod.sub      = 'rmz'.
                                         sub-cod.d-cod    = 'zdcavail'.
                                         sub-cod.ccode    = string(1).
                                         sub-cod.rdt      = g-today.
                               end.
                                   else do:
                                     create sub-cod.
                                         sub-cod.acc      = remtrz.remtrz.       
                                         sub-cod.sub      = 'rmz'.
                                         sub-cod.d-cod    = 'zdcavail'.
                                         sub-cod.ccode    = string(1).
                                         sub-cod.rdt      = g-today.
                               end.

                               /* Автоматически проставим признак */
                               find first sub-cod where sub-cod.sub       = 'rmz' 
                                                        and sub-cod.acc   = remtrz.remtrz 
                                                        and sub-cod.d-cod = 'zsgavail' exclusive-lock  no-error.
                               if avail sub-cod then do:
                                         sub-cod.acc      = remtrz.remtrz.       
                                         sub-cod.sub      = 'rmz'.
                                         sub-cod.d-cod    = 'zsgavail'.
                                         sub-cod.ccode    = 'msc'.
                                         sub-cod.rdt      = g-today.
                               end.
                                   else do:
                                     create sub-cod.
                                         sub-cod.acc      = remtrz.remtrz.       
                                         sub-cod.sub      = 'rmz'.
                                          sub-cod.d-cod    = 'zsgavail'.
                                         sub-cod.ccode    = 'msc'.
                                         sub-cod.rdt      = g-today.
                               end.
                              
                               find first sub-cod no-lock  no-error.     
                               release sub-cod.
                        end. /*l-ans = true*/
                            else do:
                                l-ans = no.
                                run yn(""," Есть запись разрешающая предоставлять информацию в правоохранительные органы","","", output l-ans). 
                                if l-ans then do:
                                      /* Автоматически проставим признак */
                                      find first sub-cod where sub-cod.sub       = 'rmz' 
                                                               and sub-cod.acc   = remtrz.remtrz 
                                                               and sub-cod.d-cod = 'zsgavail' exclusive-lock  no-error.
                                      if avail sub-cod then do:
                                                sub-cod.acc      = remtrz.remtrz.       
                                                sub-cod.sub      = 'rmz'.
                                                sub-cod.d-cod    = 'zsgavail'.
                                                sub-cod.ccode    = string(1).
                                                sub-cod.rdt      = g-today.
                                      end.
                                          else do:
                                            create sub-cod.
                                                sub-cod.acc      = remtrz.remtrz.       
                                                sub-cod.sub      = 'rmz'.
                                                sub-cod.d-cod    = 'zsgavail'.
                                                sub-cod.ccode    = string(1).
                                                sub-cod.rdt      = g-today.
                                      end.
                                      /* Автоматически проставим признак */
                                      find first sub-cod where sub-cod.sub       = 'rmz' 
                                                               and sub-cod.acc   = remtrz.remtrz 
                                                               and sub-cod.d-cod = 'zdcavail' exclusive-lock  no-error.
                                      if avail sub-cod then do:
                                                sub-cod.acc      = remtrz.remtrz.       
                                                sub-cod.sub      = 'rmz'.
                                                sub-cod.d-cod    = 'zdcavail'.
                                                sub-cod.ccode    = string(2).
                                                sub-cod.rdt      = g-today.
                                      end.
                                          else do:
                                            create sub-cod.
                                                sub-cod.acc      = remtrz.remtrz.       
                                                sub-cod.sub      = 'rmz'.
                                                sub-cod.d-cod    = 'zdcavail'.
                                                sub-cod.ccode    = string(2).
                                                sub-cod.rdt      = g-today.
                                      end.
                                      find first sub-cod no-lock  no-error.     
                                      release sub-cod.
                                end. else
                                   undo, retry. 
                               end. /*else do*/
                /*    end.*/
             end.

                       
                       end.
             end.


end.

