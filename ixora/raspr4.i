/* raspr4.i
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

v-infile = "/data/export/raspr4.htm".

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
    if v-str matches "*\{\&contract-number\}*" then do:
        v-str = replace (v-str, "\{\&contract-number\}", v-contr-num).
        next.
    end.
    if v-str matches "*\{\&lon-number\}*" then do:
        v-str = replace (v-str, "\{\&lon-number\}", loncon.lon).
        next.
    end.
    leave.
  end.

  put stream rep unformatted v-str skip.
end.
input close.
