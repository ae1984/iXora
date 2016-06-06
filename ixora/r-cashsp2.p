/* r-cashsp2.p
 * MODULE
         Транзакции по счетам главной книги
 * DESCRIPTION
        Назначение программы, описание процедур и функций (сортировка по суммам)
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
        31/12/99 pragma
 * BASES
        BANK COMM
 * CHANGES
        14/07/2011 lyubov перекомпиляция
        08.11.2011 lyubov изменила алгоритм программы
        09.11.2011 lyubov добавила проверку на Чимкент
        14/11/2011 lyubov исправила обороты
        19/01/2012 lyubov добавила возможность выбора данных за период
        24/01/2012 lyubov исправила остатки на начало дня
        02.03.12 damir - вывод формы в формате WORD (без возможности редактирования) Т.З. № 1256, добавил menu-prt.
        07.03.12 damir - убрал keyord.i
        11.03.2012 Lyubov - исправила алгоритм подсчета количества документов
        18.05.2012 Lyubov - неправильно подсчитывалась касса в пути, исправила условие при поиске данных (histrxbal.dt < edt)
        24.05.2012 Lyubov - в связи с переходом на раздельное формирование касс. ордеров, по комм. платежам сумму и комиссию считаем за 2 док-та
        24.07.2012 damir - добавил cashrep.i, изменение формата вывода в WORD.
        30.09.2013 damir - Внедрено Т.З. № 1496.
*/
{mainhead.i }
{cashrep.i}

define var bdt as date.
define var edt as date.
define var tdt as date.
define shared var vgl like gl.gl.
define var vtitle2 as char form "x(132)".
define var vtitle3 as char form "x(132)".
define var v-bal1  like jl.dam.
define var v-bal2  like jl.dam.
define var v-end1  like jl.dam.
define var v-end2  like jl.dam.
def var v-arp like arp.arp.
def var v-rem as char.
def var v-glacc as int format ">>>>>>".
def var v-depart as inte.
def var v-nom as inte format "zz9".
def buffer b-jl for jl.
def var v-tim as char.
def var ofi as char format "x(12)".

def buffer bjl for jl.
def var m-damk as int format "zz9".
def var m-camk as int format "zz9".
def var c-damk as char format "x(10)".
def var c-camk as char format "x(10)".
def var m-ln like aal.ln.
def var m-dc like jl.dc.
def var m-gl like gl.gl.
def var ln like aal.ln.

def stream v-out.
def stream v-out2.

def var v-file  as char init "Rep1.htm".
def var v-file2 as char init "Rep2.htm".
def var v-inputfile as char init "/data/export/reportdel.htm".
def var v-str       as char.

output stream v-out  to value(v-file).
output stream v-out2 to value(v-file2).

input from value(v-inputfile).
repeat:
    import unformatted v-str.
    v-str = trim(v-str).
    put stream v-out unformatted v-str.
end.
input close.

bdt = g-today.
edt = g-today.
vgl = 100100.

def var dam like jl.dam.
def var cam like jl.dam.

define temp-table wrk1 no-undo
    field gl  like jl.gl
    field jh  like jl.jh
    field dam like jl.dam
    field cam like jl.cam
    field crc like jl.crc
    field who like jl.who
    field tim as char
    field tel like jl.teller
    field rem as char
    field dc  like jl.dc
    field cd  as   inte
    index ind is PRIMARY cd cam dam.

def var s-ourbank as char no-undo.

find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).

{image1.i rpt.img}
update
    bdt      label " Период "  help " Задайте начальную дату периода" skip
    edt      label " Период "  help " Задайте конечную дату периода" skip
    v-depart label " СП     "  help " Выберите СП " skip
with row 8 centered  side-label frame opt title "Отчет по кассовым оборотам ".
hide frame opt.

find first ppoint where ppoint.depart = v-depart no-lock no-error.

find gl where gl.gl eq vgl no-lock no-error.
{image2.i}
{report1.i 63}

vtitle2 = "Счет ГК   Операция        Дебет           Кредит            ПРИМЕЧАНИЕ                               Исполнитель Время    Акцепт".

form wrk1.gl
     wrk1.jh
     wrk1.dam  format "zzz,zzz,zzz,zzz,zz9.99"
     wrk1.cam  format "zzz,zzz,zzz,zzz,zz9.99"
     wrk1.rem format "x(53)" wrk1.who wrk1.tim wrk1.tel
     with no-label width 132 down frame detail.

