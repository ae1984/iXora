/* pcstdoc.i
 * MODULE
        Новые клиенты и открытие счетов
 * DESCRIPTION
        Платежные карты: печать заявлений на отркрытие счета и выпуск корпоративной ПК
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        cif-pcul.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        1.2, верхнее меню Пкарты
 * AUTHOR
        17.05.2013 Lyubov
 * BASES
 		BANK COMM
 * CHANGES
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

        if v-str matches "*v-namecif*" then do:
           v-str = replace (v-str, "v-namecif", v-namecif).
           next.
        end.

        if v-str matches "*v-name1*" then do:
           v-str = replace (v-str, "v-name1", v-name1).
           next.
        end.

        if v-str matches "*v-name2*" then do:
           v-str = replace (v-str, "v-name2", v-name2).
           next.
        end.

        if v-str matches "*v-birthdt*" then do:
           v-str = replace (v-str, "v-birthdt", v-birthdt).
           next.
        end.

        if v-str matches "*v-latname*" then do:
           v-str = replace (v-str, "v-latname", v-latname).
           next.
        end.

        if v-str matches "*v-mailcif*" then do:
           v-str = replace (v-str, "v-mailcif", v-mailcif).
           next.
        end.

        if v-str matches "*v-mail*" then do:
           v-str = replace (v-str, "v-mail", v-mail).
           next.
        end.

        if v-str matches "*v-addrcif[1]*" then do:
           v-str = replace (v-str, "v-addrcif[1]", substr(v-addrcif[1],1,100)).
           next.
        end.

        if v-str matches "*v-addrcif[2]*" then do:
           v-str = replace (v-str, "v-addrcif[2]", substr(v-addrcif[2],1,100)).
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

        if v-str matches "*v-telcif[1]*" then do:
           v-str = replace (v-str, "v-telcif[1]", v-telcif[1]).
           next.
        end.

        if v-str matches "*v-telcif[2]*" then do:
           v-str = replace (v-str, "v-telcif[2]", v-telcif[2]).
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

        if v-str matches "*v-crcc*" then do:
           v-str = replace (v-str, "v-crcc", v-crcc).
           next.
        end.

        /*if v-str matches "*v-type*" then do:
           v-str = replace (v-str, "v-type", v-type).
           next.
        end.*/

        if v-str matches "*v1*" then do:
           if v-limitn then v-str = replace (v-str, "v1", '').
           else v-str = replace (v-str, "v1", "V").
           next.
        end.

        if v-str matches "*v2*" then do:
           if v-limitn then v-str = replace (v-str, "v2","V").
           else v-str = replace (v-str, "v2", '').
           next.
        end.

        if v-str matches "*v-sumns*" then do:
           if v-sumns >0 then v-str = replace (v-str, "v-sumns", string(v-sumns,'>>>>>9.99')).
           else v-str = replace (v-str, "v-sumns", '').
           next.
        end.

        if v-str matches "*v-sumnm*" then do:
           if v-sumnm >0 then v-str = replace (v-str, "v-sumnm", string(v-sumnm,'>>>>>>>>9.99')).
           else v-str = replace (v-str, "v-sumnm", '' ).
           next.
        end.

        if v-str matches "*v3*" then do:
           if v-limitp then v-str = replace (v-str, "v3", '').
           else v-str = replace (v-str, "v3", "V").
           next.
        end.

        if v-str matches "*v4*" then do:
           if v-limitp then v-str = replace (v-str, "v4","V").
           else v-str = replace (v-str, "v4", '').
           next.
        end.

        if v-str matches "*v-sumps*" then do:
           if v-sumps >0 then v-str = replace (v-str, "v-sumps", string(v-sumps,'>>>>>9.99')).
           else v-str = replace (v-str, "v-sumps",'').
           next.
        end.

        if v-str matches "*v-sumpm*" then do:
           if v-sumpm >0 then v-str = replace (v-str, "v-sumpm", string(v-sumpm,'>>>>>>>>9.99')).
           else v-str = replace (v-str, "v-sumpm",'').
           next.
        end.

        if v-str matches "*v5*" then do:
           if v-internet then v-str = replace (v-str, "v5", '').
           else v-str = replace (v-str, "v5", "V").
           next.
        end.

        if v-str matches "*v6*" then do:
           if v-internet then v-str = replace (v-str, "v6","V").
           else v-str = replace (v-str, "v6", '').
           next.
        end.

        if v-str matches "*v7*" then do:
           if v-sms then v-str = replace (v-str, "v7", '').
           else v-str = replace (v-str, "v7", "V").
           next.
        end.

        if v-str matches "*v8*" then do:
           if v-sms then v-str = replace (v-str, "v8","V").
           else v-str = replace (v-str, "v8", '').
           next.
        end.

        if v-str matches "*v9*" then do:
           if v-rezcif then v-str = replace (v-str, "v9","V").
           else v-str = replace (v-str, "v9", '').
           next.
        end.

        if v-str matches "*v10*" then do:
           if v-rezcif then v-str = replace (v-str, "v10","").
           else v-str = replace (v-str, "v10", '').
           next.
        end.

        if v-str matches "*v-countrycif*" then do:
           if v-rezcif then v-str = replace (v-str, "v-countrycif","v-").
           else v-str = replace (v-str, "v10", '').
           next.
        end.

        if v-str matches "*v-fiochf*" then do:
           v-str = replace (v-str, "v-fiochf", v-fiochf).
           next.
        end.

        if v-str matches "*v-fiobk*" then do:
           v-str = replace (v-str, "v-fiobk", v-fiobk).
           next.
        end.

        if v-str matches "*v-ecdivis1*" then do:
           v-str = replace (v-str, "v-ecdivis1", substr(v-ecdivis,1,30)).
           next.
        end.
        if v-str matches "*v-ecdivis2*" then do:
           v-str = replace (v-str, "v-ecdivis2", substr(v-ecdivis,31,80)).
           next.
        end.
        leave.
    end.

    put stream v-out unformatted v-str skip.
end.

input close.
output stream v-out close.

