/* lnprodop3.p
 * MODULE
        Потреб. кредитование
 * DESCRIPTION
        Формирование доп. соглашения по реструктуризации/пролонгации - отсрочка без пролонгации
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
        03/04/2010 madiyar
 * BASES
        BANK COMM
 * CHANGES
        06/04/2010 madiyar - добавлен вариант на казахском
        14/04/2010 madiyar - добавил регистрационный номер
        13/04/2011 lyubov - добавила текст в Приложение к договору
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
  field prcpure as deci
  field prcadd as deci
  field prcleft as deci
  index idx is primary idat.

def temp-table grwrk no-undo
  field stdat as date
  field stval as deci
  field prcpure as deci
  field prcadd as deci
  field pcom as deci
  field odleft as deci
  field prcleft as deci
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
    grwrk.prcpure = t-lnsci.prcpure.
    grwrk.prcadd = t-lnsci.prcadd.
    grwrk.prcleft = t-lnsci.prcleft.
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
def var v-docorg as char no-undo.
def var v-docorg_kz as char no-undo.
def var v-adres as char no-undo extent 2.
def var v-adresd as char no-undo extent 2.
def var v-telefon as char no-undo.

def var v-names as char no-undo.
def var v-rnns as char no-undo.
def var v-docnums as char no-undo.
def var v-docdts as char no-undo.
def var v-docorgs as char no-undo.
def var v-docorgs_kz as char no-undo.
def var v-adress as char no-undo extent 2.
def var v-adresds as char no-undo extent 2.
def var v-telefons as char no-undo.

def var v-sum as deci no-undo extent 4.
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

v-docorg = ''.
find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "pkdvyd" no-lock no-error.
if avail pkanketh then do:
    find first bookcod where bookcod.bookcod = "pkankvyd" and bookcod.code = pkanketh.value1 no-lock no-error.
    if avail bookcod then v-docorg = bookcod.name.
end.
if v-docorg <> '' then do:
    if trim(v-docorg) = "МВД РК" then v-docorg_kz = "ЌР ІІМ".
    else
    if trim(v-docorg) = "МЮ РК" then v-docorg_kz = "ЌР ЈМ".
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
            if trim(v-docorgs) = "МВД РК" then v-docorgs_kz = "ЌР ІІМ".
            else
            if trim(v-docorgs) = "МЮ РК" then v-docorgs_kz = "ЌР ЈМ".
        end.

        run pkdefadres (b-pkanketa.ln, no, output v-adress[1], output v-adress[2], output v-adresds[1], output v-adresds[2]).

        find pkanketh where pkanketh.bank = b-pkanketa.bank and pkanketh.credtype = b-pkanketa.credtype and pkanketh.ln = b-pkanketa.ln and pkanketh.kritcod = "tel" no-lock no-error.
        if avail pkanketh then v-telefons = trim(pkanketh.value1).

        /*run pkdefsfio (b-pkanketa.ln, output v-nameshorts).*/
    end.
end.
/* созаемщик - конец */

def shared var v-deltype as integer no-undo.
/*
v-deltype (тип отсрочки)
0 - без отсрочки
1 - отсрочка только ОД
2 - отсрочка ОД и %%
*/
def shared var v-dtend as date no-undo.
def shared var v-dtpog as date no-undo.
def shared var v-dtpog2 as date no-undo.
def shared var v-balprc_raspr as deci no-undo.


def var v-bal as deci no-undo.

def var v-od as char no-undo.
def var v-odwrd as char no-undo.
def var v-odwrd_kz as char no-undo.
def var v-odcrc as char no-undo.

def var v-prc_otsr as char no-undo.
def var v-prc_otsr_wrd as char no-undo.
def var v-prc_otsr_wrd_kz as char no-undo.
def var v-prc_otsr_crc as char no-undo.

def var tempc as char no-undo.
def var strTemp as char no-undo.
def var str1 as char no-undo.
def var str2 as char no-undo.

run lonbalcrc('lon',lon.lon,g-today,"1,7",yes,lon.crc,output v-bal).

v-od = trim(replace(string(v-bal,">,>>>,>>>,>>9.<<"),',',' ')).
if substr(v-od,length(v-od), 1) = '.' then v-od = substr(v-od, 1, length(v-od) - 1).

tempc = string (v-bal).
if num-entries(tempc,".") = 2 then do:  /*если равно, то в сумме есть тиыны*/
    tempc = substring(tempc, length(tempc) - 1, 2).
    if num-entries(tempc,".") = 2 then tempc = substring(tempc,2,1) + "0".
end.
else tempc = "00".
strTemp = string(truncate(v-bal,0)).

run Sm-vrd(input v-bal, output v-odwrd).
run sm-wrdcrc(input strTemp,input tempc,input pkanketa.crc,output str1,output str2).
v-odwrd = v-odwrd + " " + str1 + " " + tempc + " " + str2.
v-odcrc = str1.
run Sm-vrd-KZ(v-bal,pkanketa.crc,output v-odwrd_kz).



