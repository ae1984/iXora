/* lndopnk.p
 * MODULE
        Потреб. кредитование
 * DESCRIPTION
        Формирование доп. соглашения
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
        30/04/2010 madiyar
 * BASES
        BANK COMM
 * CHANGES
        11/05/2010 madiyar - подправил дату доп. соглашения
*/

{global.i}
{pk.i}
{pk-sysc.i}

def stream v-out.
def var v-ofile as char no-undo.
def var v-infile as char no-undo.
def var v-str as char no-undo.

if s-pkankln = 0 then return.

find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.ln = s-pkankln no-lock no-error.

if not avail pkanketa then do:
    message skip " Анкета N" s-pkankln "не найдена! " skip(1) view-as alert-box buttons ok title " ОШИБКА ! ".
    return.
end.

find first lon where lon.lon = pkanketa.lon no-lock no-error.
if not avail lon then do:
    message skip " Ссудный счет " + pkanketa.lon + " не найден! " skip(1) view-as alert-box buttons ok title " ОШИБКА ! ".
    return.
end.

function date2str returns char (input dt as date).
    def var mm as char no-undo extent 12 init ['января','февраля','марта','апреля','мая','июня','июля','августа','сентября','октября','ноября','декабря'].
    return string(day(dt),"99") + ' ' + mm[month(dt)] + ' ' + string(year(dt),"9999").
end function.

function date2str_kz returns char (input nm as integer, input dt as date).
    def var mm as char no-undo extent 12 init ['ќаѕтар','аќпан','наурыз','кґкек','мамыр','маусым','шілде','тамыз','ќыркїйек','ќазан','ќараша','желтоќсан'].
    if nm = 1 then return string(year(dt),"9999") + " жылєы " + string(day(dt),"99") + ' ' + mm[month(dt)].
    else return string(day(dt),"99") + ' ' + mm[month(dt)] + ' ' + string(year(dt),"9999").
end function.

/* функция get-date возвращает дату ровно через указанное число месяцев от исходной */
function get-date returns date (input v-date as date, input v-num as integer).
    def var v-datres as date no-undo.
    def var mm as integer.
    def var yy as integer.
    def var dd as integer.
    if v-num < 0 then v-datres = ?.
    else
    if v-num = 0 then v-datres = v-date.
    else do:
      mm = (month(v-date) + v-num) mod 12.
      if mm = 0 then mm = 12.
      yy = year(v-date) + integer(((month(v-date) + v-num) - mm) / 12).
      run mondays(mm,yy,output dd).
      if day(v-date) < dd then dd = day(v-date).
      v-datres = date(mm,dd,yy).
    end.
    return (v-datres).
end function.

def var crcn1 as char extent 3 init ['теѕге','доллар А&#1178;Ш','евро'].

def var v-num as integer no-undo.

def var v-toplogo as char no-undo.
def new shared var v-stamp as char no-undo.
v-toplogo = "top_logo_bw.jpg".
v-stamp = get-pksysc-char ("dcstmp").

def var v-datastr as char no-undo.
def var v-datastrkz as char no-undo.
run pkdefdtstr(g-today, output v-datastr, output v-datastrkz).

def var v-datadoc as char no-undo.
def var v-duedt as char no-undo.
v-datadoc = string(lon.rdt, "99/99/9999").
v-duedt = string(lon.duedt, "99/99/9999").

def var v-summa as char no-undo.
def var v-summawrd as char no-undo.
def var v-summawrdkz as char no-undo.
def var v-prem as char no-undo.
def var v-premwrd as char no-undo.
def var v-com as char no-undo.
def var v-comwrd as char no-undo.
def var v-comwrdkz as char no-undo.

def var tempc as char no-undo.
def var strTemp as char no-undo.
def var str1 as char no-undo.
def var str2 as char no-undo.

v-summa = replace(string(pkanketa.summa, ">>>,>>>,>>9.99"), ",", " ").

