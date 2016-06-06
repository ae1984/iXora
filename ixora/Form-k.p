/*
Form-k.p
 * MODULE
        Операционка
 * DESCRIPTION
        Карточка с образцами подписей
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
        11/12/2008 Levin Victor
 * BASES
 		BANK COMM
 * CHANGES
        24/03/2009 madiyar - в анкетах формировался некорректно, подправил
        19/01/2010 galina  - добавила ИИН
        22/10/2010 madiyar - изменения в формате
        08/11/2010 madiyar - два адреса, каждый в своей строке
        15/03/2012 id00810 - название банка из sysc
        14/05/2012 evseev - ребрендинг
        11/07/2012 id00810 - увеличила формат вывода адреса банка
        07.12.2012 damir - Внедрено Т.З. № 1606.
*/

{global.i}
{nbankBik.i}

def shared var v-name as char.
def shared var v-addr1 as char.
def shared var v-addr2 as char.
def shared var pass as char.
def shared var v-work as char .
def shared var v-rnn as char.
def shared var v-tel as char.
def shared var v-iik as char.
def shared var my-log as char.
def shared var v-ofile as char.
def shared var v-pref as char.
def shared var s-yurhand as logical.
def shared var s-yur as logical.
def shared var yur as logical.
def shared var v-iin as char.

def var v-street as char.
def var v-telbank like cmp.tel.
def var v-dt as char format "x(15)".
def var v-dtk as char.
def var v-dtshort as char.
def var v-ofcname as char.
def var v-infile as char.
def var v-str as char.
def var v-chf as char.
def var v-bk as char.
def var v-bk_dol as char.
def var image as char.
def var organ as char.

v-iik = '<input type=text style = "border:0; font-family:Times New Roman Cyr; font-size:100%;" value=" ' + v-iik + ' " name="foo" size=60>'.
my-log = '<input type=text style = "border:0; font-family:Times New Roman Cyr; font-size:100%;" name="foo" value=" ' +  my-log + ' " size=8>'.

find ofc where ofc.ofc = g-ofc no-lock no-error.
if avail ofc then do:
    v-ofcname = trim(entry(1,ofc.name,' ')).
    if num-entries(ofc.name,' ') > 1 then v-ofcname = v-ofcname + " " + substring(entry(2,ofc.name,' '),1,1) + '.'.
    if num-entries(ofc.name,' ') > 2 then v-ofcname = v-ofcname + " " + substring(entry(3,ofc.name,' '),1,1) + '.'.
end.

find first cmp no-lock no-error.
    v-street = '<input type=text style = "border:0; font-family:Times New Roman Cyr; font-size:100%;" name="foo" value="' + cmp.addr[1] + ' "  size=80>'.
    v-telbank = '<input type=text style = "border:0; font-family:Times New Roman Cyr; font-size:100%;" name="foo" value="' + cmp.tel + ' " size=10>'.
    if s-yur = yes then v-work = cmp.name.

if s-yur then v-infile = "kart_sampleyur.htm".
else do:
    if yur then do:
        image = '<br><br><br><br><br><br><br><br><br><br><br><br><br><br>'.
        v-infile = "kart_sample.htm".
        organ = /*'<input type=text style = "border:0; font-family:Times New Roman Cyr; font-size:100%;" name="foo" size=25>'*/ ''.
        v-ofcname = /*'<input type=text style = "border:0; font-family:Times New Roman Cyr; font-size:100%;" name="foo" size=25>'*/ ''.
        v-dtshort = /*'<input type=text style = "border:0; font-family:Times New Roman Cyr; font-size:100%;" name="foo" size=8>'*/ ''.
        pass = /*'<input type=text style = "border:0; font-family:Times New Roman Cyr; font-size:100%;" name="foo" size=40>'*/ ''.
        v-work = /*'<input type=text style = "border:0; font-family:Times New Roman Cyr; font-size:100%;" name="foo" size=40>'*/ ''.
    end.
    else do:
        v-dtshort = string(g-today).
        /*organ = 'АО "ForteBank"'.*/
        find first sysc where sysc.sysc = 'bankname' no-lock no-error.
        if avail sysc then organ = 'АО ' + sysc.chval.
        image = '<IMG border="0" src="pkstamp.jpg" width="160" height="160" >'.
        v-infile = "kart_sample.htm".
    end. /*Конец else*/