v-prc_otsr = trim(replace(string(v-balprc_raspr,">,>>>,>>>,>>9.<<"),',',' ')).
if substr(v-prc_otsr,length(v-prc_otsr), 1) = '.' then v-prc_otsr = substr(v-prc_otsr, 1, length(v-prc_otsr) - 1).

tempc = string (v-balprc_raspr).
if num-entries(tempc,".") = 2 then do:  /*если равно, то в сумме есть тиыны*/
    tempc = substring(tempc, length(tempc) - 1, 2).
    if num-entries(tempc,".") = 2 then tempc = substring(tempc,2,1) + "0".
end.
else tempc = "00".
strTemp = string(truncate(v-balprc_raspr,0)).

run Sm-vrd(input v-balprc_raspr, output v-prc_otsr_wrd).
run sm-wrdcrc(input strTemp,input tempc,input pkanketa.crc,output str1,output str2).
v-prc_otsr_wrd = v-prc_otsr_wrd + " " + str1 + " " + tempc + " " + str2.
v-prc_otsr_crc = str1.
run Sm-vrd-KZ(v-balprc_raspr,pkanketa.crc,output v-prc_otsr_wrd_kz).



def stream rep.
output stream rep to value(dogfile).

put stream rep unformatted
    "<html><head><title>Допсоглашение</title>" skip
    "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
    "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream rep unformatted
    "<table border=0 cellpadding=0 cellspacing=0 width=100% style=""FONT-SIZE: 12pt; FONT-FAMILY: 'Times New Roman CYR'"">" skip
    "<tr style=""FONT-SIZE: 9pt; FONT-FAMILY: 'Times New Roman CYR'""><td width=50%></td><td width=50% align=""right"">Регистрационный N 118</td></tr>" skip
    "<tr style=""font:bold"" align=""center"">" skip
    "<td colspan=2>ДОПОЛНИТЕЛЬНОЕ СОГЛАШЕНИЕ<br>к Договору N " + v-dognom + " о предоставлении потребительского кредита<br>от " +
    date2str(v-dogdate) + " года<br>&nbsp;</td>" skip
    "</tr>" skip
    "<tr><td width=50%>" + v-city + "</td><td width=50% align=""right"">" + date2str(g-today) + " г.</td></tr>" skip.

put stream rep unformatted
    "<tr><td colspan=2>" skip
    "<P style=""TEXT-ALIGN: justify"">&nbsp;<br>" + v-nbankru + ", именуемое в дальнейшем «Банк», в лице " + v-dol + ' ' + v-bankface + "," skip
    "действующе" + v-banksuff + " на основании " + v-bankosn + ", с одной стороны, и г-н (г-жа) " + v-name + ", именуемый(ая) в дальнейшем «Заемщик», с другой стороны," skip.

if v-names <> '' then do:
    put stream rep unformatted "и г-н (г-жа) " + v-names + ", именуемый (-ая) в дальнейшем «Созаемщик», с третьей стороны," skip.
end.

put stream rep unformatted
    "совместно именуемые «Стороны»," skip
    "заключили настоящее Дополнительное соглашение (далее – Дополнительное соглашение) к Договору N " + v-dognom skip
    "о предоставлении потребительского кредита от " + date2str(v-dogdate) + " г. (далее – Договор)" skip
    "о нижеследующем:</P>" skip
    "</td></tr>" skip.

v-num = 0.

v-num = v-num + 1.
put stream rep unformatted
    "<tr><td colspan=2>" skip
    "<P style=""TEXT-ALIGN: justify"">&nbsp;<br>" + string(v-num) + '.' skip
    "Заемщику предоставляется отсрочка платежей по основному долгу".

if v-dtpog <> v-dtpog2 then put stream rep unformatted " сроком до " + date2str(v-dtpog) + " г. включительно".

if v-deltype = 2 then do:
    put stream rep unformatted " и вознаграждению".
    if v-dtpog <> v-dtpog2 then put stream rep unformatted " сроком до " + date2str(v-dtpog2) + " г. включительно".
end.

if v-dtpog = v-dtpog2 then put stream rep unformatted " сроком до " + date2str(v-dtpog) + " г. включительно".

put stream rep unformatted
    ", при этом срок пользования Кредитом по Договору не продлевается.</P>" skip
    "</td></tr>" skip.

