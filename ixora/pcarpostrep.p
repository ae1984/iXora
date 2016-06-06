/* pcarpostrep.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Сверка остатков по консолидированным счетам ДПК в системе AВС iXora и OpenWay
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        12/08/2013 galina
 * BASES
        BANK COMM
 * CHANGES
*/

{global.i}

def var v-date as date no-undo.
def var v-dateow as date no-undo.
def var v-bankname as char no-undo.
def var v-path as char no-undo.
def new shared temp-table t-rep no-undo
   field bank as char
   field dateow as date
   field dateabc as date
   field dateload as date
   field arp as char
   field crccode as char
   field sumow as deci
   field sumabc as deci
   field sumdef as deci
   field arpval as int
   index bank is primary arpval bank.

def stream rep.

def var v-weekbeg as int. /*первый день недели*/
def var v-weekend as int. /*последний день недели*/

/**находим последний день недели************************************************************/
find sysc where sysc.sysc = "WKEND" no-lock no-error.
if available sysc then v-weekend = sysc.inval.
else v-weekend = 6.
/*******************************************************************************************/

/**находим первый день недели***************************************************************/
find sysc where sysc.sysc = "WKSTRT" no-lock no-error.
if available sysc then v-weekbeg = sysc.inval.
else v-weekbeg = 2.

v-date = g-today.
update v-date format "99/99/9999" validate(v-date <> ?,'Введите дату') no-label with frame fdate centered row 5 overlay title 'Введите дату'.
v-dateow = v-date - 1.
repeat while month(v-date) = month(v-dateow):
    find hol where hol.hol eq v-dateow no-lock no-error.
    if not available hol and weekday(v-dateow) ge v-weekbeg and weekday(v-dateow) le v-weekend then leave. /*если день рабочий, то продолжаем закрытие опер. дня*/
    else v-dateow = v-dateow - 1. /*если день праздничный то переключаемся на следующий день, пока не найдем первый рабочий*/
end.

find first pcarpsum where pcarpsum.dtost = v-dateow no-lock no-error.
if not avail pcarpsum then do:
    message "Не найдены остаки по счетам из OW за " + string(v-dateow,'99/99/9999') view-as alert-box title 'ВНИМАНИЕ'.
    return.
end.
message "Ждите...".
{r-branch2.i &proc = "pcarpostrep_txb(v-date,v-dateow,comm.txb.bank)"}

output stream rep to rep.htm.
{html-title.i
 &stream = " stream rep "
 &size-add = "xx-"
 &title = " "
}

 put stream rep unformatted
 "<p><B>Сверка остатков по консолидированным счетам ДПК в системе AВС iXora и OpenWay<BR>" skip
 "за " string(v-date,'99/99/9999') "</B></p><BR><BR>" skip.

  put stream rep unformatted
 "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
 "<TR align=""center"" valign=""center"" style=""font:bold"";font-size:12>" skip
 "<TD>Филиал</TD>" skip
 "<TD>Дата OW</TD>" skip
 "<TD>Дата АВС</TD>" skip
 "<TD>Дата загрузки</TD>" skip
 "<TD>Номер счета</TD>" skip
 "<TD>Валюта счета</TD>" skip
 "<TD>Сумма остатка в OW</TD>" skip
 "<TD>Сумма остатка в АВС</TD>" skip
 "<TD>Сумма расхождения (+/-)</TD></TR>" skip.
 for each t-rep where t-rep.arpval = 1 no-lock break by t-rep.bank :
    if first-of(t-rep.bank) then do:
       v-bankname = ''.
       find first txb where txb.bank = t-rep.bank no-lock no-error.
       if avail txb then v-bankname = txb.info.
    end.
    put stream rep unformatted "<TR align=""center"" valign=""center"">"
                               "<TD>" v-bankname "</TD>" skip
                               "<TD>" string(t-rep.dateow,'99/99/9999')"</TD>" skip
                               "<TD>" string(t-rep.dateabc,'99/99/9999') "</TD>" skip
                               "<TD>" string(t-rep.dateload,'99/99/9999') "</TD>" skip
                               "<TD>" t-rep.arp "</TD>" skip
                               "<TD>" t-rep.crccode "</TD>" skip
                               "<TD>" replace(string(t-rep.sumow,'>>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
                               "<TD>" replace(string(t-rep.sumabc,'>>>>>>>>>>>>>9.99'),'.',',') "</TD>" skip
                               "<TD>" replace(string(t-rep.sumdef,'->>>>>>>>>>>>>9.99'),'.',',') "</TD></TR>" skip.
 end.
 put stream rep unformatted "</table>" skip.

find first t-rep where arpval = 2 no-lock no-error.
if avail t-rep then do:
    put stream rep unformatted "<br><br><br>" skip
    "<p><B>Cчета не найденные в ABC<BR></B></p>"skip
    "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"">" skip
     "<TR align=""center"" valign=""center"" style=""font:bold"";font-size:12>" skip
     "<TD>Филиал</TD>" skip
     "<TD>Дата OW</TD>" skip
     "<TD>Дата загрузки</TD>" skip
     "<TD>Номер счета</TD>" skip
     "<TD>Валюта счета</TD>" skip
     "<TD>Сумма остатка в OW</TD></tr>" skip.
     for each t-rep where t-rep.arpval = 2 no-lock break by t-rep.bank :
        if first-of(t-rep.bank) then do:
           v-bankname = ''.
           find first txb where txb.bank = t-rep.bank no-lock no-error.
           if avail txb then v-bankname = txb.info.
        end.
        put stream rep unformatted "<TR align=""center"" valign=""center"">"
                                   "<TD>" v-bankname "</TD>" skip
                                   "<TD>" string(t-rep.dateow,'99/99/9999')"</TD>" skip
                                   "<TD>" string(t-rep.dateload,'99/99/9999') "</TD>" skip
                                   "<TD>" t-rep.arp "</TD>" skip
                                   "<TD>" t-rep.crccode "</TD>" skip
                                   "<TD>" replace(string(t-rep.sumow,'>>>>>>>>>>>>>9.99'),'.',',') "</TD></tr>" skip.
     end.

end.

{html-end.i}

output stream rep close.

hide all no-pause.

unix silent value("cptwin rep.htm excel").
unix silent rm -f  rep.htm.
