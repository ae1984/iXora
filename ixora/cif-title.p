/* cif-title.p
 * MODULE
        Платежные карты
 * DESCRIPTION
        Печать титульного листа "дела" клиента
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT

 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        03/07/128 id00810
 * BASES
 		BANK
 * CHANGES
*/

{global.i}

def shared var s-cif like cif.cif.
def shared var s-aaa like aaa.aaa.
def var v-infile as char no-undo init "/data/docs/titlelist.htm".
def var v-ofile  as char no-undo init "title.htm".
def var v-str    as char no-undo.
def stream v-out.

find first cif where cif.cif = s-cif no-lock no-error.
if not avail cif then return.

find first aaa where aaa.aaa = s-aaa no-lock no-error.
if not avail aaa then return.

output stream v-out to value(v-ofile) append .

input from value(v-infile).

repeat:
  	import unformatted v-str.
  	v-str = trim(v-str).

    repeat:

        if v-str matches "*v-cif*" then do:
           v-str = replace (v-str, "v-cif", cif.cif).
           next.
        end.

        if v-str matches "*v-name*" then do:
           v-str = replace (v-str, "v-name", cif.name).
           next.
        end.

        if v-str matches "*v-aaa*" then do:
           v-str = replace (v-str, "v-aaa", aaa.aaa).
           next.
        end.

        if v-str matches "*v-dt*" then do:
           v-str = replace (v-str, "v-dt", string(g-today,'99/99/9999')).
           next.
        end.

        if v-str matches "*v-city*" then do:
           find first sysc where sysc.sysc = 'citi' no-lock no-error.
           if avail sysc then v-str = replace (v-str, "v-city", "г." + sysc.chval).
           else v-str = replace (v-str, "v-city", "" ).
           next.
        end.

        if v-str matches "*v-year*" then do:
           v-str = replace (v-str, "v-year", string(year(g-today))).
           next.
        end.

        leave.
    end.

    put stream v-out unformatted v-str skip.
end.

input close.
output stream v-out close.
unix silent value("cptwin " + v-ofile + " winword").
unix silent value("rm -f " + v-ofile).