v-num = v-num + 1.
put stream rep unformatted
    "<tr><td colspan=2>" skip
    "<P style=""TEXT-ALIGN: justify"">&nbsp;<br>" + string(v-num) + '.' skip
    "Частичное досрочное погашение не допускается. Полное досрочное погашение допускается в любую дату," skip
    "выпадающую на рабочий день, при этом Заемщик обязуется оплатить остаток Отсроченного вознаграждения на дату досрочного погашения" skip
    "(остаток Отсроченного вознаграждения рассчитывается от начисленной на дату заключения настоящего Дополнительного соглашения," skip
    "но не погашенной суммы вознаграждения в размере " + v-prc_otsr + " " + v-prc_otsr_crc + " (" + v-prc_otsr_wrd + ")" skip
    "(далее – Отсроченное вознаграждение) за вычетом оплаченных сумм Отсроченного вознаграждения согласно действующему Графику платежей)," skip
    "а также Вознаграждение в размере, предусмотренном действующим Графиком платежей, за 3 (три) полных месяца, следующих за датой," skip
    "указанной в п.1 настоящего Дополнительного соглашения.</P>" skip
    "</td></tr>" skip.

put stream rep unformatted
    "<tr><td colspan=2>" skip
    "<P style=""TEXT-ALIGN: justify"">При возникновении указанной в настоящем пункте ситуации, нормы Договора, регулирующие" skip
    "порядок полного досрочного погашения кредита, действовавшие до подписания настоящего Дополнительного соглашения," skip
    "признаются утратившими силу.</P>" skip
    "</td></tr>" skip.


v-num = v-num + 1.
put stream rep unformatted
    "<tr><td colspan=2>" skip
    "<P style=""TEXT-ALIGN: justify"">&nbsp;<br>" + string(v-num) + '.' skip
    "Начисленная неустойка по состоянию на " + date2str(g-today) + " г. при подписании настоящего Дополнительного соглашения" skip
    "не списывается, но Банком Заемщику предоставляется отсрочка по ее выплате до полного исполнения обязательств Заемщиком по Договору." skip
    "В случае образования просроченной задолженности 90 и более дней после подписания настоящего Дополнительного соглашения," skip
    "Банк вправе требовать, а Заемщик обязуется погасить в первую очередь неустойку," skip
    "начисленную по состоянию на " + date2str(g-today) + " г., а далее - в очередности, предусмотренной нормами Договора," skip
    "не затронутыми настоящим Дополнительным соглашением. При полном погашении (в т.ч. досрочном) всей задолженности по кредиту," skip
    "сложившейся после подписания настоящего Дополнительного соглашения, начисленная по состоянию на " + date2str(g-today) + " г.," skip
    "но неуплаченная неустойка, списывается в полном объеме.</P>" skip
    "</td></tr>" skip.

v-num = v-num + 1.
put stream rep unformatted
    "<tr><td colspan=2>" skip
    "<P style=""TEXT-ALIGN: justify"">&nbsp;<br>" + string(v-num) + '.' skip
    "Приложение N 1 к Договору изложить в следующей редакции:</P>" skip
    "</td></tr>" skip
    "<tr>" skip
    "<td colspan=""2"" style=""font:bold"" align=""right"">&nbsp;<br>«Приложение N 1<br>к Договору N " + v-dognom + " о предоставлении<br>потребительского кредита от " +
    date2str(v-dogdate) + " года" skip
    "</td></tr>" skip.



put stream rep unformatted
    "<tr><td colspan=2>" skip
    "<P style=""TEXT-ALIGN: justify"">&nbsp;<br>"skip
    "Подписанием настоящего Приложения № 1 к Договору, Заемщик подтверждает, что  ознакомлен с предложенными Банком графиками погашения Кредита, рассчитанными различными методами, таким образом, при выборе Заемщиком метода погашения Стороны пришли к следующему: </P>" skip
    "</td></tr>" skip.

put stream rep unformatted
    "<tr><td colspan=2>" skip
    "<P style=""TEXT-ALIGN: justify"">&nbsp;<br>"skip
    "1.	Заемщик от методов погашения аннуитетными платежами, других методов по соглашению сторон отказывается. </P>" skip
    "</td></tr>" skip.

put stream rep unformatted
    "<tr><td colspan=2>" skip
    "<P style=""TEXT-ALIGN: justify"">&nbsp;<br>"skip
    "2.	Заемщиком выбран метод погашения равными долями, с начислением вознаграждения за пользование Кредитом на Сумму Кредита,  применяемый в нижеследующем Графике платежей: </P>" skip
    "</td></tr>" skip.

put stream rep unformatted
    "<tr><td colspan=2>" skip
    "<P style=""TEXT-ALIGN: justify"">&nbsp;<br>Погашение остатка кредита в размере " + v-od + " " + v-odcrc + " (" + v-odwrd + ') производится в следующем порядке:</P>' skip.

