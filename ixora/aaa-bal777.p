/* aaa-bal777.p
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
        31/12/99 pragma
 * CHANGES
        05/10/2006 tsoy для DDA добавил vavl = aaa.cbal по умолчанию
        10/01/2012 lyubov - отменила свои изменения (создала аналогичный файл aaa-bal.p)
*/

def input parameter vaaa like aaa.aaa.
def output parameter vbal like jl.dam.
def output parameter vavl like jl.dam.
def output parameter vhbal like jl.dam.
def output parameter vfbal like jl.dam.
def output parameter vcrline like jl.dam.
def output parameter vcrlused like jl.dam.
def output parameter vooo like aaa.aaa.
def buffer baaa for aaa.

   vbal = 0.     /*Full balance*/
   vavl = 0.     /*Available balance*/
   vhbal = 0.    /*Hold balance*/
   vfbal = 0.    /*Float balance*/
   vcrline = 0.  /*Credit line*/
   vcrlused = 0. /*Used credit line*/
   vooo = "".

find aaa where aaa.aaa = vaaa no-lock.
find lgr where lgr.lgr = aaa.lgr no-lock.



if lgr.led = "DDA" then do:

/*
   vbal = aaa.cr[1] - aaa.dr[1].
   vhbal = aaa.hbal.
   vavl = aaa.cbal - vhbal.
   vfbal = vbal - aaa.cbal.
  find baaa where baaa.aaa = aaa.craccnt no-lock no-error.
  if available baaa then do:
   vooo = baaa.aaa.
   vbal = vbal + baaa.cbal.
   vavl = vavl + baaa.cbal.
   vcrlused = baaa.dr[1] - baaa.cr[1].
   vcrline = vcrlused + baaa.cbal.
  end.
*/

   vbal = aaa.cr[1] - aaa.dr[1].


/* 02/10/2006 tsoy для DDA добавил vavl = aaa.cbal по умолчанию */
   vavl = aaa.cbal.

   if aaa.hbal < 0 then do:
      vhbal = - aaa.hbal.
      run savelog ("hbal", aaa.aaa + " HBAL MINUS " + string (aaa.hbal)).
   end. else vhbal = aaa.hbal.

   vfbal = vbal - aaa.cbal.
  find baaa where baaa.aaa = aaa.craccnt no-lock no-error.
  if available baaa then do:
   vooo = baaa.aaa.
  /* vbal = vbal + baaa.cbal.  id00205  Показываем отрицательный остаток (без учета овера)*/


   vavl = aaa.cbal + baaa.cbal.
   vcrlused = baaa.dr[1] - baaa.cr[1] + aaa.dr[1] - aaa.cr[1].
   if vcrlused lt 0 then vcrlused = 0.
   vcrline = baaa.opnamt.
  end.
  vavl = vavl - vhbal.
end.
else if lgr.led = "ODA" then do:

   find baaa where baaa.aaa = aaa.craccnt no-lock no-error.
   if available baaa then vooo = baaa.aaa.
   vcrlused =  baaa.dr[1] - baaa.cr[1] + aaa.dr[1] - aaa.cr[1].
   vbal = - vcrlused.
   if vcrlused lt 0 then vcrlused = 0.
   vcrline = aaa.opnamt.

   if baaa.hbal < 0 then do:
      vavl = aaa.cbal + baaa.cbal + baaa.hbal.
      run savelog ("hbal", baaa.aaa + " HBAL MINUS " + string (baaa.hbal)).
   end. else vavl = aaa.cbal + baaa.cbal - baaa.hbal.

end.
else do:

   vbal = aaa.cr[1] - aaa.dr[1].

   if aaa.hbal < 0 then do:
      vhbal = - aaa.hbal.
      run savelog ("hbal", aaa.aaa + " HBAL MINUS " + string (aaa.hbal)).
   end. else vhbal = aaa.hbal.

   vavl = aaa.cbal - vhbal.
   vfbal = vbal - aaa.cbal.
end.



