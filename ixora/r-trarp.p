/* r-trarp.p
 * MODULE
        Дебиторы
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
        25.03.10 marinav
 * BASES
        BANK COMM
 * CHANGES
        25.05.2010  marinav - Если есть данные по старому счету, то по нему тоже показывать обороты
        17/01/2012 evseev - ТЗ-1253
        06.03.2012 damir - вывод формы в формате WORD (без возможности редактирования) Т.З. № 1256, добавил menu-prt.
        07.03.2012 damir - убрал keyord.i
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
        25.09.2012 damir - по запросу ОД сделал редактируемым документ WORD.
*/

{mainhead.i}

define variable fdate as date.
define variable tdate as date.
define variable vledger like jl.gl.
define variable vsubled like arp.arp.
define variable vsubled1 like arp.arp.
define variable v-gl like gl.gl.
define variable v-bal as decimal.
define variable v-dam as decimal.
define variable v-cam as decimal.
define variable v-damcam as decimal.
define variable v-difdam as decimal.
define variable v-difcam as decimal.
define variable v-dt as date.
define variable v-dt1 as date.
define variable inamt like jl.dam initial 0.
define variable dba like jl.dam initial 0.
define variable cra like jl.dam initial 0.
define variable dbcon like jl.dam initial 0.
define variable crcon like jl.dam initial 0.
define variable titl as character format "x(132)".
define buffer jla for jl.
define buffer arpa for arp.
define variable glblin0 like glbal.bal.
define variable glblin like glbal.bal.
define variable glblout like glbal.bal.
define variable glbldelta like glbal.bal.
define variable strokis as character.
define variable v-acc like jl.acc.
define variable r     as character.
define variable v-des as character.
define variable v-des2 as character.
define variable v-subled as character.
define variable v-accnt as character.
def var v-country as char.
def var v-kbe as char.
def var v-knp as char.
def var v-cod as char.
def var v-eknp as char.
define buffer buff-jl for jl.
def var ofi as char.
def var v-tmpval as inte init 0.

def stream v-out.
def stream v-out2.

def var v-file  as char init "TransArp.htm".
/*def var v-file2 as char init "Rep2.htm".
def var v-inputfile as char init "/data/export/report.htm".*/
def var v-str       as char.

output stream v-out  to value(v-file).
/*output stream v-out2 to value(v-file2).

input from value(v-inputfile).
repeat:
    import unformatted v-str.
    v-str = trim(v-str).
    put stream v-out unformatted v-str.
end.
input close.*/

define buffer b-gl for gl.
define buffer b-arp for arp.

define temp-table w-bl
       field    crc      like crc.crc
       field    bl       as decimal
       field    db       as decimal
       field    cr       as decimal
       field    bl-today as decimal.

/* 31.10.2001 sasco */
define var sortofc as logical format "да/нет" label "ОТСОРТИРОВАТЬ ВЫПИСКУ ПО ИСПОЛНИТЕЛЯМ ?(да/нет)".
update sortofc with centered.

{p-trarp.f}

fdate = g-today.
tdate = g-today.

{image1.i rpt.img}

display
    vledger
    vsubled
    fdate
    tdate
with row 8 centered no-box side-labels frame opt.
update
    vledger validate(vledger = 0 or can-find(gl where gl.gl = vledger), "Не существует счет")
    vsubled validate(vsubled = "" or can-find(arp where arp.arp = vsubled), "Не существует ARP")
with frame opt.

update fdate validate(fdate <= g-today,"За завтра невозможно получить отчет !") with frame opt.

update tdate validate(tdate >= fdate and tdate <= g-today, "Должно быть: Начало <= Конец <= Сегодня") with frame opt.

{a-trarp.f}
{image2.i}
{report1.i 0}
{v-trarp.f}
{report2.i 133}

{html-title.i &stream = "stream v-out"}

find first cmp no-lock no-error.
find first ofc where ofc.ofc = g-ofc no-lock no-error.
if avail ofc then ofi = "Исп. " + caps(g-ofc).

put stream v-out unformatted
        "<P align=left>" cmp.name + "  " + string(today,"99/99/9999") + string(time,"HH:MM:SS") + "  " + ofi "</P>" skip
        "<P align=left>" g-fname + "  " + g-mdes "</P>" skip
        "<P align=left>" vtitle "</P>" skip.

put stream v-out unformatted
    "<TABLE width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""0"">" skip.

if lookup(string(vledger), "287034,187034,287035,187035,287036,187036,287037,187037,287033,187033" ) > 0 then do:
    put ":  Дата  : Транз. :    Д е б е т   :   К р е д и т   : Исполн.:Корр.счет:  Н а и м е н о в а н и е  и  д е т а л и  п л а т е ж а    :  Код/КБе/КНП  :  Страна  :"  skip.

    put stream v-out unformatted
        "<TR align=center><FONT size=2>" skip
        "<TD>Дата</TD>" skip
        "<TD>Транз.</TD>" skip
        "<TD width=23%>Дебет</TD>" skip
        "<TD width=23%>Кредит</TD>" skip
        "<TD>Исполн.</TD>" skip
        "<TD>Корр.счет</TD>" skip
        "<TD>Наименование и детали платежа</TD>" skip
        "<TD>Код/КБе/КНП</TD>" skip
        "<TD>Страна</TD>" skip
        "</FONT></TR>" skip.

    v-tmpval = 9.
end.
else do:
    put ":  Дата  : Транз. :    Д е б е т   :   К р е д и т   : Исполн.:Корр.счет:  Н а и м е н о в а н и е  и  д е т а л и  п л а т е ж а    :"  skip.

    put stream v-out unformatted
        "<TR align=center><FONT size=2>" skip
        "<TD>Дата</TD>" skip
        "<TD>Транз.</TD>" skip
        "<TD width=23%>Дебет</TD>" skip
        "<TD width=23%>Кредит</TD>" skip
        "<TD>Исполн.</TD>" skip
        "<TD>Корр.счет</TD>" skip
        "<TD>Наименование и детали платежа</TD>" skip
        "</FONT></TR>" skip.

    v-tmpval = 7.
end.
find first sprarp20 where sprarp20.acc9 = vsubled no-lock no-error.
if avail sprarp20 then vsubled1 = sprarp20.acc20.
find first sprarp20 where sprarp20.acc20 = vsubled no-lock no-error.
if avail sprarp20 then vsubled1 = sprarp20.acc9.

