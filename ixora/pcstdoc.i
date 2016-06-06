/* pcstdoc.i
 * MODULE
        Платежные карты
 * DESCRIPTION
        Документы для печати: заявление на выпуск карточки
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        16-1-2
 * AUTHOR
        07/06/2012 id00810
 * BASES
 		BANK COMM
 * CHANGES
        13/08/2012 id00810 - уточнение формата v-issdoc
        23/08/2012 id00810 - добавлено v-work для продукта Salary
        13.05.2013 Lyubov  - ТЗ № 1539, добавила обработку переменных для Заявлений и Согласия
        01.08.2013 Lyubov  - ТЗ 1941, в заявление подтягиеваем резидество из salary-файла
*/

output stream v-out to value(v-ofile) append .

input from value(v-infile).

repeat:
  	import unformatted v-str.
  	v-str = trim(v-str).

    repeat:

        if v-str matches "*v-rnn*" then do:
           v-str = replace (v-str, "v-rnn", v-rnn).
           next.
        end.

        if v-str matches "*v-iin*" then do:
           v-str = replace (v-str, "v-iin", v-iin).
           next.
        end.

        if v-str matches "*v-work*" then do:
           v-str = replace (v-str, "v-work", substr(v-work,1,50)).
           next.
        end.

        if v-str matches "*v-name*" then do:
           v-str = replace (v-str, "v-name", v-name).
           next.
        end.

        if v-str matches "*v-latname*" then do:
           v-str = replace (v-str, "v-latname", v-latname).
           next.
        end.

        if v-str matches "*v-mail*" then do:
           v-str = replace (v-str, "v-mail", v-mail).
           next.
        end.

        if v-str matches "*v-addr1*" then do:
           v-str = replace (v-str, "v-addr1", substr(v-addr1,1,50)).
           next.
        end.

        if v-str matches "*v-addr2*" then do:
           v-str = replace (v-str, "v-addr2", substr(v-addr2,1,50)).
           next.
        end.

        if v-str matches "*v-telh*" then do:
           v-str = replace (v-str, "v-telh", v-telh).
           next.
        end.

        if v-str matches "*v-telm*" then do:
           v-str = replace (v-str, "v-telm", v-telm).
           next.
        end.

        if v-str matches "*v-cword*" then do:
           v-str = replace (v-str, "v-cword", v-cword).
           next.
        end.

        if v-str matches "*v-nomdoc*" then do:
           v-str = replace (v-str, "v-nomdoc", v-nomdoc).
           next.
        end.

        if v-str matches "*v-issdoc*" then do:
           v-str = replace (v-str, "v-issdoc", substr(v-issdoc,1,25)).
           next.
        end.

        if v-str matches "*v-issdt*" then do:
           v-str = replace (v-str, "v-issdt", v-issdt).
           next.
        end.

        if v-str matches "*v-expdt*" then do:
           v-str = replace (v-str, "v-expdt", v-expdt).
           next.
        end.

        if v-str matches "*v-rezid*" then do:
           v-str = replace (v-str, "v-rezid", v-rezid).
           next.
        end.

        if v-str matches "*v-crcc*" then do:
           v-str = replace (v-str, "v-crcc", v-crcc).
           next.
        end.

        if v-str matches "*v-type*" then do:
           v-str = replace (v-str, "v-type", v-type).
           next.
        end.

        if v-str matches "*v-work*" then do:
           v-str = replace (v-str, "v-work", substr(v-work,1,50)).
           next.
        end.

        if v-str matches "*v-birthdt*" then do:
           v-str = replace (v-str, "v-birthdt", v-birthdt).
           next.
        end.

        if v-str matches "*v-birtplc*" then do:
           v-str = replace (v-str, "v-birtplc", v-birtplc).
           next.
        end.

        if v-str matches "*v-nomer*" then do:
           v-str = replace (v-str, "v-nomer", v-nomer).
           next.
        end.

        if v-str matches "*v-schet*" then do:
           v-str = replace (v-str, "v-schet", v-schet).
           next.
        end.
        leave.
    end.

    put stream v-out unformatted v-str skip.
end.

input close.
output stream v-out close.

