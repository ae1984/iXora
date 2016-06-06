/* pkrefpog.p
 * MODULE
        Потребкредиты
 * DESCRIPTION
        Печать заявления на досрочное погашение рефинансируемого кредита
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
        12/05/2006 madiyar
 * CHANGES
        18/05/2006 madiyar - не находилась анкета
        08/09/2006 madiyar - общие договора в /data/docs/
        06/01/08 marinav - исправлен путь к базам с /data/9/ на  /data/
*/


def input parameter v-lon as char no-undo.

def stream v-out.
def var v-ofile as char no-undo.
def var v-infile as char no-undo.
def var v-str as char no-undo.

{global.i}
{pk.i}

if s-pkankln = 0 then return.

find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and
     pkanketa.ln = s-pkankln no-lock no-error.
if not avail pkanketa then return.

def shared var v-name as char.
def shared var v-docnum as char.
def shared var v-docdt as char. /* дата выдачи документа */
def shared var v-datastr as char. /* дата формирования договоров */

def var v-dog as char no-undo.
def var v-dogdt as char no-undo.
find first loncon where loncon.lon = v-lon no-lock no-error.
if avail loncon then v-dog = loncon.lcnt.
find first lon where lon.lon = v-lon no-lock no-error.
if avail lon then v-dogdt = string(lon.rdt, "99/99/9999").


find first pksysc where pksysc.credtype = '6' and pksysc.sysc = "dcdocs" no-lock no-error.
v-ofile = "refpog.htm".
if avail pksysc then  v-ofile = pksysc.chval + v-ofile.
v-infile = "refpog.htm".
output stream v-out to value(v-infile).
run upd_field.
output stream v-out close.
unix silent value("cptwin " + v-infile + " iexplore").


procedure upd_field.

input from value(v-ofile).
repeat:
  import unformatted v-str.
  v-str = trim(v-str).

  repeat:
    if v-str matches "*\{\&docnum\}*" then do:
        v-str = replace (v-str, "\{\&docnum\}", v-docnum).
        next.
    end.
    if v-str matches "*\{\&docnumdt\}*" then do:
        v-str = replace (v-str, "\{\&docnumdt\}", string(v-docdt)).
        next.
    end.
    if v-str matches "*\{\&vname\}*" then do:
        v-str = replace (v-str, "\{\&vname\}", v-name).
        next.
    end.
    if v-str matches "*\{\&vdog\}*" then do:
        v-str = replace (v-str, "\{\&vdog\}", v-dog).
        next.
    end.
    if v-str matches "*\{\&vcif\}*" then do:
        v-str = replace (v-str, "\{\&vcif\}", pkanketa.cif).
        next.
    end.
    if v-str matches "*\{\&vdogdt\}*" then do:
        v-str = replace (v-str, "\{\&vdogdt\}", v-dogdt).
        next.
    end.
    if v-str matches "*\{\&vdat\}*" then do:
        v-str = replace (v-str, "\{\&vdat\}", v-datastr).
        next.
    end.
    
    leave.
  end.

  put stream v-out unformatted v-str skip.
end.
input close.
output stream v-out close.

end. /* procedure */