for each gl where gl.gl eq (if vledger eq 0 then gl.gl else vledger) and gl.subled eq "ARP" no-lock break by gl.gl:

    for each w-bl:
        delete w-bl.
    end.

    v-gl = gl.gl.

    if vsubled = "" then do:
        if lookup(string(vledger), "287034,187034,287035,187035,287036,187036,287037,187037,287033,187033" ) > 0 then
        put ":====================================================================================================================================:==========================:" skip.
        else
        put ":====================================================================================================================================:" skip.
        put ":" gl.gl " " gl.des format "x(65)"   "Входящий  остаток (KZT)".
    end.

    /* вход.остаток по счету гл.книги на дату начала периода с конвертацией */
    glblin0 = 0.
    glblin = 0.
    for each crc no-lock:

        create w-bl.
        w-bl.crc = crc.crc.
        find last glday where glday.gdt < fdate and glday.gl = v-gl and glday.crc = crc.crc no-lock no-error.

        if available glday then do:
             find last crchis where crchis.crc eq crc.crc and crchis.rdt <= fdate no-lock no-error.

             if gl.type eq "A" or gl.type eq "E"   then do:
                  glblin = glblin + round((glday.dam - glday.cam) * crchis.rate[1] / crchis.rate[9],2).
                  w-bl.bl = glday.dam - glday.cam.
                  find last crchis where crchis.crc = crc.crc and crchis.rdt < fdate no-lock no-error.
                  glblin0 = glblin0 + round((glday.dam - glday.cam) * crchis.rate[1] / crchis.rate[9],2).
             end.
             else do:
                  glblin = glblin + round((glday.cam - glday.dam) * crchis.rate[1] / crchis.rate[9],2).
                  w-bl.bl = glday.cam - glday.dam.
                  find last crchis where crchis.crc = crc.crc and crchis.rdt < fdate no-lock no-error.
                  glblin0 = glblin0 + round((glday.cam - glday.dam) * crchis.rate[1] / crchis.rate[9],2).
             end.
        end.
    end.

    glbldelta = glblin - glblin0.

    if vsubled = "" then do:
        put glblin format "->,>>>,>>>,>>9.99"  " (" + trim(string(glbldelta,"->,>>>,>>>,>>9.99")) + ")"  format "x(20)"  ":" skip.
        put ":                                                                                                                                    :"  skip.

        if v-tmpval <> 0 then do:
            put stream v-out unformatted
                "<TR align=left><FONT size=2>" skip
                "<TD colspan=" v-tmpval ">" string(gl.gl) + " " + gl.des "  Входящий  остаток (KZT)  " +
                string(glblin,"->,>>>,>>>,>>9.99") + "  (" + string(glbldelta,"->,>>>,>>>,>>9.99") ")</TD>"
                "</FONT></TR>" skip.
        end.
    end.
    dbcon = 0. crcon = 0.

