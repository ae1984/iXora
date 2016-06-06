/* rdeltrx.p
 * MODULE
        Контроль документов
 * DESCRIPTION
        Отчет по удаленным транзакциям на дату. 
 * RUN
        П.м. 8-6-3-1
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        8-6-3-1
 * AUTHOR
        25.04.05 saltanat
 * CHANGES
*/
{mainhead.i}

def var dt1 as date.
def var dt2 as date.
def var dep as char.
def var cod as char.
def var depname as char.
def var manager as char.
def var controller as char.
def var v-crc like crc.code.
def var v-nom as int.

dt1 = g-today.
dt2 = g-today.
dep = '*'.
cod = '000,001,002,003,004,msc'.

def frame fr
    dt1 label 'Введите нач.дату   ' format '99/99/99' skip
    dt2 label 'Введите кон.дату   ' format '99/99/99' skip
    dep label 'Введите департамент' format 'x(20)' 
        validate(can-find(codfr where codfr.codfr = 'sproftcn' and 
                                      codfr.code = dep and codfr.code matches '...' and 
                                      lookup(codfr.code,cod) = 0 no-lock) or (dep = '*'), ' Ошибочный код Департамента - повторите ! ') 
        help '* - Данные по всем департаментам' skip
 with side-label centered row 3 title 'Данные отчета'.

on help of dep in frame fr do:
  {itemlist.i
       &file = "codfr"
       &frame = "row 6 scroll 1 12 down overlay "
       &where = " codfr.codfr = 'sproftcn' and codfr.code matches '...' and lookup(codfr.code,cod) = 0 "
       &flddisp = " codfr.code label 'Код' codfr.name[1] label 'Департамент' format 'x(50)'
                  "
       &chkey = "code"
       &chtype = "string"
       &index  = "cdco_idx"
       &end = "if keyfunction(lastkey) eq 'end-error' then return."
  }
  dep = codfr.code.
  displ dep with frame fr.
end.

update dt1 dt2 with frame fr.

find ofc where ofc.ofc = g-ofc no-lock no-error.
if avail ofc and ofc.titcd = '513' then
   update dt1 dt2 dep with frame fr. 
else
   update dep with frame fr.

/* вывод отчета в HTML */
def stream vcrpt.
/* Ш А П К А */
output stream vcrpt to vcreestr.xls.
{html-title.i 
 &stream = " stream vcrpt "
 &title = "Отчет по общей сумме оборотов"
 &size-add = "xx-"
}
        put stream vcrpt unformatted 
           "<P align = ""center""><FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans"">"
           "<B>Отчет по удаленным транзакциям <BR>" + depname + "<BR>за период с " + string(dt1, "99/99/9999") + 
               " по " + string(dt2, "99/99/9999") + "</B></FONT></P>" skip(1).

        put stream vcrpt unformatted 
           "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"">" skip.
     
        put stream vcrpt unformatted 
            "<TR align=""center"" bgcolor=""#999999"">" skip
         "<TD><FONT size=""2""><B>Департамент</B></FONT></TD>" skip
         "<TD><FONT size=""2""><B>N=транз</B></FONT></TD>" skip
         "<TD><FONT size=""2""><B>Счет гл.кн.</B></FONT></TD>" skip
         "<TD><FONT size=""2""><B>Счет</B></FONT></TD>" skip
         "<TD><FONT size=""2""><B>Дебет</B></FONT></TD>" skip
         "<TD><FONT size=""2""><B>Кредит</B></FONT></TD>" skip
         "<TD><FONT size=""2""><B>Содержание</B></FONT></TD>" skip
         "<TD><FONT size=""2""><B>Валюта</B></FONT></TD>" skip
             "<TD><FONT size=""2""><B>Причина</B></FONT></TD>" skip
         "<TD><FONT size=""2""><B>Вина</B></FONT></TD>" skip
             "<TD><FONT size=""2""><B>Удалил</B></FONT></TD>" skip
             "<TD><FONT size=""2""><B>Дата</B></FONT></TD>" skip
             "<TD><FONT size=""2""><B>Время</B></FONT></TD>" skip
             "<TD><FONT size=""2""><B>Акцептовал</B></FONT></TD>" skip
             "<TD><FONT size=""2""><B>Дата</B></FONT></TD>" skip
             "<TD><FONT size=""2""><B>Время</B></FONT></TD>" skip
            "</TR>" skip.          
    /* Ш А П К А */      

