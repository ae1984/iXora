/* ec-cashsp1.p
 * MODULE
        Транзакции ЭК по счетам главной книги
 * DESCRIPTION
        Назначение программы, описание процедур и функций (сортировка по счету ГК)
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
 * BASES
        BANK COMM
 * AUTHOR
        02.03.2012 Lyubov
 * CHANGES
        25.04.2012 damir - вывод отчета в формате WORD, добавил menu-prt.
        24.07.2012 damir - добавил cashrep.i, изменение формата вывода в WORD.
        27.07.2012 Lyubov - ТЗ №1447, если проводка из п.м. 15-1-3, пересчет в соотв-вии с кол-вом касс. ордеров
        11.09.2012 Lyubov - если проводка из п.м. 15-1-2, пересчет в соотв-вии с кол-вом касс. ордеров
        20.09.2012 Lyubov - линии проводок по переводным операциям суммируются по ГК
        30.09.2013 damir - Внедрено Т.З. № 1496.

*/

{mainhead.i }
{cashrep.i}

define new shared var bdt as date.
define new shared var edt as date.
define new shared var tdt as date.
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

def var m-damk as int format "zz9".
def var m-camk as int format "zz9".
def var c-damk as char format "x(10)".
def var c-camk as char format "x(10)".
def var m-ln like aal.ln.
def var m-dc like jl.dc.

def var ln  like aal.ln.
def var ofi as char format "x(12)".

{cashjl.i "new"}

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
    index ind is PRIMARY cd gl cam dam.

def var dam like jl.dam.
def var cam like jl.dam.

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
vgl = 100500.

def var s-ourbank as char no-undo.

find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
    display " There is no record OURBNK in bank.sysc file !!".
    pause.
    return.
end.
s-ourbank = trim(sysc.chval).
find first cmp no-lock no-error.
{image1.i rpt.img}
     update
              bdt      label " Период "  help " Задайте начальную дату периода" skip
              edt      label " Период "  help " Задайте конечную дату периода" skip
              v-depart label " СП     "  help " Выберите СП " skip
              with row 8 centered  side-label frame opt title "Отчет по кассовым оборотам ".
     hide frame  opt.

find first ppoint where ppoin.depart = v-depart no-lock no-error.

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

for each crc no-lock where crc.crc <  5 break by crc.crc:

    v-nom = 0.  v-arp = "". v-bal1 = 0. v-bal2 = 0. m-damk = 0. m-camk = 0. m-ln = 0. m-dc = ''.

    if first(crc) eq false then page.

    /* касса на утро */
    if s-ourbank = "TXB15" then do:
        find last bank.caspoint where bank.caspoint.depart = v-depart and bank.caspoint.rdt < edt and bank.caspoint.crc = crc.crc and bank.caspoint.info[1] = string(vgl) no-lock no-error.
        if available bank.caspoint then v-bal1 = bank.caspoint.amount.
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

    run cashsp (crc.crc).

    empty temp-table wrk1.
    for each t-jl where t-jl.crc = crc.crc no-lock break by t-jl.crc by t-jl.jdt by t-jl.cd by t-jl.gl by t-jl.dam by t-jl.cam:
        find last ofchis where ofchis.ofc = t-jl.who and ofchis.regdt <= t-jl.jdt no-lock no-error.
        if ofchis.depart = v-depart then do:
            if v-nom = 0  then do:
                display v-bal1 label "НАЛИЧНОСТЬ В КАССЕ       - 100500 "  with width 122 side-label frame gl.
                put stream v-out unformatted
                "<TR align=left style=""font-size:9.0pt"">" skip
                "<TD colspan=5>НАЛИЧНОСТЬ В КАССЕ - 100500</TD>" skip
                "<TD colspan=3>" string(v-bal1,"zzz,zzz,zzz,zzz,zz9.99-") "</TD>" skip
                "</TR>" skip.
            end.
            v-rem = trim(t-jl.rem[1] + t-jl.rem[2]).
            v-nom = v-nom + 1.
            v-tim = string(t-jl.tim,"HH:MM") .

            if not (v-rem matches "*обмен валюты*") then
            find first wrk1 where wrk1.jh = t-jl.jh and wrk1.crc = t-jl.crc and wrk1.dc = t-jl.dc and not (wrk1.rem matches "*обмен валюты*")  no-error.
            else
            find first wrk1 where wrk1.jh = t-jl.jh and wrk1.crc = t-jl.crc and wrk1.dc = t-jl.dc and wrk1.rem matches "*обмен валюты*"  no-error.
            if not available wrk1 then do:
                create wrk1.
                wrk1.jh = t-jl.jh.
                wrk1.crc = t-jl.crc.
                wrk1.dam = t-jl.dam.
                wrk1.cam = t-jl.cam.
                wrk1.who = t-jl.who.
                wrk1.tim = v-tim.
                wrk1.tel = t-jl.tel.
                wrk1.rem = v-rem.
                wrk1.dc = t-jl.dc.
                wrk1.cd = if wrk1.dc = 'D' then 1 else 2.
                wrk1.gl = t-jl.gl.
            end.
            else do:
                wrk1.dam = wrk1.dam + t-jl.dam.
                wrk1.cam = wrk1.cam + t-jl.cam.
                if t-jl.dc = "D" then do:
                    if not v-rem matches "*комиссия*" then do:
                        wrk1.gl = t-jl.gl.
                        wrk1.rem = v-rem.
                    end.
                end.
                else wrk1.rem = v-rem.
            end.
            v-bal1 = v-bal1 + t-jl.dam - t-jl.cam.
            accumulate t-jl.dam (total by t-jl.crc)  t-jl.cam (total by t-jl.crc).
        end. /* ofchis */
        if last-of(t-jl.crc) then do:
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
            /*display accum sub-total by t-jl.crc t-jl.dam @ t-jl.dam  format "z,zzz,zzz,zz9.99"  accum sub-total by t-jl.crc t-jl.cam @ t-jl.cam  format "z,zzz,zzz,zz9.99" with frame detail.*/

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
                "<TD>" string(accum sub-total by t-jl.crc t-jl.dam,"zzz,zzz,zzz,zzz,zz9.99-") "</TD>" skip
                "<TD>" string(accum sub-total by t-jl.crc t-jl.cam,"zzz,zzz,zzz,zzz,zz9.99-") "</TD>" skip
                "<TD></TD>" skip
                "<TD></TD>" skip
                "<TD></TD>" skip
                "<TD></TD>" skip
                "</TR>" skip.

            display v-bal1 label "НАЛИЧНОСТЬ В КАССЕ       - 100500 "  at 40 with side-label frame bal.

            put stream v-out unformatted
                "<TR align=left style=""font-size:9.0pt"">" skip
                "<TD colspan=8>НАЛИЧНОСТЬ В КАССЕ - 100500   -    " string(v-bal1,"zzz,zzz,zzz,zzz,zz9.99-") "</TD>" skip
                "</TR>" skip.
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