find first cmp no-lock no-error.
find first ofc where ofc.ofc = g-ofc no-lock no-error.
if avail ofc then ofi = "Исп. " + caps(g-ofc).

for each crc no-lock where crc.crc <  5 break by crc.crc:

    assign v-nom = 0 v-arp = "" v-bal1 = 0 v-bal2 = 0 m-damk = 0 m-camk = 0 m-ln = 0 m-dc = ''.

    if first(crc) eq false then page.
    for each arp where arp.gl = 100200 and arp.crc = crc.crc  no-lock:
        find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "arptype" and sub-cod.acc = arp.arp and sub-cod.ccode <> "msc" no-lock no-error.
        if not avail sub-cod or sub-cod.ccode <> "obmen1002" then next.
        find first sub-cod where sub-cod.sub = "arp" and sub-cod.d-cod = "sproftcn" and sub-cod.acc = arp.arp and sub-cod.ccode <> "msc" no-lock no-error.
        if avail sub-cod and (inte(substr(sub-cod.ccode, 2, 2)) = v-depart or (v-depart = 1 and sub-cod.ccode = "514")) then do:
            find last histrxbal where histrxbal.sub = 'arp' and histrxbal.acc = arp.arp and histrxbal.dt < edt no-lock no-error.
            if avail histrxbal then do:
                v-bal2 = histrxbal.dam - histrxbal.cam.
                v-arp = arp.arp.
            end.
        end.
    end.
    if v-arp = "" then message "Не найден счет кассы в пути для валюты " crc.code " !" view-as alert-box.
    /*посчитаем кассу в пути на конец периода*/
    v-end2 = v-bal2.
    for each b-jl where b-jl.jdt >= bdt and b-jl.jdt <= edt and b-jl.acc = v-arp no-lock.
        v-end2 = v-end2 + b-jl.dam - b-jl.cam.
    end.
    if s-ourbank = "TXB15" then do:
        find last bank.caspoint where bank.caspoint.depart = v-depart and bank.caspoint.rdt < edt and bank.caspoint.crc = crc.crc and bank.caspoint.info[1] = string(vgl) no-lock no-error.
        if available bank.caspoint then do:
            v-bal1 = bank.caspoint.amount.
        end.
    end.
    if s-ourbank <> "TXB15" then do:
        if ppoint.info[1] = 'cash' then do:
            find last glday where glday.gdt < edt and glday.gl eq vgl and glday.crc eq crc.crc  no-lock no-error.
            if avail glday then v-bal1 = glday.dam - glday.cam.
        end.
    end.

    vtitle = ppoint.name + ".   Обороты по кассе за период : с " + string(bdt) + " по " + string(edt) .
    vtitle3 = " ВАЛЮТА   - " + caps(crc.des) + "      " + " СЧЕТ ГК   - " + string(vgl).

    {rep.i 132 "vtitle2 fill(""="",132) format ""x(132)"" "}

    put stream v-out unformatted
        "<TABLE width=""100%"" bordercolor=""white"" border=""1"" cellspacing=""0"" cellpadding=""0"">" skip.
    put stream v-out unformatted
        "<TR align=left style=""font-size:9.0pt"">" skip
        "<TD colspan=8>" cmp.name + "  " + string(today,"99/99/9999") + string(time,"HH:MM:SS") + "  " + ofi "</TD>" skip
        "</TR>" skip
        "<TR align=left style=""font-size:9.0pt"">" skip
        "<TD colspan=8>" vtitle "</TD>" skip
        "</TR>" skip
        "<TR align=left style=""font:bold;font-size:9.0pt"">" skip
        "<TD colspan=8>" vtitle3 "</TD>" skip
        "</TR>" skip
        "<TR align=left style=""font-size:9.0pt"">" skip
        "<TD colspan=5>НАЛИЧНОСТЬ В КАССЕ - 100100</TD>" skip
        "<TD colspan=3>" string(v-bal1,"zzz,zzz,zzz,zzz,zz9.99-") "</TD>" skip
        "</TR>" skip
        "<TR align=left style=""font-size:9.0pt"">" skip
        "<TD colspan=5>БАНКНОТЫ И МОНЕТЫ В ПУТИ - 100200</TD>" skip
        "<TD colspan=3>" string(v-bal2,"zzz,zzz,zzz,zzz,zz9.99-") "</TD>" skip
        "</TR>" skip
        "<TR align=center style=""font-size:9.0pt"">" skip
        "<TD width=7%>Счет ГК</TD>" skip
        "<TD>Операция</TD>" skip
        "<TD width=14%>Дебет</TD>" skip
        "<TD width=14%>Кредит</TD>" skip
        "<TD width=32%>ПРИМЕЧАНИЕ</TD>" skip
        "<TD>Исполнитель</TD>" skip
        "<TD>Время</TD>" skip
        "<TD>Акцепт</TD>" skip
        "</TR>" skip.

    empty temp-table wrk1.
    for each jl no-lock where jl.jdt >= bdt and jl.jdt <= edt and jl.gl eq vgl and jl.crc eq crc.crc use-index jdt,
    each gl no-lock where gl.gl eq jl.gl,
    each jh no-lock where jh.jh eq jl.jh break by gl.gl by jl.crc by jl.cam by jl.dam by jl.jh:
        for each bjl where bjl.jh = jl.jh and bjl.gl ne vgl no-lock break by bjl.jh:
            if jl.ln = 1 or jl.ln = 3 or jl.ln = 5 or jl.ln = 7 or jl.ln = 9 or jl.ln = 11 then ln = jl.ln + 1.
            else ln = jl.ln - 1.
            if bjl.ln eq ln then m-gl = bjl.gl.
        end.
        find last ofchis where ofchis.ofc = jl.who and ofchis.regdt <= jl.jdt no-lock no-error.
        if ofchis.depart = v-depart then do:
            if v-nom = 0  then do:
                display v-bal1 label "НАЛИЧНОСТЬ В КАССЕ       - 100100 "  skip
                v-bal2 label "БАНКНОТЫ И МОНЕТЫ В ПУТИ - 100200 " with width 122 side-label frame gl.
            end.

            m-ln = jl.jh.
            m-dc = jl.dc.
            v-rem = trim(jl.rem[1] + jl.rem[2]).
            v-nom = v-nom + 1.
            v-tim = string(jh.tim,"HH:MM") .

            if not (v-rem matches "*обмен валюты*") then
            find first wrk1 where wrk1.jh = jl.jh and wrk1.crc = jl.crc and wrk1.dc = jl.dc and not (wrk1.rem matches "*обмен валюты*")  no-error.
            else
            find first wrk1 where wrk1.jh = jl.jh and wrk1.crc = jl.crc and wrk1.dc = jl.dc and wrk1.rem matches "*обмен валюты*"  no-error.
            if not available wrk1 then do:
                create wrk1.
                wrk1.jh = jl.jh.
                wrk1.crc = jl.crc.
                wrk1.dam = jl.dam.
                wrk1.cam = jl.cam.
                wrk1.who = jl.who.
                wrk1.tim = v-tim.
                wrk1.tel = jl.tel.
                wrk1.rem = v-rem.
                wrk1.dc = jl.dc.
                wrk1.cd = if wrk1.dc = 'D' then 1 else 2.
                wrk1.gl = m-gl.
            end.
            else do:
                wrk1.dam = wrk1.dam + jl.dam.
                wrk1.cam = wrk1.cam + jl.cam.
                if jl.dc = "D" then do:
                    if not v-rem matches "*комиссия*" then do:
                        wrk1.gl = m-gl.
                        wrk1.rem = v-rem.
                    end.
                end.
                else wrk1.rem = v-rem.
            end.

            v-bal1 = v-bal1 + jl.dam - jl.cam.
            accumulate jl.dam (total by jl.crc)  jl.cam (total by jl.crc).
        end. /* ofchis */
        if last-of(jl.crc) then do:
            dam = 0. cam = 0.
            for each wrk1 break by wrk1.cd by wrk1.gl.
                display wrk1.gl wrk1.jh wrk1.dam wrk1.cam wrk1.rem wrk1.who wrk1.tim wrk1.tel with frame detail.
                down 1 with frame detail.
                dam = dam + wrk1.dam.
                cam = cam + wrk1.cam.
                put stream v-out unformatted
                    "<TR align=center style=""font-size:9.0pt"">" skip
                    "<TD>" string(wrk1.gl) "</TD>" skip
                    "<TD>" string(wrk1.jh) "</TD>" skip
                    "<TD align=right>" string(wrk1.dam,"zzz,zzz,zzz,zzz,zz9.99-") "</TD>" skip
                    "<TD align=right>" string(wrk1.cam,"zzz,zzz,zzz,zzz,zz9.99-") "</TD>" skip
                    "<TD align=left>" wrk1.rem "</TD>" skip
                    "<TD>" wrk1.who "</TD>" skip
                    "<TD>" wrk1.tim "</TD>" skip
                    "<TD>" wrk1.tel "</TD>" skip
                    "</TR>" skip.
            end.

            for each wrk1 exclusive-lock:
                if wrk1.cd = 1 then m-damk = m-damk + 1.
                if wrk1.cd = 2 then m-camk = m-camk + 1.
                c-damk = 'кол.: ' + string(m-damk).
                c-camk = 'кол.: ' + string(m-camk).
            end.

            underline wrk1.dam wrk1.cam with frame detail.
            down 1 with frame detail.

            display c-damk @ wrk1.dam no-label c-camk @ wrk1.cam no-label with frame detail.
            down 2 with frame detail.
            display dam @ wrk1.dam no-label cam @ wrk1.cam no-label with frame detail.
            down 4 with frame detail.

            put stream v-out unformatted
                "<TR align=center style=""font-size:9.0pt"">" skip
                "<TD></TD>" skip
                "<TD></TD>" skip
                "<TD>" c-damk "</TD>" skip
                "<TD>" c-camk "</TD>" skip
                "<TD></TD>" skip
                "<TD></TD>" skip
                "<TD></TD>" skip
                "<TD></TD>" skip
                "</TR>" skip
                "<TR align=center style=""font-size:9.0pt"">" skip
                "<TD></TD>" skip
                "<TD></TD>" skip
                "<TD>" string(accum sub-total by jl.crc jl.dam,"zzz,zzz,zzz,zzz,zz9.99-") "</TD>" skip
                "<TD>" string(accum sub-total by jl.crc jl.cam,"zzz,zzz,zzz,zzz,zz9.99-") "</TD>" skip
                "<TD></TD>" skip
                "<TD></TD>" skip
                "<TD></TD>" skip
                "<TD></TD>" skip
                "</TR>" skip.
        end.
        if last-of(gl.gl) then do:
            display v-bal1 label "НАЛИЧНОСТЬ В КАССЕ       - 100100 "  at 40  skip
            v-end2 label "БАНКНОТЫ И МОНЕТЫ В ПУТИ - 100200 "  at 40  with side-label frame bal.

            put stream v-out unformatted
                "<TR align=left><FONT size=2>" skip
                "<TD colspan=8>НАЛИЧНОСТЬ В КАССЕ - 100100   -    " string(v-bal1,"zzz,zzz,zzz,zzz,zz9.99-") "</TD>" skip
                "</FONT></TR>" skip
                "<TR align=left><FONT size=2>" skip
                "<TD colspan=8>БАНКНОТЫ И МОНЕТЫ В ПУТИ - 100200   -    " string(v-end2,"zzz,zzz,zzz,zzz,zz9.99-") "</TD>" skip
                "</FONT></TR>" skip.
        end.
    end. /* for each jl */
    put stream v-out unformatted
        "</TABLE>" skip.
    put stream v-out unformatted
        "<br clear=all style='page-break-before:always'>" skip.
end.  /*for each crc */

put stream v-out unformatted
    "<P align=left>*****************Конец документа***********************</P>" skip.
output stream v-out close.

input from value(v-file).
repeat:
    import unformatted v-str.
    v-str = trim(v-str).
    repeat:
        if v-str matches "*</body>*" then do:
            v-str = replace(v-str,"</body>","").
            next.
        end.
        if v-str matches "*</html>*" then do:
            v-str = replace(v-str,"</html>","").
            next.
        end.
        else v-str = trim(v-str).
        leave.
    end.
    put stream v-out2 unformatted v-str skip.
end.
input close.
output stream v-out2 close.

if v-norep = yes then unix silent cptwin value(v-file2) winword.

{report3.i}
/*{image3.i}*/

pause 0	before-hide.
run	menu-prt( "rpt.img" ).
pause before-hide.