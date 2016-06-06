/* doggcvp.p
 * MODULE
        Договора ГЦВП
 * DESCRIPTION
        Формирование договоров
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        
 * BASES
        BANK COMM
 * AUTHOR
        13.09.2008 alex
 * CHANGES
        25.09.2008 alex - перекомпиляция
*/
 
{global.i}

def var v-city as char.
def var v-citykz as char.
def var v-datastr as char.
def var v-datastrkz as char.

def var v-bankname as char.
def var v-banknamekz as char.
def var v-bankface as char.
def var v-bankfaceKZ as char.

def var v-iik as char.
def var v-name as char.
def var v-namefull as char.
def var v-nameshort as char.
def var v-rnn as char.
def var v-docnum as char.
def var v-adres as char.
def var v-adreslabel as char.
def var v-telefon as char.
def var v-fax as char.
def var v-telefonr as char.
def var v-crc as char.
def var v-odt as date.
def var v-keyw as char.
def var v-bank as char.
def var v-bankkz as char.

def shared var s-cif like cif.cif.
def shared var s-aaa like aaa.aaa.


def stream v-out.
def var v-ofile as char no-undo.
def var v-infile as char no-undo.
def var v-str as char no-undo.
def var v-paym as char no-undo.


/*******************************************************************/
def var v-bankadres as char.
def var v-bankadreskz as char.
def var v-bankrnn as char.
def var v-bankcontact as char.
def var v-bankiik as char.
def var v-bankbik as char.
def var v-bankups as char.
def var v-iikval as char.
/*******************************************************************/


find first cmp no-lock no-error.
if avail cmp then do:
    v-bankname = cmp.name.
    find sysc where sysc.sysc = "bnkadr" no-lock no-error.
        if avail sysc and num-entries(sysc.chval,"|") > 13 then v-banknamekz = entry(14, sysc.chval,"|").
    v-city = entry(1, cmp.addr[1]).
    find sysc where sysc.sysc = "bnkadr" no-lock no-error.
        if avail sysc and num-entries(sysc.chval,"|") > 12 then v-citykz = entry(12, sysc.chval,"|").
    v-bankadres = cmp.addr[1].
    find sysc where sysc.sysc = "bnkadr" no-lock no-error.
        if avail sysc and num-entries(sysc.chval,"|") > 11 then v-bankadreskz = entry(11, sysc.chval,"|"). 
    v-bankrnn = cmp.addr[2].
    v-bankcontact = cmp.contact.
end.

run pkdefdtstr(g-today, output v-datastr, output v-datastrkz).


{sysc.i}
v-bankiik = get-sysc-cha ("bnkiik").
v-bankbik = get-sysc-cha ("clecod").
v-bankups = get-sysc-cha ("bnkups").
/*v-bankface = get-sysc-cha ("dkface").*/


find last sysc where sysc.sysc = "OURBNK" no-lock no-error.
if sysc.chval = "TXB00" then do:
    v-bankfaceKZ = "Бояркина Ирина Якубовна".
    v-ofile = "op-doggcvp.htm".
    v-bank = "".
    v-bankkz = "".
end. else do:
    v-ofile = "doggcvp.htm".
    v-bankfaceKZ = get-sysc-cha ("dkpodp").
    find last sysc where sysc.sysc eq "bnkadr" no-lock no-error.
    if avail sysc then do:
        if num-entries(sysc.chval,"|") > 13 then do:
            find first cmp no-lock no-error.
            v-bank = cmp.name + ", " + entry(1, sysc.chval, "|") + ", " + cmp.addr[1] + ", РНН " + cmp.addr[2] + ", корреспондентский счет " + v-bankiik + 
                " в Управлении учета монетарных операций (ООКСП) Национального Банка Республики Казахстан, БИК " + v-bankbik.
            v-bankKZ = entry(14, sysc.chval, "|") + ", " + entry(1, sysc.chval, "|") + ", " + entry(11, sysc.chval, "|") + ", СТТН " + cmp.addr[2] + 
                "  корреспонденттiк шот " + v-bankiik + " &#1178;аза&#1179;стан Республикасыны&#1187; &#1200;лтты&#1179; Банкiнi&#1187; монетарлы&#1179; операциялар бас&#1179;армасында (ООКСП), БСК " + v-bankbik.
        end.
    end.
