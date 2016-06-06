/* mob-u300.i
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

/* 
  24.05.2003 nadejda - убраны параметры -H -S из коннекта 
*/

   define var kcell-ref as char format "x(10)" init "0".
   define var kcell-joudoc as char format "x(10)".

   if commonpl.joudoc <> ? then do:
      find first joudoc where joudoc.docnum = commonpl.joudoc no-lock no-error.
      if avail joudoc then if joudoc.jh > 0 and joudoc.jh <> ?
                      then do: 
                             kcell-ref = string(commonpl.dnum). 
                             kcell-joudoc = string(commonpl.joudoc).    
                           end.
   end.

   if can-find (joudoc where joudoc.docnum = commonpl.joudoc) 
      then run chgsts ("jou", commonpl.joudoc, "mb3"). 

   if ourbank = "TXB00" then do:

      create mobtemp.
      assign mobtemp.valdate = today
             mobtemp.cdate = today
             mobtemp.ctime = time
             mobtemp.sum = commonpl.sum
             mobtemp.who = g-ofc
             mobtemp.state = 3
             mobtemp.phone = string(commonpl.counter)
             mobtemp.ref = kcell-ref
             mobtemp.joudoc = kcell-joudoc
             mobtemp.rid = 0
             mobtemp.npl = commonpl.npl.
   end.
/*

   else do:
           find first comm.txb where comm.txb.txb = 0 and comm.txb.visible and comm.txb.consolid and comm.txb.city = 0 no-lock no-error.
           if connected ("txb") then disconnect "txb".
           connect value(" -db " + comm.txb.path + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).

           run ibcomtxb (today, g-ofc, kcell-ref, string(commonpl.counter),
                          commonpl.sum, string (commonpl.counter), 0, " ").

           if connected ('txb') then disconnect "txb".
       end.

*/



