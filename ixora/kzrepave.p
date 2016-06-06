/* kzrepave-dat2.p
 * MODULE
        7.4.3.7.2 Операции с нал. ин. вал. в разрезе филиалов
 * DESCRIPTION
        Описание
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
        05.12.2011 aigul
 * BASES
        BANK COMM
 * CHANGES
        07.12.2011 aigul - добавила тип отчета
*/

{global.i}

def new shared var v-dt1 as date no-undo.
def new shared var v-dt2 as date no-undo.
def var v-reptype as int.
def new shared temp-table wrk
    field bcode as char
    field bank as char
    field dt as date
    field fil as char
    field ubuymin as decimal
    field ubuymax as decimal
    field ubuyave as decimal
    field ubuysum as decimal
    field usellmin as decimal
    field usellmax as decimal
    field usellave as decimal
    field usellsum as decimal

    field ebuymin as decimal
    field ebuymax as decimal
    field ebuyave as decimal
    field ebuysum as decimal
    field esellmin as decimal
    field esellmax as decimal
    field esellave as decimal
    field esellsum as decimal

    field rbuymin as decimal
    field rbuymax as decimal
    field rbuyave as decimal
    field rbuysum as decimal
    field rsellmin as decimal
    field rsellmax as decimal
    field rsellave as decimal
    field rsellsum as decimal.

def new shared temp-table wrk1
    field bcode as char
    field bank as char
    field ubuyave as decimal
    field ubuysum as decimal
    field usellave as decimal
    field usellsum as decimal
    field ebuyave as decimal
    field ebuysum as decimal
    field esellave as decimal
    field esellsum as decimal
    field rbuyave as decimal
    field rbuysum as decimal
    field rsellave as decimal
    field rsellsum as decimal.

def temp-table wrk-tot
    field bcode as char
    field bank as char
    field dt as date
    field fil as char
    field ubuymin as char
    field ubuymax as char
    field ubuyave as decimal
    field ubuysum as decimal
    field usellmin as char
    field usellmax as char
    field usellave as decimal
    field usellsum as decimal

    field ebuymin as char
    field ebuymax as char
    field ebuyave as decimal
    field ebuysum as decimal
    field esellmin as char
    field esellmax as char
    field esellave as decimal
    field esellsum as decimal

    field rbuymin as char
    field rbuymax as char
    field rbuyave as decimal
    field rbuysum as decimal
    field rsellmin as char
    field rsellmax as char
    field rsellave as decimal
    field rsellsum as decimal.


def temp-table wrk-tot1
    field bcode as char
    field bank as char
    field dt as date
    field fil as char
    field ubuyave as decimal
    field ubuysum as decimal
    field usellave as decimal
    field usellsum as decimal
    field ebuyave as decimal
    field ebuysum as decimal
    field esellave as decimal
    field esellsum as decimal
    field rbuyave as decimal
    field rbuysum as decimal
    field rsellave as decimal
    field rsellsum as decimal.


def var v-min as deci.
def var v-max as deci.


def var v-ubuyave as decimal.
def var v-usellave as decimal.
def var v-ebuyave as decimal.
def var v-esellave as decimal.
def var v-rbuyave as decimal.
def var v-rsellave as decimal.

def var v-ubuysum as decimal.
def var v-usellsum as decimal.
def var v-ebuysum as decimal.
def var v-esellsum as decimal.
def var v-rbuysum as decimal.
def var v-rsellsum as decimal.

def frame fparam
   v-dt1 label "Период с" format "99/99/9999" validate(v-dt1 <= g-today,'Дата не может быть больше операционной')
   v-dt2 label "по" format "99/99/9999" validate(v-dt1 <= v-dt2 and v-dt2 <= g-today,'Дата начала не может быть меньше даты окончания и больше текущей даты') skip
   v-reptype label ' Вид отчета' format "9"
   validate ( v-reptype > 0 and v-reptype < 3, " Тип курса - 1, 2") help "1 - по дате, 2 - за период"
   with side-label width 100 row 5 title " ПАРАМЕТРЫ ОТЧЕТА ".

