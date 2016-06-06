﻿/* vcdnglg.p
 * MODULE
        Валютный контроль/Клиенты и контракты
 * DESCRIPTION
        Данные долгов по контракту
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Меню Долги
 * AUTHOR
        21/06/04 saltanat
 * CHANGES
11.03.2011 damir - перекомпиляция в связи с добавлением нового поля opertyp
*/

def new shared var s-vcdoctypes as char init "".
def new shared var s-dnvid as char init "".

for each codfr where codfr.codfr = "vcdoc" break by codfr.name[5]:
  if first-of(codfr.name[5]) then do:
     s-dnvid = s-dnvid + codfr.name[5] + ",".
  end.
end.

for each codfr where codfr.codfr = "vcdoc":
  s-vcdoctypes = s-vcdoctypes + codfr.code + ",".
end.

run vcdndlgs.