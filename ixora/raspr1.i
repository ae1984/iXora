/* raspr1.i
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

v-infile="/data/export/raspr1.htm".

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
        v-str = replace (v-str, "\{\&number-contract\}", v-lon-cntr).
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
        v-str = replace (v-str, "\{\&fin-type\}", v-prnmos).
        next.
    end.
    if v-str matches "*\{\&contract-number\}*" then do:
        v-str = replace (v-str, "\{\&contract-number\}", v-contr-num).
        next.
    end.
    if v-str matches "*\{\&lon-number\}*" then do:
        v-str = replace (v-str, "\{\&lon-number\}", loncon.lon).
        next.
    end.
    if v-str matches "*\{\&balance\}*" then do:
        v-str = replace (v-str, "\{\&balance\}",  v-balance).
        next.
    end.
    if v-str matches "*\{\&lon-sum\}*" then do:
        v-str = replace (v-str, "\{\&lon-sum\}", v-lon-sum).
        next.
    end.
    if v-str matches "*\{\&lon-date\}*" then do:
        v-str = replace (v-str, "\{\&lon-date\}", v-lon-date).
        next.
    end.
    if v-str matches "*\{\&lon-rate\}*" then do:
        v-str = replace (v-str, "\{\&lon-rate\}", string(lon.prem) + " %").
        next.
    end.
    if v-str matches "*\{\&purpose\}*" then do:
        v-str = replace (v-str, "\{\&purpose\}", loncon.objekts).
        next.
    end.
    if v-str matches "*\{\&schedule\}*" then do:
        v-str = replace (v-str, "\{\&schedule\}", v-lon-plan).
        next.
    end.
    leave.
  end.

  put stream rep unformatted v-str skip.
end.
input close.
