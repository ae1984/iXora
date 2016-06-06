/* lnrdop.p
 * MODULE
        Потреб. кредитование
 * DESCRIPTION
        Формирование доп. соглашения по реструктуризации
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
        14/09/2009 madiyar
 * BASES
        BANK COMM
 * CHANGES
        16/09/2009 madiyar - подправил договор
        25/11/09 marinav - для нестандартной подписи в ЦО масштаб не указываем
        01/12/2009 galina - добавила наименование валюты для остатка суммы в цифрах
        25/04/2012 evseev  - rebranding. Название банка из sysc.
*/

{global.i}
{pk.i}
{nbankBik.i}

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

def shared temp-table t-lnsch no-undo
  field stdat as date
  field stval as deci
  field pcom as deci
  field odleft as deci
  index idx is primary stdat.

def shared temp-table t-lnsci no-undo
  field idat as date
  field iv-sc as deci
  index idx is primary idat.

def temp-table grwrk no-undo
  field stdat as date
  field stval as deci
  field iv-sc as deci
  field pcom as deci
  field odleft as deci
  index idx is primary stdat.

def buffer b-grwrk for grwrk.

empty temp-table grwrk.
for each t-lnsch no-lock:
    create grwrk.
    assign grwrk.stdat = t-lnsch.stdat
           grwrk.stval = t-lnsch.stval
           grwrk.pcom = t-lnsch.pcom
           grwrk.odleft = t-lnsch.odleft.
end.
for each t-lnsci no-lock:
    find first grwrk where grwrk.stdat = t-lnsci.idat no-error.
    if not avail grwrk then do:
        create grwrk.
        grwrk.stdat = t-lnsci.idat.
        find first b-grwrk where b-grwrk.stdat <= grwrk.stdat and b-grwrk.odleft > 0 no-lock no-error.
        if avail b-grwrk then grwrk.odleft = b-grwrk.odleft.
    end.
    grwrk.iv-sc = t-lnsci.iv-sc.
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

def var crcn1 as char extent 3 init ['теѕге','доллар А&#1178;Ш','евро'].

def var v-num as integer no-undo.

def var v-bankface as char no-undo.
def var v-bankface_kz as char no-undo.
def var v-dol as char no-undo.
def var v-dol_kz as char no-undo.
def var v-banksuff as char no-undo.
def var v-bankosn as char no-undo.
def var v-bankosn_kz as char no-undo.
def var v-bankname as char no-undo.
def var v-bankname_kz as char no-undo.
def var v-bankadres as char no-undo.
def var v-bankadres_kz as char no-undo.
def var v-bankrnn as char no-undo.
def var v-bankpodp as char no-undo.
def var v-bankpodp_kz as char no-undo.
def var v-bankiik as char no-undo.
def var v-bankbik as char no-undo.

def var v-dognom as char no-undo.
def var v-dogdate as date no-undo.
def var v-city as char no-undo.
def var v-city_kz as char no-undo.

def var v-name as char no-undo.
def var v-rnn as char no-undo.
def var v-docnum as char no-undo.
def var v-docdt as char no-undo.
def var v-adres as char no-undo extent 2.
def var v-adresd as char no-undo extent 2.
def var v-telefon as char no-undo.

def var v-sum as deci no-undo extent 3.
def var dogfile as char no-undo.
dogfile = "rep.htm".

def var dat_wrk as date no-undo.
find last cls where cls.del no-lock no-error.
if avail cls then dat_wrk = cls.whn. else dat_wrk = g-today.

{sysc.i}
find bookcod where bookcod.bookcod = "credtype" and bookcod.code = s-credtype no-lock no-error.
v-bankface = entry(1, get-sysc-cha(bookcod.info[1] + "face")).
v-bankface_kz = entry(1, get-sysc-cha(bookcod.info[1] + "facekz")).
v-dol = entry(2, get-sysc-cha(bookcod.info[1] + "face")).
v-dol_kz = entry(2, get-sysc-cha(bookcod.info[1] + "facekz")).
v-banksuff = get-sysc-cha(bookcod.info[1] + "suff").
v-bankosn = get-sysc-cha(bookcod.info[1] + "osn").
v-bankosn_kz = get-sysc-cha(bookcod.info[1] + "osnkz").
v-bankpodp = get-sysc-cha(bookcod.info[1] + "podp").
v-bankpodp_kz = get-sysc-cha(bookcod.info[1] + "podpkz").