for each trxdel_aks_control where trxdel_aks_control.sts = 'a' and trxdel_aks_control.dwhn >= dt1 and
                                  trxdel_aks_control.dwhn <= dt2 and 
                                  if dep = '*' then true else trxdel_aks_control.dop = dep no-lock 
                            break by trxdel_aks_control.dop by trxdel_aks_control.dwhn:
   if first-of(trxdel_aks_control.dop) then do:
            find codfr where codfr.codfr = 'sproftcn' and codfr.code = trxdel_aks_control.dop and 
                         codfr.code matches '...' and lookup(codfr.code,cod) = 0 no-lock no-error.
            if avail codfr then depname = codfr.name[1].
        else depname = ''.                 
   end.
   
   /* Д А Н Н Ы Е */
   
        find ofc where ofc.ofc = trxdel_aks_control.dwho no-lock no-error.
        if avail ofc then manager = ofc.name.
        else manager = ''.
        
        find ofc where ofc.ofc = trxdel_aks_control.awho no-lock no-error.
        if avail ofc then controller = ofc.name.
        else controller = ''.
        
        find first deljl where deljl.jh = trxdel_aks_control.jh no-lock no-error.
        if not avail deljl then next.
        for each deljl where deljl.jh = trxdel_aks_control.jh no-lock:

                v-nom = integer(entry(1,deljl.bywho," ")).
                find crc where crc.crc = v-nom use-index crc no-lock no-error.
                if  avail crc then do:
                    v-crc = crc.code.
                end.
                put stream vcrpt unformatted 
                "<TR align=""center"">" skip
                 "<TD><FONT size=""2"">" depname "</FONT></TD>" skip
                 "<TD><FONT size=""2"">" string(trxdel_aks_control.jh)     "</FONT></TD>" skip
                 "<TD><FONT size=""2"">" deljl.gl "</FONT></TD>" skip
                 "<TD><FONT size=""2"">" deljl.acc "</FONT></TD>" skip
                 "<TD><FONT size=""2"">" deljl.dam "</FONT></TD>" skip
                 "<TD><FONT size=""2"">" deljl.cam "</FONT></TD>" skip
                 "<TD><FONT size=""2"">" deljl.rem[1] "</FONT></TD>" skip
                 "<TD><FONT size=""2"">" v-crc "</FONT></TD>" skip
                 "<TD><FONT size=""2"">" trxdel_aks_control.reason "</FONT></TD>" skip
                     "<TD><FONT size=""2"">" trxdel_aks_control.fault  "</FONT></TD>" skip
                         "<TD><FONT size=""2"">" manager                   "</FONT></TD>" skip
                 "<TD><FONT size=""2"">" string(trxdel_aks_control.dwhn,"99/99/99")   "</FONT></TD>" skip
                 "<TD><FONT size=""2"">" string(trxdel_aks_control.dtim,"hh:mm:ss")  "</FONT></TD>" skip
                     "<TD><FONT size=""2"">" controller                "</FONT></TD>" skip
                 "<TD><FONT size=""2"">" string(trxdel_aks_control.awhn,"99/99/99")   "</FONT></TD>" skip
                "<TD><FONT size=""2"">"  string(trxdel_aks_control.atim,"hh:mm:ss")   "</FONT></TD>" skip
                "</TR>" skip.      
        end.    
        
   /* Д А Н Н Ы Е */
   
end.

    /* К О Н Е Ц */
        put stream vcrpt unformatted  
        "</TABLE>" skip.

        {html-end.i "stream vcrpt" }
        output stream vcrpt close.
        unix silent value("cptwin vcreestr.xls excel").
        pause 0.
    /* К О Н Е Ц */        