tempc = string (pkanketa.summa).
if num-entries(tempc,".") = 2 then do:  /*если равно, то в сумме есть тиыны*/
    tempc = substring(tempc, length(tempc) - 1, 2).
    if num-entries(tempc,".") = 2 then tempc = substring(tempc,2,1) + "0".
end.
else tempc = "00".
strTemp = string(truncate(pkanketa.summa,0)).

run Sm-vrd(input pkanketa.summa, output v-summawrd).
run sm-wrdcrc(input strTemp,input tempc,input pkanketa.crc,output str1,output str2).
v-summawrd = v-summawrd + " " + str1 + " " + tempc + " " + str2.
run Sm-vrd-KZ(pkanketa.summa,pkanketa.crc,output v-summawrdkz).

v-prem = trim(string(pkanketa.rateq, ">>>9")).
run Sm-vrd(pkanketa.rateq, output v-premwrd).

find first pksysc where pksysc.credtype = s-credtype and pksysc.sysc = "tarfnd" no-lock no-error.
if avail pksysc then v-com = string(pksysc.deval).
run Sm-vrd(v-com, output v-comwrd).
run Sm-vrd-KZ(v-com, 0, output v-comwrdkz).

def var v-dol as char no-undo.
def var v-dolkz as char no-undo.

def new shared var v-bankname as char.
def new shared var v-banknamekz as char.
def new shared var v-bankface as char.
def new shared var v-bankfacekz as char.
def new shared var v-bankadres as char.
def new shared var v-bankadreskz as char.
def new shared var v-bankiik as char.
def new shared var v-bankbik as char.
def new shared var v-bankups as char.
def new shared var v-bankrnn as char.
def new shared var v-bankpodp as char.
def new shared var v-bankpodpkz as char.
def new shared var v-bankcontact as char.

def var v-banksuff as char no-undo.
def var v-bankosn as char no-undo.
def var v-bankosnkz as char no-undo.

def var v-dognom as char no-undo.
def var v-city as char no-undo.
def var v-citykz as char no-undo.

def new shared var v-name as char.
def new shared var v-rnn as char.
def new shared var v-docnum as char.
def new shared var v-docdt as char.
def var v-docorg as char no-undo.
def var v-docorgkz as char no-undo.
def new shared var v-adres as char extent 2.
def var v-adresd as char no-undo extent 2.
def new shared var v-telefon as char.
def new shared var v-nameshort as char.

def new shared var v-names as char.
def new shared var v-rnns as char.
def new shared var v-docnums as char.
def new shared var v-docdts as char.
def var v-docorgs as char no-undo.
def var v-docorgskz as char no-undo.
def new shared var v-adress as char extent 2.
def var v-adresds as char no-undo extent 2.
def new shared var v-telefons as char.
def new shared var v-nameshorts as char.

def var v-where as char no-undo. /* организация рефинансирования */
v-where = "".
find first pkanketh where (pkanketh.bank eq s-ourbank) and (pkanketh.credtype eq s-credtype) and
    (pkanketh.ln eq s-pkankln) and (pkanketh.kritcod eq "orgref") no-lock no-error.
if avail pkanketh then do:
    find first bookcod where bookcod.bookcod = "pkankref" and bookcod.code = pkanketh.value1 no-lock no-error.
    if avail bookcod then v-where = bookcod.name.
end.
if v-where = "" then v-where = "_________________________".

def var v-sum as deci no-undo extent 4.
def var dogfile as char no-undo.
dogfile = "rep.htm".

def var dat_wrk as date no-undo.
find last cls where cls.del no-lock no-error.
if avail cls then dat_wrk = cls.whn. else dat_wrk = g-today.