put stream rep unformatted
    /*"<table border=1 cellpadding=0 cellspacing=0 width=100% style=""FONT-SIZE: 12pt; FONT-FAMILY: 'Times New Roman CYR'"">" skip*/
    "<table border=1 cellpadding=0 cellspacing=0 width=100% style=""FONT-SIZE: 12pt; FONT-FAMILY: 'Times New Roman CYR'"">" skip
    /*"<tr style=""font:bold"" align=""center"" >" skip*/
    "<tr align=""center"" style=""FONT-SIZE: 12pt; FONT-FAMILY: 'Arial Narrow'"">" skip
    "<td>Дата</td>" skip
    "<td>Сумма<br>Основного<br>долга по<br>Кредиту к<br>погашению</td>" skip
    "<td>Сумма<br>вознаграж-<br>дения к<br>погашению,<br>начисленного<br>за текущий<br>месяц</td>" skip
    "<td>Сумма<br>отсроченного<br>вознаграж-<br>дения к<br>погашению</td>" skip
    "<td>Сумма<br>комиссии к<br>погашению</td>" skip
    "<td>Ежемесяч-<br>ный платеж</td>" skip
    "<td>Остаток<br>суммы<br>Основного<br>долга<br>после<br>уплаты<br>ежемесячного<br>платежа</td>" skip
    "<td>Остаток<br>суммы<br>отсроченного<br>вознаграж-<br>дения после<br>уплаты<br>ежемесячного<br>платежа</td>" skip
    "</tr>" skip.

v-sum = 0.
for each grwrk where grwrk.stdat > dat_wrk no-lock:
    put stream rep unformatted
        "<tr>" skip
        "<td align=""center"">" string(grwrk.stdat,"99/99/99") "</td>" skip
        "<td align=""right"">" trim(string(grwrk.stval,">>>>>>>>9.99")) "</td>" skip
        "<td align=""right"">" trim(string(grwrk.prcpure,">>>>>>>>9.99")) "</td>" skip
        "<td align=""right"">" trim(string(grwrk.prcadd,">>>>>>>>9.99")) "</td>" skip
        "<td align=""right"">" trim(string(grwrk.pcom,">>>>>>>>9.99")) "</td>" skip
        "<td align=""right"">" trim(string(grwrk.stval + grwrk.prcpure + grwrk.prcadd + grwrk.pcom,">>>>>>>>9.99")) "</td>" skip
        "<td align=""right"">" trim(string(grwrk.odleft,">>>>>>>>9.99")) "</td>" skip
        "<td align=""right"">" trim(string(grwrk.prcleft,">>>>>>>>9.99")) "</td>" skip
        "</tr>" skip.
    v-sum[1] = v-sum[1] + grwrk.stval.
    v-sum[2] = v-sum[2] + grwrk.prcpure.
    v-sum[3] = v-sum[3] + grwrk.prcadd.
    v-sum[4] = v-sum[4] + grwrk.pcom.
end.
put stream rep unformatted
    "<tr style=""font:bold"">" skip
    "<td align=""center"">Итого:</td>" skip
    "<td align=""right"">" trim(string(v-sum[1],">>>>>>>>9.99")) "</td>" skip
    "<td align=""right"">" trim(string(v-sum[2],">>>>>>>>9.99")) "</td>" skip
    "<td align=""right"">" trim(string(v-sum[3],">>>>>>>>9.99")) "</td>" skip
    "<td align=""right"">" trim(string(v-sum[4],">>>>>>>>9.99")) "</td>" skip
    "<td align=""right"">" trim(string(v-sum[1] + v-sum[2] + v-sum[3] + v-sum[4],">>>>>>>>9.99")) "</td>" skip
    "<td align=""right""></td>" skip
    "<td align=""right""></td>" skip
    "</tr>" skip.

put stream rep unformatted
    "</table>" skip
    "»." skip
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
    "Языками настоящего Дополнительного соглашения Стороны выбрали государственный и русский языки. Стороны заявляют, что языки" skip
    "настоящего Дополнительного соглашения ими полностью поняты, смысл и значение как Дополнительного соглашения в целом, так и" skip
    "отдельных его частей полностью ясны. При возникновении разночтений (противоречий) текста настоящего Дополнительного соглашения" skip
    "на разных языках, приоритетным считается текст на русском языке.</P>" skip
    "</td></tr>" skip.

v-num = v-num + 1.
put stream rep unformatted
    "<tr><td colspan=2>" skip
    "<P style=""TEXT-ALIGN: justify"">&nbsp;<br>" + string(v-num) + '.' skip
    "Юридические адреса и реквизиты Сторон:</P>" skip
    "</td></tr>" skip.


put stream rep unformatted
    "<tr><td colspan=2>БАНК: " + v-bankname + "<br>" skip
    v-bankadres + "<br>" skip
    "РНН " + v-bankrnn + "<br>" skip
    "Корреспондентский счет " + v-bankiik + " в Управлении учета монетарных операций (ООКСП) Национального Банка Республики Казахстан<br>" skip
    "БИК " + v-bankbik + "<br>"
    "&nbsp;<br>"
    "ЗАЕМЩИК: " + v-name + "<br>" skip
    "РНН " + v-rnn + "<br>" skip
    "Удостоверение личности N " + v-docnum + " выдано " + v-docorg + " от " + v-docdt + " г.<br>" skip
    "Адрес постоянной регистрации: " + v-adres[1] + "<br>" skip
    "Адрес фактического проживания: " + v-adres[2] + "<br>" skip
    "Тел.:" + v-telefon skip.

