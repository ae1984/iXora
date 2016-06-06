/* pkdogudv.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Печать договора о замене удостоверения в случае истечении срока его действия.
 * RUN
      
 * CALLER
        jou-aasnew.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
       
 * AUTHOR
        26.11.2004 saltanat
 * CHANGES
        10/06/2005 madiyar - орган выдачи документа - из переменной
        31/01/2006 madiyar - кому адресовано заявление - из локальных настроек
        19/05/2006 madiyar - старше 45 лет - убрал next
        24/04/2007 madiyar - веб-анкеты
*/

/* Договор о замене удостоверения */

def var v-let   as inte no-undo.
def var v-esrok as date no-undo.
def var v-raz   as inte no-undo.
def var v-resdt as date no-undo.
def var v-logi  as logical no-undo init false.

FUNCTION day_fun returns integer (dd as integer, mm as integer).
def var f1 as char init '1,3,5,7,8,10,12'.
    if dd < 29 or (dd = 29 and mm <> 2) then return dd.
    if mm = 2 then return 28.
    if lookup(string(mm),f1) = 0 and dd = 31 then return 30.
    else return dd.
end FUNCTION.

FUNCTION res_dt returns date (d as date, v-srok as integer).
def var v-day  as inte no-undo.
def var v-mon  as inte no-undo.
def var v-year as inte no-undo.
def var v-nyer as inte no-undo.
def var v-ost  as inte no-undo.
def var v-res  as date no-undo.
 
   v-day  = day(d).  v-mon  = month(d). v-year = year(d).
          
   v-ost  = v-srok mod 12.
   v-nyer = (v-srok - v-ost) / 12.
   v-mon  = v-mon  + v-ost.
   v-year = v-year + v-nyer.

   if v-mon > 12 then do:
      v-mon = v-mon - 12.
      v-year = v-year + 1.
   end.

   v-day = day_fun(v-day,v-mon).

   v-res  = date( string(v-day) + '/' + string(v-mon) + '/' + string(v-year)).

   return v-res.
   
end FUNCTION.

find pkanketh where pkanketh.bank     = s-ourbank
                and pkanketh.credtype = s-credtype
                and pkanketh.ln       = s-pkankln
                and pkanketh.kritcod  = 'bdt' no-lock no-error.

if avail pkanketh then do:

    /* Приведение даты в надлежащий вид*/
    if pkanketh.value1 <> '' then do:
     
     v-let = year(g-today) - year(date(pkanketh.value1)).
     
     /* Берем возраст клиента, срок вклада и текущую дату */
     find pkanketa where pkanketa.bank     = s-ourbank
                     and pkanketa.credtype = s-credtype
                     and pkanketa.ln       = pkanketh.ln no-lock no-error.
     if avail pkanketa then do:

        if v-let > 45 then v-logi = false.
        else do:
            v-esrok = res_dt(pkanketa.rdt, pkanketa.srok).
            
            if v-let <= 25 then do:
               v-raz = 25 - v-let.
            end.
            else do:
               v-raz = 45 - v-let.
            end.
            
            v-resdt = date( string(day(date(pkanketh.value1))) + '/' + string(month(date(pkanketh.value1))) + '/' + string(year(g-today) + v-raz)).
            
            if v-resdt < v-esrok then v-logi = true.
            else v-logi = false.
        end.
     end.

    end.
    
end.

if v-logi = true then do:

v-ofile = "kredzayav7.htm".

output stream v-out to value(v-ofile).
put stream v-out unformatted "<!-- Обязательство о замене удостоверения в случае истечении срока его действия -->" skip.
{html-title.i
 &stream = " stream v-out "
 &title = " "
 &size-add = "x-"
}

/* sasco - поменял 091 на 089 */
put stream v-out unformatted
  "<TABLE width=""98%"" border=""0"" cellspacing=""0"" cellpadding=""1"" align=""center"">" skip
  "<TR><TD><TABLE width=""95%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""center"">" skip
  "<TR><TD align=""left""><img src=""" + v-toplogo + """></TD>" skip
  "</TR></TABLE></TD></TR>" skip
  "<TR><TD><TABLE width=""95%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""center"">" skip
  "<TD width=""50%""></TD>" skip
  "<TD width=""50%"">&nbsp;<BR>" skip
  v-bankkomupos "<BR>" v-bankkomufio "<BR>от " v-name "<BR>удостоверение N " v-docnum "<BR> выдано " v-docvyd " " trim(string(v-docdt,"x(40)")) "<BR><BR>&nbsp;<BR>" skip
  "</TD>" skip
  "</TR></TABLE></TD></TR>" skip
  
  "<TR><TD>" skip
  "<P align=""center""><B>ОБЯЗАТЕЛЬСТВО</B><BR></P>" skip
  "<P align=""justify"">Я, <i><u>&nbsp;" v-name "&nbsp;</i></u>, "
  "обязуюсь в течении 3-х дней с даты получения нового удостоверения личности предоставить его в АО 'Метрокомбанк', в связи с тем, что срок "
  "действия данного удостоверения истекает&nbsp;" string(v-resdt, "99/99/9999") "&nbsp;г.</P></TD></TR>" skip
  "<TR><TD><BR><BR><BR><BR><BR>" skip
  "<TABLE width=""95%"" border=""0"" cellspacing=""0"" cellpadding=""0"">" skip
  "<TR><TD align=""left"" width=""50%"">""______""______________________________г.</TD>" skip
  "<TD align=""right"" width=""50%""></TD></TR>" skip
  "<TR><TD colspan=""2"">&nbsp;</TD></TR>" skip
  "<TR><TD align=""left"" width=""50%"">*_____________________________________</TD>" skip
  "<TD align=""right"" width=""50%"">_____________________________________</TD></TR>" skip
  "<TR style=""font-size:9px;font:bold,italic""><TD align=""center"" width=""50%"">(Ф.И.О. полностью)</TD>" skip
  "<TD align=""center"" width=""50%"">(подпись)</TD></TR>" skip
  "<TR><TD width=""50%"">&nbsp;<BR>&nbsp;<BR>&nbsp;<BR>&nbsp;<BR></TD><TD width=""50%""></TD></TR>" skip
  "</TABLE>" skip
  "</TD></TR></TABLE>" skip.

{html-end.i "stream v-out" }

output stream v-out close.
if v-inet then unix silent value("mv " + v-ofile + " /var/www/html/docs/" + s-credtype + "/" + string(s-pkankln) + "; chmod 666 /var/www/html/docs/" + s-credtype + "/" + string(s-pkankln) + "/" + v-ofile).
else unix silent value("cptwin " + v-ofile + " iexplore").
end.
