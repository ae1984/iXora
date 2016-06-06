/* lndopdog.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Дополнение к кредитному договору
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
        03/01/2008 madiyar
 * BASES
        BANK COMM
 * CHANGES
        24/04/2008 madiyar - pkendtable -> pkendtable_old
        25/11/09 marinav - для нестандартной подписи в ЦО масштаб не указываем
        25/04/2012 evseev  - rebranding. Название банка из sysc или изменил проверку банка или рко
*/

{global.i}
{pk.i}
{sysc.i}
{pk-sysc.i}
{nbankBik.i}

find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.ln = s-pkankln no-lock no-error.
if not avail pkanketa then do:
  message skip " Анкета N" s-pkankln "не найдена !" skip(1) view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

def new shared var v-inet as logi init no.
if pkanketa.id_org = "inet" then v-inet = yes.

def new shared var v-toplogo as char.
def new shared var v-stamp as char.
if v-inet then do:
    v-toplogo = "c:\\tmp\\top_logo_bw.jpg".
    /*
    s-dogsign определяется один раз в PKI_ps.p
    */
    v-stamp = "c:\\tmp\\pkstamp.jpg".
end.
else do:
    v-toplogo = "top_logo_bw.jpg".
    if s-ourbank = "TXB00" then s-dogsign = "<IMG border=""0"" src=""pkdogsgn.jpg"" v:shapes=""_x0000_s1026"">".
                           else s-dogsign = "<IMG border=""0"" src=""pkdogsgn.jpg"" width=""180"" height=""60"" v:shapes=""_x0000_s1026"">".
    v-stamp = get-pksysc-char ("dcstmp").
end.

def var v-str as char no-undo.

def var v-dognom as char no-undo.
def var v-dogdt as char no-undo.
def var v-city as char no-undo.
def var v-datastr as char no-undo.
def new shared var v-name as char.
def var v-effrate_d as deci no-undo.
def var v-effrate as char no-undo.
def var v-monthname as char init "января,февраля,марта,апреля,мая,июня,июля,августа,сентября,октября,ноября,декабря".
def var v-pdat as date no-undo.
def var v-comved as deci no-undo.

v-dognom = entry(1, pkanketa.rescha[1]).
v-dogdt = string(pkanketa.docdt,"99/99/9999").
find first cmp no-lock no-error.
v-datastr = trim(string(day(today), ">9")) + " " + entry(month(today), v-monthname) + " " + string(year(today), "9999").
v-name = pkanketa.name.

v-pdat = ?.
find first lnsch where lnsch.lnn = pkanketa.lon and lnsch.f0 > 0 no-lock no-error.
if avail lnsch then v-pdat = lnsch.stdat.
else message "Ошибка! Не найден первый платеж по графику для расчета эфф. ставки" view-as alert-box error.
v-comved = 0.
find first tarifex2 where tarifex2.aaa = pkanketa.aaa and tarifex2.cif = pkanketa.cif and tarifex2.str5 = "195" and tarifex2.stat = 'r' no-lock no-error.
if avail tarifex2 then v-comved = tarifex2.ost.
else message "Ошибка определения суммы комиссии за обслуживание кредита" view-as alert-box error.
run erl_bdf(pkanketa.summa,pkanketa.srok,pkanketa.rateq,pkanketa.docdt,v-pdat,pkanketa.sumcom,v-comved,0,output v-effrate_d).
v-effrate = string(v-effrate_d,">>9.<<").
if substr(v-effrate,length(v-effrate),1) = '.' then v-effrate = substr(v-effrate,1,length(v-effrate) - 1).

def new shared var v-rnn as char.
def new shared var v-docnum as char.
def new shared var v-adres as char extent 2.
def var v-adresd as char no-undo extent 2.
def new shared var v-telefon as char.
def new shared var v-nameshort as char.