if v-names <> '' then do:
    put stream rep unformatted
        "&nbsp;<br>" skip
        "СОЗАЕМЩИК: " + v-names + "<br>" skip
        "РНН " + v-rnns + "<br>" skip
        "Удостоверение личности N " + v-docnums + " выдано " + v-docorgs + " от " + v-docdts + " г.<br>" skip
        "Адрес постоянной регистрации: " + v-adress[1] + "<br>" skip
        "Адрес фактического проживания: " + v-adress[2] + "<br>" skip
        "Тел.:" + v-telefons skip.
end.

put stream rep unformatted
    "</td></tr>" skip.

put stream rep unformatted
    "<tr><td align=""center"" colspan=2>ПОДПИСИ И ПЕЧАТИ</td><tr>" skip
    "<tr><td align=""left"">" skip
    "От Банка<br>" skip.

if s-ourbank = "TXB00" then
    put stream rep unformatted
    "<IMG border=""0"" src=""pkdogsgn.jpg"" v:shapes=""_x0000_s1026""><br>(" + v-bankpodp + ")" skip.
else
    put stream rep unformatted
    "<IMG border=""0"" src=""pkdogsgn.jpg"" width=""120"" height=""40"" v:shapes=""_x0000_s1026""><br>(" + v-bankpodp + ")" skip.

put stream rep unformatted
    "</td>" skip
    "<td align=""left""><IMG border=""0"" src=""pkstamp.jpg"" width=""160"" height=""160""></td>" skip
    "</td></tr>" skip.

put stream rep unformatted
    "<tr><td colspan=""2"">" skip
    "Заемщик<br>" skip
    "&nbsp;<br>" skip
    "____________________________________________________________________/_______________<br>" skip
    "<center><i>(ФИО полностью, Подпись)</i><center><br>" skip
    "</td></tr>" skip.

if v-names <> '' then do:
    put stream rep unformatted
        "<tr><td colspan=""2"">" skip
        "Созаемщик<br>" skip
        "&nbsp;<br>" skip
        "____________________________________________________________________/_______________<br>" skip
        "<center><i>(ФИО полностью, Подпись)</i><center><br>" skip
        "</td></tr>" skip.
end.


/*####################################################################################*/

put stream rep unformatted
    "<tr style=""page-break-before:always;FONT-SIZE: 9pt; FONT-FAMILY: 'Times New Roman CYR'""><td width=50%></td><td width=50% align=""right"">Тіркеу N 118</td></tr>" skip
    "<tr style=""font:bold"" align=""center"">" skip
    "<td colspan=2>" + date2str_kz(1,v-dogdate) + " N " + v-dognom + "<br>Тўтыну несиесін беру туралы шартќа<br>" skip
    "ЌОСЫМША КЕЛІСІМ<br>&nbsp;</td>" skip
    "</tr>" skip
    "<tr><td width=50%>" + v-city_kz + "</td><td width=50% align=""right"">" + date2str_kz(0,g-today) + " ж.</td></tr>" skip.

put stream rep unformatted
    "<tr><td colspan=2>" skip
    "<P style=""TEXT-ALIGN: justify"">&nbsp;<br>" + v-nbankkz + ", бўдан јрі «Банк» деп аталады," skip
    v-bankosn_kz + " негізінде іс-ќимыл жасайтын " + v-dol_kz + ' ' + v-bankface_kz skip
    "арќылы, бір жаєынан жјне " + v-name + " мырза (ханым), бўдан јрі «Ќарыз алушы» деп аталады, екінші жаєынан".

if v-names <> '' then do:
    put stream rep unformatted "жјне " + v-names + " мырза (ханым), бўдан јрі «Ќосалќы ќарыз алушы» деп аталады, їшінші жаєынан".
end.

put stream rep unformatted
    ", бірлесіп «Тараптар» деп аталып," skip
    "мына тґмендегілер туралы "  + date2str_kz(1,v-dogdate) + " N " + v-dognom + " Тўтыну несиесін беру туралы шартќа" skip
    "(бўдан јрі – Шарт) осы Ќосымша келісімді (бўдан јрі – Ќосымша келісім) жасады:</P>" skip
    "</td></tr>" skip.

v-num = 0.

v-num = v-num + 1.
put stream rep unformatted
    "<tr><td colspan=2>" skip
    "<P style=""TEXT-ALIGN: justify"">&nbsp;<br>" + string(v-num) + '.' skip
    "Ќарыз алушыєа " + date2str_kz(1,v-dtpog) + " ќоса алєанєа дейінгі мерзімге негізгі борыш".

if v-deltype = 2 then do:
    if v-dtpog = v-dtpog2 then put stream rep unformatted " пен сыйаќы".
    else put stream rep unformatted " пен " + date2str_kz(1,v-dtpog2) + " ќоса алєанєа дейінгі мерзімге сыйаќы".
end.

