/* comm-arp.i
 * MODULE
        PRAGMA
 * DESCRIPTION
        Проверка остатка на АРП с заданой суммой на выходе хватит средств или нет
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
        03/02/2004 sasco Проверка на активность счета Г/К
*/

function comm-arp returns logical (ref as char, amt as decimal ).
 def var ok as logical init false.

 find first arp where trim(arp.arp) = trim(ref) no-lock no-error.
 if avail arp then do:
                 find gl where gl.gl = arp.gl no-lock no-error.
                 if gl.type = "A" or gl.type = "E" then 
                 do: /* активный счет Г/К */
                    if (arp.dam[1] - arp.cam[1]) >= amt 
                       then ok = true.
                       else do:
                              ok = false.
                              message "Не хватает средств на счете " + ref + "(" + 
                              trim(string(arp.dam[1] - arp.cam[1],"->>>,>>>,>>>,>>9.99")) + "),  платеж: " +
                              trim(string(amt,"->>>,>>>,>>>,>>9.99")).
                            end.
                 end. 
                 else do: /* пассивный счет Г/К */
                    if (arp.cam[1] - arp.dam[1]) >= amt 
                       then ok = true.
                       else do:
                              ok = false.
                              message "Не хватает средств на счете " + ref + "(" + 
                              trim(string(arp.cam[1] - arp.dam[1],"->>>,>>>,>>>,>>9.99")) + "),  платеж: " +
                              trim(string(amt,"->>>,>>>,>>>,>>9.99")).
                            end.
                 end. 
              end.
              else do:
                     message "Нет такого счета " + ref.
                     ok = false.
                   end.
 return ok.

end.

