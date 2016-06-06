/* raspr2_garan.i
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
        14/06/2013 yerganat
 * CHANGES
*/

def var v-infile as char init "/data/export/raspr2_garan.htm".
def var v-str as char.

input from value(v-infile).
repeat:
  import unformatted v-str.
  v-str = trim(v-str).
  repeat:
    if v-str matches "*\{\&city\}*" then do:
        v-str = replace (v-str, "\{\&city\}", v-city2).
        next.
    end.
    if v-str matches "*\{\&number-contract\}*" then do:
        v-str = replace (v-str, "\{\&number-contract\}", num_dog).
        next.
    end.
    if v-str matches "*\{\&today\}*" then do:
        v-str = replace (v-str, "\{\&today\}", v-rep-date).
        next.
    end.
    if v-str matches "*\{\&borrow-name\}*" then do:
        v-str = replace (v-str, "\{\&borrow-name\}", trim(cif.prefix + " " + cif.name)).
        next.
    end.
    if v-str matches "*\{\&bin\}*" then do:
        v-str = replace (v-str, "\{\&bin\}", cif.bin).
        next.
    end.
    if v-str matches "*\{\&fin-type\}*" then do:
        v-str = replace (v-str, "\{\&fin-type\}", "Гарантия").
        next.
    end.
    if v-str matches "*\{\&contract-number\}*" then do:
        v-str = replace (v-str, "\{\&contract-number\}",  num_dog + " от " + string(garan.dtfrom, "99/99/9999")).
        next.
    end.
    if v-str matches "*\{\&lon-sum\}*" then do:
        v-str = replace (v-str, "\{\&lon-sum\}", replace(replace(string(garan.sumtreb, ">>>,>>>,>>>,>>9.99"),","," "),".",",") + " " + v-crc).
        next.
    end.
    if v-str matches "*\{\&lon-date\}*" then do:
        v-str = replace (v-str, "\{\&lon-date\}", "по " + v-date + " ").
        next.
    end.
    if v-str matches "*\{\&garan-type\}*" then do:
        v-str = replace (v-str, "\{\&garan-type\}", ListType[garan.gtype]).
        next.
    end.
    if v-str matches "*\{\&sum_commis\}*" then do:
        v-str = replace (v-str, "\{\&sum_commis\}",  replace(replace(string(garan.sumkom, ">>>,>>>,>>>,>>9.99"),","," "),".",",") + " " + v-crc2 ).
        next.
    end.
    if v-str matches "*\{\&borrow_sum_money\}*" then do:
        v-str = replace (v-str, "\{\&borrow_sum_money\}", replace(replace(string(garan.sum, ">>>,>>>,>>>,>>9.99"),","," "),".",",") ).
        next.
    end.
    if v-str matches "*\{\&borrow_sum\}*" then do:
        v-str = replace (v-str, "\{\&borrow_sum\}", replace(replace(string(garan.sumzalog, ">>>,>>>,>>>,>>9.99"),","," "),".",",") ).
        next.
    end.
    leave.
  end.

  put stream rep unformatted v-str skip.
end.
input close.