v-bankiik = get-sysc-cha ("bnkiik2").
v-bankbik = get-sysc-cha ("clecod").

v-dognom = entry(1, pkanketa.rescha[1]).
v-dogdate = pkanketa.docdt.

find first cmp no-lock no-error.
if avail cmp then do:
    v-bankname = cmp.name.
    find first sysc where sysc.sysc = "bnkadr" no-lock no-error.
    if avail sysc and num-entries(sysc.chval,"|") > 13 then v-bankname_kz = entry(14, sysc.chval,"|").
    v-city = entry(1, cmp.addr[1]).
    find first sysc where sysc.sysc = "bnkadr" no-lock no-error.
    if avail sysc and num-entries(sysc.chval,"|") > 12 then v-city_kz = entry(12, sysc.chval,"|").
    v-bankadres = cmp.addr[1].
    find first sysc where sysc.sysc = "bnkadr" no-lock no-error.
    if avail sysc and num-entries(sysc.chval,"|") > 11 then v-bankadres_kz = entry(11, sysc.chval,"|").
    v-bankrnn = cmp.addr[2].
    /*v-bankcontact = cmp.contact.*/
end.

v-name = pkanketa.name.
v-rnn = pkanketa.rnn.
v-docnum = pkanketa.docnum.

find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "dtpas" no-lock no-error.
if avail pkanketh then do:
  if index(pkanketh.value1,"/") > 0 then v-docdt = pkanketh.value1.
  else v-docdt = string(pkanketh.value1, "99/99/9999").
end.

run pkdefadres (pkanketa.ln, no, output v-adres[1], output v-adres[2], output v-adresd[1], output v-adresd[2]).

find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and
     pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "tel" no-lock no-error.
if avail pkanketh then v-telefon = trim(pkanketh.value1).

def shared var v-perrate1 as deci no-undo.
def shared var v-perrate2 as deci no-undo.
def shared var v-comrate1 as deci no-undo.
def shared var v-comrate2 as deci no-undo.

def var v-premold as char no-undo.
def var v-premnew as char no-undo.
def var v-comold as char no-undo.
def var v-comnew as char no-undo.
def var v-bal as deci no-undo.
def var v-od as char no-undo.
def var v-odwrd as char no-undo.
def var v-odwrd_kz as char no-undo.

/*
def var v-premoldwrd as char no-undo.
def var v-premoldwrd_kz as char no-undo.
def var v-premnewwrd as char no-undo.
def var v-premnewwrd_kz as char no-undo.
*/

def var tempc as char no-undo.
def var strTemp as char no-undo.
def var str1 as char no-undo.
def var str2 as char no-undo.

v-premold = trim(string(v-perrate1,">>9.<<")).
if substr(v-premold,length(v-premold), 1) = '.' then v-premold = substr(v-premold, 1, length(v-premold) - 1).
/*
run Sm-vrd(v-perrate1, output v-premoldwrd).
run Sm-vrd-KZ(v-perrate1,0,output v-premoldwrd_kz).
*/

v-premnew = trim(string(v-perrate2,">>9.<<")).
if substr(v-premnew,length(v-premnew), 1) = '.' then v-premnew = substr(v-premnew, 1, length(v-premnew) - 1).
/*
run Sm-vrd(v-perrate2, output v-premnewwrd).
run Sm-vrd-KZ(v-perrate2,0,output v-premnewwrd_kz).
*/

v-comold = trim(string(v-comrate1,">>9.<<")).
if substr(v-comold,length(v-comold), 1) = '.' then v-comold = substr(v-comold, 1, length(v-comold) - 1).
v-comnew = trim(string(v-comrate2,">>9.<<")).
if substr(v-comnew,length(v-comnew), 1) = '.' then v-comnew = substr(v-comnew, 1, length(v-comnew) - 1).

run lonbalcrc('lon',lon.lon,g-today,"1,7",yes,lon.crc,output v-bal).
v-od = trim(replace(string(v-bal,">,>>>,>>>,>>9.<<"),',',' ')).
if substr(v-od,length(v-od), 1) = '.' then v-od = substr(v-od, 1, length(v-od) - 1).

