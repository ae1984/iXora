/* upd-dep.i
 * MODULE
        Доходы-расходы
 * DESCRIPTION
        Раскидка по профит-центрам
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        06/06/2006 nataly
 * BASES
        bank
 * CHANGES
        14/06/2006 madiyar - добавил 5й класс
*/

    for each bjl where  bjl.jh = s-jh and (string(bjl.gl) begins '4' or string(bjl.gl) begins '5') no-lock.
     find last trxcods where trxcods.trxh = s-jh and trxcods.trxln = bjl.ln and  trxcods.codfr = 'cods' no-error. 
     if not avail trxcods then next.
       v-code = substr(trxcods.code,1,7).
      find cif where cif.cif = aaa.cif no-lock no-error.
     if avail cif then  v-dep = getdep(cif.cif).
     if v-dep <> ""  then  trxcods.code = v-code + v-dep.
   end.
   