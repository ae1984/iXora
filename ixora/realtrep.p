/* realtrep.p
 * MODULE
        Комуналки
 * DESCRIPTION
        Reestr платежей , принятых за один день по РГП "Центр по недвижимости по г. Алматы"
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
        вызывается из меню
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
       
 * AUTHOR
        17.01.06 u00568 evgeniy  по ТЗ198 от 20/12/05 ДРР
 * CHANGES
*/

def stream st1.
def var v-dat as date init today.
def var v-coun as deci.
def var v-sum as deci.
def var temp-sum as deci init 0.
def var p-npl like commonpl.npl.
def var nam as char init "".

update v-dat label ' Укажите дату ' format '99/99/9999' skip
       with side-label row 5 centered frame dat .

   output stream st1 to atk.img.

   {html-title.i
    &stream = " stream st1 "
    &title = " "
    &size-add = "x-"
   }
   put stream st1 unformatted   "<P align=""center"" style=""font:bold"">Реестр платежей <br> на дату " string(v-dat, "99/99/9999") skip.

   put stream st1 unformatted
     "<TABLE cellspacing=""0"" cellpadding=""5"" border=""1"">" skip
       "<TR align=""center"" style=""font:bold"">" skip
         "<TD>Дата платежа</TD>" skip
         "<TD>Номер заказа</TD>" skip
         "<TD>Наименование</TD>" skip
         "<TD>Сумма <br>платежа</TD>" skip
         "<TD>Ф.И.О.</TD>" skip
         "<TD>Кассир <br>(номер)</TD>" skip
     "</TR>" skip.
   
   v-sum = 0.
   v-coun = 0.

   for each commonpl where date = v-dat and deluid=? and rnnbn="600700022288" no-lock break by npl.

     if first-of (commonpl.npl) then do:
         put stream st1 unformatted
           "<TR><TD colspan = ""6""><b> Наименование услуги: " commonpl.npl  "</TD></tr>" skip.
     end.

     find first codfr where codfr.codfr="realty_a" and codfr.code = commonpl.info[4] no-lock no-error.
       if avail codfr then
         nam = codfr.name[1].
       else
        nam = ''.

     put stream st1 unformatted
        "<TR><TD>" commonpl.date format '99/99/9999' "</TD>" skip
          "<TD align=""center"">" commonpl.info[2]   /*номер заказа*/  "</TD>" skip
          "<TD>("commonpl.info[4]")"  nam  "</TD>" skip
          "<TD align=""center"">" commonpl.sum "</TD>" skip
          "<TD align=""center"">" commonpl.fio /*format "x(45)"*/ "</TD>" skip
          "<TD align=""center"">" commonpl.uid "</TD>" skip
        "</TR>" skip.

     v-sum = v-sum + commonpl.sum.
     temp-sum = temp-sum + commonpl.sum.

     if last-of (commonpl.npl) then do:
       put stream st1 unformatted
         "<TR><TD><b>Итого</TD><TD></TD><TD></TD>"
         "<TD><b>" replace(trim(string(temp-sum, "->>>>>>>>>>>9.99")),".",",") "</TD><TD></TD><TD></TD>" skip
         "</TR>" skip.
       temp-sum = 0.
     end.
   end.

   put stream st1 unformatted
      "<TR><TD><b>Всего"  "</TD><TD><b></TD><TD></TD>"
          "<TD><b>" replace(trim(string(v-sum, "->>>>>>>>>>>9.99")),".",",") "</TD><TD></TD><TD></TD>" skip
      "</TR>" skip.


   put stream st1 unformatted "</TABLE>" skip.

   {html-end.i " stream st1 "}
 
   output stream st1 close.
   unix silent cptwin atk.img excel.
                                    
