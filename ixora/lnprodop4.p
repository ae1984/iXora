/* lnprodop4.p
 * MODULE
        Потреб. кредитование
 * DESCRIPTION
        Формирование доп. соглашения по реструктуризации/пролонгации - перенос пени на отсрочку
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

def stream rep.
output stream rep to value(dogfile).

put stream rep unformatted
    "<html><head><title>Допсоглашение</title>" skip
    "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
    "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.

put stream rep unformatted
    "<table border=0 cellpadding=0 cellspacing=0 width=100% style=""FONT-SIZE: 12pt; FONT-FAMILY: 'Times New Roman CYR'"">" skip
    "<tr style=""FONT-SIZE: 9pt; FONT-FAMILY: 'Times New Roman CYR'""><td width=50%></td><td width=50% align=""right"">Регистрационный N 117</td></tr>" skip
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
    "<tr style=""page-break-before:always;FONT-SIZE: 9pt; FONT-FAMILY: 'Times New Roman CYR'""><td width=50%></td><td width=50% align=""right"">Тіркеу N 117</td></tr>" skip
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




