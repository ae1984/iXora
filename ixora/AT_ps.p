/* almtv-ofp.p
 * MODULE
        Коммунальные платежи
 * DESCRIPTION
        Автоматическая отправка реестров в Алматытелеком
        (bank,comm)
 * RUN
      
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        Процесс
 * AUTHOR
        15/08/2006 dpuchkov
 * CHANGES
        15/08/2006 dpuchkov добавил отправку в 9-00
        16/08/2006 dpuchkov переделал отправку в 9-00, 11-00,15-00,17-00.
        17/08/2006 dpuchkov добавил проверку на случай если закрытие дня прошло до 24-00.
        11/09/2006 dpuchkov убрал отправку DBF файлов.
        27.09.2006 dpuchkov вернул отправку файлов.
        05.10.2006 dpuchkov запретил отправку файлов
*/

{global.i}
{comm-txb.i}
{get-dep.i}


def buffer b-syss9  for sysc.
def buffer b-syss11 for sysc.
def buffer b-syss13 for sysc.
def buffer b-syss16 for sysc.
def buffer b-syss18 for sysc.
def var out as char    no-undo.
def var outtxt as char no-undo.
def var sum_final as decimal init 0 no-undo.
def var files as char initial "" no-undo.
def var ftxt as char initial "" no-undo.
def var subj as char no-undo.
def var v-email-name as char no-undo.
def var count_rec as integer init 0 no-undo.
def var s_izv as char no-undo.
def var s_ack as char no-undo.
def var v-bank-id as char no-undo.
def var str as char no-undo.
def var crlf as char no-undo.
def var dat as date no-undo.
crlf = chr(13) + chr(10).
DEFINE STREAM s1.
DEFINE STREAM s2.




find last b-syss9  where b-syss9.sysc  = 'KAZT09' exclusive-lock no-error.
find last b-syss11 where b-syss11.sysc = 'KAZT11' exclusive-lock no-error.
find last b-syss13 where b-syss13.sysc = 'KAZT13' exclusive-lock no-error.
find last b-syss16 where b-syss16.sysc = 'KAZT16' exclusive-lock no-error.
find last b-syss18 where b-syss18.sysc = 'KAZT18' exclusive-lock no-error.


if (not avail b-syss9) or (not avail b-syss11) or (not avail b-syss13) or (not avail b-syss16) or (not avail b-syss18) then do:
   return.
end.


if (time > 81000) and (time < 86400) then do:
   return.
end.

/*if today = date(b-syss13.chval) then return.*/
/* if today = 10.01.06 then*/
 return.


find last cls where cls.whn < g-today no-lock no-error.



if comm-cod() = 0  then do:
find first commonls where commonls.txb = 0 and commonls.grp = 3 and commonls.visible = yes and commonls.type = 1 no-lock no-error.


/* 11-00 */
  if time > 39600 then do:
     if g-today <> date(b-syss11.chval) then do:
        out = "TX" + string(day(g-today), "99") + string(month(g-today), "99") + substr(string("0001", "9999"), 3) + "." + "dbf".
        outtxt = "Tx" + string(g-today, "99.99.99" ).
        substr(outtxt, 5, 1) = "".
     
        OUTPUT STREAM s1 TO value(out).
        OUTPUT STREAM s2 TO value(outtxt).
        b-syss11.chval = string(g-today).
        for each commonpl where commonpl.txb = 0 and commonpl.date = g-today and commonpl.deluid = ? and commonpl.arp = commonls.arp and commonpl.grp = 3 exclusive-lock:
            if commonpl.cretime <= 39600 then do:
               commonpl.info[5] = "1".
               /* Формируем реестр*/
               dat = g-today.
               run Pr_reestr.
            end.
        end.
        OUTPUT STREAM s1 CLOSE.
        OUTPUT STREAM s2 CLOSE.


        unix SILENT value('kztdbf.pl 1 ' /* + string(count_rec,">>>>>>9") */ + ' ' + out).
        if sum_final > 0 then do:
           files = files + ";" + out.
           ftxt = ftxt + ";" + outtxt.
        end.
        substr(files,1,1) = "".
        if files = "" then subj = "11-00 С " + string(g-today,"99.99.99") + " по " + string(g-today,"99.99.99") + " платежей не было.".
        else subj = "Платежи АлматыТелеком 11-00 C " + string(g-today,"99.99.99") + " по " + string(g-today,"99.99.99").
        v-email-name = "municipal" + comm-txb() + "@elexnet.kz,oud@almatytelecom.kz".

 run mail(v-email-name,"TEXAKABANK <abpk@elexnet.kz>", subj, "", "1", "", files). 
 run mail("dpuchkov@elexnet.kz","TEXAKABANK <abpk@elexnet.kz>", subj, "", "1", "", files). 

   unix SILENT value('rm -f ' + out).
   unix SILENT value('rm -f Tx*'). 
     end.
  end.




