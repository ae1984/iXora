/* incrgnk.p
 * MODULE
      Клиенты и счета
 * DESCRIPTION
      Отчет по реестру инкассовых распоряжений
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
        --/--/2008 alex
 * BASES
        BANK COMM
 * CHANGES
        06/06/2011 evseev - переход на ИИН/БИН

*/

{global.i}
{chbin.i}
def var dt1 as date.
def var dt2 as date.
def var v-num as integer.
def var v-mt100in as char.
def var v-exist1 as char.

    form dt1 label ' Укажите период с' format '99/99/9999'
         dt2 label ' по' format '99/99/9999' skip(1)
         v-num label ' Номер реестра' format ">>>>>>>>>9"
    with side-label row 5 width 48 centered frame dat.

    dt2 = today.
    dt1 = date(month(dt2),1,year(dt2)).

    update dt1 dt2 v-num with frame dat.
    hide frame dat.

    /*********************************************************************************************************************************************************/

def temp-table t-rep no-undo
    field dt like increg.dt
    field num like increg.num
    field rdt like increg.rdt
    field rtm as char label 'Время'
    field inc as char label 'Инкассовые распоряжения'
    index num as primary num.

def var v-filename like increg.filename.
def var v-str as char.

def stream rep.
message "Формируется отчет.......".
for each increg where (increg.rdt le dt2) and (increg.rdt ge dt1) and ((v-num = 0) or (v-num > 0 and increg.num = v-num)) no-lock:

  v-mt100in = "/data/import/inkarc/" + string(year(increg.rdt),"9999") + string(month(increg.rdt),"99") + string(day(increg.rdt),"99") + "/".
  input through value( "find " + v-mt100in + ";echo $?").
  repeat:
      import unformatted v-exist1.
  end.
  if v-exist1 <> "0" then next.
        v-filename = v-mt100in + increg.filename.
        input stream rep from value(v-filename).
        repeat:
            import stream rep unformatted v-str.
            if v-str begins "//" then do:
                create t-rep.
                assign t-rep.dt = increg.dt
                    t-rep.num = increg.num
                    t-rep.rdt = increg.rdt
                    t-rep.rtm = string(increg.rtm, "HH:MM:SS")
                    t-rep.inc = entry(4, v-str, "/") + "|" + entry(6, v-str, "/") + "|" + entry(7, v-str, "/") + "|" + entry(8, v-str, "/").
            end.
        end.
    end.
    input stream rep close.

    /*for each t-rep no-lock:
        displ t-rep.dt format "99/99/9999" t-rep.num format ">>>>>>>>9" t-rep.rdt format "99/99/9999" t-rep.rtm format "x(8)" t-rep.inc format "x(50)".
    end.*/


def stream hrep.
output stream hrep to increport.html.


    put stream hrep unformatted
    "<html>" skip
    "<head>" skip
    "<META http-equiv= Content-Type content= text/html; charset= windows-1251>" skip
    "<title>Реестры инкассовых распоряжений</title>" skip
    '<style type="text/css">' skip
        "TABLE \{ " skip
        "border-collapse: collapse; \}" skip
    "</style>" skip
    "</head>" skip
    "<body>" skip
    "<table width= 100% border= 1 cellspacing= 0 cellpadding= 0 valign= top>" skip
    "    <tr style= font:bold; font-size:xx-small bgcolor= #C0C0C0 align= center>" skip
    "        <td rowspan= 2 width= 10%>Номер реестра</td>" skip
    "        <td rowspan= 2 width= 10%>Дата реестра</td>" skip
    "        <td rowspan= 2 width= 15%>Дата и время принятия реестра</td>" skip
    "        <td width= 65%>Инкассовые распоряжения</td>" skip
    "    </tr>" skip
    "    <tr valign= top>" skip
    "        <td>" skip
    "            <table width= 100% border = 1 cellspacing= 0 cellpadding= 0>" skip
    "                <tr align= center style= font:bold; font-size:xx-small bgcolor= #C0C0C0>" skip.
    if v-bin then put stream hrep unformatted "                    <td width= 25%>БИН</td>" skip.
    else put stream hrep unformatted "                    <td width= 25%>РНН</td>" skip.
    put stream hrep unformatted "                    <td width= 35%>Сумма</td>" skip
    "                    <td width= 20%>N раcпоряжения</td>" skip
    "                    <td width= 20%>Дата раcпоряжения</td>" skip
    "                </tr>" skip
    "            </table>" skip
    "        </td>" skip
    "    </tr>" skip.

    for each t-rep no-lock.
    put stream hrep unformatted
    "    <tr align= right valign= top cellspacing= 0 cellpadding= 0>" skip
    "        <td>" + string(t-rep.num, "999999999") + "</td>" skip
    "        <td>" + string(t-rep.dt, "99/99/9999") + "</td>" skip
    "        <td>" + string(t-rep.rdt, "99/99/9999") + " " + t-rep.rtm + "</td>" skip
    "        <td>" skip
    "            <table width= 100% border = 1 cellspacing= 0 cellpadding= 0>" skip
    "                <tr align= right>" skip
    "                    <td width= 25%>" + entry(1, t-rep.inc, "|") + "</td>" skip
    "                    <td width= 35%>" + entry(2, t-rep.inc, "|") + "</td>" skip
    "                    <td width= 20%>" + string(int(entry(3, t-rep.inc, "|")), "999999999") + "</td>" skip
    "                    <td width= 20%>" + string(date(substr(entry(4, t-rep.inc, "|"), 5, 2) + substr(entry(4, t-rep.inc, "|"), 3, 2) + substr(entry(4, t-rep.inc, "|"), 1, 2)), "99/99/9999") + "</td>" skip
    "                </tr>" skip
    "            </table>" skip
    "        </td>" skip
    "    </tr>" skip.
    end.
    put stream hrep unformatted "</table></body></html>".

    output stream hrep close.
    unix silent cptwin increport.html iexplore.
    hide all no-pause.