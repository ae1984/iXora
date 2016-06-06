/* glavarag.p
 * MODULE
        Внутренние отчеты
 * DESCRIPTION
        Средние остатки за период
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
        11.08.2005 marinav
 * CHANGES
        03/10/2005 marinav - добавились средние остатки по кредитам депозитам
        04/11/2005 marinav - выделено в PUSH
        19.04.06   marinav - добавлена возможность формирования отчета за любой период
        04/07/06 marinav - добавление новых филиалов... убрала индекс из временной таблицы, он не нужен
        25/08/06 marinav - оптимизация
        26/10/06 u00121 - добавленно поле t7 в t-gl
        06/01/08 marinav - исправлен путь к базам с /data/9/ на  /data/
*/

{mainhead.i}

def var v-sel as char no-undo.
def var fname as char no-undo.
def var quar as inte no-undo.
def var v-gl as char format 'x(4)' no-undo.
def new shared var d1 as date .
def new shared var d0 as date .

   def new shared temp-table t-gl 
       field gl as char
       field gl6 as char 
       field t0 as decimal
       field t1 as deci
       field t2 as deci
       field t3 as deci
       field t4 as deci
       field t5 as deci
       field t6 as deci
       field t7  as deci.

  run sel ("Остатки по балансу :", 
           " 1. Средние по балансу (с нач месяца)| 2. Средние по кредитам/депозитам (с нач месяца) | 3. Средние по балансу за период | 4. Средние по кредитам/депозитам за период | 5. Выход").
  v-sel = return-value.

  if v-sel = "5" then return.

  if v-sel = "1" or v-sel = "2" then do:

      update d1 label "Укажите дату "
             with side-labels centered overlay frame dtfr.
      hide frame dtfr.

      if month(d1) <= 12 then quar = 4.
      if month(d1) <= 9 then quar = 3.
      if month(d1) <= 6 then quar = 2.
      if month(d1) <= 3 then quar = 1.

      fname = "-" + string(year(d1)) + "-" + string(month(d1)) + "-" + string(quar) + "-" + string(day(d1)) + ".html".
   end.

  if v-sel = "3" or v-sel = "4" then do:
     def stream m-out.
     run print_repo.
  end.

case v-sel:
  when '1' then    unix silent value ("cptwin /data/reports/push/avar" + fname + " excel").
  when '2' then    unix silent value ("cptwin /data/reports/push/avard" + fname + " excel").
  when '3' then    unix silent value ("cptwin rep.html excel").
  when '4' then    unix silent value ("cptwin rep.html excel").
  when '5' then return.
  otherwise return.
end case.

procedure print_repo.

      def var vt0 as deci.
      def var vt1 as deci.
      def var vt2 as deci.
      def var vt3 as deci.
      def var vt4 as deci.
      def var vt5 as deci.
      def var vt6 as deci.

      update d0 label "Укажите дату c "  d1 label " по "
           with side-labels centered overlay frame dtfr1.
      hide frame dtfr.

      INPUT FROM /data/import/gl_acc.txt.
      repeat on error undo, leave:
         import unformatted v-gl no-error.
         if (v-sel = "3" and integer(v-gl) < 10000) or (v-sel = "4" and integer(v-gl) > 10000) then do:
            create t-gl.
            t-gl.gl = v-gl.
         end.
      end.
      input close.   

      for each t-gl where t-gl.gl ne "".
         if v-sel = "3" then do:
            for each gl where string(gl.gl) begins t-gl.gl and gl.totlev = 1 no-lock .
                t-gl.gl6 = t-gl.gl6 + string(gl.gl) + ','.
            end.
         end.
         else do:
            find last gl where gl.gl = inte(t-gl.gl) and gl.totlev = 1  no-lock no-error.
            if avail gl then t-gl.gl6 = string(gl.gl) .
         end.
      end.
         

     {r-branch.i &proc = "glavara1"}

     output stream m-out to rep.html.

     put stream m-out unformatted 
                     "<HTML> <HEAD> <TITLE>TEXAKABANK</TITLE>" skip
                     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
                     "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip.

     put stream m-out unformatted 
                     "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: xx-small;" skip
                     "</STYLE></HEAD>" skip
                     "<BODY LEFTMARGIN=""20"">" skip.

     put stream m-out unformatted "<H4> Средние остатки за период с " d0 " по " d1 "</H4>" skip.
                     
     put stream m-out unformatted "<table border=""1"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" SKIP. 
     put stream m-out unformatted "<tr style=""background: #D0D0D0;"">"
                     "<td><b> Счет </b></td>"
                     "<td><b> Алматы </b></td>"
                     "<td><b> Астана </b></td>"
                     "<td><b> Уральск </b></td>"
                     "<td><b> Атырау </b></td>"
                     "<td><b> Актюбинск </b></td>"
                     "<td><b> Караганда </b></td>"
                     "<td><b> Талдыкорган </b></td>"
                     "<td><b> В целом по банку </b></td>"
                     "</tr>" skip.

     for each t-gl:
      
           vt0 = round((t-gl.t0 / 1000) / (d1 - d0 + 1), 0).
           vt1 = round((t-gl.t1 / 1000) / (d1 - d0 + 1), 0).
           vt2 = round((t-gl.t2 / 1000) / (d1 - d0 + 1), 0).
           vt3 = round((t-gl.t3 / 1000) / (d1 - d0 + 1), 0).
           vt4 = round((t-gl.t4 / 1000) / (d1 - d0 + 1), 0).
           vt5 = round((t-gl.t5 / 1000) / (d1 - d0 + 1), 0).
           vt6 = round((t-gl.t6 / 1000) / (d1 - d0 + 1), 0).

           put stream m-out unformatted "<tr>"
                           "<td><b> " t-gl.gl " </td>"
                           "<td>    " replace(trim(string(vt0, "->>>>>>>>>>>9.99")),".",",") " </td>"
                           "<td>    " replace(trim(string(vt1, "->>>>>>>>>>>9.99")),".",",") "</b></td>"
                           "<td>    " replace(trim(string(vt2, "->>>>>>>>>>>9.99")),".",",") "</b></td>"
                           "<td>    " replace(trim(string(vt3, "->>>>>>>>>>>9.99")),".",",") "</b></td>"
                           "<td>    " replace(trim(string(vt4, "->>>>>>>>>>>9.99")),".",",") "</b></td>"
                           "<td>    " replace(trim(string(vt5, "->>>>>>>>>>>9.99")),".",",") "</b></td>"
                           "<td>    " replace(trim(string(vt6, "->>>>>>>>>>>9.99")),".",",") "</b></td>"
                           "<td>    " replace(trim(string((vt0 + vt1 + vt2 + vt3 + vt4 + vt5 + vt6), "->>>>>>>>>>>9.99")),".",",") "</b></td>"
                           "</tr>" skip.
     end.
     put stream m-out unformatted "</table>".

     put stream m-out unformatted "</body></html>" skip.

     output stream m-out close.

end.