/* 13-00 */
/*  if time > 46800 then do:
     if g-today <> date(b-syss13.chval) then do:
        out = "TX" + string(day(g-today), "99") + string(month(g-today), "99") + substr(string("0002", "9999"), 3) + "." + "dbf".
        outtxt = "Tx" + string(g-today, "99.99.99" ).
        substr(outtxt, 5, 1) = "".

        OUTPUT STREAM s1 TO value(out).
        OUTPUT STREAM s2 TO value(outtxt).
        b-syss13.chval = string(g-today).
        for each commonpl where commonpl.txb = 0 and commonpl.date = g-today and commonpl.deluid = ? and commonpl.arp = commonls.arp and commonpl.grp = 3 exclusive-lock:
            if (commonpl.cretime > 39600) and (commonpl.cretime <= 46800)  then do:
               commonpl.info[5] = "1".
               /* Формируем реестр */
               dat = g-today.
               run Pr_reestr.
            end.
        end.
        OUTPUT STREAM s1 CLOSE.
        OUTPUT STREAM s2 CLOSE.
        unix SILENT value('kztdbf.pl 1 ' /* + string(count_rec,">>>>>>9") */ + ' ' + out).
        if sum_final > 0 then do:
           files = files + ";" + out.
           ftxt = ftxt + ";" + outtxt.
        end.
 
        substr(files,1,1) = "".
        if files = "" then subj = "13-00 С " + string(g-today,"99.99.99") + " по " + string(g-today,"99.99.99") + " платежей не было.".
        else subj = "Платежи АлматыТелеком 13-00 C " + string(g-today,"99.99.99") + " по " + string(g-today,"99.99.99").
        v-email-name = "municipal" + comm-txb() + "@elexnet.kz,oud@almatytelecom.kz".
   run mail(v-email-name,"TEXAKABANK <abpk@elexnet.kz>", subj, "", "1", "", files). 
   run mail("dpuchkov@elexnet.kz","TEXAKABANK <abpk@elexnet.kz>", subj, "", "1", "", files). 
   unix SILENT value('rm -f ' + out). 
   unix SILENT value('rm -f Tx*'). 
     end.
  end. */


/* 54000 - 15-00 */
/* 61200 - 17-00 */

