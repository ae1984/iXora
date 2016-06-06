/* pkreprko.p
 * MODULE
        ПотребКредиты
 * DESCRIPTION
        Отчет за период обо всех анкетах
        с разбивкой по менеждерам и детализацией
        - для премирования или чего там еще им надо :-)
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
        11.07.2003 sasco
 * CHANGES
        17.12.2003 nadejda - добавила pk.i для перекомпиляции
*/

{mainhead.i}
{pk.i new}

/* период отчета */
def var d1 as date no-undo init today format '99/99/9999'.
def var d2 as date no-undo init today format '99/99/9999'.

def var pkk as char extent 3 init ["lname", "fname", "mname"].
def var i as int no-undo.

def var numok as int no-undo.
def var numbad as int no-undo.

def var v-ctypes as char init "".
def var v-cnames as char.

def temp-table tmp
               /* менеджер */
         field fio as char  
         field ofc as char
         field rdt as date init 01/01/1999
               /* прошедшие анкеты */
         field fok as char
         field wasok as log init no
               /* отвергнутые анкеты */
         field fbad as char
         field refus as char
         field wasbad as log init no
               /* индексное поле сортировки */
         field okbad as int
               index idx_tmp is primary ofc okbad rdt.


update d1 label "Начало периода" d2 label "Конец периода"
       with side-labels centered overlay frame dtfr.
hide frame dtfr.

run uni_book ("credtype",  "", output v-ctypes).

v-cnames = "<UL>".
for each bookcod where bookcod.bookcod = "credtype" no-lock:
    if lookup (bookcod.code, v-ctypes) > 0 then v-cnames = v-cnames + "<LI> " + bookcod.name + "</LI>".
end.
v-cnames = v-cnames + "</UL>".

if v-ctypes = "" then {error.i "Ошибка! Вы должны выбрать хотя бы один вид кредита"}

/* создадим список анкет по менеждерам */
for each pkanketa where  pkanketa.bank = s-ourbank and 
                        pkanketa.rdt >= d1 and 
                        pkanketa.rdt <= d2 no-lock:

    if lookup (pkanketa.credtype, v-ctypes) = 0 then next.

    if pkanketa.sts = "00" then do: /* отвергнутая анкета */

       find ofc where ofc.ofc = pkanketa.rwho no-lock no-error.
       
       find last tmp where tmp.ofc = pkanketa.rwho and tmp.wasok and not tmp.wasbad no-error.
       if not avail tmp then create tmp.


       assign tmp.ofc = pkanketa.rwho.
       if avail ofc then assign
                               tmp.fio = CAPS (ofc.name)
                               tmp.wasbad = yes.

       
       do i = 1 to num-entries(pkanketa.refusal):
          for each bookcod where bookcod.bookcod = "pkrefus" and bookcod.code = entry(i, pkanketa.refusal) no-lock:
              if tmp.refus <> "" then tmp.refus = tmp.refus + ", ".
              tmp.refus = tmp.refus + bookcod.name.
          end.
       end.

       do i = 1 to 3:
          find first pkanketh where pkanketh.bank = s-ourbank and 
                                    pkanketh.credtype = pkanketa.credtype and 
                                    pkanketh.ln = pkanketa.ln and 
                                    pkanketh.kritcod = pkk[i] no-lock no-error.
          tmp.fbad = tmp.fbad + CAPS (TRIM(pkanketh.value1)) + " ".
       end.

    end.
    else do: /* хорошая анкета */

       find ofc where ofc.ofc = pkanketa.rwho no-lock no-error.
       
       find last tmp where tmp.ofc = pkanketa.rwho and tmp.wasbad and not tmp.wasok no-error.
       if not avail tmp then create tmp.

       assign tmp.ofc = pkanketa.rwho.
       if avail ofc then assign
                               tmp.fio = CAPS (ofc.name)
                               tmp.wasok = yes.

       do i = 1 to 3:
          find first pkanketh where pkanketh.bank = s-ourbank and 
                                    pkanketh.credtype = pkanketa.credtype and 
                                    pkanketh.ln = pkanketa.ln and 
                                    pkanketh.kritcod = pkk[i] no-lock no-error.
          tmp.fok = tmp.fok + CAPS (TRIM(pkanketh.value1)) + " ".
       end.

    end.

    if tmp.rdt > pkanketa.rdt then tmp.rdt = pkanketa.rdt.

    if tmp.wasok and tmp.wasbad then tmp.okbad = 1.
                                else tmp.okbad = 2.


end.


output to pkrep.html.

put unformatted 
                "<HTML> <HEAD> <TITLE>TEXAKABANK</TITLE>" skip
                "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
                "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip.

put unformatted 
                "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: xx-small;" skip
                "</STYLE></HEAD>" skip
                "<BODY LEFTMARGIN=""20"">" skip.

put unformatted "<H3> Статистика по оформленным анкетам </H3>" skip
                v-cnames skip.
put unformatted "<H4> Выборка за период с " + string (d1) + " по " + string(d2) + "</H4><br>" skip.


for each tmp break by tmp.ofc:

   if first-of (tmp.ofc) then do:
      numok = 0.
      numbad = 0.
      put unformatted "<H5>" tmp.fio + "&nbsp;(" + tmp.ofc + ")</H5>" skip.
      put unformatted "<table border=""1"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" SKIP. 
      put unformatted "<tr style=""background: #D0D0D0;"">"
                      "<td><b> Выданные кредиты </b></td>"
                      "<td><b> Отказы </b></td>"
                      "<td><b> Причина отказа </b></td>"
                      "</tr>" skip.
   end.

   put unformatted "<tr>".
   put unformatted "<td align=""left"">" tmp.fok "</td>".
   put unformatted "<td align=""left"">" tmp.fbad "</td>".
   put unformatted "<td align=""left"">" tmp.refus "</td>".
   put unformatted "</tr>" skip.

   if tmp.wasok then numok = numok + 1.
   if tmp.wasbad then numbad = numbad + 1.

   if last-of (tmp.ofc) then do:
      put unformatted "<tr style=""background: #D0D0D0;"">"
                      "<td><b> Итого выдано </b></td>"
                      "<td><b> Итого отказов </b></td>"
                      "<td><b>  </b></td>"
                      "</tr>" skip.
      put unformatted "<tr>"
                      "<td><b> " numok " </b></td>"
                      "<td><b> " numbad " </b></td>"
                      "<td><b>  </b></td>"
                      "</tr>" skip.
      put unformatted "</table>".
   end.

end.
put unformatted "</body></html>" skip.

output close.
unix silent value ("cptwin pkrep.html excel").
unix silent value ("rm pkrep.html").