tempc = string (v-bal).
if num-entries(tempc,".") = 2 then do:  /*если равно, то в сумме есть тиыны*/
    tempc = substring(tempc, length(tempc) - 1, 2).
    if num-entries(tempc,".") = 2 then tempc = substring(tempc,2,1) + "0".
end.
else tempc = "00".
strTemp = string(truncate(pkanketa.summa,0)).

run Sm-vrd(input v-bal, output v-odwrd).
run sm-wrdcrc(input strTemp,input tempc,input pkanketa.crc,output str1,output str2).
v-odwrd = v-odwrd + " " + str1 + " " + tempc + " " + str2.
run Sm-vrd-KZ(v-bal,pkanketa.crc,output v-odwrd_kz).
/*
run Sm-vrd(v-bal, output v-odwrd).
run Sm-vrd-KZ(v-bal,0,output v-odwrd_kz).
*/

/* эффективная ставка */
def var v-effrate as deci no-undo.
def var v-premeff as char no-undo.
/*
def var v-premeffwrd as char no-undo.
def var v-premeffwrd_kz as char no-undo.
*/
def var v-dt0 as date no-undo.
{er.i}
empty temp-table b2cl.
empty temp-table cl2b.
for each grwrk no-lock:
    create cl2b.
    cl2b.dt = grwrk.stdat.
    cl2b.days = grwrk.stdat - pkanketa.docdt.
    cl2b.sum = grwrk.stval + grwrk.iv-sc + grwrk.pcom.
end.
v-effrate = get_er(lon.opnamt,pkanketa.sumcom,0.0,0.0).
v-premeff = trim(string(v-effrate,">>9.<<")).
if substr(v-premeff,length(v-premeff), 1) = '.' then v-premeff = substr(v-premeff, 1, length(v-premeff) - 1).
/*
run Sm-vrd(v-effrate, output v-premeffwrd).
run Sm-vrd-KZ(v-effrate,0,output v-premeffwrd_kz).
*/
/* эффективная ставка - конец */

def stream rep.
output stream rep to value(dogfile).

put stream rep unformatted
    "<html><head><title>Допсоглашение</title>" skip
    "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
    "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream rep unformatted
    "<table border=0 cellpadding=0 cellspacing=0 width=100% style=""FONT-SIZE: 12pt; FONT-FAMILY: 'Times New Roman CYR'"">" skip
    "<tr style=""font:bold"" align=""center"">" skip
    "<td colspan=2>ДОПОЛНИТЕЛЬНОЕ СОГЛАШЕНИЕ<br>к Договору N " + v-dognom + " о предоставлении потребительского кредита<br>от " +
    date2str(v-dogdate) + " года<br>&nbsp;</td>" skip
    "</tr>" skip
    "<tr><td>" + v-city + "</td><td align=""right"">" + date2str(g-today) + " г.</td></tr>" skip.

put stream rep unformatted
    "<tr><td colspan=2>" skip
    "<P style=""TEXT-ALIGN: justify"">&nbsp;<br>" + v-nbankru + ", далее по тексту именуемое «Банк», в лице " + v-dol + ' ' + v-bankface + "," skip
    "действующе" + v-banksuff + " на основании " + v-bankosn + ", с одной стороны, и г-н (г-жа) " + v-name ", далее" skip
    "по тексту именуемый/ая «Заемщик», с другой стороны, совместно именуемые «Стороны»," skip
    "заключили настоящее Дополнительное соглашение к Договору N " + v-dognom + " о предоставлении потребительского кредита от " +
    date2str(v-dogdate) + " г. (далее – Договор)" skip
    "о нижеследующем:</P>" skip
    "</td></tr>" skip.

v-num = 0.


if v-perrate1 <> v-perrate2 then do:
    v-num = v-num + 1.
    put stream rep unformatted
        "<tr><td colspan=2>" skip
        "<P style=""TEXT-ALIGN: justify"">&nbsp;<br>" + string(v-num) + '.' skip
        "Фиксированная процентная ставка вознаграждения в размере " + v-premold + "%" skip
        "годовых изменяется в сторону уменьшения и на момент подписания настоящего Дополнительного Соглашения устанавливается в размере" skip
        v-premnew + "% годовых; годовая эффективная ставка вознаграждения по Кредиту, рассчитываемая Банком" skip
        "в соответствии с порядком, установленным государственным уполномоченным органом, составляет " + v-premeff + "%.</P>" skip
        "</td></tr>" skip.