/* 15-00 */
/*  if time > 57600 then do:*/
  if time > 54000 then do:
     if g-today <> date(b-syss16.chval) then do:
        out = "TX" + string(day(g-today), "99") + string(month(g-today), "99") + substr(string("0002", "9999"), 3) + "." + "dbf".
        outtxt = "Tx" + string(g-today, "99.99.99" ).
        substr(outtxt, 5, 1) = "".

        OUTPUT STREAM s1 TO value(out).
        OUTPUT STREAM s2 TO value(outtxt).
        b-syss16.chval = string(g-today).
        for each commonpl where commonpl.txb = 0 and commonpl.date = g-today and commonpl.deluid = ? and commonpl.arp = commonls.arp and commonpl.grp = 3 exclusive-lock:
            if (commonpl.cretime > 39600) and (commonpl.cretime <= 54000)  then do:
               commonpl.info[5] = "1".
       /* Формируем реестр */
               dat = g-today.
               run Pr_reestr.
            end.
        end.
        OUTPUT STREAM s1 CLOSE.
        OUTPUT STREAM s2 CLOSE.
        unix SILENT value('kztdbf.pl 1 ' /* + string(count_rec,">>>>>>9") */ + ' ' + out).
        if sum_final > 0 then do:
           files = files + ";" + out.
           ftxt = ftxt + ";" + outtxt.
        end.

        substr(files,1,1) = "".
        if files = "" then subj = "15-00 С " + string(g-today,"99.99.99") + " по " + string(g-today,"99.99.99") + " платежей не было.".
        else subj = "Платежи АлматыТелеком 15-00 C " + string(g-today,"99.99.99") + " по " + string(g-today,"99.99.99").
        v-email-name = "municipal" + comm-txb() + "@elexnet.kz,oud@almatytelecom.kz".
   run mail(v-email-name,"TEXAKABANK <abpk@elexnet.kz>", subj, "", "1", "", files). 
   run mail("dpuchkov@elexnet.kz","TEXAKABANK <abpk@elexnet.kz>", subj, "", "1", "", files). 
   unix SILENT value('rm -f ' + out).
   unix SILENT value('rm -f Tx*'). 

     end.
  end.


 /* 17-00 */
 if time > 61200 then do:
    if g-today <> date(b-syss18.chval) then do:
       out = "TX" + string(day(g-today), "99") + string(month(g-today), "99") + substr(string("0003", "9999"), 3) + "." + "dbf".
       outtxt = "Tx" + string(g-today, "99.99.99" ).
       substr(outtxt, 5, 1) = "".

       OUTPUT STREAM s1 TO value(out).
       OUTPUT STREAM s2 TO value(outtxt).
       b-syss18.chval = string(g-today).

       for each commonpl where commonpl.txb = 0 and commonpl.date = g-today and commonpl.deluid = ? and commonpl.arp = commonls.arp and commonpl.grp = 3 exclusive-lock:
           if (commonpl.cretime > 54000) and (commonpl.cretime <= 61200)  then do:
              commonpl.info[5] = "1".
              /* Формируем реестр */
              dat = g-today.
              run Pr_reestr.
           end.
       end.
       OUTPUT STREAM s1 CLOSE.
       OUTPUT STREAM s2 CLOSE.
       unix SILENT value('kztdbf.pl 1 ' /* + string(count_rec,">>>>>>9") */ + ' ' + out).
       if sum_final > 0 then do:
          files = files + ";" + out.
          ftxt = ftxt + ";" + outtxt.
       end.

       substr(files,1,1) = "".
       if files = "" then subj = "17-00 С " + string(g-today,"99.99.99") + " по " + string(g-today,"99.99.99") + " платежей не было.".
       else subj = "Платежи АлматыТелеком 17-00 C " + string(g-today,"99.99.99") + " по " + string(g-today,"99.99.99").
       v-email-name = "municipal" + comm-txb() + "@elexnet.kz,oud@almatytelecom.kz".
   run mail(v-email-name,"TEXAKABANK <abpk@elexnet.kz>", subj, "", "1", "", files). 
   run mail("dpuchkov@elexnet.kz","TEXAKABANK <abpk@elexnet.kz>", subj, "", "1", "", files). 
   unix SILENT value('rm -f ' + out).
   unix SILENT value('rm -f Tx*'). 


    end.
 end.                        



 /* 9-00 за предыдущий день */

   if time > 32400 then do: 
      if g-today <> date(b-syss9.chval) then do:
         out = "TX" + string(day(cls.whn), "99") + string(month(cls.whn), "99") + substr(string("0004", "9999"), 3) + "." + "dbf".
         outtxt = "Tx" + string(cls.whn, "99.99.99" ).
         substr(outtxt, 5, 1) = "".
         OUTPUT STREAM s1 TO value(out).
         OUTPUT STREAM s2 TO value(outtxt).
         b-syss9.chval = string(g-today).

         for each commonpl where commonpl.txb = 0 and commonpl.date = cls.whn and commonpl.deluid = ? and commonpl.arp = commonls.arp and commonpl.grp = 3 exclusive-lock:
             if commonpl.info[5] <> "1" then do:
                commonpl.info[5] = "1".

                dat = cls.whn.
                run Pr_reestr.
             end.
         end.
         OUTPUT STREAM s1 CLOSE.
         OUTPUT STREAM s2 CLOSE.
         unix SILENT value('kztdbf.pl 1 ' /* + string(count_rec,">>>>>>9") */ + ' ' + out).
         if sum_final > 0 then do:
            files = files + ";" + out.
            ftxt = ftxt + ";" + outtxt.
         end.

         substr(files,1,1) = "".
         if files = "" then subj = "9-00 С " + string(cls.whn,"99.99.99") + " по " + string(cls.whn,"99.99.99") + " платежей не было.".
         else subj = "Платежи АлматыТелеком 9-00 C " + string(cls.whn,"99.99.99") + " по " + string(cls.whn,"99.99.99").
         v-email-name = "municipal" + comm-txb() + "@elexnet.kz,oud@almatytelecom.kz".
   run mail(v-email-name,"TEXAKABANK <abpk@elexnet.kz>", subj, "", "1", "", files). 
   run mail("dpuchkov@elexnet.kz","TEXAKABANK <abpk@elexnet.kz>", subj, "", "1", "", files). 
   unix SILENT value('rm -f ' + out).
   unix SILENT value('rm -f Tx*'). 

      end.
   end.


end.





Procedure Pr_reestr.
        count_rec = 0.

    PUT STREAM s2 "14" + string(get-dep(commonpl.uid, dat),"99") format "9999" " "
        commonpl.counter format "999999" " "
        commonpl.fioadr format "x(15)" " "
        commonpl.sum format ">>>>>>>>9.99" " "
        left-trim(string(commonpl.dnum,">>>>>>9")) format "x(5)"  " "
        commonpl.date
        chr(13) format "9"
        skip.



        find first kaztelsp where kaztelsp.statenmb = commonpl.fioadr and kaztelsp.accnt = commonp.accnt no-lock no-error.
        if avail kaztelsp then do:
        s_izv = trim(kaztelsp.statenmb).
        s_ack = string(kaztelsp.accnt).
        end.
        else do:
        if commonpl.accnt <> 0 then do:
        s_izv = commonpl.fioadr.
        s_ack = string(commonpl.accnt).
        end.
        else do:
/*        message "Отсутствует счет извещения абонента" view-as alert-box title "Внимание".
          return. */
        end.
        end.
        v-bank-id = "0007".
        str = v-bank-id + "|" +
              trim(string(commonpl.rko)) + "|" +
              s_izv + "|" +
              s_ack + "|" +
              string(day(commonpl.date),"99") + "." +
              string(month(commonpl.date),"99") + "." +
              string(year(commonpl.date)) + " " +
              string(commonpl.cretime,"HH:MM:SS") + "|" +
              trim(string(commonpl.dnum)) + "|" +
              trim(string(commonpl.sum)).
        count_rec = count_rec + 1.
        put stream s1 unformatted str crlf.
        sum_final = sum_final + commonpl.sum.

end.