{sysc.i}
find bookcod where bookcod.bookcod = "credtype" and bookcod.code = s-credtype no-lock no-error.
v-bankface = entry(1, get-sysc-cha(bookcod.info[1] + "face")).
v-bankfacekz = entry(1, get-sysc-cha(bookcod.info[1] + "facekz")).
v-dol = entry(2, get-sysc-cha(bookcod.info[1] + "face")).
v-dolkz = entry(2, get-sysc-cha(bookcod.info[1] + "facekz")).
v-banksuff = get-sysc-cha(bookcod.info[1] + "suff").
v-bankosn = get-sysc-cha(bookcod.info[1] + "osn").
v-bankosnkz = get-sysc-cha(bookcod.info[1] + "osnkz").
v-bankpodp = get-sysc-cha(bookcod.info[1] + "podp").
v-bankpodpkz = get-sysc-cha(bookcod.info[1] + "podpkz").

v-bankiik = get-sysc-cha ("bnkiik2").
v-bankbik = get-sysc-cha ("clecod").

v-dognom = entry(1, pkanketa.rescha[1]).

find first cmp no-lock no-error.
if avail cmp then do:
    v-bankname = cmp.name.
    find first sysc where sysc.sysc = "bnkadr" no-lock no-error.
    if avail sysc and num-entries(sysc.chval,"|") > 13 then v-banknamekz = entry(14, sysc.chval,"|").
    v-city = entry(1, cmp.addr[1]).
    find first sysc where sysc.sysc = "bnkadr" no-lock no-error.
    if avail sysc and num-entries(sysc.chval,"|") > 12 then v-citykz = entry(12, sysc.chval,"|").
    v-bankadres = cmp.addr[1].
    find first sysc where sysc.sysc = "bnkadr" no-lock no-error.
    if avail sysc and num-entries(sysc.chval,"|") > 11 then v-bankadreskz = entry(11, sysc.chval,"|").
    v-bankrnn = cmp.addr[2].
    /*v-bankcontact = cmp.contact.*/
end.

v-name = pkanketa.name.
v-rnn = pkanketa.rnn.
v-docnum = pkanketa.docnum.
run pkdefsfio (pkanketa.ln, output v-nameshort).

find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "dtpas" no-lock no-error.
if avail pkanketh then do:
  if index(pkanketh.value1,"/") > 0 then v-docdt = pkanketh.value1.
  else v-docdt = string(pkanketh.value1, "99/99/9999").
end.

v-docorg = ''.
find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "pkdvyd" no-lock no-error.
if avail pkanketh then do:
    find first bookcod where bookcod.bookcod = "pkankvyd" and bookcod.code = pkanketh.value1 no-lock no-error.
    if avail bookcod then v-docorg = bookcod.name.
end.
if v-docorg <> '' then do:
    if trim(v-docorg) = "МВД РК" then v-docorgkz = "ЌР ІІМ".
    else
    if trim(v-docorg) = "МЮ РК" then v-docorgkz = "ЌР ЈМ".
end.

run pkdefadres (pkanketa.ln, no, output v-adres[1], output v-adres[2], output v-adresd[1], output v-adresd[2]).

find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and
     pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "tel" no-lock no-error.
if avail pkanketh then v-telefon = trim(pkanketh.value1).