end.

if v-comrate1 <> v-comrate2 then do:
    v-num = v-num + 1.
    put stream rep unformatted
        "<tr><td colspan=2>" skip
        "<P style=""TEXT-ALIGN: justify"">&nbsp;<br>" + string(v-num) + '.' skip
        "Комиссия за ведение счета/обслуживание кредита, выплачиваемая в соответствии с графиком платежей в размере " + v-comold + "%" skip
        "от суммы кредита изменяется в сторону уменьшения и на момент подписания настоящего Дополнительного Соглашения устанавливается в размере" skip
        v-comnew + "% от суммы кредита.</P>" skip
        "</td></tr>" skip.
end.

if v-perrate1 = v-perrate2 then do:
    v-num = v-num + 1.
    put stream rep unformatted
        "<tr><td colspan=2>" skip
        "<P style=""TEXT-ALIGN: justify"">&nbsp;<br>" + string(v-num) + '.' skip
        "Годовая эффективная ставка вознаграждения по Кредиту, рассчитываемая Банком в соответствии с порядком, установленным государственным" skip
        "уполномоченным органом, составляет " + v-premeff + "%.</P>" skip
        "</td></tr>" skip.
end.

v-num = v-num + 1.
put stream rep unformatted
    "<tr><td colspan=2>" skip
    "<P style=""TEXT-ALIGN: justify"">&nbsp;<br>" + string(v-num) + '.' skip
    "Приложение N 1 к Договору изложить в следующей редакции:</P>" skip
    "</td></tr>" skip
    "<tr>" skip
    "<td colspan=""2"" style=""font:bold"" align=""right"">&nbsp;<br>Приложение N 1<br>к Договору N " + v-dognom + " о предоставлении<br>потребительского кредита от " +
    date2str(v-dogdate) + " года" skip
    "</td></tr>" skip.

put stream rep unformatted
    "<tr><td colspan=2>" skip
    "<P style=""TEXT-ALIGN: justify"">&nbsp;<br>Погашение остатка кредита в размере " + v-od + " " + str1 + " (" + v-odwrd + ') производится в следующем порядке:</P>' skip.

put stream rep unformatted
    "<table border=1 cellpadding=0 cellspacing=0 width=100% style=""FONT-SIZE: 12pt; FONT-FAMILY: 'Times New Roman CYR'"">" skip
    "<tr style=""font:bold"" align=""center"">" skip
    "<td>Дата</td>" skip
    "<td>Сумма Кредита к погашению</td>" skip
    "<td>Сумма вознаграждения к погашению</td>" skip
    "<td>Сумма комиссии к погашению</td>" skip
    "<td>Ежемесячный платеж</td>" skip
    "<td>Остаток суммы Кредита после уплаты ежемесячного платежа</td>" skip
    "</tr>" skip.

v-sum = 0.
for each grwrk where grwrk.stdat > dat_wrk no-lock:
    put stream rep unformatted
        "<tr>" skip
        "<td align=""center"">" string(grwrk.stdat,"99/99/99") "</td>" skip
        "<td align=""right"">" trim(string(grwrk.stval,">>>>>>>>9.99")) "</td>" skip
        "<td align=""right"">" trim(string(grwrk.iv-sc,">>>>>>>>9.99")) "</td>" skip
        "<td align=""right"">" trim(string(grwrk.pcom,">>>>>>>>9.99")) "</td>" skip
        "<td align=""right"">" trim(string(grwrk.stval + grwrk.iv-sc + grwrk.pcom,">>>>>>>>9.99")) "</td>" skip
        "<td align=""right"">" trim(string(grwrk.odleft,">>>>>>>>9.99")) "</td>" skip
        "</tr>" skip.
    v-sum[1] = v-sum[1] + grwrk.stval.
    v-sum[2] = v-sum[2] + grwrk.iv-sc.
    v-sum[3] = v-sum[3] + grwrk.pcom.
