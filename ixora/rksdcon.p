/* rksdcon.p
 * MODULE
       Департамент Регионального Развития
 * DESCRIPTION
       Отчет по изменениям оборотов клиентов с процентами (консолидированный) - вызывающая процедура
 * RUN

 * CALLER
        
 * SCRIPT

 * INHERIT

 * MENU
        
 * AUTHOR
        02/08/04 kanat
 * CHANGES
*/
{global.i}

def new shared var dt1 as date.
def new shared var dt2 as date.
def new shared var v-prc as decimal format "99".

def new shared frame opt 
       v-prc label "Процент уменьшения оборотов" skip
       dt1 label  "c " validate (dt1 <= g-today, " Дата не может быть больше текущей!") 
       dt2 label  "по " validate (dt2 <= g-today, " Дата не может быть больше текущей!")
       with row 8 centered side-labels.

update v-prc
       dt1
       dt2
       with frame opt.

if dt2 < dt1 then do:
    message "Неверно задана дата конца отчета".
    undo,retry.    
end.
hide frame opt.

output to report1.htm.
{html-start.i}

put unformatted
   "<IMG border=""0"" src=""http://www.texakabank.kz/images/top_logo_bw.gif""><BR><BR><BR>" skip
   "<B><P align = ""left""><FONT size=""2"" face=""Times New Roman Cyr, Verdana, sans"">" skip
   " Уменьшение оборотов клиентов СПФ с " string(dt1) " по " string(dt2) "</B></FONT><BR>" skip.

{r-branch.i &proc = "rksd1 (txb.name)"}

{html-end.i}
output close.
unix silent value("cptwin report1.htm excel").
pause 0.