v-dt1 = g-today.
v-dt2 = g-today.
v-reptype = 1.
update v-dt1 with frame fparam.
update v-dt2 with frame fparam.
update v-reptype with frame fparam.

{r-brfilial.i &proc = "kzrepave-dat"}

for each wrk where wrk.bcode = "0" no-lock:
    create wrk-tot.
    wrk-tot.fil = wrk.fil.
    wrk-tot.dt = wrk.dt.
end.

for each wrk where wrk.bcode <> "0" no-lock:
    for each wrk-tot where wrk-tot.dt = wrk.dt exclusive-lock break by wrk-tot.dt:
        /*usd*/
        if wrk-tot.ubuymin = "" then wrk-tot.ubuymin = string(wrk.ubuymin).
        else wrk-tot.ubuymin = wrk-tot.ubuymin + "," + string(wrk.ubuymin).
        if wrk-tot.ubuymax = "" then wrk-tot.ubuymax = string(wrk.ubuymax).
        else wrk-tot.ubuymax = wrk-tot.ubuymax + "," + string(wrk.ubuymax).
        wrk-tot.ubuyave = wrk-tot.ubuyave + (wrk.ubuyave * wrk.ubuysum).
        wrk-tot.ubuysum = wrk-tot.ubuysum + wrk.ubuysum.
        if wrk-tot.usellmin = "" then wrk-tot.usellmin = string(wrk.usellmin).
        else wrk-tot.usellmin = wrk-tot.usellmin + "," + string(wrk.usellmin).
        if wrk-tot.usellmax = "" then wrk-tot.usellmax = string(wrk.usellmax).
        else wrk-tot.usellmax = wrk-tot.usellmax + "," + string(wrk.usellmax).
        wrk-tot.usellave = wrk-tot.usellave + (wrk.usellave * wrk.usellsum).
        wrk-tot.usellsum = wrk-tot.usellsum + wrk.usellsum.
        /*eur*/
        if wrk-tot.ebuymin = "" then wrk-tot.ebuymin = string(wrk.ebuymin).
        else wrk-tot.ebuymin = wrk-tot.ebuymin + "," + string(wrk.ebuymin).
        if wrk-tot.ebuymax = "" then wrk-tot.ebuymax = string(wrk.ebuymax).
        else wrk-tot.ebuymax = wrk-tot.ebuymax + "," + string(wrk.ebuymax).
        wrk-tot.ebuyave = wrk-tot.ebuyave + (wrk.ebuyave * wrk.ebuysum).
        wrk-tot.ebuysum = wrk-tot.ebuysum + wrk.ebuysum.
        if wrk-tot.esellmin = "" then wrk-tot.esellmin = string(wrk.esellmin).
        else wrk-tot.esellmin = wrk-tot.esellmin + "," + string(wrk.esellmin).
        if wrk-tot.esellmax = "" then wrk-tot.esellmax = string(wrk.esellmax).
        else wrk-tot.esellmax = wrk-tot.esellmax + "," + string(wrk.esellmax).
        wrk-tot.esellave = wrk-tot.esellave + (wrk.esellave * wrk.esellsum).
        wrk-tot.esellsum = wrk-tot.esellsum + wrk.esellsum.
        /*rub*/
        if wrk-tot.rbuymin = "" then wrk-tot.rbuymin = string(wrk.rbuymin).
        else wrk-tot.rbuymin = wrk-tot.rbuymin + "," + string(wrk.rbuymin).
        if wrk-tot.rbuymax = "" then wrk-tot.rbuymax = string(wrk.rbuymax).
        else wrk-tot.rbuymax = wrk-tot.rbuymax + "," + string(wrk.rbuymax).
        wrk-tot.rbuyave = wrk-tot.rbuyave + (wrk.rbuyave * wrk.rbuysum).
        wrk-tot.rbuysum = wrk-tot.rbuysum + wrk.rbuysum.
        if wrk-tot.rsellmin = "" then wrk-tot.rsellmin = string(wrk.rsellmin).
        else wrk-tot.rsellmin = wrk-tot.rsellmin + "," + string(wrk.rsellmin).
        if wrk-tot.rsellmax = "" then wrk-tot.rsellmax = string(wrk.rsellmax).
        else wrk-tot.rsellmax = wrk-tot.rsellmax + "," + string(wrk.rsellmax).
        wrk-tot.rsellave = wrk-tot.rsellave + (wrk.rsellave * wrk.rsellsum).
        wrk-tot.rsellsum = wrk-tot.rsellsum + wrk.rsellsum.
    end.