/* созаемщик */
v-names = ''.
v-rnns = ''.
v-docnums = ''.
v-docorgs = ''.
def buffer b-pkanketa for pkanketa.
find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "subln" no-lock no-error.
if avail pkanketh and trim(pkanketh.value1) <> '' then do:
    find b-pkanketa where b-pkanketa.bank = s-ourbank and b-pkanketa.credtype = s-credtype and b-pkanketa.ln = integer(entry(1,pkanketh.value1)) no-lock no-error.
    if avail b-pkanketa then do:
        assign v-names = b-pkanketa.name
               v-rnns = b-pkanketa.rnn
               v-docnums = b-pkanketa.docnum.
        find pkanketh where pkanketh.bank = b-pkanketa.bank and pkanketh.credtype = b-pkanketa.credtype and pkanketh.ln = b-pkanketa.ln and pkanketh.kritcod = "dtpas" no-lock no-error.
        if avail pkanketh then do:
            if index(pkanketh.value1,".") > 0 then v-docdts = replace(pkanketh.value1,'.','/').
            else do:
                if index(pkanketh.value1,"/") > 0 then v-docdts = pkanketh.value1.
                else v-docdts = string(pkanketh.value1, "99/99/9999").
            end.
        end.

        v-docorgs = ''.
        find first pkanketh where pkanketh.bank = b-pkanketa.bank and pkanketh.credtype = b-pkanketa.credtype and pkanketh.ln = b-pkanketa.ln and pkanketh.kritcod = "pkdvyd" no-lock no-error.
        if avail pkanketh then do:
            find first bookcod where bookcod.bookcod = "pkankvyd" and bookcod.code = pkanketh.value1 no-lock no-error.
            if avail bookcod then v-docorgs = bookcod.name.
        end.

        if v-docorgs <> '' then do:
            if trim(v-docorgs) = "МВД РК" then v-docorgskz = "ЌР ІІМ".
            else
            if trim(v-docorgs) = "МЮ РК" then v-docorgskz = "ЌР ЈМ".
        end.

        run pkdefadres (b-pkanketa.ln, no, output v-adress[1], output v-adress[2], output v-adresds[1], output v-adresds[2]).

        find pkanketh where pkanketh.bank = b-pkanketa.bank and pkanketh.credtype = b-pkanketa.credtype and pkanketh.ln = b-pkanketa.ln and pkanketh.kritcod = "tel" no-lock no-error.
        if avail pkanketh then v-telefons = trim(pkanketh.value1).

        run pkdefsfio (b-pkanketa.ln, output v-nameshorts).
    end.
end.
/* созаемщик - конец */

/* расчет эффективной ставки */
def var v-effrate_d as deci no-undo.
def var v-pdat as date no-undo.
def var v-comved as deci no-undo.
def var v-effrate as char no-undo.

v-pdat = ?.
find first lnsch where lnsch.lnn = pkanketa.lon and lnsch.f0 > 0 no-lock no-error.
if avail lnsch then v-pdat = lnsch.stdat.
else v-pdat = get-date(pkanketa.docdt,1).

v-comved = 0.
find first tarifex2 where tarifex2.aaa = pkanketa.aaa and tarifex2.cif = pkanketa.cif and tarifex2.str5 = "195" and tarifex2.stat = 'r' no-lock no-error.
if avail tarifex2 then v-comved = tarifex2.ost.
else do:
    find pksysc where pksysc.credtype = s-credtype and pksysc.sysc = "bdacc" no-lock no-error.
    if avail pksysc then v-comved = pkanketa.summa * pksysc.deval / 100.
    else message "Ошибка определения суммы комиссии за обслуживание кредита" view-as alert-box error.
end.
run erl_bdf(pkanketa.summa,pkanketa.srok,pkanketa.rateq,pkanketa.docdt,v-pdat,pkanketa.sumcom,v-comved,0,output v-effrate_d).
v-effrate = string(v-effrate_d,">>9.<<").
if substr(v-effrate,length(v-effrate), 1) = '.' then v-effrate = substr(v-effrate, 1, length(v-effrate) - 1).











if v-names <> '' then v-ofile  = "dop_dognks.htm".
else v-ofile  = "dop_dognk.htm".
v-infile = "dog.htm".

output stream v-out to value(v-infile).

find pksysc where pksysc.credtype = '4' and pksysc.sysc = "dcdocs" no-lock no-error.
if avail pksysc then v-ofile = pksysc.chval + v-ofile.
run upd_field.

output stream v-out close.

run pkendtable2(v-infile, "БАНК", "ЗАЕМЩИК", "ЌАРЫЗ АЛУШЫ", true, "style=""font-size:12pt""", no, yes, yes).

output stream v-out to value(v-infile) append.