end.
put stream rep unformatted
    "<tr style=""font:bold"">" skip
    "<td align=""center"">Итого:</td>" skip
    "<td align=""right"">" trim(string(v-sum[1],">>>>>>>>9.99")) "</td>" skip
    "<td align=""right"">" trim(string(v-sum[2],">>>>>>>>9.99")) "</td>" skip
    "<td align=""right"">" trim(string(v-sum[3],">>>>>>>>9.99")) "</td>" skip
    "<td align=""right"">" trim(string(v-sum[1] + v-sum[2] + v-sum[3],">>>>>>>>9.99")) "</td>" skip
    "<td align=""right""></td>" skip
    "</tr>" skip.

put stream rep unformatted
    "</table>" skip
    "</td></tr>" skip.

v-num = v-num + 1.
put stream rep unformatted
    "<tr><td colspan=2>" skip
    "<P style=""TEXT-ALIGN: justify"">&nbsp;<br>" + string(v-num) + '.' skip
    "Остальные условия Договора остаются без изменений.</P>" skip
    "</td></tr>" skip.

v-num = v-num + 1.
put stream rep unformatted
    "<tr><td colspan=2>" skip
    "<P style=""TEXT-ALIGN: justify"">&nbsp;<br>" + string(v-num) + '.' skip
    "Настоящее Дополнительное соглашение является неотъемлемой частью Договора и действует с момента его подписания Сторонами.</P>" skip
    "</td></tr>" skip.

v-num = v-num + 1.
put stream rep unformatted
    "<tr><td colspan=2>" skip
    "<P style=""TEXT-ALIGN: justify"">&nbsp;<br>" + string(v-num) + '.' skip
    "Языками настоящего Дополнительного соглашения Стороны выбрали государственный и русский языки. Стороны заявляют, что языки настоящего Дополнительного соглашения ими полностью поняты, смысл и значение как Дополнительного соглашения в целом, так и отдельных его частей полностью ясны. При возникновении разночтений (противоречий) текста настоящего Дополнительного соглашения на разных языках, приоритетным считается текст на русском языке.</P>" skip
    "</td></tr>" skip.

v-num = v-num + 1.
put stream rep unformatted
    "<tr><td colspan=2>" skip
    "<P style=""TEXT-ALIGN: justify"">&nbsp;<br>" + string(v-num) + '.' skip
    "Наименования и реквизиты Сторон:</P>" skip
    "</td></tr>" skip.

put stream rep unformatted
    "<tr align=""center""><td>БАНК</td>" skip
    "<td>ЗАЕМЩИК<td></tr>" skip
    "<tr><td>" skip
    "&nbsp;<br>" + v-bankname + "<br>"
    v-bankadres + "<br>"
    "РНН " + v-bankrnn + "<br>" skip
    "Корреспондентский счет " + v-bankiik + " в Управлении учета монетарных операций (ООКСП) Национального Банка Республики Казахстан<br>" skip
    "БИК " + v-bankbik + "<br>"
    "Признак резидентства - 1<br>Код сектора экономики – 4" skip
    "</td><td>" skip
    "&nbsp;<br>" + v-name + "<br>"
    "РНН " + v-rnn + "<br>" skip
    "Удостоверение личности N " + v-docnum + " выдано МВД РК (МЮ РК) от " + v-docdt + " г.<br>" skip
    "Адрес постоянной регистрации: " + v-adres[1] + "<br>" skip
    "Адрес фактического проживания: " + v-adres[2] + "<br>" skip
    "Тел.:" + v-telefon skip
    "</td></tr>" skip.

put stream rep unformatted
    "<tr align=""center"">" skip
    "<td>" skip
      "<table border=0 cellpadding=0 cellspacing=0 width=100% style=""FONT-SIZE: 12pt; FONT-FAMILY: 'Times New Roman CYR'"">" skip.
      if s-ourbank = "TXB00" then
                             put stream rep unformatted
                             "<td><IMG border=""0"" src=""pkdogsgn.jpg"" v:shapes=""_x0000_s1026""><br>(" + v-bankpodp + ")</td>" skip.
                             else
                             put stream rep unformatted
                             "<td><IMG border=""0"" src=""pkdogsgn.jpg"" width=""120"" height=""40"" v:shapes=""_x0000_s1026""><br>(" + v-bankpodp + ")</td>" skip.

      put stream rep unformatted
      "<td align=""center""><IMG border=""0"" src=""pkstamp.jpg"" width=""160"" height=""160""></td>" skip
      "</tr></table>" skip
    "</td><td align=""center"">" skip
    "_______________________<br>" skip
    "(Подпись)<br>" skip
    "_______________________________________<br>" skip
    "(Ф.И.О. полностью)" skip
    "</td></tr>" skip.

