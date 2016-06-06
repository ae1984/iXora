/* r-obmcrc.p
 * MODULE
        Название Программного Модуля
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
 * BASES
        BANK
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        10/08/04 kanat - добавил кассу в пути в выборку по операциям кассиров
                         и будет новый групповой почтовый адрес для рассылки по СПФ и ДРР распоряжений по курсам валют
        11/08/04 kanat - добавил дополнительные адреса к отправке писем распоряжений валют
        18.10.04 dpuchkov - исправил tolebi@texabank.kz на tolebi@elexnet.kz
        07.09.05 nataly  c изменением сайта  - http://www.texakabank.kz/tkb/cards/img/gerb.gif
        25/04/2012 evseev  - rebranding. Название банка из sysc или изменил проверку банка или рко
*/

/* ------------------------------ */
/* r-obmcrc.p 16.04.2003 Sasco    */
/* Отчет о курсах покупки-продажи */
/* в обменных пунктах             */
/* ------------------------------ */
{nbankBik.i}
{get-dep.i}
def shared var g-today as date.
def var out as char.

def var v-m as char extent 12 init ["января",
                                    "февраля",
                                    "марта",
                                    "апреля",
                                    "мая",
                                    "июня",
                                    "июля",
                                    "августа",
                                    "сентября",
                                    "октября",
                                    "ноября",
                                    "декабря"].


def var v-dat   as date no-undo.
def var lastbr  as decimal extent 15 no-undo.
def var lastsr  as decimal extent 15 no-undo.

def var str_p   as char no-undo.
def var sel_p   as int no-undo.
def var depname as char no-undo.

def var ll as log.

def temp-table spc
               field jou  like joudoc.docnum
               field crc  like crc.crc
               field code like crc.code
               field br   as decimal
               field sr   as decimal
               field bspc as log init no
               field sspc as log init no
               field tim  as int
               field uid  like ofc.ofc
               field dam  as decimal
               field cam  as decimal
               field fio  as char
               field pass as char
               index idx_spc_br is primary bspc tim uid
               index idx_spc_sr sspc tim uid.

def temp-table tmp
               field crc  like crc.crc
               field code like crc.code
               field br   as   decimal
               field sr   as   decimal
               field tim  as   int
               field bspc as   log init no
               field sspc as   log init no
               index idx_tmp is primary crc tim.

str_p = "".
for each ppoint no-lock by ppoint.depart:
    str_p = str_p + string (ppoint.depart) + ". " + ppoint.name + "|".
end.
str_p = SUBSTR (str_p, 1, LENGTH(str_p) - 1).
run sel ("Выберите департамент", str_p).
if return-value = ? then undo, return.
sel_p = int(return-value).
sel_p = INT (ENTRY (1, ENTRY(sel_p, str_p, "|"), ".")).
find ppoint where ppoint.depart = sel_p no-lock no-error.
if not avail ppoint then undo, return.
depname = ppoint.name.

v-dat = g-today.
update v-dat label "Введите дату отчета" with row 5 centered frame datFr.
hide frame datFr.
pause 0.

for each crchis where crchis.rdt = v-dat no-lock:
    find crc where crc.crc = crchis.crc no-lock no-error.
    create tmp.
    assign tmp.crc  = crchis.crc
           tmp.code = crc.des
           tmp.br   = crchis.rate[2]
           tmp.sr   = crchis.rate[3]
           tmp.bspc = no
           tmp.sspc = no
           tmp.tim  = crchis.tim.
end.

for each jl where (jl.gl = 100100  or jl.gl = 100200 or jl.gl = 100300) and substring(jl.rem[1],1,5) = 'Обмен' and
                   jl.crc <> 1 and jl.jdt = v-dat no-lock:
    if get-dep (jl.teller, jl.jdt) <> sel_p then next.
    find joudoc where joudoc.jh = jl.jh and joudoc.who = jl.who and joudoc.whn = jl.jdt no-lock no-error.
    if avail joudoc then
    do:

          find crc where crc.crc = jl.crc no-lock no-error.

          find last tmp where tmp.crc = jl.crc and tmp.tim <= joudoc.tim no-lock no-error.
          if not avail tmp then find first tmp where tmp.crc = jl.crc no-lock no-error.
          if not avail tmp then assign lastbr[jl.crc] = 0.0
                                       lastsr[jl.crc] = 0.0.
                           else assign lastbr[jl.crc] = tmp.br
                                       lastsr[jl.crc] = tmp.sr.

