/* cifcrgl.p
 * MODULE
        Клиенты и их счета
 * DESCRIPTION
        Просмотр клиентов, не прошедших акцепт 1.11
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        s-cifchk.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        1.4.1.10.
 * AUTHOR
        04.11.03 sasco
 * CHANGES
        11.04.2013 damir - Внедрено Т.З. № 1793.
*/
{mainhead.i}

def new shared var v-type as char no-undo.

def new shared temp-table t-wrk
    field cif as char
    field cifname as char
    field ofc as char.

def var v-sel as inte.
def var v-title as char.
def var i as inte.

def stream rep.

def var v-file as char init "CifCrg.htm".

run sel("ВЫБЕРИТЕ ТИП","1. Юридические лица|2. Физические лица").
v-sel = inte(return-value).
if v-sel = 1 then do: v-type = "B". v-title = "ЮЛ". end.
else if v-sel = 2 then do: v-type = "P". v-title = "ФЛ". end.
else return.

{r-brfilial.i &proc = "cifcrgl_txb"}

output stream rep to value(v-file).
{html-title.i &stream = "stream rep"}

put stream rep unformatted
    "<P align=center style='font-size:14pt;font:bold'>Неакцептованные карточки клиентов-" v-title "</P>" skip.

put stream rep unformatted
    "<TABLE width='100%' border='1' cellspacing='0' cellpadding = '0'>" skip.

put stream rep unformatted
    "<TR align=center style='font-size:12pt;font:bold'>" skip
    "<TD>№</TD>" skip
    "<TD>CIF-код</TD>" skip.
if v-type = "B" then put stream rep unformatted
    "<TD>Наименование клиента</TD>" skip.
else put stream rep unformatted
    "<TD>Ф.И.О. клиента</TD>" skip.
put stream rep unformatted
    "<TD>id менеджера</TD>" skip
    "</TR>" skip.

i = 0.
for each t-wrk no-lock:
    i = i + 1.

    put stream rep unformatted
        "<TR align=center style='font-size:10pt'>" skip
        "<TD>" string(i) "</TD>" skip
        "<TD>" t-wrk.cif "</TD>" skip
        "<TD align=left>" t-wrk.cifname "</TD>" skip
        "<TD>" t-wrk.ofc "</TD>" skip
        "</TR>" skip.
end.

put stream rep unformatted
    "</TABLE>" skip.

{html-end.i "stream rep"}
output stream rep close.

unix silent cptwin value(v-file) winword.

/*output to rpt.img.

put unformatted g-today " / " string (time, "HH:MM:SS") " / " g-ofc skip.
put unformatted " СПИСОК КЛИЕНТОВ - ФИЗ. ЛИЦ, НЕ ПРОШЕДШИХ АКЦЕПТ СТ. МЕНЕДЖЕРОМ" skip(2).
put unformatted fill ('-', 63) format 'x(63)' skip.
put unformatted  "CIF    | Наименование клиента           | Обслуж1  | Обслуж2  " skip.
put unformatted fill ('-', 63) format 'x(63)' skip.

for each cif where cif.type = 'P' and cif.crg = '' and cif.jame = cdep no-lock:

   oofc1 = substr(cif.fname,1,8).
   oofc2 = substr(cif.fname,10,8).

   put unformatted cif.cif format 'x(6)' " | "
                   cif.name format 'x(30)' " | "
                   oofc1 format 'x(8)' " | "
                   oofc2 format 'x(8)' skip.

end.
put unformatted fill ('-', 63) format 'x(63)' skip(2).

output close.
run menu-prt ('rpt.img').*/