put stream rep unformatted


    "<td></tr>" skip.

/*####################################################################################*/

put stream rep unformatted
    "<tr style=""font:bold;page-break-before:always"" align=""center"">" skip
    "<td colspan=2>" + date2str_kz(1,v-dogdate) + "<br>N " + v-dognom + " Тўтыну кредитін беру туралы шартќа<br>ЌОСЫМША КЕЛІСІМ<br>&nbsp;</td>" skip
    "</tr>" skip
    "<tr><td>" + v-city_kz + "</td><td align=""right"">" + date2str_kz(2,g-today) + " ж.</td></tr>" skip.

put stream rep unformatted
    "<tr><td colspan=2>" skip
    "<P style=""TEXT-ALIGN: justify"">&nbsp;<br>" + v-nbankkz + ", бўдан јрі мјтін бойынша «Банк» деп аталады," skip
    v-bankosn_kz + " негізінде јрекет ететін " + v-dol_kz + ' ' + v-bankface_kz skip
    "арќылы, бір жаєынан жјне " + v-name + ", бўдан јрі мјтін бойынша «Ќарыз алушы» деп аталады, екінші жаєынан, бірлесіп «Тараптар» деп аталып," skip
    "мына тґмендегілер туралы "  + date2str_kz(1,v-dogdate) + " N " + v-dognom + " Тўтыну кредитін беру туралы шартќа (бўдан јрі – Шарт) осы Ќосымша келісімді жасады:</P>" skip
    "</td></tr>" skip.

v-num = 0.

if v-perrate1 <> v-perrate2 then do:
    v-num = v-num + 1.
    put stream rep unformatted
        "<tr><td colspan=2>" skip
        "<P style=""TEXT-ALIGN: justify"">&nbsp;<br>" + string(v-num) + '.' skip
        "Жылдыќ " + v-premold + "%" skip
        "мґлшеріндегі тіркелген пайыздыќ мґлшерлеме азаю жаєына ќарай ґзгереді жјне осы Ќосымша келісімге ќол ќою сјтіне жылдыќ" skip
        v-premnew + "% мґлшерінде белгіленеді; Банк мемлекеттік ујкілетті орган белгілеген тјртіпке" skip
        "сјйкес есептейтін Кредит бойынша сыйаќыныѕ жылдыќ тиімді мґлшерлемесін " + v-premeff + "% ќўрайды.</P>" skip
        "</td></tr>" skip.
end.

if v-comrate1 <> v-comrate2 then do:
    v-num = v-num + 1.
    put stream rep unformatted
        "<tr><td colspan=2>" skip
        "<P style=""TEXT-ALIGN: justify"">&nbsp;<br>" + string(v-num) + '.' skip
        "Тґлем кестесіне сјйкес кредит сомасыныѕ " + v-comold + "%" skip
        "мґлшерінде тґленетін кредит шотын жїргізу/ќызмет кґрсету їшін комиссия азаю жаєына ќарай ґзгереді жјне осы Ќосымша келісімге ќол ќою сјтіне кредит сомасыныѕ" skip
        v-comnew + "% мґлшерінде белгіленеді.</P>" skip
        "</td></tr>" skip.
end.

if v-perrate1 = v-perrate2 then do:
    v-num = v-num + 1.
    put stream rep unformatted
        "<tr><td colspan=2>" skip
        "<P style=""TEXT-ALIGN: justify"">&nbsp;<br>" + string(v-num) + '.' skip
        "Банк мемлекеттік ујкілетті орган белгілеген тјртіпке сјйкес есептейтін Кредит бойынша сыйаќыныѕ жылдыќ тиімді мґлшерлемесін" skip
        v-premeff + "% ќўрайды.</P>" skip
        "</td></tr>" skip.