/*          release tmp. */
          if jl.dc = 'd' and jl.dam <> 0 then do:
             if lastbr[jl.crc] <> joudoc.brate then do:
                create tmp.
                tmp.crc  = jl.crc.
                tmp.code = crc.des.
                tmp.br   = joudoc.brate.
                tmp.sr   = lastsr[jl.crc].
                tmp.tim  = joudoc.tim.
                tmp.sspc = no.
                tmp.bspc = no.
                if joudoc.sts = "SPC" then tmp.bspc = yes.
             end.
          end.

          if jl.dc = 'c' and jl.cam <> 0 then do:
             if lastsr[jl.crc] <> joudoc.srate then do:
                create tmp.
                tmp.crc  = jl.crc.
                tmp.code = crc.des.
                tmp.br   = lastbr[jl.crc].
                tmp.sr   = joudoc.srate.
                tmp.tim  = joudoc.tim.
                tmp.sspc = no.
                tmp.bspc = no.
                if joudoc.sts = "SPC" then tmp.sspc = yes.
             end.
          end.

/*          if avail tmp  / * and joudoc.sts = "SPC" and (tmp.bspc or tmp.sspc)  * / then do: */
             create spc.
             assign spc.crc  = jl.crc
                    spc.code = tmp.code
                    spc.br   = tmp.br
                    spc.sr   = tmp.sr
                    spc.uid  = jl.who
                    spc.bspc = tmp.bspc
                    spc.sspc = tmp.sspc
                    spc.tim  = tmp.tim
                    spc.dam  = jl.dam
                    spc.cam  = jl.cam
                    spc.fio  = joudoc.info
                    spc.pass = joudoc.passp
                    spc.jou  = joudoc.docnum.
             if jl.dc = 'c' then spc.br = 0.0.
             if jl.dc = 'd' then spc.sr = 0.0.

/*          end. */

    end.
end.

/* удалим нулевые */
for each tmp:
    if tmp.br = 0.0 and tmp.sr = 0.0 then delete tmp.
end.
for each spc:
    if spc.br = 0.0 and spc.sr = 0.0 then delete spc.
end.

/* первый курс сделаем на 9:00 */

for each crc:
    find first tmp where tmp.crc = crc.crc no-error.
    if avail tmp then tmp.tim = 32400.
end.


output to rpt.html.
put unformatted "<html><head><title>" + v-nbank1 + "</title>" SKIP
        "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" SKIP
        "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body leftmargin=""30"" topmargin=""30"">" SKIP.


put unformatted "<table align=""center"" width = 600 border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" SKIP.
put unformatted "<div align=""center""><H1 align=""center"">T&nbsp;&nbsp;E&nbsp;&nbsp;X&nbsp;&nbsp;A&nbsp;&nbsp;K&nbsp;&nbsp;A&nbsp;&nbsp;B&nbsp;&nbsp;A&nbsp;&nbsp;N&nbsp;&nbsp;K</H1></div> <br><br>" SKIP.
put unformatted "<H3 align=""right"">&#139;&#139;" DAY (v-dat) "&#155;&#155;&nbsp;&nbsp;" v-m[MONTH(v-dat)] "&nbsp;&nbsp;" STRING (YEAR(v-dat), "9999") "&nbsp;г.</H3> <br><br>" SKIP.
put unformatted "<H3 align=""center""><u>Р А С П О Р Я Ж Е Н И Е</u></H3>" SKIP.
put unformatted "<H3 align=""center"">П О &nbsp;&nbsp;&nbsp;О Б М Е Н Н О М У &nbsp;&nbsp;&nbsp; П У Н К Т У</H3>" SKIP.
put unformatted "<H3 align=""center"">" + depname + "</H3>" SKIP.

put unformatted "<H4 align=""center"">Установить следующие курсы покупки и продажи наличных валют</H4><br>" SKIP.

put unformatted "<table align=""center"" width = 600 border=""1"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" SKIP.
put unformatted "<tr><td></td><td align=""right""><b>&nbsp;Покупка&nbsp;</b></td><td align=""right""><b>&nbsp;Продажа&nbsp;</b></td><td align=""right""><b>&nbsp;Время&nbsp;</b></td></tr>" SKIP.

ll = no.
for each tmp break by tmp.crc:

    if first-of (tmp.crc) then do: if ll then put unformatted "<tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>" SKIP. ll = yes. end.
    put unformatted "<tr><td>" SKIP.
    if first-of (tmp.crc) then put unformatted CAPS(TRIM(tmp.code)).

    put unformatted "</td>" SKIP.
    put unformatted "<td align=""right"">".
    if tmp.bspc then put unformatted "&nbsp; * &nbsp;".
    put unformatted  tmp.br format "zzzzz9.99".
    put unformatted  "&nbsp;</td>" SKIP.

    put unformatted "<td align=""right"">".
    if tmp.sspc then put unformatted "&nbsp; * &nbsp;".
    put unformatted  tmp.sr format "zzzzz9.99".
    put unformatted  "&nbsp;</td>" SKIP.

    put unformatted "<td align=""right"">&nbsp;" string (tmp.tim, "hh:mm:ss") "&nbsp;</td></tr>".