v-rnn = pkanketa.rnn.
v-docnum = pkanketa.docnum.
run pkdefadres (pkanketa.ln, no, output v-adres[1], output v-adres[2], output v-adresd[1], output v-adresd[2]).
find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "tel" no-lock no-error.
if avail pkanketh then v-telefon = trim(pkanketh.value1).
run pkdefsfio (pkanketa.ln, output v-nameshort).

def new shared var v-bankname as char.
def new shared var v-bankadres as char.
def new shared var v-bankiik as char.
def new shared var v-bankbik as char.
def new shared var v-bankups as char.
def new shared var v-bankrnn as char.
def new shared var v-bankpodp as char.
def new shared var v-bankcontact as char.

find first cmp no-lock no-error.
if avail cmp then do:
  v-bankname = v-nbankru.
  v-city = "г.Алматы". /*entry(1, cmp.addr[1]).*/
  v-bankadres = "г.Алматы, пр-т Аль-Фараби, 13, ПФЦ ""Нурлы Тау"", здание 3В". /*cmp.addr[1].*/
  v-bankrnn = "600400585309". /*cmp.addr[2].*/
  v-bankcontact = ''. /*cmp.contact.*/
end.

v-bankiik = get-sysc-cha ("bnkiik").
v-bankbik = get-sysc-cha ("clecod").
v-bankups = get-sysc-cha ("bnkups").

find bookcod where bookcod.bookcod = "credtype" and bookcod.code = s-credtype no-lock no-error.
if avail bookcod then v-bankpodp = get-sysc-cha (bookcod.info[1] + "podp").



def stream v-out.
def var v-ofile as char no-undo.
def var v-infile as char no-undo.
v-ofile  = "dopdog.htm".
v-infile = "dopdog2.htm".
output stream v-out to value(v-infile).


find pksysc where pksysc.credtype = '4' and pksysc.sysc = "dcdocs" no-lock no-error.
if avail pksysc then v-ofile = pksysc.chval + v-ofile.
run upd_field.
output stream v-out close.
run pkendtable_old(v-infile, "БАНК", "ЗАЕМЩИК", true, " style=""font-size:9pt""", no, yes, yes).

output stream v-out to value(v-infile) append.
put stream v-out unformatted "<body><html>" skip.
output stream v-out close.

if v-inet then unix silent value("mv " + v-infile + " /var/www/html/docs/" + s-credtype + "/" + string(s-pkankln) + "; chmod 666 /var/www/html/docs/" + s-credtype + "/" + string(s-pkankln) + "/" + v-infile).
else unix silent value("cptwin " + v-infile + " iexplore").

pause 0.


procedure upd_field.

    input from value(v-ofile).
    repeat:
        import unformatted v-str.
        v-str = trim(v-str).

        repeat:

            if v-str matches "*\{\&v-dognom\}*" then do:
                v-str = replace (v-str, "\{\&v-dognom\}", v-dognom).
                next.
            end.
            if v-str matches "*\{\&v-dogdt\}*" then do:
                v-str = replace (v-str, "\{\&v-dogdt\}", v-dogdt).
                next.
            end.
            if v-str matches "*\{\&v-city\}*" then do:
                v-str = replace (v-str, "\{\&v-city\}", v-city).
                next.
            end.
            if v-str matches "*\{\&v-datastr\}*" then do:
                v-str = replace (v-str, "\{\&v-datastr\}", v-datastr).
                next.
            end.
            if v-str matches "*\{\&v-name\}*" then do:
                v-str = replace (v-str, "\{\&v-name\}", "<b>&nbsp;" + v-name + "&nbsp;</b>").
                next.
            end.
            if v-str matches "*\{\&v-effrate\}*" then do:
                v-str = replace (v-str, "\{\&v-effrate\}", v-effrate).
                next.
            end.

            leave.
        end. /* repeat */

        put stream v-out unformatted v-str skip.
    end. /* repeat */
    input close.

end procedure.



