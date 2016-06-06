/* repMT998_in.p
 * MODULE
       Платежная система 
 * DESCRIPTION
        отчеты по подтверждениям по уведомлениям об откр/закр счетов ЮЛ
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
        02.12.2008 galina - убрала отладочный message             
*/
{global.i}

def input parameter p-bank as char.
def input parameter p-bankname as char.
def input parameter p-dep1 as integer.
def input parameter p-departch as char.
def input parameter p-dat1 as date.
def input parameter p-dat2 as date.
def input parameter p-acc as char.

def temp-table t-repmt998in
  field depart as char
  field dtin as date
  field intime as char
  field acc as char
  field result as char
  field resultch as char
  field bankname as char
  field accdt as date.

def stream repmt998in.
  acc:  
  for each acclet-detail where (acclet-detail.bank = p-bank or p-bank = "ALL") and (acclet-detail.dtin >= p-dat1 and acclet-detail.dtin <= p-dat2) and (p-acc = " " or acclet-detail.acc = p-acc) use-index bnkdtinacc no-lock:
    if p-dep1 <> 0 then do: 
      if p-dep1 <> 1 and acclet-detail.jame = " " then next acc.
      if acclet-detail.jame <> " " and (integer(acclet-detail.jame) mod 1000 <> p-dep1) then next acc.
    end. 
    find codfr where codfr.codfr = "mt998res" and codfr.code = acclet-detail.result no-lock no-error.
    if not avail codfr then message "Неверный код результата завешения операции!" view-as alert-box.
    create t-repmt998in.
    assign
       t-repmt998in.depart = p-departch
       t-repmt998in.dtin = acclet-detail.dtin
       t-repmt998in.intime = string(acclet-detail.intime,'hh:mm:ss')
       t-repmt998in.acc = acclet-detail.acc
       t-repmt998in.result = acclet-detail.result
       t-repmt998in.resultch = codfr.name[1]
       t-repmt998in.accdt = acclet-detail.accdt.
        
       find txb where txb.consolid = true and txb.bank = acclet-detail.bank no-lock no-error. 
       if avail txb then t-repmt998in.bankname = txb.info.
  end.
/*end.*/

output stream repmt998in to value("repmt998in.xls").
  
{html-title.i 
 &stream = " stream repmt998in "
 &title = " "
 &size-add = "xx-"}
      
 find first cmp no-lock no-error.
 put stream repmt998in unformatted
     "<P align = ""center""><FONT size=""3"" face=""Times New Roman"">" skip
     "<B>Подтверждение получения уведомления об открытии/закрытии банковского счета</B><BR>".
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
       p-bankname "</P></FONT>" skip.     
 
    
  put stream repmt998in unformatted
      "<TABLE  border=""1"" cellspacing=""33"" cellpadding=""0"">" skip
      "<TR align=""center"" valign=""center"" style=""font:bold; font-family:Arial; font-size:8.0pt"" bgcolor=""#C0C0C0"">" skip.
      
  if p-bank <> "ALL" then put stream repmt998in unformatted
      "<TD>Структурное подразделение</TD>" skip.
      
  else put stream repmt998in unformatted
      "<TD>Наименование банка</TD>" skip.
      
      put stream repmt998in unformatted    
      "<TD>ИИК</TD>"
      "<TD>Дата открытия/закрытия счета</TD>"
      "<TD>Дата и время<BR>принятия уведомления</TD>"
      "<TD>Статус уведомления<BR>с расшифровкой</TD>"
      "</TR>" skip. 

 find first t-repmt998in no-lock no-error.
 if avail t-repmt998in then do:     
      for each  t-repmt998in no-lock:   
          put stream repmt998in unformatted
          "<TR align=""center""<font size=""4"">".
          
          if p-bank <> "ALL" then put stream repmt998in unformatted
          "<TD>" t-repmt998in.depart "</TD>" skip.
          
          else put stream repmt998in unformatted
          "<TD>" t-repmt998in.bankname "</TD>" skip.
          
          put stream repmt998in unformatted
          "<TD>&nbsp;" t-repmt998in.acc "</TD>" skip
          "<TD>" t-repmt998in.accdt "</TD>" skip
          "<TD>" string(t-repmt998in.dtin,'99/99/99') "&nbsp;" t-repmt998in.intime "</TD>" skip
          "<TD>" t-repmt998in.result "&nbsp;" t-repmt998in.resultch "</TD>" skip
          "</FOUNT></TR>" skip.                    
      end.
      put stream repmt998in unformatted
      "</FOUNT></TABLE>" skip.
  end.     
      
  {html-end.i}  
   output stream repmt998in close.  
   unix silent value("cptwin repmt998in.xls excel").
   unix silent value("rm -f repmt998in.xls excel").