end.

put unformatted "</table><br><br>" SKIP.

put unformatted "<H3 align=""left"" style=""margin-bottom: 0"">Директор&nbsp;&nbsp;Департамента</H3>" SKIP.
put unformatted "<H3 align=""left"" style=""margin-top:0; margin-bottom: 0"">Казначейства</H3>" SKIP.
put unformatted "<H3 align=""left"" style=""margin-top:0; margin-bottom: 0"">&nbsp&nbsp;"
                "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;___________________________" SKIP.

put unformatted "<br><br>" SKIP.

put unformatted "<H3 align=""left"" style=""margin-bottom: 0"">Менеджер</H3>" SKIP.
put unformatted "<H3 align=""left"" style=""margin-top:0; margin-bottom: 0"">&nbsp;&nbsp"
                "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;___________________________" SKIP.

put unformatted "</table>" SKIP.

{html-end.i}
output close.

out = string(day(v-dat),'99') + string(month(v-dat),'99') + substring(string(year(v-dat),'9999'),3,2) + ".htm".
unix SILENT value('cat rpt.html | koi2win  > ' + out).

 run mail("merkur@elexnet.kz;samal@elexnet.kz;reiz@elexnet.kz;sulpak@elexnet.kz;tolebi@elexnet.kz;Atakent@elexnet.kz",
          "TEXAKABANK <abpk@elexnet.kz>",
          "Распоряжения по курсам валют за " + string(day(v-dat),'99.') + string(month(v-dat),'99.') + substring(string(year(v-dat),'9999'),3,2) +
          ". Время: " + string(time,"HH:MM:SS"),
          "", "1", "", out).

ll = no.
output to pril.html.
put unformatted "<html><head><title>" + v-nbank1 + "</title>" SKIP
        "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" SKIP
        "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body leftmargin=""30"" topmargin=""30"">" SKIP.

put unformatted "<table align=""center"" width = 600 border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" SKIP.
/*
put unformatted "<div align=""center""><H1 align=""center"">T&nbsp;&nbsp;E&nbsp;&nbsp;X&nbsp;&nbsp;A&nbsp;&nbsp;K&nbsp;&nbsp;A&nbsp;&nbsp;B&nbsp;&nbsp;A&nbsp;&nbsp;N&nbsp;&nbsp;K</H1></div> <br><br>" SKIP.
*/
put unformatted "<H3 align=""center""><br></H3>" SKIP.
put unformatted "<H3 align=""center""><u>С П Е Ц . К У Р С Ы</u></H3>" SKIP.
put unformatted "<H3 align=""center"">К &nbsp;&nbsp;&nbsp;Р А С П О Р Я Ж Е Н И Ю&nbsp;&nbsp;&nbsp;О Т &nbsp;&nbsp; &#139;&#139;" DAY (v-dat) "&#155;&#155;&nbsp;&nbsp;" v-m[MONTH(v-dat)] "&nbsp;&nbsp;" STRING (YEAR(v-dat), "9999") "&nbsp;г.</H3>" SKIP.
put unformatted "<H3 align=""center"">" + depname + "</H3>" SKIP.
put unformatted "<H3 align=""center""></H3> <br>" SKIP.

put unformatted "<table align=""center"" width = 600 border=""1"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" SKIP.
put unformatted "<tr><td></td><td align=""right""><b>&nbsp;Покупка&nbsp;</b></td><td align=""right""><b>&nbsp;Продажа&nbsp;</b></td><td align=""right""><b>&nbsp;Сумма&nbsp;</b></td><td align=""right""><b>&nbsp;Время&nbsp;</b></td><td align=""right""><b>&nbsp;Кассир&nbsp;</b><br><b>&nbsp;Документ&nbsp;</b></td><td><b>&nbsp;ФИО &nbsp;<br>&nbsp; Паспорт &nbsp;</b></td></tr>" SKIP.

