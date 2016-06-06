/* repMT998_out.p
 * MODULE
       Платежная система 
 * DESCRIPTION
        отчеты по уведомлениям об откр/закр счетов ЮЛ
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
       repMT998.p 
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
      
 * AUTHOR
        23/07/2008 galina
 * BASES
        BANK COMM
 * CHANGES
        24.07.2008 galina - перекомпиляция после загрузки новой таблицы в comm
        25.07.2008 galina - добавлен консолидированный отчет
        12.08.2008 galina - выводим наменование банка для консолидированного отчета
        25.08.2008 galina - исправила вывод периода формирования отчета
        09.09.2008 galina - выводим дату открытия/закрытия счета  
        16.04.2009 galina - формирования отчета по изменению номера счета                  
*/
{global.i}
def input parameter p-reptype as integer.
def input parameter p-bank as char.
def input parameter p-bankname as char.
def input parameter p-dep1 as integer.
def input parameter p-departch as char.
def input parameter p-dat1 as date.
def input parameter p-dat2 as date.
def input parameter p-acc as char.
def input parameter p-opertype as char.

def var v-resultch as char.

def temp-table t-repmt998in
  field depart as char
  field dtin as date
  field intime as char
  field dtout as date
  field outtime as char
  field acc as char
  field result as char
  field resultch as char
  field bankname as char
  field accdt as date.

def stream repmt998in.

  acc:
  for each acclet-detail where (acclet-detail.bank = p-bank or p-bank = "ALL") and (acclet-detail.dtout >= p-dat1 and acclet-detail.dtout <= p-dat2) and (p-acc = " " or acclet-detail.acc = p-acc) use-index bnkdtoutacc no-lock:
    if acclet-detail.opertype <> p-opertype then next acc.
    if p-dep1 <> 0 then do: 
      if p-dep1 <> 1 and acclet-detail.jame = " " then next acc.
      if acclet-detail.jame <> " " and (integer(acclet-detail.jame) mod 1000 <> p-dep1) then next acc.
    end.
    if acclet-detail.answer <> " " then do:
        find codfr where codfr.codfr = "mt998res" and codfr.code = acclet-detail.result no-lock no-error.
        if not avail codfr then message "Неверный код результата завешения операции!" view-as alert-box.
        v-resultch = codfr.name[1].
    end.
    else v-resultch = " ".
    create t-repmt998in.
    assign
       t-repmt998in.depart = p-departch
       t-repmt998in.dtin = acclet-detail.dtin
       t-repmt998in.intime = string(acclet-detail.intime,'hh:mm:ss')
       t-repmt998in.dtout = acclet-detail.dtout
       t-repmt998in.outtime = string(acclet-detail.outtime,'hh:mm:ss')
       t-repmt998in.acc = acclet-detail.acc
       t-repmt998in.result = acclet-detail.result
       t-repmt998in.resultch = v-resultch
       t-repmt998in.accdt = acclet-detail.accdt.
       
       find txb where txb.consolid = true and txb.bank = acclet-detail.bank no-lock no-error. 
       if avail txb then t-repmt998in.bankname = txb.info.

  end.