put stream v-out unformatted
    "<TABLE class=MsoNormalTable " skip
    "style=""WIDTH: 100%; BORDER-COLLAPSE: collapse; mso-padding-alt: 0cm 0cm 0cm 0cm"" cellSpacing=0 cellPadding=0 width=""100%"" border=0>" skip
      "<TBODY>" skip
      "<TR style='page-break-before:always'>" skip
        "<TD width=""49%"" style=""PADDING-RIGHT: 0cm; PADDING-LEFT: 0cm; PADDING-BOTTOM: 0cm; PADDING-TOP: 0cm"" vAlign=top>" skip
        "<P class=MsoNormal style=""TEXT-ALIGN: justify"">" skip
        "<SPAN style=""FONT-SIZE: 12pt"">2. Шарттыѕ ќалєан талаптары ґзгеріссіз ќалады.<o:p></o:p></SPAN></P></TD>" skip
        "<TD style=""PADDING-RIGHT: 0cm; PADDING-LEFT: 0cm; PADDING-BOTTOM: 0cm; WIDTH: 1%; PADDING-TOP: 0cm"" width=""1%""></TD>" skip
        "<TD style=""PADDING-RIGHT: 0cm; PADDING-LEFT: 0cm; PADDING-BOTTOM: 0cm; PADDING-TOP: 0cm"" vAlign=top>" skip
          "<P class=MsoNormal style=""TEXT-ALIGN: justify"">" skip
          "<SPAN style=""FONT-SIZE: 12pt"">2. Остальные условия Договора остаются без изменений.<o:p></o:p></SPAN></P></TD></TR>" skip
        "<TR>" skip
        "<TD width=""49%"" style=""PADDING-RIGHT: 0cm; PADDING-LEFT: 0cm; PADDING-BOTTOM: 0cm; PADDING-TOP: 0cm"" vAlign=top>" skip
          "<P class=MsoNormal style=""TEXT-ALIGN: justify"">" skip
          "<SPAN style=""FONT-SIZE: 12pt"">3. Тараптар осы Ќосымша келісімніѕ тілдері ретінде мемлекеттік жјне орыс тілдерін таѕдады." skip
          "Тараптар осы Ќосымша келісімніѕ тілдері оларєа толыєымен тїсінікті, бїкіл Ќосымша келісімніѕ, сол сияќты оныѕ жекелеген" skip
          "бґліктерініѕ маєынасы мен мјні оларєа толыєымен аныќ екендігі жайында мјлімдейді. Осы Ќосымша келісімніѕ тїрлі тілдердегі" skip
          "мјтіндерініѕ арасында сјйкессіздіктер (келіспеушіліктер) туындаєан кезде орыс тіліндегі мјтінге басымдыќ" skip
          "беріледі.<o:p></o:p></SPAN></P></TD>" skip
        "<TD style=""PADDING-RIGHT: 0cm; PADDING-LEFT: 0cm; PADDING-BOTTOM: 0cm; WIDTH: 1%; PADDING-TOP: 0cm"" width=""1%""></TD>" skip
        "<TD style=""PADDING-RIGHT: 0cm; PADDING-LEFT: 0cm; PADDING-BOTTOM: 0cm; PADDING-TOP: 0cm"" vAlign=top>" skip
          "<P class=MsoNormal style=""TEXT-ALIGN: justify"">" skip
          "<SPAN style=""FONT-SIZE: 12pt"">3. Языками настоящего Дополнительного соглашения Стороны выбрали государственный и русский" skip
          "языки. Стороны заявляют, что языки настоящего Дополнительного соглашения ими полностью поняты, смысл и значение как" skip
          "Дополнительного соглашения в целом, так и отдельных его частей полностью ясны. При возникновении разночтений" skip
          "(противоречий) текста настоящего Дополнительного соглашения на разных языках, приоритетным считается текст на" skip
          "русском языке.<o:p></o:p></SPAN></P></TD></TR>".