end.

for each wrk-tot exclusive-lock break by wrk-tot.dt:
    if first-of(wrk-tot.dt) then do:
        /*usd*/
        v-min = 0.
        v-max = 0.
        run kzrepave-dat2(wrk-tot.ubuymin, wrk-tot.ubuymax, output v-min, output v-max).
        wrk-tot.ubuymin = string(v-min).
        wrk-tot.ubuymax = string(v-max).
        v-min = 0.
        v-max = 0.
        run kzrepave-dat2(wrk-tot.usellmin, wrk-tot.usellmax, output v-min, output v-max).
        wrk-tot.usellmin = string(v-min).
        wrk-tot.usellmax = string(v-max).
        /*eur*/
        v-min = 0.
        v-max = 0.
        run kzrepave-dat2(wrk-tot.ebuymin, wrk-tot.ebuymax, output v-min, output v-max).
        wrk-tot.ebuymin = string(v-min).
        wrk-tot.ebuymax = string(v-max).
        v-min = 0.
        v-max = 0.
        run kzrepave-dat2(wrk-tot.esellmin, wrk-tot.esellmax, output v-min, output v-max).
        wrk-tot.esellmin = string(v-min).
        wrk-tot.esellmax = string(v-max).
        /*rub*/
        v-min = 0.
        v-max = 0.
        run kzrepave-dat2(wrk-tot.rbuymin, wrk-tot.rbuymax, output v-min, output v-max).
        wrk-tot.rbuymin = string(v-min).
        wrk-tot.rbuymax = string(v-max).
        v-min = 0.
        v-max = 0.
        run kzrepave-dat2(wrk-tot.rsellmin, wrk-tot.rsellmax, output v-min, output v-max).
        wrk-tot.rsellmin = string(v-min).
        wrk-tot.rsellmax = string(v-max).
        wrk-tot.ubuyave = wrk-tot.ubuyave / wrk-tot.ubuysum.
        wrk-tot.usellave = wrk-tot.usellave / wrk-tot.usellsum.
        wrk-tot.ebuyave = wrk-tot.ebuyave / wrk-tot.ebuysum.
        wrk-tot.esellave = wrk-tot.esellave / wrk-tot.esellsum.
        wrk-tot.rbuyave = wrk-tot.rbuyave / wrk-tot.rbuysum.
        wrk-tot.rsellave = wrk-tot.rsellave / wrk-tot.rsellsum.
    end.
end.