for each spc where spc.bspc or spc.sspc break by spc.crc:

    if first-of (spc.crc) then do: if ll then put unformatted "<tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>" SKIP. ll = yes. end.

    put unformatted "<tr><td>" SKIP.
    if first-of (spc.crc) then put unformatted CAPS(TRIM(spc.code)).

    put unformatted "</td>" SKIP.

    put unformatted "<td align=""right"">".
    if spc.bspc then put unformatted spc.br format "zzzzz9.99".
    put unformatted  "&nbsp;</td>" SKIP.

    put unformatted "<td align=""right"">".
    if spc.sspc then put unformatted spc.sr format "zzzzz9.99".
    put unformatted  "&nbsp;</td>" SKIP.

    put unformatted "<td align=""right"">&nbsp;&nbsp;" TRIM (string (spc.dam + spc.cam, "z,zzz,zzz,zzz,zz9.99")) "</td>" SKIP.

    put unformatted "<td align=""right"">&nbsp;" string (spc.tim, "hh:mm:ss") "&nbsp;</td>" SKIP.

    put unformatted "<td align=""right"">&nbsp;" spc.uid "&nbsp;<br>&nbsp;" spc.jou "&nbsp;</td>" SKIP.

    put unformatted "<td>" TRIM(REPLACE(spc.fio, " ", "&nbsp;")) + "<br>" + spc.pass "</td>" SKIP.

    put unformatted "</tr>".
end.

put unformatted "</table><br><br>" SKIP.
put unformatted "</table>" SKIP.

{html-end.i}
output close.

ll = no.
output to pril2.html.
put unformatted "<html><head><title>" + v-nbank1 + "</title>" SKIP
        "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" SKIP
        "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body leftmargin=""30"" topmargin=""30"">" SKIP.

put unformatted "<table align=""center"" width = 600 border=""0"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" SKIP.
put unformatted "<H3 align=""center""><br></H3>" SKIP.
put unformatted "<H3 align=""center"">Расшифровка обменных операций по наличной валюте</H3>" SKIP.
put unformatted "<H3 align=""center"">&nbsp; &#139;&#139;" DAY (v-dat) "&#155;&#155;&nbsp;&nbsp;" v-m[MONTH(v-dat)] "&nbsp;&nbsp;" STRING (YEAR(v-dat), "9999") "&nbsp;г.</H3>" SKIP.
put unformatted "<H3 align=""center"">" + depname + "</H3>" SKIP.
put unformatted "<H3 align=""center""></H3> <br>" SKIP.

put unformatted "<table align=""center"" width = 600 border=""1"" cellpadding=""0"" cellspacing=""0"" style=""border-collapse: collapse"">" SKIP.
put unformatted "<tr><td></td><td align=""right""><b>&nbsp;Покупка&nbsp;</b></td><td align=""right""><b>&nbsp;Продажа&nbsp;</b></td><td align=""right""><b>&nbsp;Сумма&nbsp;</b></td><td align=""right""><b>&nbsp;Время&nbsp;</b></td><td align=""right""><b>&nbsp;Кассир&nbsp;</b><br><b>&nbsp;Документ&nbsp;</b></td><td><b>&nbsp;ФИО &nbsp;<br>&nbsp; Паспорт &nbsp;</b></td></tr>" SKIP.

for each spc break by spc.crc:

    if first-of (spc.crc) then do: if ll then put unformatted "<tr><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>" SKIP. ll = yes. end.

    put unformatted "<tr><td>" SKIP.
    if first-of (spc.crc) then put unformatted CAPS(TRIM(spc.code)).

    put unformatted "</td>" SKIP.

    put unformatted "<td align=""right"">".
    if spc.br <> 0.0 then put unformatted spc.br format "zzzzz9.99".
    put unformatted  "&nbsp;</td>" SKIP.

    put unformatted "<td align=""right"">".
    if spc.sr <> 0.0 then put unformatted spc.sr format "zzzzz9.99".
    put unformatted  "&nbsp;</td>" SKIP.

    put unformatted "<td align=""right"">&nbsp;&nbsp;" TRIM(string (spc.dam + spc.cam, "z,zzz,zzz,zzz,zz9.99")) "</td>" SKIP.

    put unformatted "<td align=""right"">&nbsp;" string (spc.tim, "hh:mm:ss") "&nbsp;</td>" SKIP.

    put unformatted "<td align=""right"">&nbsp;" spc.uid "&nbsp;<br>&nbsp;" spc.jou "&nbsp;</td>" SKIP.

    put unformatted "<td>" TRIM(REPLACE(spc.fio, " ", "&nbsp;")) + "<br>" + spc.pass "</td>" SKIP.

    put unformatted "</tr>".
end.

put unformatted "</table><br><br>" SKIP.
put unformatted "</table>" SKIP.

{html-end.i}
output close.

unix silent value ("cptwin rpt.html explorer.exe").
unix silent value ("cptwin pril.html explorer.exe").
unix silent value ("cptwin pril2.html explorer.exe").

unix silent value ("rm rpt.html").
unix silent value ("rm pril.html").
unix silent value ("rm pril2.html").