put stream v-out unformatted
      "<TR><TD width=""49%"" style=""PADDING-RIGHT: 0cm; PADDING-LEFT: 0cm; PADDING-BOTTOM: 0cm; PADDING-TOP: 0cm"" vAlign=top>" skip
          "<P class=MsoNormal style=""TEXT-ALIGN: justify"">" skip
          "<SPAN style=""FONT-SIZE: 12pt"">4. Осы Ќосымша келісім Шарттыѕ ажыратылмас бґлігі болып табылады жјне Тараптар оєан ќол ќойєан сјттен бастап ќолданылады.<o:p></o:p></SPAN></P></TD>" skip
        "<TD style=""PADDING-RIGHT: 0cm; PADDING-LEFT: 0cm; PADDING-BOTTOM: 0cm; WIDTH: 1%; PADDING-TOP: 0cm"" width=""1%""></TD>" skip
        "<TD style=""PADDING-RIGHT: 0cm; PADDING-LEFT: 0cm; PADDING-BOTTOM: 0cm; PADDING-TOP: 0cm"" vAlign=top>" skip
          "<P class=MsoNormal style=""TEXT-ALIGN: justify"">" skip
          "<SPAN style=""FONT-SIZE: 12pt"">4. Настоящее Дополнительное соглашение является неотъемлемой частью Договора и действует с момента его подписания Сторонами.<o:p></o:p></SPAN></P></TD></TR>" skip
      "<TR><TD width=""49%"" style=""PADDING-RIGHT: 0cm; PADDING-LEFT: 0cm; PADDING-BOTTOM: 0cm; PADDING-TOP: 0cm"" vAlign=top>" skip
          "<P class=MsoNormal style=""TEXT-ALIGN: justify""><SPAN style=""FONT-SIZE: 12pt"">5. Тараптардыѕ атаулары мен деректемелері:<o:p></o:p></SPAN></P></TD>" skip
        "<TD style=""PADDING-RIGHT: 0cm; PADDING-LEFT: 0cm; PADDING-BOTTOM: 0cm; WIDTH: 1%; PADDING-TOP: 0cm"" width=""1%""></TD>" skip
        "<TD style=""PADDING-RIGHT: 0cm; PADDING-LEFT: 0cm; PADDING-BOTTOM: 0cm; PADDING-13P: 0cm:"" vAlign=top>" skip
          "<P class=MsoNormal style=""TEXT-ALIGN: justify""><SPAN style=""FONT-SIZE: 12pt"">5. Наименования и реквизиты Сторон:<o:p></o:p></SPAN></P></TD></TR>" skip.

