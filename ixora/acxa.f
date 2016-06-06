/* acxa.f
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

/* acxa.f */

repeat on endkey undo, return:
        acc = "".
        update acc with frame aax.
             find aaa where aaa.aaa = acc no-lock no-error. 
            if not available aaa then do:
                bell.
                message "Konts nav atrasts!".
                pause.
                hide message.
                undo,retry.
            end.
        s-aaa = acc.
            
        run aaa-aas.
        find first aas where aas.aaa = s-aaa and aas.sic = 'SP' 
            no-lock no-error.
            if available aas then do: 
                pause. 
                undo,retry. 
            end.
      
        if aaa.crc ne 1 then do:
            bell.
            message "Izmaksa notiek tikai latos. Uzr–diet latu kontu!".
            pause.
            hide message.
            undo,retry.
        end.
        if aaa.sta eq "C" then do:
            bell.
            message "Konts ir aizvёrts!".
            pause.
            hide message.
            undo,retry.
        end.
        
        find cif of aaa no-lock no-error.
        cifname = trim(trim(cif.prefix) + " " + trim(cif.name)).
        tt1 = substring (cifname,1,60).
        tt2 = substring (cifname,61,60).
        v-reg5 = trim(substr(cif.jss,1,13)).
        pause 0.

        if aaa.craccnt ne "" then
            find first xaaa where xaaa.aaa = aaa.craccnt no-lock no-error.
                
            if available xaaa then do:
                bila = aaa.cr[1] - aaa.dr[1] - aaa.hbal + xaaa.cbal
                    - aaa.fbal[1] - aaa.fbal[2] - aaa.fbal[3] 
                    - aaa.fbal[4] - aaa.fbal[5] - aaa.fbal[6] - aaa.fbal[7].

                display  bila tt1 tt2  cif.lname cif.pss cif.jss
                    with frame ggg.
                pause 0.
            end.
            else do:
                bila = aaa.cr[1] - aaa.dr[1] - aaa.hbal  .
                display bila tt1 tt2 cif.lname cif.pss cif.jss
                    with frame ggg.
                pause 0.
            end.
            
            leave.
    end.  /** repeat **/


