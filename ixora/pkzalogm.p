/* pkzalogm.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Печать заявления о материальном залоге
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
        25/03/07 marinav
 * CHANGES
        27/04/2007 madiyar - web-анкета
        30/04/08 marinav - добавила назв филиала и должность
        12/06/2008 madiyar - назв филиала и должность из dkkomu
*/


{global.i}
{pk.i}


if s-pkankln = 0 then return.

find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and
     pkanketa.ln = s-pkankln no-lock no-error.

if not avail pkanketa then return.


def stream v-out.
def var v-ofile as char.
def var v-ifile as char.
def var v-infile as char.
def var v-str as char.
def var v-name as char.
def var i as integer.
def var v-param as logical.
def var docnum as char.
def var docdt as char.
def new shared var v-adres as char extent 2.
def var v-adresd as char no-undo extent 2.

{sysc.i}
{pk-sysc.i}
def new shared var v-bankname as char.
def new shared var v-bankface as char.
def new shared var v-dol as char.

find first cmp no-lock no-error.
if avail cmp then  v-bankname = cmp.name.

find bookcod where bookcod.bookcod = "credtype" and bookcod.code = s-credtype no-lock no-error.
v-bankface = entry(2, get-sysc-cha (bookcod.info[1] + "komu")).
v-dol = entry(1, get-sysc-cha (bookcod.info[1] + "komu")).

/* номер и дата  */

v-name = pkanketa.name.

find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and
     pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "numpas" no-lock no-error.
docnum =  pkanketh.value1.

find pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and
     pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "dtpas" no-lock no-error.
if avail pkanketh then do:
  if index(pkanketh.value1,"/") > 0 then docdt = pkanketh.value1.
  else docdt = string(pkanketh.value1, "99/99/9999").
end.

run pkdefadres (pkanketa.ln, no, output v-adres[1], output v-adres[2], output v-adresd[1], output v-adresd[2]).

/* печать заявления */

v-ofile = "zalog.htm".
v-infile = "zalog_m.htm".
output stream v-out to value(v-ofile).


v-ifile = get-pksysc-char ("dcdocs").
if not v-ifile begins "/" then v-ifile = "/" + v-ifile.
if substr (v-ifile, length(v-ifile), 1) <> "/" then v-ifile = v-ifile + "/".
v-ifile = v-ifile + v-infile.

input from value(v-ifile).
repeat:
  import unformatted v-str.
  v-str = trim(v-str).

  /* заменить параметры на данные клиента */
  repeat:
    if v-str matches "*\{\&v-dol\}*" then do:
        v-str = replace (v-str, "\{\&v-dol\}", v-dol).
        next.
    end.
    if v-str matches "*\{\&v-bankname\}*" then do:
        v-str = replace (v-str, "\{\&v-bankname\}", v-bankname).
        next.
    end.
    if v-str matches "*\{\&v-bankface\}*" then do:
        v-str = replace (v-str, "\{\&v-bankface\}", v-bankface).
        next.
    end.
    if v-str matches "*\{\&addr\}*" then do:
        v-str = replace (v-str, "\{\&addr\}", v-adres[1]).
        next.
    end.
    if v-str matches "*\{\&docnum\}*" then do:
        v-str = replace (v-str, "\{\&docnum\}", docnum).
        next.
    end.
    if v-str matches "*\{\&docdt\}*" then do:
        v-str = replace (v-str, "\{\&docdt\}", docdt).
        next.
    end.
    
    if v-str matches "*\{\&vname\}*" then do:
        v-str = replace (v-str, "\{\&vname\}", "<u>&nbsp;" + v-name + "&nbsp;</u>").
        next.
    end.
    
    leave.
  end.

  put stream v-out unformatted v-str skip.
end.

input close.

{html-end.i "stream v-out"}

output stream v-out close.

if pkanketa.id_org = "inet" then unix silent value("mv " + v-ofile + " /var/www/html/docs/" + s-credtype + "/" + string(s-pkankln) + "; chmod 666 /var/www/html/docs/" + s-credtype + "/" + string(s-pkankln) + "/" + v-ofile).
else unix silent cptwin value(v-ofile) iexplore.
