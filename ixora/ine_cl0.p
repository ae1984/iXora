/* ine_cl0.p
 * MODULE
        IO
 * DESCRIPTION
        Обнуление пароля 
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
 * BASES
        BANK COMM IB
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

{getdep.i}

def var v-s as char.
output to inetrep_cl.csv.

put unformatted "Пользователи не работающие по еТокен, активность 90 дней " skip.

for each usr where authptype <> 'otp' no-lock.

if usr.cif  begins "T" then do:

   find first aaa where aaa.cif = usr.cif and aaa.sta <> "C" no-lock no-error.
   if not avail aaa then next.

end.


    find  last ib.hist where ib.hist.wdate > today - 90
        and ib.hist.wdate <= today
        and ib.hist.id_usr = usr.id
        and ib.hist.type1 = 1
        and ib.hist.type2 = 1
    no-lock no-error.

    if not avail ib.hist then
       next.

    if usr.cif  begins "T" then do:
             v-s = getdep (usr.cif).
             find ppoint where ppoint.tel1 = v-s no-lock no-error.

             find cif where cif.cif = usr.cif no-lock no-error.
               put unformatted if avail ppoint then ppoint.name else ""  ";"  usr.cif ";" usr.id ";" if avail cif then
               cif.name else "" skip.
    end.  else                     do:
             find cif where cif.cif = usr.cif no-lock no-error.
               put unformatted "Филиал"  ";"  usr.cif ";" usr.id ";" if avail cif then
               cif.name else "" skip.

   end.


end.
output close.

unix silent value("cptwin inetrep_cl.csv excel").