put stream v-out unformatted
        "<tr valign=""top"" align=""left"">" skip
            "<td>" skip
                "<table width=100% border=0 cellspacing=1 cellpadding=0 align=center valign=top style=""font-size:12pt"">" skip
                    "<tr valign=""top"">" skip
                        "<td width=50%>Банктіѕ атынан<br>" skip.
                  if s-ourbank = "TXB00" then
                                         put stream v-out unformatted
                                         "<IMG border=0 src=pkdogsgn.jpg v:shapes=_x0000_s1026><br>" .
                                         else
                                         put stream v-out unformatted
                                         "<IMG border=0 src=pkdogsgn.jpg width= 120 height= 40 v:shapes=_x0000_s1026><br>" .
                        put stream v-out unformatted
                          "(" + v-bankpodpkz + ")<br>" skip
                          "<center><IMG border=0 src=pkstamp.jpg width=160 height=160></center>" skip
                        "</td>" skip
                        "<td width=50%>Ќарыз алушы<br><br>" skip
                          "________________________<br>" skip
                          "________________________<br>" skip
                          "________________________<br>" skip
                          "________________________<br>" skip
                          "(Аты-жґнi толыєымен, Ќолы)" skip
                        "</td>" skip
                    "</tr>" skip.
                    if v-names <> '' then put stream v-out unformatted
                    "<tr valign=""top"">" skip
                        "<td width=50%>" skip

                        "</td>" skip
                        "<td width=50%>Ќосалќы ќарыз алушы<br><br>" skip
                          "________________________<br>" skip
                          "________________________<br>" skip
                          "________________________<br>" skip
                          "________________________<br>" skip
                          "(Аты-жґнi толыєымен, Ќолы)" skip
                        "</td>" skip
                    "</tr>" skip.

               put stream v-out unformatted "</table>" skip
            "</td>" skip
            "<td></td>" skip
            "<td>" skip
                "<table width=100% border=0 cellspacing=0 cellpadding=0 align=center valign=top style=""font-size:12pt"">" skip
                    "<tr valign=""top"">" skip
                        "<td width=50%>" skip
                          "От Банка<br>" skip.
                  if s-ourbank = "TXB00" then
                                         put stream v-out unformatted
                                         "<IMG border=0 src=pkdogsgn.jpg v:shapes=_x0000_s1026><br>" .
                                         else
                                         put stream v-out unformatted
                                         "<IMG border=0 src=pkdogsgn.jpg width= 120 height= 40 v:shapes=_x0000_s1026><br>" .
                        put stream v-out unformatted
                         "(" + v-bankpodp + ")<br>" skip
                          "<center><IMG border=0 src=pkstamp.jpg width=160 height=160></center>" skip
                        "</td>" skip
                        "<td width=50%>Заемщик<br><br>" skip
                          "________________________<br>" skip
                          "________________________<br>" skip
                          "________________________<br>" skip
                          "________________________<br>" skip
                          "(ФИО полностью, Подпись)" skip
                        "</td>" skip
                    "</tr>" skip.

                    if v-names <> '' then put stream v-out unformatted "<tr valign=""top"">" skip
                        "<td width=50%></td>" skip
                        "<td width=50%>Созаемщик<br><br>" skip
                          "________________________<br>" skip
                          "________________________<br>" skip
                          "________________________<br>" skip
                          "________________________<br>" skip
                          "(ФИО полностью, Подпись)" skip
                        "</td>" skip
                    "</tr>" skip.

                put stream v-out unformatted "</table>" skip
            "</td>" skip
        "</tr>" skip
"</tbody></table>" skip.

put stream v-out unformatted "</body></html>" skip.
output stream v-out close.

unix silent value("cptwin " + v-infile + " iexplore").