put stream rep unformatted
    " бойынша тґлем мерзімін ўзарту ўсынылады, бўл ретте Шарт бойынша несиені пайдалану мерзімі ўзартылмайды..</P>" skip
    "</td></tr>" skip.

v-num = v-num + 1.
put stream rep unformatted
    "<tr><td colspan=2>" skip
    "<P style=""TEXT-ALIGN: justify"">&nbsp;<br>" + string(v-num) + '.' skip
    "Мерзімінен бўрын ішінара ґтеуге жол берілмейді. Мерзімінен бўрын толыќ ґтеуге жўмыс кїніне тїсетін кез келген кїні болады," skip
    "бўл ретте Ќарыз алушы мерзімінен бўрын ґтеу кїніне Мерзімі ўзартылєан сыйаќыныѕ ќалдыєын (Мерзімі ўзартылєан сыйаќыныѕ ќалдыєы" skip
    "осы Ќосымша келісімді жасау кїніне есептелген, біраќ ќолданыстаєы Тґлемдер кестесіне сай Мерзімі ўзартылєан сыйаќыныѕ тґленген" skip
    "сомаларын шегере отырып " + v-prc_otsr + " " + crcn1[pkanketa.crc] + " (" + v-prc_otsr_wrd_kz + ")" skip
    "мґлшеріндегі ґтелмеген сыйаќы сомасынан есептеледі (бўдан јрі - Мерзімі ўзартылєан сыйаќы), сондай-аќ Кезекті тґлемдер кїніне" skip
    "ќолданыстаєы Тґлемдер кестесінде кґзделген мґлшердегі сыйаќыны 3 (їш) толыќ ай їшін тґлеуге міндеттенеді.</P>" skip
    "</td></tr>" skip.

put stream rep unformatted
    "<tr><td colspan=2>" skip
    "<P style=""TEXT-ALIGN: justify"">Осы тармаќта кґрсетілген жаєдай туындаєан кезде осы Ќосымша келісімге ќол ќойєанєа дейін" skip
    "ќолданыста болєан несиені мерзімінен бўрын толыќ ґтеу тјртібін реттейтін Шарттыѕ нормалары кїшін жоєалтќан болып танылады.</P>" skip
    "</td></tr>" skip.


v-num = v-num + 1.
put stream rep unformatted
    "<tr><td colspan=2>" skip
    "<P style=""TEXT-ALIGN: justify"">&nbsp;<br>" + string(v-num) + '.' skip
    "Осы Ќосымша келісімге ќол ќойєан кезде " + date2str_kz(1,g-today) + " жаєдай бойынша есептелген тўраќсыздыќ айыбы есептен" skip
    "шыєарылмайды, біраќ Банк Ќарыз алушыєа ол Шарт бойынша міндеттемелерді толыќ орындаєанєа дейін оны тґлеу бойынша мерзімін" skip
    "ўзартуды ўсынады. Осы Ќосымша келісімге ќол ќойылєаннан кейін 90 жјне одан да кґп кїнге мерзімі ґткен берешек пайда болєан" skip
    "жаєдайда, Банк талап етуге ќўќылы, ал Ќарыз алушы бірінші кезекте " + date2str_kz(1,g-today) + " жаєдай бойынша есептелген" skip
    "тўраќсыздыќ айыбын, ал одан јрі осы Ќосымша келісіммен ќозєалмаєан Шарттыѕ нормаларында кґзделген кезектілікпен ґтеуге" skip
    "міндеттенеді. Осы Ќосымша келісімге ќол ќойылєаннан кейін пайда болєан несие бойынша барлыќ берешек толыќ (соныѕ ішінде мерзімінен" skip
    "бўрын) ґтелген кезде " + date2str_kz(1,g-today) + " жаєдай бойынша есептелген, біраќ тґленбеген тўраќсыздыќ айыбы толыќ кґлемде" skip
    "есептен шыєарылады.</P>" skip
    "</td></tr>" skip.

v-num = v-num + 1.
put stream rep unformatted
    "<tr><td colspan=2>" skip
    "<P style=""TEXT-ALIGN: justify"">&nbsp;<br>" + string(v-num) + '.' skip
    "Шарттыѕ № 1 ќосымшасы мынадай редакцияда жазылсын:</P>" skip
    "</td></tr>" skip
    "<tr>" skip
    "<td colspan=""2"" style=""font:bold"" align=""right"">&nbsp;<br>" date2str_kz(1,v-dogdate) skip
    "N " + v-dognom + " Тўтыну несиесін беру туралы шартќа<br>N 1 ќосымша" skip
    "</td></tr>" skip.

put stream rep unformatted
    "<tr><td colspan=2>" skip
    "<P style=""TEXT-ALIGN: justify"">&nbsp;<br>"skip
    "Заемшы Шартќа осы Ќосымша  № 1 ќол ќоя отырып, Банкпен  тїрлі јдістерімен есептеліп ўсынылєан  Несиені ґтеу кестесімен танысќанын растайды, Заемшымен  ґтеу јдісін таѕдауда  Тараптар келесіге тоќтады: </P>" skip
    "</td></tr>" skip.