end.

find aaa where aaa.cif eq s-cif and aaa.aaa eq s-aaa no-lock no-error.
if avail aaa then do:
    v-odt = g-today.
    v-iik = s-aaa.
    find first crc where crc.crc eq aaa.crc no-lock no-error.
        if avail crc then v-crc = crc.des.
end.
find cif where cif.cif eq s-cif no-lock no-error.
if avail cif then do:
    v-name = cif.name.
    v-adres = cif.addr[1] + " " + cif.addr[2].
    v-telefon = cif.tel.
    v-fax = cif.fax.
    v-rnn = cif.jss.
    v-docnum = cif.pss.
    if cif.attn ne "" then v-keyw = cif.attn.
    else v-keyw = "____________________".
end.

find pksysc where pksysc.credtype = '6' and pksysc.sysc = "dcdocs" no-lock no-error.
if avail pksysc then v-ofile = pksysc.chval + v-ofile.
v-infile = "dog.htm".

output stream v-out to value(v-infile).


input from value(v-ofile).
repeat:
  import unformatted v-str.
  v-str = trim(v-str).

  repeat:
    if v-str matches "*\{\&v-docnum\}*" then do:
        v-str = replace (v-str, "\{\&v-docnum\}", v-docnum).
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
    if v-str matches "*\{\&v-bankname\}*" then do:
        v-str = replace (v-str, "\{\&v-bankname\}", "<b>&nbsp;" + v-bankname + "&nbsp;</b>").
        next.
    end.
    if v-str matches "*\{\&v-banknamekz\}*" then do:
        v-str = replace (v-str, "\{\&v-banknamekz\}", "<b>&nbsp;" + v-banknamekz + "&nbsp;</b>").
        next.
    end.
    if v-str matches "*\{\&v-bankface\}*" then do:
        v-str = replace (v-str, "\{\&v-bankface\}", "<b>&nbsp;" + v-bankfaceKZ + "&nbsp;</b>").
        next.
    end.
    if v-str matches "*\{\&v-bankfaceKZ\}*" then do:
        v-str = replace (v-str, "\{\&v-bankfaceKZ\}", "<b>&nbsp;" + v-bankfaceKZ + "&nbsp;</b>").
        next.
    end.
    if v-str matches "*\{\&v-name\}*" then do:
        v-str = replace (v-str, "\{\&v-name\}", "<b>&nbsp;" + v-name + "&nbsp;</b>").
        next.
    end.
    if v-str matches "*\{\&v-crc\}*" then do:
        v-str = replace (v-str, "\{\&v-crc\}", v-crc).
        next.
    end.
    if v-str matches "*\{\&v-iik\}*" then do:
        v-str = replace (v-str, "\{\&v-iik\}", v-iik).
        next.
    end.
    if v-str matches "*\{\&v-odt\}*" then do:
        v-str = replace (v-str, "\{\&v-odt\}", string(v-odt, "99/99/9999")).
        next.
    end.
    if v-str matches "*\{\&v-addr\}*" then do:
        v-str = replace (v-str, "\{\&v-addr\}", v-adres).
        next.
    end.
    if v-str matches "*\{\&v-telefon\}*" then do:
        v-str = replace (v-str, "\{\&v-telefon\}", v-telefon).
        next.
    end.
    if v-str matches "*\{\&v-fax\}*" then do:
        v-str = replace (v-str, "\{\&v-fax\}", "").
        next.
    end.
    if v-str matches "*\{\&v-rnn\}*" then do:
        v-str = replace (v-str, "\{\&v-rnn\}", v-rnn).
        next.
    end.
    if v-str matches "*\{\&v-keyw\}*" then do:
        v-str = replace (v-str, "\{\&v-keyw\}", v-keyw).
        next.
    end.
    if v-str matches "*\{\&v-bankKZ\}*" then do:
        v-str = replace (v-str, "\{\&v-bankKZ\}", v-bankKZ).
        next.
    end.
    if v-str matches "*\{\&v-bank\}*" then do:
        v-str = replace (v-str, "\{\&v-bank\}", v-bank).
        next.
    end.
    leave.
  end.

  put stream v-out unformatted v-str skip.
end.
input close.
output stream v-out close.

unix silent value("cptwin " + v-infile + " winword").