end.  /*Конец else*/
v-work = replace(v-work,'"',"'").
find first pksysc where pksysc.credtype = '6' and pksysc.sysc = "dcdocs" no-lock no-error.
if avail pksysc then v-infile = pksysc.chval + v-infile.

def stream v-out.
output stream v-out to value(v-ofile).

run pkdefdtstr(g-today, output v-dt, output v-dtk).

input from value(v-infile).

repeat:
  	import unformatted v-str.
  	v-str = trim(v-str).

    repeat:

        if v-str matches "*\{\&v-pref\}*" then do:
           v-str = replace (v-str, "\{\&v-pref\}", v-pref).
           next.
        end.

        if v-str matches "*\{\&organ\}*" then do:
           v-str = replace (v-str, "\{\&organ\}", organ).
           next.
        end.

        if v-str matches "*\{\&image\}*" then do:
           v-str = replace (v-str, "\{\&image\}", image).
           next.
        end.

        if v-str matches "*\{\&v-bk\}*" then do:
           v-str = replace (v-str, "\{\&v-bk\}", string(v-bk)).
           next.
        end.

        if v-str matches "*\{\&v-chf\}*" then do:
           v-str = replace (v-str, "\{\&v-chf\}", string(v-chf)).
           next.
        end.

        if v-str matches "*\{\&v-dtshort\}*" then do:
           v-str = replace (v-str, "\{\&v-dtshort\}", v-dtshort).
           next.
        end.

        if v-str matches "*\{\&v-tel\}*" then do:
           v-str = replace (v-str, "\{\&v-tel\}", string(v-tel)).
           next.
        end.

        if v-str matches "*\{\&v-iik\}*" then do:
           v-str = replace (v-str, "\{\&v-iik\}", string(v-iik)).
           next.
        end.

        if v-str matches "*\{\&v-rnn\}*" then do:
           v-str = replace (v-str, "\{\&v-rnn\}", string(v-rnn)).
           next.
        end.

        if v-str matches "*\{\&v-work\}*" then do:
           v-str = replace (v-str, "\{\&v-work\}", string(v-work)).
           next.
        end.

        if v-str matches "*\{\&v-name\}*" then do:
           v-str = replace (v-str, "\{\&v-name\}", v-name).
           next.
        end.

        if v-str matches "*\{\&v-dt\}*" then do:
           v-str = replace (v-str, "\{\&v-dt\}", v-dt).
           next.
        end.

        if v-str matches "*\{\&v-addr1\}*" then do:
           v-str = replace (v-str, "\{\&v-addr1\}", v-addr1).
           next.
        end.

        if v-str matches "*\{\&v-addr2\}*" then do:
           v-str = replace (v-str, "\{\&v-addr2\}", v-addr2).
           next.
        end.

        if v-str matches "*\{\&v-cif\}*" then do:
           v-str = replace (v-str, "\{\&v-cif\}", my-log).
           next.
        end.

        if v-str matches "*\{\&v-telbank\}*" then do:
           v-str = replace (v-str, "\{\&v-telbank\}", v-telbank).
           next.
        end.

        if v-str matches "*\{\&ofc\}*" then do:
           v-str = replace (v-str, "\{\&ofc\}", v-ofcname).
           next.
        end.

        if v-str matches "*\{\&v-street\}*" then do:
           v-str = replace (v-str, "\{\&v-street\}", v-street).
           next.
        end.

        if v-str matches "*\{\&pass\}*" then do:
           v-str = replace (v-str, "\{\&pass\}", pass).
           next.
        end.

        if v-str matches "*\{\&v-iin\}*" then do:
           v-str = replace (v-str, "\{\&v-iin\}", v-iin).
           next.
        end.

        if v-str matches "*banknamefil*" then do:
           v-str = replace (v-str, "banknamefil", v-nbankfil).
           next.
        end.

        leave.
    end.

    put stream v-out unformatted v-str skip.
end.

input close.
output stream v-out close.

unix silent value("cptwin " + v-ofile + " iexplore").