put stream rep unformatted
    "<tr><td colspan=2>" skip
    "<P style=""TEXT-ALIGN: justify"">&nbsp;<br>"skip
    "1.	Заемшы аннуитетті тґлемдермен тґлеу јдістерінен, ґзге јдістерден тараптардыѕ келісуі бойынша бас тартады. </P>" skip
    "</td></tr>" skip.

put stream rep unformatted
    "<tr><td colspan=2>" skip
    "<P style=""TEXT-ALIGN: justify"">&nbsp;<br>"skip
    "2.	Заемшымен тґмендегі тґлем Кестесінде ќолданылатын Несиені пайдаланєаны їшін Несие Сомасына сыйаќы есептелуімен теѕ їлесте тґлеу јдісі таѕдалды: </P>" skip
    "</td></tr>" skip.

put stream rep unformatted
    "<tr><td colspan=2>" skip
    "<P style=""TEXT-ALIGN: justify"">&nbsp;<br>" + v-od + " " + crcn1[pkanketa.crc] + " (" + v-odwrd_kz + ') мґлшеріндегі несие ќалдыєын ґтеу мынадай тјртіппен жасалады:</P>' skip.

put stream rep unformatted
    "<table border=1 cellpadding=0 cellspacing=0 width=100% style=""FONT-SIZE: 12pt; FONT-FAMILY: 'Times New Roman CYR'"">" skip
    "<tr align=""center"" style=""FONT-SIZE: 12pt; FONT-FAMILY: 'Arial Narrow'"">" skip
    "<td>Кїні</td>" skip
    "<td>Ґтелуге<br>жататын<br>Несие<br>бойынша<br>негізгі<br>борыш<br>сомасы</td>" skip
    "<td>Аєымдаєы<br>ай їшін<br>есептелген,<br>ґтелуге<br>жататын<br>сыйаќы<br>сомасы</td>" skip
    "<td>Ґтелуге<br>жататын<br>мерзімі<br>ўзартылєан<br>сыйаќы<br>сомасы</td>" skip
    "<td>Ґтелуге<br>жататын<br>комиссия<br>сомасы</td>" skip
    "<td>Ай<br>сайынєы<br>тґлем</td>" skip
    "<td>Ай<br>сайынєы<br>тґлем<br>тґленгеннен<br>кейінгі<br>негізгі<br>борыш<br>сомасыныѕ<br>ќалдыєы</td>" skip
    "<td>Ай<br>сайынєы<br>тґлем<br>тґленгеннен<br>кейінгі<br>мерзімі<br>ўзартылєан<br>сыйаќы<br>сомасыныѕ<br>ќалдыєы</td>" skip
    "</tr>" skip.

v-sum = 0.
for each grwrk where grwrk.stdat > dat_wrk no-lock:
    put stream rep unformatted
        "<tr>" skip
        "<td align=""center"">" string(grwrk.stdat,"99/99/99") "</td>" skip
        "<td align=""right"">" trim(string(grwrk.stval,">>>>>>>>9.99")) "</td>" skip
        "<td align=""right"">" trim(string(grwrk.prcpure,">>>>>>>>9.99")) "</td>" skip
        "<td align=""right"">" trim(string(grwrk.prcadd,">>>>>>>>9.99")) "</td>" skip
        "<td align=""right"">" trim(string(grwrk.pcom,">>>>>>>>9.99")) "</td>" skip
        "<td align=""right"">" trim(string(grwrk.stval + grwrk.prcpure + grwrk.prcadd + grwrk.pcom,">>>>>>>>9.99")) "</td>" skip
        "<td align=""right"">" trim(string(grwrk.odleft,">>>>>>>>9.99")) "</td>" skip
        "<td align=""right"">" trim(string(grwrk.prcleft,">>>>>>>>9.99")) "</td>" skip
        "</tr>" skip.
    v-sum[1] = v-sum[1] + grwrk.stval.
    v-sum[2] = v-sum[2] + grwrk.prcpure.
    v-sum[3] = v-sum[3] + grwrk.prcadd.
    v-sum[4] = v-sum[4] + grwrk.pcom.
end.
put stream rep unformatted
    "<tr style=""font:bold"">" skip
    "<td align=""center"">Жиынтыєы:</td>" skip
    "<td align=""right"">" trim(string(v-sum[1],">>>>>>>>9.99")) "</td>" skip
    "<td align=""right"">" trim(string(v-sum[2],">>>>>>>>9.99")) "</td>" skip
    "<td align=""right"">" trim(string(v-sum[3],">>>>>>>>9.99")) "</td>" skip
    "<td align=""right"">" trim(string(v-sum[4],">>>>>>>>9.99")) "</td>" skip
    "<td align=""right"">" trim(string(v-sum[1] + v-sum[2] + v-sum[3] + v-sum[4],">>>>>>>>9.99")) "</td>" skip
    "<td align=""right""></td>" skip
    "<td align=""right""></td>" skip
    "</tr>" skip.