if v-reptype = 1 then do:
    def stream vcrpt.
    output stream vcrpt to kzrepave.xls.
    {html-title.i
     &title = "Приложение 3" &stream = "stream vcrpt" &size-add = "x-"}
     find first cmp no-lock no-error.

    put stream vcrpt unformatted
       "<P align = ""center""><FONT size=""3"" face=""Times New Roman""></P>" skip
       "<P align = ""left""><FONT size=""2"" face=""Times New Roman"">"
       "<B>Приложение 3</B></FONT></P>" skip
       "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"">" skip.

    /* Исходящие платежи, которых нет в Прагме. */
    put stream vcrpt unformatted
       "<TR align=""center"">" skip
         "<TD rowspan = 3 bgcolor=""#C0C0C0"" align=""center""><FONT size=""2""><B>Дата</B></FONT></TD>" skip
         "<TD rowspan = 3 bgcolor=""#C0C0C0"" align=""center""><FONT size=""2""><B>Филиал</B></FONT></TD>" skip
         "<TD colspan = 8 bgcolor=""#C0C0C0"" align=""center""><FONT size=""2"" ><B>Доллар США</B></FONT></TD>" skip
         "<TD colspan = 8 bgcolor=""#C0C0C0"" align=""center""><FONT size=""2"" ><B>Евро</B></FONT></TD>" skip
         "<TD colspan = 8 bgcolor=""#C0C0C0"" align=""center""><FONT size=""2"" ><B>Российские рубли</B></FONT></TD>" skip
       "</TR>" skip.
       put stream vcrpt unformatted "<tr style=""font:bold"">"
       "<td colspan = 4 bgcolor=""#C0C0C0"" align=""center""> Покупка</td>"
       "<td colspan = 4 bgcolor=""#C0C0C0"" align=""center""> Продажа</td>"
       "<td colspan = 4 bgcolor=""#C0C0C0"" align=""center""> Покупка</td>"
       "<td colspan = 4 bgcolor=""#C0C0C0"" align=""center""> Продажа</td>"
       "<td colspan = 4 bgcolor=""#C0C0C0"" align=""center""> Покупка</td>"
       "<td colspan = 4 bgcolor=""#C0C0C0"" align=""center""> Продажа</td></tr>" skip.
       put stream vcrpt unformatted "<tr style=""font:bold"">"
       "<td bgcolor=""#C0C0C0"" align=""center""> Мин курс</td>"
       "<td bgcolor=""#C0C0C0"" align=""center""> Макс курс</td>"
       "<td bgcolor=""#C0C0C0"" align=""center""> Средневз курс</td>"
       "<td bgcolor=""#C0C0C0"" align=""center""> Сумма</td>"
       "<td bgcolor=""#C0C0C0"" align=""center""> Мин курс</td>"
       "<td bgcolor=""#C0C0C0"" align=""center""> Макс курс</td>"
       "<td bgcolor=""#C0C0C0"" align=""center""> Средневз курс</td>"
       "<td bgcolor=""#C0C0C0"" align=""center""> Сумма</td>"
       "<td bgcolor=""#C0C0C0"" align=""center""> Мин курс</td>"
       "<td bgcolor=""#C0C0C0"" align=""center""> Макс курс</td>"
       "<td bgcolor=""#C0C0C0"" align=""center""> Средневз курс</td>"
       "<td bgcolor=""#C0C0C0"" align=""center""> Сумма</td>"
       "<td bgcolor=""#C0C0C0"" align=""center""> Мин курс</td>"
       "<td bgcolor=""#C0C0C0"" align=""center""> Макс курс</td>"
       "<td bgcolor=""#C0C0C0"" align=""center""> Средневз курс</td>"
       "<td bgcolor=""#C0C0C0"" align=""center""> Сумма</td>"
       "<td bgcolor=""#C0C0C0"" align=""center""> Мин курс</td>"
       "<td bgcolor=""#C0C0C0"" align=""center""> Макс курс</td>"
       "<td bgcolor=""#C0C0C0"" align=""center""> Средневз курс</td>"
       "<td bgcolor=""#C0C0C0"" align=""center""> Сумма</td>"
       "<td bgcolor=""#C0C0C0"" align=""center""> Мин курс</td>"
       "<td bgcolor=""#C0C0C0"" align=""center""> Макс курс</td>"
       "<td bgcolor=""#C0C0C0"" align=""center""> Средневз курс</td>"
       "<td bgcolor=""#C0C0C0"" align=""center""> Сумма</td>"
       "</tr>" skip.

    for each wrk no-lock break by wrk.dt by wrk.fil:
            if wrk.bcode = "0" then do:
                find first wrk-tot where wrk-tot.dt = wrk.dt and wrk-tot.fil = wrk.fil no-lock no-error.
                if avail wrk-tot then do:
                    put stream vcrpt unformatted
                    "<TD><FONT size=""2"">" + string(wrk-tot.dt, "99/99/99") + "</FONT></TD>" skip
                    "<TD><FONT size=""2"">Консолидированный</FONT></TD>" skip
                    "<TD><FONT size=""2"">" + wrk-tot.ubuymin + "</FONT></TD>" skip
                    "<TD><FONT size=""2"">" + wrk-tot.ubuymax + "</FONT></TD>" skip
                    "<TD><FONT size=""2"">" + replace(trim(string(wrk-tot.ubuyave, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
                    "<TD><FONT size=""2"">" + replace(trim(string(wrk-tot.ubuysum, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
                    "<TD><FONT size=""2"">" + wrk-tot.usellmin + "</FONT></TD>" skip
                    "<TD><FONT size=""2"">" + wrk-tot.usellmax + "</FONT></TD>" skip
                    "<TD><FONT size=""2"">" + replace(trim(string(wrk-tot.usellave, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
                    "<TD><FONT size=""2"">" + replace(trim(string(wrk-tot.usellsum , "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip

                    "<TD><FONT size=""2"">" + wrk-tot.ebuymin + "</FONT></TD>" skip
                    "<TD><FONT size=""2"">" + wrk-tot.ebuymax + "</FONT></TD>" skip
                    "<TD><FONT size=""2"">" + replace(trim(string(wrk-tot.ebuyave, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
                    "<TD><FONT size=""2"">" + replace(trim(string(wrk-tot.ebuysum, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
                    "<TD><FONT size=""2"">" + wrk-tot.esellmin + "</FONT></TD>" skip
                    "<TD><FONT size=""2"">" + wrk-tot.esellmax + "</FONT></TD>" skip
                    "<TD><FONT size=""2"">" + replace(trim(string(wrk-tot.esellave, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
                    "<TD><FONT size=""2"">" + replace(trim(string(wrk-tot.esellsum , "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip

                    "<TD><FONT size=""2"">" + replace(trim(string(deci(wrk-tot.rbuymin), "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
                    "<TD><FONT size=""2"">" + replace(trim(string(deci(wrk-tot.rbuymax), "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
                    "<TD><FONT size=""2"">" + replace(trim(string(wrk-tot.rbuyave, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
                    "<TD><FONT size=""2"">" + replace(trim(string(wrk-tot.rbuysum, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
                    "<TD><FONT size=""2"">" + replace(trim(string(deci(wrk-tot.rsellmin), "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
                    "<TD><FONT size=""2"">" + replace(trim(string(deci(wrk-tot.rsellmax), "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
                    "<TD><FONT size=""2"">" + replace(trim(string(wrk-tot.rsellave, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
                    "<TD><FONT size=""2"">" + replace(trim(string(wrk-tot.rsellsum , "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip.
                    put stream vcrpt unformatted "</TR>" skip.
                end.
            end.
            else do:
                put stream vcrpt unformatted
                "<TD><FONT size=""2"">" + string(wrk.dt, "99/99/99") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + wrk.fil   + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(trim(string(wrk.ubuymin, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(trim(string(wrk.ubuymax, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(trim(string(wrk.ubuyave, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(trim(string(wrk.ubuysum, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(trim(string(wrk.usellmin, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(trim(string(wrk.usellmax, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(trim(string(wrk.usellave, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(trim(string(wrk.usellsum , "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip

                "<TD><FONT size=""2"">" + replace(trim(string(wrk.ebuymin, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(trim(string(wrk.ebuymax, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(trim(string(wrk.ebuyave, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(trim(string(wrk.ebuysum, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(trim(string(wrk.esellmin, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(trim(string(wrk.esellmax, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(trim(string(wrk.esellave, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(trim(string(wrk.esellsum , "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip

                "<TD><FONT size=""2"">" + replace(trim(string(wrk.rbuymin, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(trim(string(wrk.rbuymax, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(trim(string(wrk.rbuyave, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(trim(string(wrk.rbuysum, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(trim(string(wrk.rsellmin, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(trim(string(wrk.rsellmax, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(trim(string(wrk.rsellave, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(trim(string(wrk.rsellsum , "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip.
                put stream vcrpt unformatted "</TR>" skip.
            end.
    end.


    put stream vcrpt unformatted "</TABLE>" skip.
    {html-end.i "stream vcrpt" }


    output stream vcrpt close.
    unix silent value("cptwin kzrepave.xls excel").
end.
if v-reptype = 2 then do:
    def stream vcrpt1.
    output stream vcrpt1 to kzrepave1.xls.
    {html-title.i
     &title = "Приложение 4" &stream = "stream vcrpt1" &size-add = "x-"}
     find first cmp no-lock no-error.

    put stream vcrpt1 unformatted
       "<P align = ""center""><FONT size=""3"" face=""Times New Roman""></P>" skip
       "<P align = ""left""><FONT size=""2"" face=""Times New Roman"">"
       "<B>Приложение 4</B></FONT></P>" skip
       "<P align = ""left""><FONT size=""2"" face=""Times New Roman"">"
       "<B>За период с " v-dt1 " по " v-dt2 "</B></FONT></P>" skip
       "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""3"">" skip.

    /* Исходящие платежи, которых нет в Прагме. */
    put stream vcrpt1 unformatted
       "<TR align=""center"">" skip
         "<TD rowspan = 3 bgcolor=""#C0C0C0"" align=""center""><FONT size=""2""><B>Филиал</B></FONT></TD>" skip
         "<TD colspan = 4 bgcolor=""#C0C0C0"" align=""center""><FONT size=""2"" ><B>Доллар США</B></FONT></TD>" skip
         "<TD colspan = 4 bgcolor=""#C0C0C0"" align=""center""><FONT size=""2"" ><B>Евро</B></FONT></TD>" skip
         "<TD colspan = 4 bgcolor=""#C0C0C0"" align=""center""><FONT size=""2"" ><B>Российские рубли</B></FONT></TD>" skip
       "</TR>" skip.
       put stream vcrpt1 unformatted "<tr style=""font:bold"">"
       "<td colspan = 2 bgcolor=""#C0C0C0"" align=""center""> Покупка</td>"
       "<td colspan = 2 bgcolor=""#C0C0C0"" align=""center""> Продажа</td>"
       "<td colspan = 2 bgcolor=""#C0C0C0"" align=""center""> Покупка</td>"
       "<td colspan = 2 bgcolor=""#C0C0C0"" align=""center""> Продажа</td>"
       "<td colspan = 2 bgcolor=""#C0C0C0"" align=""center""> Покупка</td>"
       "<td colspan = 2 bgcolor=""#C0C0C0"" align=""center""> Продажа</td></tr>" skip.
       put stream vcrpt1 unformatted "<tr style=""font:bold"">"
       "<td bgcolor=""#C0C0C0"" align=""center""> Средневз курс</td>"
       "<td bgcolor=""#C0C0C0"" align=""center""> Сумма</td>"
       "<td bgcolor=""#C0C0C0"" align=""center""> Средневз курс</td>"
       "<td bgcolor=""#C0C0C0"" align=""center""> Сумма</td>"
       "<td bgcolor=""#C0C0C0"" align=""center""> Средневз курс</td>"
       "<td bgcolor=""#C0C0C0"" align=""center""> Сумма</td>"
       "<td bgcolor=""#C0C0C0"" align=""center""> Средневз курс</td>"
       "<td bgcolor=""#C0C0C0"" align=""center""> Сумма</td>"
       "<td bgcolor=""#C0C0C0"" align=""center""> Средневз курс</td>"
       "<td bgcolor=""#C0C0C0"" align=""center""> Сумма</td>"
       "<td bgcolor=""#C0C0C0"" align=""center""> Средневз курс</td>"
       "<td bgcolor=""#C0C0C0"" align=""center""> Сумма</td>"
       "</tr>" skip.
    for each wrk1 no-lock:
        v-ubuyave = v-ubuyave + (wrk1.ubuyave * wrk1.ubuysum).
        v-usellave = v-usellave + (wrk1.usellave * wrk1.usellsum).
        v-ebuyave = v-ebuyave + (wrk1.ebuyave * wrk1.ebuysum).
        v-esellave = v-esellave + (wrk1.esellave * wrk1.esellsum).
        v-rbuyave = v-rbuyave + (wrk1.rbuyave * wrk1.rbuysum).
        v-rsellave = v-rsellave + (wrk1.rsellave * wrk1.rsellsum).

        v-ubuysum = v-ubuysum + wrk1.ubuysum.
        v-usellsum = v-usellsum + wrk1.usellsum.
        v-ebuysum = v-ebuysum + wrk1.ebuysum.
        v-esellsum = v-esellsum + wrk1.esellsum.
        v-rbuysum = v-rbuysum + wrk1.rbuysum.
        v-rsellsum = v-rsellsum + wrk1.rsellsum.
    end.
    create wrk-tot1.
    wrk-tot1.ubuyave = v-ubuyave / v-ubuysum.
    wrk-tot1.ubuysum = v-ubuysum .
    wrk-tot1.usellave = v-usellave / v-usellsum.
    wrk-tot1.usellsum = v-usellsum.
    wrk-tot1.ebuyave = v-ebuyave / v-ebuysum.
    wrk-tot1.ebuysum = v-ebuysum.
    wrk-tot1.esellave = v-esellave / v-esellsum.
    wrk-tot1.esellsum = v-esellsum.
    wrk-tot1.rbuyave = v-rbuyave / v-rbuysum.
    wrk-tot1.rbuysum = v-rbuysum.
    wrk-tot1.rsellave = v-rsellave / v-rsellsum.
    wrk-tot1.rsellsum = v-rsellsum.
    for each wrk1 no-lock break by wrk1.bank:
        if wrk1.bcode = "0" then do:
            find first wrk-tot1 no-lock no-error.
            if avail wrk-tot1 then do:
                put stream vcrpt1 unformatted
                "<TD><FONT size=""2"">Консолидированный</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(trim(string(wrk-tot1.ubuyave, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(trim(string(wrk-tot1.ubuysum, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(trim(string(wrk-tot1.usellave, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(trim(string(wrk-tot1.usellsum , "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip

                "<TD><FONT size=""2"">" + replace(trim(string(wrk-tot1.ebuyave, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(trim(string(wrk-tot1.ebuysum, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(trim(string(wrk-tot1.esellave, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(trim(string(wrk-tot1.esellsum , "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip

                "<TD><FONT size=""2"">" + replace(trim(string(wrk-tot1.rbuyave, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(trim(string(wrk-tot1.rbuysum, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(trim(string(wrk-tot1.rsellave, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
                "<TD><FONT size=""2"">" + replace(trim(string(wrk-tot1.rsellsum , "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip.
                put stream vcrpt1 unformatted "</TR>" skip.
            end.
        end.
        else do:
            put stream vcrpt1 unformatted
            "<TD><FONT size=""2"">" + wrk1.bank   + "</FONT></TD>" skip
            "<TD><FONT size=""2"">" + replace(trim(string(wrk1.ubuyave, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
            "<TD><FONT size=""2"">" + replace(trim(string(wrk1.ubuysum, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
            "<TD><FONT size=""2"">" + replace(trim(string(wrk1.usellave, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
            "<TD><FONT size=""2"">" + replace(trim(string(wrk1.usellsum , "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
            "<TD><FONT size=""2"">" + replace(trim(string(wrk1.ebuyave, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
            "<TD><FONT size=""2"">" + replace(trim(string(wrk1.ebuysum, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
            "<TD><FONT size=""2"">" + replace(trim(string(wrk1.esellave, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
            "<TD><FONT size=""2"">" + replace(trim(string(wrk1.esellsum, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
            "<TD><FONT size=""2"">" + replace(trim(string(wrk1.rbuyave, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
            "<TD><FONT size=""2"">" + replace(trim(string(wrk1.rbuysum, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
            "<TD><FONT size=""2"">" + replace(trim(string(wrk1.rsellave, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip
            "<TD><FONT size=""2"">" + replace(trim(string(wrk1.rsellsum, "->>>>>>>>>>>>>>9.999")),".",",") + "</FONT></TD>" skip.
            put stream vcrpt1 unformatted "</TR>" skip.
        end.
    end.


    put stream vcrpt1 unformatted "</TABLE>" skip.
    {html-end.i "stream vcrpt1" }


    output stream vcrpt1 close.
    unix silent value("cptwin kzrepave1.xls excel").
end.

pause 0.