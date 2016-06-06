/* repcrio2.p
 * MODULE
        Интернет Офис
 * DESCRIPTION
        Отчет о зарегистрированных пользователях за период
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
        24/03/05 tsoy
 * CHANGES
*/


def var v-dt1 as date.
def var v-dt2 as date.
 
def frame f-date
   v-dt1 label "Начало"  skip
   v-dt2 label "Конец "  skip
with side-labels centered row 7 title "Параметры отчета".


def stream v-out.
output stream v-out to repcrio2.html.



update  v-dt1 v-dt2 with frame f-date.

put stream v-out unformatted "<html><head><title>TEXAKABANK</title>" 
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" 
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream v-out unformatted  "<h2>Отчет о зарегистрированных пользователях за период с " string(v-dt1) " по " string(v-dt2) "</h2>" skip. 

put stream v-out unformatted  "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"" style=""font-size:10px"">" skip. 

                  put stream v-out unformatted "<tr align=center>"
                                                     "<td>CIF<br>(Код клиента)</td>"
                                                     "<td>Наименование<br>клиента</td>"
                                                     "<td>Регистрационный<br>номер</td>"
                                                     "<td>Дата<br>регистрации</td>"
                                                     "<td>СПФ, в котором<br>обслуживается Клиент</td>"
                                                "</tr>" skip.


for each ib.hist where ib.hist.wdate         >= v-dt1 
                       and ib.hist.wdate     <= v-dt2 
                       and ib.hist.type1     = 2 
                       and ib.hist.type2     = 1 
                       and ib.hist.procname  = "IBPL_CrUsr" no-lock.

      find ib.usr where ib.usr.id = ib.hist.idusraff no-lock no-error.
      if avail usr then do:
         find cif where cif.cif = ib.usr.cif no-lock no-error.

         if avail cif then do:
             find ppoint where ppoint.depart = integer(cif.jame) mod 1000 no-lock no-error.

             if avail ppoint then do:

                  put stream v-out unformatted "<tr>"
                                                     "<td>" cif.cif  "</td>"
                                                     "<td>" cif.name "</td>"
                                                     "<td>" string (usr.id) "</td>"
                                                     "<td>" string (ib.hist.wdate) "</td>"
                                                     "<td>" ppoint.name "</td>"
                                                "</tr>" skip.
 

                     
             end.
             
         end.

      end.

end.

put stream v-out unformatted "</table>".


output stream v-out close.
unix silent value("cptwin repcrio2.html excel").