put stream rep unformatted
    "</table>" skip
    "»." skip
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
    "Тараптар осы Ќосымша келісімніѕ тілдері ретінде мемлекеттік жјне орыс тілдерін таѕдады. Тараптар осы Ќосымша келісімніѕ тілдері" skip
    "оларєа толыєымен тїсінікті, бїкіл Ќосымша келісімніѕ, сол сияќты оныѕ жекелеген бґліктерініѕ маєынасы мен мјні оларєа толыєымен" skip
    "аныќ екендігі жайында мјлімдейді. Осы Ќосымша келісімніѕ тїрлі тілдердегі мјтіндерініѕ арасында сјйкессіздіктер (келіспеушіліктер)" skip
    "туындаєан кезде орыс тіліндегі мјтінге басымдыќ беріледі.</P>" skip
    "</td></tr>" skip.

v-num = v-num + 1.
put stream rep unformatted
    "<tr><td colspan=2>" skip
    "<P style=""TEXT-ALIGN: justify"">&nbsp;<br>" + string(v-num) + '.' skip
    "Тараптардыѕ заѕды мекенжайлары мен деректемелері:</P>" skip
    "</td></tr>" skip.


put stream rep unformatted
    "<tr><td colspan=2>БАНК: " + v-bankname_kz + "<br>" skip
    v-bankadres_kz + "<br>" skip
    "СТН " + v-bankrnn + "<br>" skip
    "Ќазаќстан Республикасы Ўлттыќ Банкініѕ Монетарлыќ операцияларды есепке алу басќармасындаєы (ООКСП) ИИК " + v-bankiik + "<br>" skip
    "БЖК " + v-bankbik + "<br>"
    "&nbsp;<br>"
    "ЌАРЫЗ АЛУШЫ: " + v-name + "<br>" skip
    "СТН " + v-rnn + "<br>" skip
    "Жеке кујлік N " + v-docnum + ", " + v-docdt + " ж." + v-docorg_kz + " берген<br>" skip
    "Тўраќты тіркеу мекенжайы: " + v-adres[1] + "<br>" skip
    "Наќты тўратын жерініѕ мекенжайы: " + v-adres[2] + "<br>" skip
    "Тел.:" + v-telefon skip.

if v-names <> '' then do:
    put stream rep unformatted
        "&nbsp;<br>" skip
        "ЌОСАЛЌЫ ЌАРЫЗ АЛУШЫ: " + v-names + "<br>" skip
        "СТН " + v-rnns + "<br>" skip
        "Жеке кујлік N " + v-docnums + ", " + v-docdts + " ж." + v-docorgs_kz + " берген<br>" skip
        "Тўраќты тіркеу мекенжайы: " + v-adress[1] + "<br>" skip
        "Наќты тўратын жерініѕ мекенжайы: " + v-adress[2] + "<br>" skip
        "Тел.:" + v-telefons skip.
end.

put stream rep unformatted
    "</td></tr>" skip.

put stream rep unformatted
    "<tr><td align=""center"" colspan=2>ЌОЙЫЛЄАН ЌОЛДАРЫ МЕН МҐРЛЕРІ</td><tr>" skip
    "<tr><td align=""left"">" skip
    "Банктіѕ атынан<br>" skip.

if s-ourbank = "TXB00" then
    put stream rep unformatted
    "<IMG border=""0"" src=""pkdogsgn.jpg"" v:shapes=""_x0000_s1026""><br>(" + v-bankpodp + ")" skip.
else
    put stream rep unformatted
    "<IMG border=""0"" src=""pkdogsgn.jpg"" width=""120"" height=""40"" v:shapes=""_x0000_s1026""><br>(" + v-bankpodp + ")" skip.

put stream rep unformatted
    "</td>" skip
    "<td align=""left""><IMG border=""0"" src=""pkstamp.jpg"" width=""160"" height=""160""></td>" skip
    "</td></tr>" skip.

put stream rep unformatted
    "<tr><td colspan=""2"">" skip
    "Ќарыз алушы<br>" skip
    "&nbsp;<br>" skip
    "____________________________________________________________________/_______________<br>" skip
    "<center><i>(Аты-жґні толыєымен, Ќолы)</i><center><br>" skip
    "</td></tr>" skip.

if v-names <> '' then do:
    put stream rep unformatted
        "<tr><td colspan=""2"">" skip
        "Ќосалќы ќарыз алушы<br>" skip
        "&nbsp;<br>" skip
        "____________________________________________________________________/_______________<br>" skip
        "<center><i>(Аты-жґні толыєымен, Ќолы)</i><center><br>" skip
        "</td></tr>" skip.
end.

put stream rep unformatted "</table>" skip.

/*####################################################################################*/


put stream rep unformatted
    "</table></body></html>" skip.

output stream rep close.
unix silent cptwin rep.htm iexplore.