end.

v-num = v-num + 1.
put stream rep unformatted
    "<tr><td colspan=2>" skip
    "<P style=""TEXT-ALIGN: justify"">&nbsp;<br>" + string(v-num) + '.' skip
    "Шарттыѕ N 1 ќосымшасы мынадай редакцияда жазылсын:</P>" skip
    "</td></tr>" skip
    "<tr>" skip
    "<td colspan=""2"" style=""font:bold"" align=""right"">&nbsp;<br>" + date2str_kz(1,v-dogdate) + "<br>N " + v-dognom + " Тўтыну кредитін беру туралы шартќа<br>" +
    "N 1 ќосымша" skip
    "</td></tr>" skip.

put stream rep unformatted
    "<tr><td colspan=2>" skip
    "<P style=""TEXT-ALIGN: justify"">&nbsp;<br>" + v-od  + " " +  crcn1[pkanketa.crc] + " (" + v-odwrd_kz + ') мґлшеріндегі кредит ќалдыєын ґтеу мынадай тјртіппен жасалады:</P>' skip.

put stream rep unformatted
    "<table border=1 cellpadding=0 cellspacing=0 width=100% style=""FONT-SIZE: 12pt; FONT-FAMILY: 'Times New Roman CYR'"">" skip
    "<tr style=""font:bold"" align=""center"">" skip
    "<td>Кїні</td>" skip
    "<td>Тґлеуге жататын Кредит сомасы</td>" skip
    "<td>Тґлеуге жататын сыйаќы сомасы</td>" skip
    "<td>Тґлеуге жататын комиссия сомасы</td>" skip
    "<td>Ай сайынєы тґлем</td>" skip
    "<td>Ай сайынєы тґлем тґленгеннен кейінгі Кредит сомасыныѕ ќалдыєы</td>" skip
    "</tr>" skip.

v-sum = 0.
for each grwrk where grwrk.stdat > dat_wrk no-lock:
    put stream rep unformatted
        "<tr>" skip
        "<td align=""center"">" string(grwrk.stdat,"99/99/99") "</td>" skip
        "<td align=""right"">" trim(string(grwrk.stval,">>>>>>>>9.99")) "</td>" skip
        "<td align=""right"">" trim(string(grwrk.iv-sc,">>>>>>>>9.99")) "</td>" skip
        "<td align=""right"">" trim(string(grwrk.pcom,">>>>>>>>9.99")) "</td>" skip
        "<td align=""right"">" trim(string(grwrk.stval + grwrk.iv-sc + grwrk.pcom,">>>>>>>>9.99")) "</td>" skip
        "<td align=""right"">" trim(string(grwrk.odleft,">>>>>>>>9.99")) "</td>" skip
        "</tr>" skip.
    v-sum[1] = v-sum[1] + grwrk.stval.
    v-sum[2] = v-sum[2] + grwrk.iv-sc.
    v-sum[3] = v-sum[3] + grwrk.pcom.
end.
put stream rep unformatted
    "<tr style=""font:bold"">" skip
    "<td align=""center"">Жиынтыєы:</td>" skip
    "<td align=""right"">" trim(string(v-sum[1],">>>>>>>>9.99")) "</td>" skip
    "<td align=""right"">" trim(string(v-sum[2],">>>>>>>>9.99")) "</td>" skip
    "<td align=""right"">" trim(string(v-sum[3],">>>>>>>>9.99")) "</td>" skip
    "<td align=""right"">" trim(string(v-sum[1] + v-sum[2] + v-sum[3],">>>>>>>>9.99")) "</td>" skip
    "<td align=""right""></td>" skip
    "</tr>" skip.

put stream rep unformatted
    "</table>" skip
    "</td></tr>" skip.

v-num = v-num + 1.
put stream rep unformatted
    "<tr><td colspan=2>" skip
    "<P style=""TEXT-ALIGN: justify"">&nbsp;<br>" + string(v-num) + '.' skip
    "Шарттыѕ ќалєан талаптары ґзгеріссіз ќалады.</P>" skip
    "</td></tr>" skip.

