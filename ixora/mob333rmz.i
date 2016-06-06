/* mob333rmz.i
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
        03.08.2005 kanat   - Добавил условие по просьбе получателя платежей - если платеж - безнал., то 
        		     вместо префикса и номера телефлона ставим 1000000000,
                             так как есть номер телефона 1000000 в K-Mobile.

        24.07.2006 tsoy       - изменил счет  CIF на АРП Картела

*/

    /* ТОО "КаР-Тел" cif = t24810*/    
    if remtrz.cracc = "011999832" or 
       (trim (remtrz.cracc) = "" and remtrz.racc = "011999832")
    then do: /* автоматически пошлем извещение в KMobile */

        define var i-phone as int.
        define var v-phones as char init "".
        define var v-detpay as char.
        define var kmobile-ref as char format "x(10)" init "0".

        if (remtrz.jh2 <> 0) and (remtrz.jh2 <> ?) then kmobile-ref = string (remtrz.jh2).
        else
        if (remtrz.jh1 <> 0) and (remtrz.jh1 <> ?) then kmobile-ref = string (remtrz.jh1).


        /* здесь - выяснить, в какой строке брать номер телефона */
        v-detpay = trim(remtrz.detpay[1]) +
                   trim(remtrz.detpay[2]) +
                   trim(remtrz.detpay[3]) +
                   trim(remtrz.detpay[4]).

        v-phones = v-detpay.

        if length(v-detpay) = 10 then do:


            if seltown = "TXB00" then do:                                                                  
               create mobtemp.                                                                                
               assign mobtemp.valdate = today                                                                    
                      mobtemp.cdate = g-today                                                                   
                      mobtemp.ctime = time                                                                    
                      mobtemp.sum = remtrz.amt
                      mobtemp.who = g-ofc                                                                     
                      mobtemp.state = 0                                                                       
                      mobtemp.phone = v-detpay
                      mobtemp.ref = kmobile-ref
                      mobtemp.npl = v-detpay
                      no-error.                                                                               

            create mobi-pay.
                   mobi-pay.creator_uid  = "TEXAKA1". 
                   mobi-pay.msisdn       = mobtemp.phone.
                   mobi-pay.amount       = mobtemp.sum.
                   mobi-pay.pay_date     = today.

                   find jh where jh.jh  = integer(kmobile-ref) no-lock no-error.
                   if avail jh then do:
                       mobi-pay.receipt_num  = kmobile-ref.    
                       mobi-pay.commit_date  = jh.jdt.
                       mobi-pay.commit_time  = jh.tim.
                   end.

                   mobi-pay.pay_src_id   = "4".  
                   mobi-pay.branch       = "ALA".
                   mobi-pay.trade_point  = "". 
                   mobi-pay.filename     = "".    
                   mobi-pay.comm         = 0.    


            end.                                                                                              
            else run mob333txa (today, g-ofc, kmobile-ref, v-phones, remtrz.amt, v-detpay).

        end.
        end.
