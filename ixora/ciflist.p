/* ciflist.p
 * MODULE
        Список клиентов
 * DESCRIPTION
        Список клиентов с их контактами (Физ./ юр. лиц)
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
        30/06/2010 Aigul
 * BASES
        BANK COMM
 * CHANGES
        24/06/2011 dmitriy - добавил столбцы ФИО Дир., ФИО Бух., в столбце Наименование компании - сокращенную форму собственности
        15/03/2012 id00810 - добавила v-bankn для печати
        04/05/2012 evseev - изменил название банка на banknameDgv
*/
{global.i}

def var d1      as date no-undo.
def var v-bankn as char no-undo.

def new shared temp-table wrk1 no-undo
     FIELD BANK AS CHAR
     FIELD w-cif as char
     FIELD w-name as char
     FIELD w-tel as char
     FIELD w-t1 as char
     FIELD w-t2 as char
     FIELD w-addr1 as char
     FIELD w-addr2 as char
     FIELD w-c as char
     FIELD w-mail as char
     FIELD dir as char
     FIELD buh as char.

find first sysc where sysc.sysc = "banknameDgv" no-lock no-error.
if avail sysc then v-bankn = sysc.chval.

{r-brfilial.i &proc = "ciflist_def(d1)"}
define stream m-out.

output stream m-out to ciflist.htm.
put stream m-out unformatted "<html><head><title>""</title>"
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream m-out unformatted "<br><br><h3>" "АО " v-bankn "</h3><br>" skip.
put stream m-out unformatted "<h3>Список клиентов</h3><br>" skip.
put stream m-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">"
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"">ФИО клиента / Наименование компании</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Номер телефона</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Юридический адрес</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Фактический адрес</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">email</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">ФИО руководителя предприятия</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">ФИО главного бухгалтера предприятия</td>"
                  "</tr>" skip.
  for each wrk1 no-lock BREAK BY wrk1.BANK by wrk1.w-name:
    IF FIRST-OF (wrk1.BANK) THEN DO:
        FIND FIRST TXB WHERE TXB.CONSOLID AND TXB.BANK = wrk1.BANK NO-LOCK NO-ERROR.
            put stream m-out unformatted "<tr bgcolor=""#C0C0C0"" style=""font:bold"">" skip.
            IF AVAIL TXB THEN
                put stream m-out unformatted "<td COLSPAN = 7 >" TXB.INFO "</td>" skip.
            ELSE  put stream m-out unformatted "<td COLSPAN = 7>" "</td>" skip.
                put stream m-out unformatted "</tr>" skip.
    END.

                    put stream m-out unformatted
                    "<tr>" skip
                    "<td>" wrk1.w-name "</td>" skip
                    "<td align=""left"">" wrk1.w-tel "<br>" wrk1.w-t1 "<br>" wrk1.w-t2 "</td>" skip
                    "<td>" wrk1.w-addr1 "</td>" skip
                    "<td>" wrk1.w-addr2 "</td>" skip
                    "<td>" wrk1.w-mail "</td>"
                    "<td>" wrk1.dir "</td>"
                    "<td>" wrk1.buh "</td>"
                    "</tr>" skip.

end.

put stream m-out "</table></body></html>" skip.
output stream m-out close.
hide message no-pause.
unix silent cptwin ciflist.htm excel.

