/* accr.i
 * MODULE
        Вставка кодов доходов - расходов
 * DESCRIPTION
        Вставка кодов доходов - расходов
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        trx-cods.p
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        29/09/05 nataly
 * CHANGES
        05/10/06 nataly поменяла алгоритм выбора департамента с ofc.titcd на getdep(cif.cif)
        24/04/2009 madiyar - подправил - везде blgr, а не lgr
*/

    find blgr where blgr.lgr = aaa.lgr no-lock no-error.
  if avail blgr then
    find first trxlevgl11 where  trxlevgl11.gl = blgr.gl and
               trxlevgl11.sub = "cif" and trxlevgl11.lev = 11 no-lock no-error.
   else
    find first trxlevgl11 where  trxlevgl11.gl = aaa.gl and
               trxlevgl11.sub = "cif" and trxlevgl11.lev = 11 no-lock no-error.
      if avail trxlevgl11 then accr.gl = trxlevgl11.glr.
      find cif where cif.cif = aaa.cif no-lock no-error.
        if avail cif then  v-dep = getdep(cif.cif).
        if v-dep = ""  then v-dep = '208'. /*Операционный департамент*/
         accr.dep = v-dep.
/*       if avail ofc and ofc.ofc <> 'сс' then do:
         find codfr where codfr.codfr = "sproftcn" and codfr.code = ofc.titcd no-lock  no-error.
          if avail codfr then accr.dep = codfr.name[4].
       end.   /
         else accr.dep = '208'.  */