/*end.*/

   output stream repmt998in to value("repmt998.xls").
  
   {html-title.i 
    &stream = " stream repmt998in "
    &title = " "
    &size-add = "xx-"
    }
      
    find first cmp no-lock no-error.
    
    if p-reptype = 2 then 
      put stream repmt998in unformatted
        "<P align = ""center""><FONT size=""3"" face=""Times New Roman"">" skip
        "<B>Отчет по уведомлениям об открытии счетов ЮЛ</B><BR>".

    if p-reptype = 3 then 
      put stream repmt998in unformatted
        "<P align = ""center""><FONT size=""3"" face=""Times New Roman"">" skip
        "<B>Отчет по уведомлениям о закрытии счетов ЮЛ</B><BR>".

    if p-reptype = 4 then 
      put stream repmt998in unformatted
        "<P align = ""center""><FONT size=""3"" face=""Times New Roman"">" skip
        "<B>Отчет по уведомлениям об изменении номеров банковских счетов</B><BR>".

    
    if p-dat1 <> p-dat2 then 
         put stream repmt998in unformatted
         "За период с " string(p-dat1,'99/99/99') " по " string(p-dat2,'99/99/99') "<BR>".
    if p-dat1 = p-dat2 then 
         put stream repmt998in unformatted
         "За " string(p-dat1,'99/99/99') "<BR>".               
           
    put stream repmt998in unformatted    
        "Дата отчета " g-today
        "</FONT></P>"
        "<P align = ""left""><FONT size=""2"" face=""Times New Roman"">" skip
        "Наименование банка: "  cmp.name "&nbsp;&nbsp;" 
         p-bankname skip.
         
    if p-bank <> "ALL" then        
     put stream repmt998in unformatted    
         "<BR>Структурное подразделение: " p-departch  "</P></FONT>" skip.
  
       put stream repmt998in unformatted
           "<TABLE  border=""1"" cellspacing=""33"" cellpadding=""0"">" skip
           "<TR align=""center"" valign=""center"" style=""font:bold; font-family:Arial; font-size:8.0pt"" bgcolor=""#C0C0C0"">" skip
           "<TD>Дата и время<BR>отправки Уведомления<BR>об открытии<BR>банковских счетов</TD>" skip.
       if p-opertype = "1" then 
          put stream repmt998in unformatted    
           "<TD>Открытый счет(а)</TD>" skip
           "<TD>Дата открытия счета</TD>" skip.

       if p-opertype = "2" then 
          put stream repmt998in unformatted    
           "<TD>Закрытый счет(а)</TD>" skip
           "<TD>Дата закрытия счета</TD>" skip.
        
       if p-opertype = "3" then 
          put stream repmt998in unformatted    
          "<TD>Открытый счет(а)</TD>" skip.
           
           
       put stream repmt998in unformatted    
          "<TD>Дата и время<BR>получения Подтверждения<BR>о получении<BR>Уведомления<BR>".
          
       if p-opertype = "1" then put stream repmt998in unformatted  "об открытии<BR>".
       
       if p-opertype = "2" then put stream repmt998in unformatted  "о закрытии<BR>".
       
       if p-opertype = "3" then put stream repmt998in unformatted  "о изменении номеров<BR>".
       
       put stream repmt998in unformatted "банковских счетов</TD>" skip.

       if p-opertype = "1" then 
          put stream repmt998in unformatted               
           "<TD>Код результатов<BR>завершения операций<BR>по открытию счета<BR>с расшифровкой</TD>" skip.

       if p-opertype = "2" then 
          put stream repmt998in unformatted               
           "<TD>Код результатов<BR>завершения операций<BR>по закрытию счета<BR>с расшифровкой</TD>" skip.

       if p-opertype = "3" then 
          put stream repmt998in unformatted               
           "<TD>Код результатов<BR>завершения операций<BR>по изменению номеров банковских счетов<BR>(с расшифровкой)</TD>" skip.
    
           
        if p-bank = "ALL" then 
          put stream repmt998in unformatted               
           "<TD>Наименование банка</TD>" skip.
     
          put stream repmt998in unformatted               
          "</TR>" skip. 

  find first t-repmt998in no-lock no-error.
  if avail t-repmt998in then do:
      for each  t-repmt998in no-lock:   
           put stream repmt998in unformatted
           "<TR align=""center""<font size=""4"">"
           "<TD>" string(t-repmt998in.dtout,'99/99/99') "&nbsp;" t-repmt998in.outtime "</TD>" skip
           "<TD>&nbsp;" t-repmt998in.acc "</TD>" skip.
           if p-opertype <> "3" then 
           put stream repmt998in unformatted
           "<TD>" string(t-repmt998in.accdt,'99/99/99') "</TD>".
           
           if (t-repmt998in.dtin <> ? and t-repmt998in.intime <> "00:00:00") then
               put stream repmt998in unformatted
               "<TD>" string(t-repmt998in.dtin,'99/99/99') "&nbsp;" t-repmt998in.intime "</TD>" skip.
           else 
               put stream repmt998in unformatted
               "<TD>"  "</TD>" skip.
           
           put stream repmt998in unformatted
           "<TD>" t-repmt998in.result "&nbsp;" t-repmt998in.resultch "</TD>" skip.
           
           if p-bank = "ALL" then 
             put stream repmt998in unformatted
             "<TD>" t-repmt998in.bankname "</TD>" skip.     
           
           put stream repmt998in unformatted       
           "</FOUNT></TR>" skip.                    

      end.
      put stream repmt998in unformatted
      "</FOUNT></TABLE>" skip.
   end.     
      
   {html-end.i}  
   output stream repmt998in close.  
   unix silent value("cptwin repmt998.xls excel").
   unix silent value("rm -f repmt998.xls excel").