if sortofc then do:
    for each arp where arp.gl eq v-gl and  (arp.arp eq (if vsubled eq " " then arp.arp else vsubled) or arp.arp eq (if vsubled eq " " then arp.arp else vsubled1)) no-lock,
        each jl where jl.acc eq arp.arp and jl.lev = 1 and jl.jdt ge fdate and jl.jdt le tdate
        use-index acc no-lock break by arp.crc by arp.arp by jl.acc by jl.who by jl.jdt:

        find crc where crc.crc eq arp.crc no-lock no-error.

        if first-of(arp.crc) and vsubled = ""
        then do:
            if lookup(string(vledger), "287034,187034,287035,187035,287036,187036,287037,187037,287033,187033" ) > 0 then
            put ":====================================================================================================================================:==========================:" skip.
            else
            put ":====================================================================================================================================:" skip.
            find first w-bl where w-bl.crc = crc.crc no-error.
            put ":    Валюта          " crc.des format "x(52)"  "Входящий  остаток (" crc.code ")"  w-bl.bl format  "->,>>>,>>>,>>9.99" "                    :" skip.
            if v-tmpval <> 0 then do:
                put stream v-out unformatted
                    "<TR align=left><FONT size=2>" skip
                    "<TD colspan=" v-tmpval ">Валюта  " crc.des + "  Входящий  остаток (" + crc.code + ")  " + string(w-bl.bl,"->,>>>,>>>,>>9.99") "</TD>" skip
                    "</FONT></TR>" skip.
            end.

            if lookup(string(vledger), "287034,187034,287035,187035,287036,187036,287037,187037,287033,187033" ) > 0 then
            put ":========:========:================:=================:========:=========:============================================================:==========================:"   skip.
            else
            put ":========:========:================:=================:========:=========:============================================================:"   skip.
        end.

        if first-of (arp.arp) then do:
            put ":    ARP N " arp.arp "(" + string(arp.gl) + ")" + arp.des format "x(52)" "Входящий  остаток (" crc.code ")".
            /* получение входящего остатка на дату запроса по каждому ARP */
            find trxbal where trxbal.subled = "ARP" and trxbal.acc = arp.arp and trxbal.level = 1 and trxbal.crc = arp.crc no-lock.
            if gl.type eq "A" or gl.type eq "E" then inamt = trxbal.pdam - trxbal.pcam.
                                                else inamt = trxbal.pcam - trxbal.pdam.

            for each jla where jla.acc eq arp.arp and jla.lev = 1
                and jla.jdt >= fdate and jla.jdt < g-today
                use-index acc no-lock break by jla.gl by jla.acc by jla.jdt:

                if gl.type eq "A" or gl.type eq "E" then
                    inamt = inamt - jla.dam + jla.cam.
                else
                    inamt = inamt + jla.dam - jla.cam.
            end.
            put inamt format "->,>>>,>>>,>>9.99"  "                    :" skip.

            if v-tmpval <> 0 then do:
                put stream v-out unformatted
                    "<TR align=left><FONT size=2>" skip
                    "<TD colspan=" v-tmpval ">ARP N  " arp.arp + " (" + string(arp.gl) + ") " + arp.des +
                    " Входящий  остаток (" + crc.code + ") " + string(inamt,"->,>>>,>>>,>>9.99") "</TD>" skip
                    "</FONT></TR>" skip.
            end.

            if lookup(string(vledger), "287034,187034,287035,187035,287036,187036,287037,187037,287033,187033" ) > 0 then
               put ":========:========:================:=================:========:=========:============================================================:===============:==========:" skip.
            else
               put ":========:========:================:=================:========:=========:============================================================:" skip.
        end.

        /* транзакции за указанный период */

        strokis = trim (jl.rem[1]) + " " + trim (jl.rem[2]) + " " + trim (jl.rem[3]) + " " + jl.rem[4].

        find jh where jh.jh = jl.jh no-lock.
        v-acc = "".
        v-des = "".
        v-des2 = "".
        v-subled = "".
        v-accnt = "".

        find first sub-cod where sub-cod.acc = entry(1,jh.ref) and sub-cod.d-cod = 'iso3166' no-lock no-error.
        if avail sub-cod then
           v-country = sub-cod.ccode.
        else
           v-country = "---".

        if jh.sub = "JOU" or jh.sub = "UJO" or jh.sub = "RMZ"
        then do:
             v-cod = "".
             v-kbe = "".
             v-knp = "".
             for each buff-jl where buff-jl.jh = jh.jh no-lock:
               run GetEKNP(jh.jh, buff-jl.ln, buff-jl.dc, input-output v-cod, input-output v-kbe, input-output v-knp).
             end.
             v-eknp = string(integer(v-cod),"999") + "," + string(integer(v-kbe),"999") + "," + string(integer(v-knp),"999").
             r = entry(1,jh.ref).
             if jh.sub = "JOU"
             then do:
                  find joudoc where joudoc.docnum = r no-lock.
                  if jl.dc = "D"
                  then v-acc = joudoc.cracc.
                  else v-acc = joudoc.dracc.
             end.
             else if jh.sub = "UJO"
             then do:
                  find last ujo where ujo.docnum = r no-lock no-error.
		  if avail ujo then
		  do:
	                  if jl.dc = "D"
        	        	  then v-acc = ujo.cracc.
                	  else v-acc = ujo.dracc.
		  end.
             end.
             else if jh.sub = "RMZ"
             then do:
                  find remtrz where remtrz.remtrz = r no-lock no-error.
                  if avail remtrz then do.
                  find first sub-cod where sub-cod.sub = "RMZ" and sub-cod.acc = r and sub-cod.d-cod = "eknp" and sub-cod.ccode = "eknp" no-lock no-error.
                  if avail sub-cod then v-eknp = sub-cod.rcod.
                  else v-eknp = "".

                  if jl.dc = "D"
                  then do:
                       v-acc = remtrz.rbank.
                       v-accnt = remtrz.ba.
                       v-des = remtrz.bn[1].
                  end.
                  else do:
                       v-acc = remtrz.dracc.
                       v-des = remtrz.ordins[1].
                  end.
                  end.

             end.
        end.
        if v-acc = "" or v-des = "" then do:
             if jl.dc = "D"
             then do:
                  for each jla where jla.jh = jh.jh and jla.dc = "C" and jla.lev = 1 and
                      jla.crc = jl.crc and jla.cam = jl.dam no-lock:
                      v-subled = jla.subled.
                      if v-acc = ""
                      then v-acc = jla.acc.
                      if v-acc = ""
                      then do:
                           v-acc = string(jla.gl,"999999").
                           find b-gl where b-gl.gl = jla.gl no-lock.
                           if v-des = "" then v-des = b-gl.des.
                      end.
                      else do:
                           if jla.subled = "ARP"
                           then do:
                                find b-arp where b-arp.arp = v-acc no-lock.
                                v-des = b-arp.des.
                           end.
                           else if jla.subled = "CIF"
                           then do:
                                find aaa where aaa.aaa = v-acc no-lock.
                                find cif where cif.cif = aaa.cif no-lock.
                                v-des = cif.name.
                           end.
                           else if jla.subled = "DFB"
                           then do:
                                find dfb where dfb.dfb = v-acc no-lock.
                                v-des = dfb.name.
                           end.
                           else if jla.subled = "EPS"
                           then do:
                                find eps where eps.eps = v-acc no-lock.
                                v-des = eps.des.
                           end.
                           else if jla.subled = "AST"
                           then do:
                                find ast where ast.ast = v-acc no-lock.
                                v-des = ast.name.
                           end.
                           else do:
                                find b-gl where b-gl.gl = jla.gl no-lock.
                                v-des = b-gl.des.
                           end.
                      end.
                      leave.
                  end.
             end.
             else do:
                  for each jla where jla.jh = jh.jh and jla.dc = "D" and jla.lev = 1 and
                      jla.crc = jl.crc and jla.dam = jl.cam no-lock:
                      v-subled = jla.subled.
                      if v-acc = ""
                      then v-acc = jla.acc.
                      if v-acc = ""
                      then do:
                           v-acc = string(jla.gl,"999999").
                           find b-gl where b-gl.gl = jla.gl no-lock.
                           if v-des = ""
                           then v-des = b-gl.des.
                      end.
                      else do:
                           if jla.subled = "ARP"
                           then do:
                                find b-arp where b-arp.arp = v-acc no-lock.
                                v-des = b-arp.des.
                           end.
                           else if jla.subled = "CIF"
                           then do:
                                find aaa where aaa.aaa = v-acc no-lock.
                                find cif where cif.cif = aaa.cif no-lock.
                                v-des = cif.name.
                           end.
                           else do:
                                find b-gl where b-gl.gl = jla.gl no-lock.
                                v-des = b-gl.des.
                           end.
                      end.
                      leave.
                  end.
             end.
        end.

        find last crchis where crchis.crc eq jl.crc and
             crchis.rdt <= jl.jdt no-lock no-error.

        if gl.type eq "A" or gl.type eq "E"
        then do:
             inamt = inamt + (jl.dam - jl.cam).
             w-bl.bl = w-bl.bl + (jl.dam - jl.cam).
             if jl.jdt = g-today
             then w-bl.bl-today = w-bl.bl-today +
                                  round(crchis.rate[1] / crchis.rate[9] *
                                        (jl.dam - jl.cam),2).
        end.
        else do:
             inamt = inamt + (jl.cam - jl.dam).
             w-bl.bl = w-bl.bl + (jl.cam - jl.dam).
             if jl.jdt = g-today
             then w-bl.bl-today = w-bl.bl-today +
                                  round(crchis.rate[1] / crchis.rate[9] *
                                  (jl.cam - jl.dam),2).
        end.
        w-bl.db = w-bl.db + jl.dam.
        w-bl.cr = w-bl.cr + jl.cam.
        v-des2 = v-des + strokis.
        if lookup(string(vledger), "287034,187034,287035,187035,287036,187036,287037,187037,287033,187033" ) > 0 then do:
            put ":" jl.jdt ":"
                string (jl.jh) ":"
                jl.dam format ">,>>>,>>>,>>9.99" ":"
                jl.cam format ">>,>>>,>>>,>>9.99" ":"
                jl.who ":"
                v-acc format "x(9)" ":"
                v-des format "x(60)" ":"
                v-eknp format "x(15)" ":"
                v-country format "x(10)" ":" skip.

            put stream v-out unformatted
                "<TR align=left><FONT size=2>" skip
                "<TD>" string(jl.jdt,"99/99/9999") "</TD>" skip
                "<TD>" string(jl.jh) "</TD>" skip
                "<TD align=center>" string(jl.dam,">,>>>,>>>,>>9.99") "</TD>" skip
                "<TD align=center>" string(jl.cam,">,>>>,>>>,>>9.99") "</TD>" skip
                "<TD>" jl.who "</TD>" skip
                "<TD>" v-acc "</TD>" skip
                "<TD>" v-des2 "</TD>" skip
                "<TD>" v-eknp "</TD>" skip
                "<TD>" v-country "</TD>" skip
                "</FONT></TR>" skip.
        end.
        else do:
            put ":" jl.jdt ":"
                string (jl.jh) ":"
                jl.dam format ">,>>>,>>>,>>9.99" ":"
                jl.cam format ">>,>>>,>>>,>>9.99" ":"
                jl.who ":"
                v-acc format "x(9)" ":"
                v-des format "x(60)" ":" skip.

            put stream v-out unformatted
                "<TR align=left><FONT size=2>" skip
                "<TD>" string(jl.jdt,"99/99/9999") "</TD>" skip
                "<TD>" string(jl.jh) "</TD>" skip
                "<TD>" string(jl.dam,">,>>>,>>>,>>9.99") "</TD>" skip
                "<TD>" string(jl.cam,">,>>>,>>>,>>9.99") "</TD>" skip
                "<TD>" jl.who "</TD>" skip
                "<TD>" v-acc "</TD>" skip
                "<TD>" v-des2 "</TD>" skip
                "</FONT></TR>" skip.
        end.
        if v-subled = "" then v-subled = v-accnt.
        do while strokis <> "" or v-subled <> "":
            run rin-dal(input-output strokis,output v-des,60).
            if lookup(string(vledger), "287034,187034,287035,187035,287036,187036,287037,187037,287033,187033" ) > 0 then do:
                put ":        :        :                :"
                    "                 :        :"
                    v-subled format "x(9)" ":"
                    v-des format "x(60)" ":"
                    "               :          :"
                    skip.
            end.
            else do:
                put ":        :        :                :"
                    "                 :        :"
                    v-subled format "x(9)" ":"
                    v-des format "x(60)" ":"
                    skip.
            end.
            v-subled = "".
        end.

        dba = dba + jl.dam.
        cra = cra + jl.cam.

        if last-of(arp.arp) then do:
            if lookup(string(vledger), "287034,187034,287035,187035,287036,187036,287037,187037,287033,187033" ) > 0 then do:
                put ":--------:--------:----------------:-----------------:--------:---------:"
                    "------------------------------------------------------------:---------------:----------:"  skip.
                put ":Итого по ARP     :"
                    dba format ">,>>>,>>>,>>9.99" ":"
                    cra format ">>,>>>,>>>,>>9.99"
                    ":                   "
                    "Исходящий остаток (" crc.code ")"
                    inamt format "->,>>>,>>>,>>9.99"
                    "                    :" skip.
                put ":========:========:================:=================:========:=========:"
                    "============================================================:===============:==========:" skip.

                put stream v-out unformatted
                    "<TR align=left><FONT size=2>" skip
                    "<TD colspan=2>Итого по ARP</TD>" skip
                    "<TD>" string(dba,">,>>>,>>>,>>9.99") "</TD>" skip
                    "<TD>" string(cra,">,>>>,>>>,>>9.99") "</TD>" skip
                    "<TD></TD>" skip
                    "<TD colspan=4>Исходящий остаток (" crc.code ") " + string(inamt,">,>>>,>>>,>>9.99") "</TD>" skip
                    "</FONT></TR>" skip.
            end.
            else do:
                put ":--------:--------:----------------:-----------------:--------:---------:"
                    "------------------------------------------------------------:"  skip.
                put ":Итого по ARP     :"
                    dba format ">,>>>,>>>,>>9.99" ":"
                    cra format ">>,>>>,>>>,>>9.99"
                    ":                   "
                    "Исходящий остаток (" crc.code ")"
                    inamt format "->,>>>,>>>,>>9.99" skip.
                put ":========:========:================:=================:========:=========:"
                    "============================================================:" skip.

                put stream v-out unformatted
                    "<TR align=left><FONT size=2>" skip
                    "<TD colspan=2>Итого по ARP</TD>" skip
                    "<TD>" string(dba,">,>>>,>>>,>>9.99") "</TD>" skip
                    "<TD>" string(cra,">,>>>,>>>,>>9.99") "</TD>" skip
                    "<TD colspan=3>Исходящий остаток (" crc.code ") " + string(inamt,">,>>>,>>>,>>9.99") "</TD>" skip
                    "</FONT></TR>" skip.
            end.
            dba = 0.    cra = 0.
        end.
        if last-of(arp.crc) and vsubled = ""
        then do:
            if lookup(string(vledger), "287034,187034,287035,187035,287036,187036,287037,187037,287033,187033" ) > 0 then do:
                put ":Итого по " + string(crc.code,"xxx") + "     :" format "x(19)"
                    w-bl.db format ">,>>>,>>>,>>9.99" ":"
                    w-bl.cr format ">>,>>>,>>>,>>9.99"
                    ":                   "
                    "Исходящий остаток (" crc.code ")"
                    w-bl.bl format "->,>>>,>>>,>>9.99"
                    "                    :" skip.
                put ":==================================="
                    "====================================="
                    "============================================================:==========================:"
                    skip.

                put stream v-out unformatted
                    "<TR align=left><FONT size=2>" skip
                    "<TD colspan=2>Итого по  " string(crc.code,"xxx") "</TD>" skip
                    "<TD>" string(w-bl.db,">,>>>,>>>,>>9.99") "</TD>" skip
                    "<TD>" string(w-bl.cr,">,>>>,>>>,>>9.99") "</TD>" skip
                    "<TD></TD>" skip
                    "<TD colspan=4>Исходящий остаток (" crc.code ") " + string(w-bl.bl,">,>>>,>>>,>>9.99") "</TD>" skip
                    "</FONT></TR>" skip.

            end.
            else do:
                put ":Итого по " + string(crc.code,"xxx") + "     :" format "x(19)"
                    w-bl.db format ">,>>>,>>>,>>9.99" ":"
                    w-bl.cr format ">>,>>>,>>>,>>9.99"
                    ":                   "
                    "Исходящий остаток (" crc.code ")"
                    w-bl.bl format "->,>>>,>>>,>>9.99" skip.
                put ":==================================="
                    "====================================="
                    "============================================================:"
                    skip.

                put stream v-out unformatted
                    "<TR align=left><FONT size=2>" skip
                    "<TD colspan=2>Итого по  " string(crc.code,"xxx") "</TD>" skip
                    "<TD>" string(w-bl.db,">,>>>,>>>,>>9.99") "</TD>" skip
                    "<TD>" string(w-bl.cr,">,>>>,>>>,>>9.99") "</TD>" skip
                    "<TD colspan=3>Исходящий остаток (" crc.code ") " + string(w-bl.bl,">,>>>,>>>,>>9.99") "</TD>" skip
                    "</FONT></TR>" skip.
            end.
        end.
    end.

    /* выход.остаток на дату конца периода с конвертацией */

    glblout = 0.
    glbldelta = 0.
    dbcon = 0.
    crcon = 0.

    for each crc no-lock:
        v-bal = 0.
        v-dam = 0.
        v-cam = 0.
        v-damcam = 0.
        v-dt1 = ?.
        find last glday where glday.gdt < fdate and glday.gl = v-gl and
             glday.crc = crc.crc no-lock no-error.
        if available glday
        then do:
             v-dt1 = glday.gdt.
             if gl.type eq "A" or gl.type eq "E"
             then do:
                  v-bal = glday.dam - glday.cam.
                  v-damcam = glday.cam.
             end.
             else do:
                  v-bal = glday.cam - glday.dam.
                  v-damcam = glday.dam.
             end.
             v-dam = glday.dam.
             v-cam = glday.cam.
        end.

        for each glday where glday.gdt >= fdate and
            glday.gdt <= tdate and glday.gl = v-gl and
            glday.crc = crc.crc no-lock by glday.gdt:

            if v-dt1 = ?
            then v-dt1 = glday.gdt.
            v-difdam = glday.dam - v-dam.
            v-difcam = glday.cam - v-cam.
            if year(glday.gdt) <> year(v-dt1)
            then do:
                 v-difdam = v-difdam + v-damcam.
                 v-difcam = v-difcam + v-damcam.
            end.
            find last crchis where crchis.crc eq crc.crc and
                 crchis.rdt <= glday.gdt no-lock no-error.
            dbcon = dbcon +
                    round(crchis.rate[1] / crchis.rate[9] * v-difdam,2).
            crcon = crcon +
                    round(crchis.rate[1] / crchis.rate[9] * v-difcam,2).

            v-dam = glday.dam.
            v-cam = glday.cam.
            if year(glday.gdt) <> year(v-dt1)
            then do:
                 v-dam = v-dam + v-damcam.
                 v-cam = v-cam + v-damcam.
            end.
            else do:
                 if gl.type = "A" or gl.type = "E"
                 then v-damcam = glday.cam.
                 else v-damcam = glday.dam.
            end.
            v-bal = glday.dam - glday.cam.
        end.

        find last glday where glday.gl = gl.gl and glday.crc = crc.crc and
             glday.gdt <= tdate no-lock no-error.
        if available glday
        then do:
             find last crchis where crchis.crc = crc.crc and
                  crchis.rdt <= tdate no-lock.
             if gl.type = "A" or gl.type = "E"
             then glblout = glblout + round((glday.dam - glday.cam) *
                          crchis.rate[1] / crchis.rate[9],2).
             else glblout = glblout + round((glday.cam - glday.dam) *
                          crchis.rate[1] / crchis.rate[9],2).
        end.
    end.

    if tdate = g-today
    then do:
         for each arp where arp.gl = v-gl no-lock:
             for each jl where /*jl.gl = v-gl and*/ jl.acc = arp.arp and jl.lev = 1 and
                 jl.jdt = tdate no-lock:
                 find last crchis where crchis.crc = jl.crc and
                      crchis.rdt <= jl.jdt no-lock.
                 dbcon = dbcon +
                         round(jl.dam * crchis.rate[1] / crchis.rate[9],2).
                 crcon = crcon +
                         round(jl.cam * crchis.rate[1] / crchis.rate[9],2).

                 if gl.type eq "A" or gl.type eq "E"
                 then glblout = glblout +
                                round(crchis.rate[1] / crchis.rate[9] *
                                      (jl.dam - jl.cam),2).
                 else glblout = glblout +
                                round(crchis.rate[1] / crchis.rate[9] *
                                      (jl.cam - jl.dam),2).
             end.
         end.
    end.

    if gl.type = "A" or gl.type = "E"
    then glbldelta = glblout - glblin - (dbcon - crcon).
    else glbldelta = glblout - glblin - (crcon - dbcon).

    if vsubled = ""
    then do:
        if lookup(string(vledger), "287034,187034,287035,187035,287036,187036,287037,187037,287033,187033" ) > 0 then do:
            put ":                                   "
            "                                     "
            "                                                            :"
            skip.
            put ":Итого по Б/С     :"
            dbcon format ">,>>>,>>>,>>9.99" ":"
            crcon format ">>,>>>,>>>,>>9.99"
            ":                   "
            "Исходящий остаток (KZT)"
            glblout format "->,>>>,>>>,>>9.99"
            " (" + trim(string(glbldelta,"->,>>>,>>>,>>9.99")) + ")"
            format "x(20)"  ":" skip.
            put ":==================================="
            "====================================="
            "============================================================:==========================:"
            skip.
            put stream v-out unformatted
                "<TR align=left><FONT size=2>" skip
                "<TD colspan=2>Итого по Б/С " string(crc.code,"xxx") "</TD>" skip
                "<TD>" string(dbcon,">,>>>,>>>,>>9.99") "</TD>" skip
                "<TD>" string(crcon,">,>>>,>>>,>>9.99") "</TD>" skip
                "<TD></TD>" skip
                "<TD colspan=4>Исходящий остаток (KZT) " + string(glblout,">,>>>,>>>,>>9.99") +  " (" +
                trim(string(glbldelta,"->,>>>,>>>,>>9.99")) + ")</TD>" skip
                "</FONT></TR>" skip.
         end.
         else do:
             put ":                                   "
                 "                                     "
                 "                                                            :"
                 skip.
             put ":Итого по Б/С     :"
                  dbcon format ">,>>>,>>>,>>9.99" ":"
                  crcon format ">>,>>>,>>>,>>9.99"
                  ":                   "
                  "Исходящий остаток (KZT)"
                  glblout format "->,>>>,>>>,>>9.99"
                  " (" + trim(string(glbldelta,"->,>>>,>>>,>>9.99")) + ")"
                         format "x(20)"  ":" skip.
             put ":==================================="
                 "====================================="
                 "============================================================:"
                 skip.

            put stream v-out unformatted
                "<TR align=left><FONT size=2>" skip
                "<TD colspan=2>Итого по Б/С " string(crc.code,"xxx") "</TD>" skip
                "<TD>" string(dbcon,">,>>>,>>>,>>9.99") "</TD>" skip
                "<TD>" string(crcon,">,>>>,>>>,>>9.99") "</TD>" skip
                "<TD colspan=3>Исходящий остаток (KZT) " + string(glblout,">,>>>,>>>,>>9.99") +  " (" +
                trim(string(glbldelta,"->,>>>,>>>,>>9.99")) + ")</TD>" skip
                "</FONT></TR>" skip.
         end.
    end.