v-num = v-num + 1.
put stream rep unformatted
    "<tr><td colspan=2>" skip
    "<P style=""TEXT-ALIGN: justify"">&nbsp;<br>" + string(v-num) + '.' skip
    "Осы Ќосымша келісім Шарттыѕ ажыратылмас бґлігі болып табылады жјне Тараптар оєан ќол ќойєан сјттен бастап ќолданылады.</P>" skip
    "</td></tr>" skip.

v-num = v-num + 1.
put stream rep unformatted
    "<tr><td colspan=2>" skip
    "<P style=""TEXT-ALIGN: justify"">&nbsp;<br>" + string(v-num) + '.' skip
    "Тараптар осы Ќосымша келісімніѕ тілдері ретінде  мемлекеттік жјне орыс тілдерін таѕдады. Тараптар осы Ќосымша келісімніѕ тілдерін олар толыєымен тїсінгендігін, жалпы Ќосымша келісімніѕ, сол сияќты оныѕ жекелеген бґліктерініѕ мјні мен маєынасы аныќ екендігін мјлімдейді. Осы Ќосымша келісімніѕ тїрлі тілдердегі мјтіндерініѕ арасында сјйкессіздіктер (ќайшылыќтар) туындаєан кезде орыс тіліндегі мјтінге басымдыќ беріледі.</P>" skip
    "</td></tr>" skip.

v-num = v-num + 1.
put stream rep unformatted
    "<tr><td colspan=2>" skip
    "<P style=""TEXT-ALIGN: justify"">&nbsp;<br>" + string(v-num) + '.' skip
    "Тараптардыѕ атаулары мен деректемелері:</P><br>&nbsp;" skip
    "</td></tr>" skip.

put stream rep unformatted
    "<tr align=""center""><td>БАНК</td>" skip
    "<td>ЌАРЫЗ АЛУШЫ<td></tr>" skip
    "<tr><td>" skip
    "&nbsp;<br>" + v-bankname_kz + "<br>"
    v-bankadres_kz + "<br>"
    "СТН " + v-bankrnn + "<br>" skip
    "Ќазаќстан Республикасы Ўлттыќ Банкініѕ Монетарлыќ операцияларды есепке алу басќармасындаєы (ООКСП) корреспонденттік шот " + v-bankiik + "<br>" skip
    "БЖК " + v-bankbik + "<br>"
    "Резиденттік белгісі  - 1<br>Экономика секторыныѕ коды – 4" skip
    "</td><td>" skip
    "&nbsp;<br>" + v-name + "<br>"
    "СТН " + v-rnn + "<br>" skip
    "Жеке кујлiгi N " + v-docnum + ", " + v-docdt + " ж. ЌР IIМ (ЌР ЈМ) берiлген<br>" skip
    "Тўрєылыќты тiркелген мекен-жайы: " + v-adres[1] + "<br>" skip
    "Тўрєылыќты мекен-жайы: " + v-adres[2] + "<br>" skip
    "Тел.:" + v-telefon skip
    "</td></tr>" skip.

put stream rep unformatted
    "<tr align=""center"">" skip
    "<td>" skip
      "<table border=0 cellpadding=0 cellspacing=0 width=100% style=""FONT-SIZE: 12pt; FONT-FAMILY: 'Times New Roman CYR'"">" skip.
      if s-ourbank = "TXB00" then
                             put stream rep unformatted
                             "<td><IMG border=""0"" src=""pkdogsgn.jpg"" v:shapes=""_x0000_s1026""><br>(" + v-bankpodp + ")</td>" skip.
                             else
                             put stream rep unformatted
                             "<td><IMG border=""0"" src=""pkdogsgn.jpg"" width=""120"" height=""40"" v:shapes=""_x0000_s1026""><br>(" + v-bankpodp + ")</td>" skip.
      put stream rep unformatted
      "<td align=""center""><IMG border=""0"" src=""pkstamp.jpg"" width=""160"" height=""160""></td>" skip
      "</tr></table>" skip
    "</td><td align=""center"">" skip
    "_______________________<br>" skip
    "(Ќолы)<br>" skip
    "_______________________________________<br>" skip
    "(Аты жґнi толыќ)" skip
    "</td></tr>" skip.

put stream rep unformatted
    "</body></html>" skip.

output stream rep close.
unix silent cptwin rep.htm iexplore.