procedure upd_field.
    input from value(v-ofile).
    repeat:
        import unformatted v-str.
        v-str = trim(v-str).
        repeat:
            if v-str matches "*\{\&v-dol\}*" then do:
                v-str = replace (v-str, "\{\&v-dol\}", v-dol).
                next.
            end.

            if v-str matches "*\{\&v-dolKZ\}*" then do:
                v-str = replace (v-str, "\{\&v-dolKZ\}", v-dolkz).
            next.
            end.
            if v-str matches "*\{\&toplogo\}*" then do:
                v-str = replace (v-str, "\{\&toplogo\}", v-toplogo).
                next.
            end.
            if v-str matches "*\{\&v-docnum\}*" then do:
                v-str = replace (v-str, "\{\&v-docnum\}", v-docnum).
                next.
            end.
            if v-str matches "*\{\&v-dognom\}*" then do:
                v-str = replace (v-str, "\{\&v-dognom\}", v-dognom).
                next.
            end.
            if v-str matches "*\{\&v-city\}*" then do:
                v-str = replace (v-str, "\{\&v-city\}", v-city).
                next.
            end.
            if v-str matches "*\{\&v-citykz\}*" then do:
                v-str = replace (v-str, "\{\&v-citykz\}", v-citykz).
                next.
            end.
            if v-str matches "*\{\&v-datastr\}*" then do:
                v-str = replace (v-str, "\{\&v-datastr\}", v-datastr).
                next.
            end.
            if v-str matches "*\{\&v-datastrkz\}*" then do:
                v-str = replace (v-str, "\{\&v-datastrkz\}", v-datastrkz).
                next.
            end.
            if v-str matches "*\{\&v-datadoc\}*" then do:
                v-str = replace (v-str, "\{\&v-datadoc\}", v-datadoc).
                next.
            end.
            if v-str matches "*\{\&v-bankname\}*" then do:
                v-str = replace (v-str, "\{\&v-bankname\}", "<b>&nbsp;" + v-bankname + "&nbsp;</b>").
                next.
            end.
            if v-str matches "*\{\&v-banknamekz\}*" then do:
                v-str = replace (v-str, "\{\&v-banknamekz\}", "<b>&nbsp;" + v-banknamekz + "&nbsp;</b>").
                next.
            end.
            if v-str matches "*\{\&v-bankface\}*" then do:
                v-str = replace (v-str, "\{\&v-bankface\}", "<b>&nbsp;" + v-bankface + "&nbsp;</b>").
                next.
            end.
            if v-str matches "*\{\&v-bankfaceKZ\}*" then do:
                v-str = replace (v-str, "\{\&v-bankfaceKZ\}", "<b>&nbsp;" + v-bankfacekz + "&nbsp;</b>").
                next.
            end.
            if v-str matches "*\{\&v-banksuff\}*" then do:
                v-str = replace (v-str, "\{\&v-banksuff\}", v-banksuff).
                next.
            end.
            if v-str matches "*\{\&v-bankosn\}*" then do:
                v-str = replace (v-str, "\{\&v-bankosn\}", "<b>&nbsp;" + v-bankosn + "&nbsp;</b>").
                next.
            end.
            if v-str matches "*\{\&v-bankosnKZ\}*" then do:
                v-str = replace (v-str, "\{\&v-bankosnKZ\}", "<b>&nbsp;" + v-bankosnkz + "&nbsp;</b>").
                next.
            end.
            if v-str matches "*\{\&v-name\}*" then do:
                v-str = replace (v-str, "\{\&v-name\}", "<b>&nbsp;" + v-name + "&nbsp;</b>").
                next.
            end.
            if v-str matches "*\{\&v-clnames\}*" then do:
                v-str = replace (v-str, "\{\&v-clnames\}", "<b>&nbsp;" + v-names + "&nbsp;</b>").
                next.
            end.
            if v-str matches "*\{\&v-summa\}*" then do:
                v-str = replace (v-str, "\{\&v-summa\}", v-summa).
                next.
            end.
            if v-str matches "*\{\&v-summawrd\}*" then do:
                v-str = replace (v-str, "\{\&v-summawrd\}", v-summawrd).
                next.
            end.
            if v-str matches "*\{\&v-summawrdKZ\}*" then do:
                v-str = replace (v-str, "\{\&v-summawrdKZ\}", v-summawrdkz).
                next.
            end.
            if v-str matches "*\{\&v-duedt\}*" then do:
                v-str = replace (v-str, "\{\&v-duedt\}", string(v-duedt)).
                next.
            end.
            if v-str matches "*\{\&v-prem\}*" then do:
                v-str = replace (v-str, "\{\&v-prem\}", v-prem).
                next.
            end.
            if v-str matches "*\{\&v-premwrd\}*" then do:
                v-str = replace (v-str, "\{\&v-premwrd\}", v-premwrd).
                next.
            end.
            if v-str matches "*\{\&v-com\}*" then do:
                v-str = replace (v-str, "\{\&v-com\}", v-com).
                next.
            end.
            if v-str matches "*\{\&v-comwrd\}*" then do:
                v-str = replace (v-str, "\{\&v-comwrd\}", v-comwrd).
                next.
            end.
            if v-str matches "*\{\&v-comwrd_kz\}*" then do:
                v-str = replace (v-str, "\{\&v-comwrd_kz\}", v-comwrdkz).
                next.
            end.
            if v-str matches "*\{\&v-effrate\}*" then do:
                v-str = replace (v-str, "\{\&v-effrate\}", v-effrate).
                next.
            end.
            if v-str matches "*\{\&v-where\}*" then do:
                v-str = replace (v-str, "\{\&v-where\}", v-where).
                next.
            end.
            leave.
        end.
        put stream v-out unformatted v-str skip.
    end.
    input close.
    output stream v-out close.
end.
