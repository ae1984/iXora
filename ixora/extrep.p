/* extrep.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание программы
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
        26.05.2011 k.gitalov
 * BASES
        BANK COMM
 * CHANGES
*/

{classes.i}

def var dt1 as date no-undo.
def var dt2 as date no-undo.


function GetTypeName returns char (input s-code as char).
   if index(s-code,".mt") > 0 then return "Финальная выписка".
   if index(s-code,".dbf") > 0 then return "Промежуточная выписка".
end function.

dt2 = g-today.
dt1 = dt2.

displ dt1 label " С " format "99/99/9999" validate( dt1 <= g-today, "Некорректная дата!") skip
      dt2 label " По" format "99/99/9999" validate( dt2 >= dt1, "Некорректная дата!") skip
with side-label row 4 centered frame dat.

update dt1 with frame dat.
update dt2 with frame dat.


def stream rep1.
output stream rep1 to value("extrep.htm").
put stream rep1 "<html><head><title>Сформированные выписки по счетам </title>" skip
                       "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                       "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream rep1 unformatted
            "<b> Выписки на внешний сервер C " string(dt1) " По " string(dt2) " </b><BR><BR>" skip
            "<table border=1 cellpadding=0 cellspacing=0>" skip
            "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">" skip
            "<td width=120> Наименование клиента </td>" skip
            "<td width=180> Номер счета </td>" skip
            "<td width=180> Тип выписки </td>" skip
            "<td width=160> Файл выписки </td>" skip
            "<td width=100> Время формирования </td>" skip
            "<td width=100> Время копирования на сервер </td>" skip.
put stream rep1 unformatted "</tr>" skip.

def var Client as class ClientClass.


for each extract_his where extract_his.whn_cr >= dt1 and extract_his.whn_cr <= dt2  no-lock by extract_his.whn_cr by extract_his.time_cr:
  Client = new ClientClass(Base).
  Client:FindClientNo(extract_his.cif).

       put stream rep1 unformatted "<tr>" skip.
       put stream rep1 unformatted "<td>" Client:clientname "</td>" skip.
       put stream rep1 unformatted "<td>" extract_his.acc "</td>" skip.
       put stream rep1 unformatted "<td>" GetTypeName(extract_his.ext_name) "</td>" skip.
       put stream rep1 unformatted "<td>" extract_his.ext_name "</td>" skip.
       put stream rep1 unformatted "<td>" string(extract_his.time_cr,"HH:MM:SS") "</td>" skip.
       put stream rep1 unformatted "<td>" string(extract_his.time_post,"HH:MM:SS") "</td>" skip.
       put stream rep1 unformatted "</tr>" skip.

  if valid-object(Client) then delete object Client no-error.
end.


put stream rep1 unformatted "</table></body></html>" skip.
output stream rep1 close.
unix silent value("cptwin extrep.htm excel").