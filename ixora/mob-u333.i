/* mob-u333.i
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
      24.07.2006 tsoy     - создание mobi-pay
        30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
*/



   define var kmobile-ref as char format "x(10)" init "0".

   if commonpl.joudoc <> ? then do:
      find first joudoc where joudoc.docnum = commonpl.joudoc no-lock no-error.
      if avail joudoc then if joudoc.jh > 0 and joudoc.jh <> ?
                      then kmobile-ref = string(joudoc.jh).
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
             mobtemp.state = 0
             mobtemp.phone = string(commonpl.counter)
             mobtemp.ref = kmobile-ref
             mobtemp.npl = string (commonpl.counter).

   end.
   else do:
           find first comm.txb where comm.txb.txb = 0 and comm.txb.visible and comm.txb.city = 0 and comm.txb.consolid no-lock no-error.
           if connected ("txb") then disconnect "txb".
           connect value(" -db " + comm.txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).

           run mob333txb (today, g-ofc, kmobile-ref, string(commonpl.counter),
                          commonpl.sum, string (commonpl.counter)).

           if connected ('txb') then disconnect "txb".
   end.

   create mobi-pay.
   assign    mobi-pay.creator_uid  = "TEXAKA1"
       mobi-pay.msisdn       = mobtemp.phone
       mobi-pay.amount       = mobtemp.sum
       mobi-pay.pay_date     = today.

       find jh where jh.jh  = s-jh no-lock no-error.
       if avail jh then do:
           mobi-pay.receipt_num  = string(s-jh).    
           mobi-pay.commit_date  = jh.jdt.
           mobi-pay.commit_time  = jh.tim.
       end.

       mobi-pay.pay_src_id   = "4".  
       mobi-pay.branch       = "ALA" + ourbank.
       mobi-pay.trade_point  = "". 
       mobi-pay.filename     = "".    
       mobi-pay.comm         = 0.    