end. /* sortofc = yes */
else
do: /* sortofc = no */
  /* message v-gl vsubled .*/
   for each arp where arp.gl eq v-gl and  (arp.arp eq (if vsubled eq " " then arp.arp else vsubled) or arp.arp eq (if vsubled eq " " then arp.arp else vsubled1)) no-lock,
    each jl where jl.acc eq arp.arp and  jl.lev = 1  and jl.jdt ge fdate and jl.jdt le tdate
        use-index acc  no-lock break by arp.crc by arp.arp /* by jl.acc */ by jl.jdt by jl.jh:

        find crc where crc.crc eq arp.crc no-lock no-error.

        if first-of(arp.crc) and vsubled = ""
        then do:
            if lookup(string(vledger), "287034,187034,287035,187035,287036,187036,287037,187037,287033,187033" ) > 0 then
            put ":==================================="
            "====================================="
            "============================================================:==========================:"
            skip.
            else
            put ":==================================="
            "====================================="
            "============================================================:"
            skip.
            find first w-bl where w-bl.crc = crc.crc no-error.
            put ":    Валюта"
            "          "
            crc.des format "x(52)"
            "Входящий  остаток (" crc.code ")"
            w-bl.bl format  "->,>>>,>>>,>>9.99"
            "                    :" skip.

            put stream v-out unformatted
                "<TR align=left><FONT size=2>" skip
                "<TD colspan=" v-tmpval ">Валюта" crc.des "  Входящий  остаток (" crc.code ") " +
                string(w-bl.bl,"->,>>>,>>>,>>9.99")  "</TD>" skip
                "</FONT></TR>" skip.

            if lookup(string(vledger), "287034,187034,287035,187035,287036,187036,287037,187037,287033,187033" ) > 0 then
            put ":========:========:================:"
            "=================:========:=========:"
            "============================================================:==========================:"
            skip.
            else
            put ":========:========:================:"
            "=================:========:=========:"
            "============================================================:"
            skip.
        end.

        if first-of (arp.arp) then do:
             put ":    ARP N "
                 arp.arp
                 "(" + string(arp.gl) + ")" + arp.des format "x(52)"
                 "Входящий  остаток (" crc.code ")".

            /* получение входящего остатка на дату запроса по каждому ARP */
            find trxbal where trxbal.subled = "ARP" and
                 trxbal.acc = arp.arp and trxbal.level = 1 and
                 trxbal.crc = arp.crc no-lock.
            if gl.type eq "A" or gl.type eq "E" then
                inamt = trxbal.pdam - trxbal.pcam.
            else
                inamt = trxbal.pcam - trxbal.pdam.

            for each jla where /* jla.gl eq v-gl and*/ jla.acc eq arp.arp and jla.lev = 1
                and jla.jdt >= fdate and jla.jdt < g-today
                use-index acc no-lock break by jla.gl by jla.acc by jla.jdt:

                if gl.type eq "A" or gl.type eq "E" then
                    inamt = inamt - jla.dam + jla.cam.
                else
                    inamt = inamt + jla.dam - jla.cam.
            end.
            put inamt format "->,>>>,>>>,>>9.99"
                "                    :" skip.


            put stream v-out unformatted
                "<TR align=left><FONT size=2>" skip
                "<TD colspan=" v-tmpval ">ARP N" arp.arp "(" + string(arp.gl) + ")  " + arp.des +
                "  Входящий  остаток (" crc.code ")  " + string(inamt,"->,>>>,>>>,>>9.99") "</TD>" skip
                "</FONT></TR>" skip.

            if lookup(string(vledger), "287034,187034,287035,187035,287036,187036,287037,187037,287033,187033" ) > 0 then
                put ":========:========:================:"
                    "=================:========:=========:"
                    "============================================================:===============:==========:"
                    skip.
            else
                put ":========:========:================:"
                    "=================:========:=========:"
                    "============================================================:"
                    skip.
        end.

        /* транзакции за указанный период */

        strokis = trim (jl.rem[1]) + " " + trim (jl.rem[2]) + " " +
            trim (jl.rem[3]) + " " + jl.rem[4].

        find jh where jh.jh = jl.jh no-lock.
        v-acc = "".
        v-des = "".
        v-des2 = "".
        v-subled = "".
        v-accnt = "".
        find first sub-cod where sub-cod.acc = entry(1,jh.ref) and sub-cod.d-cod = 'iso3166' no-lock no-error.
        if avail sub-cod then
           v-country = sub-cod.ccode.
        else
           v-country = "---".

        if jh.sub = "JOU" or jh.sub = "UJO" or jh.sub = "RMZ"
        then do:
             v-cod = "".
             v-kbe = "".
             v-knp = "".
             for each buff-jl where buff-jl.jh = jh.jh no-lock:
               run GetEKNP(jh.jh, buff-jl.ln, buff-jl.dc, input-output v-cod, input-output v-kbe, input-output v-knp).
             end.

             v-eknp = string(integer(v-cod),"999") + "," + string(integer(v-kbe),"999") + "," + string(integer(v-knp),"999").

             r = entry(1,jh.ref).
             if jh.sub = "JOU"
             then do:
                  find joudoc where joudoc.docnum = r no-lock.
                  if jl.dc = "D"
                  then v-acc = joudoc.cracc.
                  else v-acc = joudoc.dracc.
             end.
             else if jh.sub = "UJO"
             then do:
                  find last ujo where ujo.docnum = r no-lock no-error.
                  if avail ujo then
                  do:
                      if jl.dc = "D"
                      then v-acc = ujo.cracc.
                      else v-acc = ujo.dracc.
                  end.
             end.
             else if jh.sub = "RMZ"
             then do:
                  find remtrz where remtrz.remtrz = r no-lock no-error.
                  if avail remtrz then do.
                  find first sub-cod where sub-cod.sub = "RMZ" and sub-cod.acc = r and sub-cod.d-cod = "eknp" and sub-cod.ccode = "eknp" no-lock no-error.
                  if avail sub-cod then v-eknp = sub-cod.rcod.
                  else v-eknp = "".
                  if jl.dc = "D"
                  then do:
                       v-acc = remtrz.rbank.
                       v-accnt = remtrz.ba.
                       v-des = remtrz.bn[1].
                  end.
                  else do:
                       v-acc = remtrz.dracc.
                       v-des = remtrz.ordins[1].
                  end.
                  end.

             end.
        end.
        if v-acc = "" or v-des = ""
        then do:
             if jl.dc = "D"
             then do:
                  for each jla where jla.jh = jh.jh and jla.dc = "C" and jla.lev = 1 and
                      jla.crc = jl.crc and jla.cam = jl.dam no-lock:
                      v-subled = jla.subled.
                      if v-acc = ""
                      then v-acc = jla.acc.
                      if v-acc = ""
                      then do:
                           v-acc = string(jla.gl,"999999").
                           find b-gl where b-gl.gl = jla.gl no-lock.
                           if v-des = ""
                           then v-des = b-gl.des.
                      end.
                      else do:
                           if jla.subled = "ARP"
                           then do:
                                find b-arp where b-arp.arp = v-acc no-lock.
                                v-des = b-arp.des.
                           end.
                           else if jla.subled = "CIF"
                           then do:
                                find aaa where aaa.aaa = v-acc no-lock.
                                find cif where cif.cif = aaa.cif no-lock.
                                v-des = cif.name.
                           end.
                           else if jla.subled = "DFB"
                           then do:
                                find dfb where dfb.dfb = v-acc no-lock.
                                v-des = dfb.name.
                           end.
                           else if jla.subled = "EPS"
                           then do:
                                find eps where eps.eps = v-acc no-lock.
                                v-des = eps.des.
                           end.
                           else if jla.subled = "AST"
                           then do:
                                find ast where ast.ast = v-acc no-lock.
                                v-des = ast.name.
                           end.
                           else do:
                                find b-gl where b-gl.gl = jla.gl no-lock.
                                v-des = b-gl.des.
                           end.
                      end.
                      leave.
                  end.
             end.
             else do:
                  for each jla where jla.jh = jh.jh and jla.dc = "D" and jla.lev = 1 and
                      jla.crc = jl.crc and jla.dam = jl.cam no-lock:
                      v-subled = jla.subled.
                      if v-acc = ""
                      then v-acc = jla.acc.
                      if v-acc = ""
                      then do:
                           v-acc = string(jla.gl,"999999").
                           find b-gl where b-gl.gl = jla.gl no-lock.
                           if v-des = ""
                           then v-des = b-gl.des.
                      end.
                      else do:
                           if jla.subled = "ARP"
                           then do:
                                find b-arp where b-arp.arp = v-acc no-lock.
                                v-des = b-arp.des.
                           end.
                           else if jla.subled = "CIF"
                           then do:
                                find aaa where aaa.aaa = v-acc no-lock.
                                find cif where cif.cif = aaa.cif no-lock.
                                v-des = cif.name.
                           end.
                           else do:
                                find b-gl where b-gl.gl = jla.gl no-lock.
                                v-des = b-gl.des.
                           end.
                      end.
                      leave.
                  end.
             end.
        end.

        find last crchis where crchis.crc eq jl.crc and
             crchis.rdt <= jl.jdt no-lock no-error.

        if gl.type eq "A" or gl.type eq "E"
        then do:
             inamt = inamt + (jl.dam - jl.cam).
             w-bl.bl = w-bl.bl + (jl.dam - jl.cam).
             if jl.jdt = g-today
             then w-bl.bl-today = w-bl.bl-today +
                                  round(crchis.rate[1] / crchis.rate[9] *
                                        (jl.dam - jl.cam),2).
        end.
        else do:
             inamt = inamt + (jl.cam - jl.dam).
             w-bl.bl = w-bl.bl + (jl.cam - jl.dam).
             if jl.jdt = g-today
             then w-bl.bl-today = w-bl.bl-today +
                                  round(crchis.rate[1] / crchis.rate[9] *
                                  (jl.cam - jl.dam),2).
        end.
        w-bl.db = w-bl.db + jl.dam.
        w-bl.cr = w-bl.cr + jl.cam.
        v-des2 = v-des + strokis.
        if lookup(string(vledger), "287034,187034,287035,187035,287036,187036,287037,187037,287033,187033" ) > 0 then do:
            put ":" jl.jdt ":"
                string (jl.jh) ":"
                jl.dam format ">,>>>,>>>,>>9.99" ":"
                jl.cam format ">>,>>>,>>>,>>9.99" ":"
                jl.who ":"
                v-acc format "x(9)" ":"
                v-des format "x(60)" ":"
                v-eknp format "x(15)" ":"
                v-country format "x(10)" ":" skip.

            put stream v-out unformatted
                "<TR align=left><FONT size=2>" skip
                "<TD>" string(jl.jdt,"99/99/9999") "</TD>" skip
                "<TD>" string(jl.jh) "</TD>" skip
                "<TD align=center>" string(jl.dam,">,>>>,>>>,>>9.99") "</TD>" skip
                "<TD align=center>" string(jl.cam,">,>>>,>>>,>>9.99") "</TD>" skip
                "<TD>" jl.who "</TD>" skip
                "<TD>" v-acc "</TD>" skip
                "<TD>" v-des2 "</TD>" skip
                "<TD>" v-eknp "</TD>" skip
                "<TD>" v-country "</TD>" skip
                "</FONT></TR>" skip.
        end.
        else do:
            put ":" jl.jdt ":"
                string (jl.jh) ":"
                jl.dam format ">,>>>,>>>,>>9.99" ":"
                jl.cam format ">>,>>>,>>>,>>9.99" ":"
                jl.who ":"
                v-acc format "x(9)" ":"
                v-des format "x(60)" ":" skip.

            put stream v-out unformatted
                "<TR align=left><FONT size=2>" skip
                "<TD>" string(jl.jdt,"99/99/9999") "</TD>" skip
                "<TD>" string(jl.jh) "</TD>" skip
                "<TD align=center>" string(jl.dam,">,>>>,>>>,>>9.99") "</TD>" skip
                "<TD align=center>" string(jl.cam,">,>>>,>>>,>>9.99") "</TD>" skip
                "<TD>" jl.who "</TD>" skip
                "<TD>" v-acc "</TD>" skip
                "<TD>" v-des2 "</TD>" skip
                "</FONT></TR>" skip.
        end.
        if v-subled = ""
        then v-subled = v-accnt.
        do while strokis <> "" or v-subled <> "":
           run rin-dal(input-output strokis,output v-des,60).
           if lookup(string(vledger), "287034,187034,287035,187035,287036,187036,287037,187037,287033,187033" ) > 0 then do:
                put ":        :        :                :"
                    "                 :        :"
                    v-subled format "x(9)" ":"
                    v-des format "x(60)" ":"
                    "               :          :"
                    skip.
           end.
           else do:
                put ":        :        :                :"
                    "                 :        :"
                    v-subled format "x(9)" ":"
                    v-des format "x(60)" ":"
                    skip.
           end.
           v-subled = "".
        end.

        dba = dba + jl.dam.
        cra = cra + jl.cam.

        if last-of(arp.arp)
        then do:
            if lookup(string(vledger), "287034,187034,287035,187035,287036,187036,287037,187037,287033,187033" ) > 0 then do:
                put ":--------:--------:----------------:"
                "-----------------:--------:---------:"
                "------------------------------------------------------------:---------------:----------:"
                skip.
                put ":Итого по ARP     :"
                dba format ">,>>>,>>>,>>9.99" ":"
                cra format ">>,>>>,>>>,>>9.99"
                ":                   "
                "Исходящий остаток (" crc.code ")"
                inamt format "->,>>>,>>>,>>9.99"
                "                    :" skip.
                put ":========:========:================:"
                "=================:========:=========:"
                "============================================================:===============:==========:"
                skip.

                put stream v-out unformatted
                    "<TR align=left><FONT size=2>" skip
                    "<TD colspan=2>Итого по ARP</TD>" skip
                    "<TD>" string(dba,">,>>>,>>>,>>9.99") "</TD>" skip
                    "<TD>" string(cra,">,>>>,>>>,>>9.99") "</TD>" skip
                    "<TD></TD>" skip
                    "<TD colspan=4>Исходящий остаток (" crc.code ") " + string(inamt,">,>>>,>>>,>>9.99") "</TD>" skip
                    "</FONT></TR>" skip.
            end.
            else do:
                put ":--------:--------:----------------:"
                "-----------------:--------:---------:"
                "------------------------------------------------------------::"
                skip.
                put ":Итого по ARP     :"
                dba format ">,>>>,>>>,>>9.99" ":"
                cra format ">>,>>>,>>>,>>9.99"
                ":                   "
                "Исходящий остаток (" crc.code ")"
                inamt format "->,>>>,>>>,>>9.99"
                "                    :" skip.
                put ":========:========:================:"
                "=================:========:=========:"
                "============================================================:"
                skip.

                put stream v-out unformatted
                    "<TR align=left><FONT size=2>" skip
                    "<TD colspan=2>Итого по ARP</TD>" skip
                    "<TD>" string(dba,">,>>>,>>>,>>9.99") "</TD>" skip
                    "<TD>" string(cra,">,>>>,>>>,>>9.99") "</TD>" skip
                    "<TD colspan=3>Исходящий остаток (" crc.code ") " + string(inamt,">,>>>,>>>,>>9.99") "</TD>" skip
                    "</FONT></TR>" skip.
            end.
            dba = 0.    cra = 0.
        end.
        if last-of(arp.crc) and vsubled = "" then do:
            put ":Итого по " + string(crc.code,"xxx") + "     :" format "x(19)"
                w-bl.db format ">,>>>,>>>,>>9.99" ":"
                w-bl.cr format ">>,>>>,>>>,>>9.99"
                ":                   "
                "Исходящий остаток (" crc.code ")"
                w-bl.bl format "->,>>>,>>>,>>9.99"
                "                    :" skip.


            put stream v-out unformatted
                    "<TR align=left><FONT size=2>" skip
                    "<TD colspan=" v-tmpval ">Итого по  " string(crc.code,"xxx") + "  " + string(w-bl.db,">,>>>,>>>,>>9.99") +
                    "  " + string(w-bl.cr,">,>>>,>>>,>>9.99") + "  Исходящий остаток (" + crc.code + ") " +
                    string(w-bl.bl,">,>>>,>>>,>>9.99") "</TD>" skip
                    "</FONT></TR>" skip.

            if lookup(string(vledger), "287034,187034,287035,187035,287036,187036,287037,187037,287033,187033" ) > 0 then
                put ":==================================="
                    "====================================="
                    "============================================================:==========================:"
                    skip.
            else
                put ":==================================="
                    "====================================="
                    "============================================================:"
                    skip.
        end.
    end.

    /* выход.остаток на дату конца периода с конвертацией */

    glblout = 0.
    glbldelta = 0.
    dbcon = 0.
    crcon = 0.

    for each crc no-lock:
        v-bal = 0.
        v-dam = 0.
        v-cam = 0.
        v-damcam = 0.
        v-dt1 = ?.
        find last glday where glday.gdt < fdate and glday.gl = v-gl and
             glday.crc = crc.crc no-lock no-error.
        if available glday
        then do:
             v-dt1 = glday.gdt.
             if gl.type eq "A" or gl.type eq "E"
             then do:
                  v-bal = glday.dam - glday.cam.
                  v-damcam = glday.cam.
             end.
             else do:
                  v-bal = glday.cam - glday.dam.
                  v-damcam = glday.dam.
             end.
             v-dam = glday.dam.
             v-cam = glday.cam.
        end.

        for each glday where glday.gdt >= fdate and
            glday.gdt <= tdate and glday.gl = v-gl and
            glday.crc = crc.crc no-lock by glday.gdt:

            if v-dt1 = ?
            then v-dt1 = glday.gdt.
            v-difdam = glday.dam - v-dam.
            v-difcam = glday.cam - v-cam.
            if year(glday.gdt) <> year(v-dt1)
            then do:
                 v-difdam = v-difdam + v-damcam.
                 v-difcam = v-difcam + v-damcam.
            end.
            find last crchis where crchis.crc eq crc.crc and
                 crchis.rdt <= glday.gdt no-lock no-error.
            dbcon = dbcon +
                    round(crchis.rate[1] / crchis.rate[9] * v-difdam,2).
            crcon = crcon +
                    round(crchis.rate[1] / crchis.rate[9] * v-difcam,2).

            v-dam = glday.dam.
            v-cam = glday.cam.
            if year(glday.gdt) <> year(v-dt1)
            then do:
                 v-dam = v-dam + v-damcam.
                 v-cam = v-cam + v-damcam.
            end.
            else do:
                 if gl.type = "A" or gl.type = "E"
                 then v-damcam = glday.cam.
                 else v-damcam = glday.dam.
            end.
            v-bal = glday.dam - glday.cam.
        end.

        find last glday where glday.gl = gl.gl and glday.crc = crc.crc and
             glday.gdt <= tdate no-lock no-error.
        if available glday
        then do:
             find last crchis where crchis.crc = crc.crc and
                  crchis.rdt <= tdate no-lock.
             if gl.type = "A" or gl.type = "E"
             then glblout = glblout + round((glday.dam - glday.cam) *
                          crchis.rate[1] / crchis.rate[9],2).
             else glblout = glblout + round((glday.cam - glday.dam) *
                          crchis.rate[1] / crchis.rate[9],2).
        end.
    end.

    if tdate = g-today
    then do:
         for each arp where arp.gl = v-gl no-lock:
             for each jl where /*jl.gl = v-gl and*/ jl.acc = arp.arp and jl.lev = 1 and
                 jl.jdt = tdate no-lock:
                 find last crchis where crchis.crc = jl.crc and
                      crchis.rdt <= jl.jdt no-lock.
                 dbcon = dbcon +
                         round(jl.dam * crchis.rate[1] / crchis.rate[9],2).
                 crcon = crcon +
                         round(jl.cam * crchis.rate[1] / crchis.rate[9],2).

                 if gl.type eq "A" or gl.type eq "E"
                 then glblout = glblout +
                                round(crchis.rate[1] / crchis.rate[9] *
                                      (jl.dam - jl.cam),2).
                 else glblout = glblout +
                                round(crchis.rate[1] / crchis.rate[9] *
                                      (jl.cam - jl.dam),2).
             end.
         end.
    end.

    if gl.type = "A" or gl.type = "E"
    then glbldelta = glblout - glblin - (dbcon - crcon).
    else glbldelta = glblout - glblin - (crcon - dbcon).

    if vsubled = "" then do:
        put ":                                   "
        "                                     "
        "                                                            :"
        skip.
        put ":Итого по Б/С     :"
        dbcon format ">,>>>,>>>,>>9.99" ":"
        crcon format ">>,>>>,>>>,>>9.99"
        ":                   "
        "Исходящий остаток (KZT)"
        glblout format "->,>>>,>>>,>>9.99"
        " (" + trim(string(glbldelta,"->,>>>,>>>,>>9.99")) + ")"
        format "x(20)"  ":" skip.

        put stream v-out unformatted
            "<TR align=left><FONT size=2>" skip
            "<TD colspan=" v-tmpval ">Итого по Б/С   " + string(dbcon,">,>>>,>>>,>>9.99") +
            "  " + string(crcon,">,>>>,>>>,>>9.99") + "  Исходящий остаток (KZT)  " + string(glblout,"->,>>>,>>>,>>9.99") +
            "  (" + trim(string(glbldelta,"->,>>>,>>>,>>9.99")) + ")</TD>" skip
            "</FONT></TR>" skip.

        if lookup(string(vledger), "287034,187034,287035,187035,287036,187036,287037,187037,287033,187033" ) > 0 then
        put ":==================================="
        "====================================="
        "============================================================:==========================:"
        skip.
        else
        put ":==================================="
        "====================================="
        "============================================================:"
        skip.
    end.

end. /* sortofc... */

end.

put stream v-out unformatted
    "</TABLE>" skip
    "<P align=left>*****************Конец документа***********************</P>" skip.

{html-end.i "stream v-out"}

output stream v-out close.

/*input from value(v-file).
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
output stream v-out2 close.*/

unix silent cptwin value(v-file) winword.

{report3.i}
/* {image3.i} */
run menu-prt("rpt.img").
