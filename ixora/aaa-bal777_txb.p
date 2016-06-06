/* aaa-bal777_txb.p
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
 * BASES
        BANK COMM TXB
 * AUTHOR
        11/10/2012 Luiza  - файл создан по подобию aaa-bal777.p только для межфил
 * CHANGES
*/

def input parameter vaaa like txb.aaa.aaa.
def output parameter vbal like txb.jl.dam.
def output parameter vavl like txb.jl.dam.
def output parameter vhbal like txb.jl.dam.
def output parameter vfbal like txb.jl.dam.
def output parameter vcrline like txb.jl.dam.
def output parameter vcrlused like txb.jl.dam.
def output parameter vooo like txb.aaa.aaa.
def buffer baaa for txb.aaa.

   vbal = 0.     /*Full balance*/
   vavl = 0.     /*Available balance*/
   vhbal = 0.    /*Hold balance*/
   vfbal = 0.    /*Float balance*/
   vcrline = 0.  /*Credit line*/
   vcrlused = 0. /*Used credit line*/
   vooo = "".

find txb.aaa where txb.aaa.aaa = vaaa no-lock.
find txb.lgr where txb.lgr.lgr = txb.aaa.lgr no-lock.



if txb.lgr.led = "DDA" then do:


   vbal = txb.aaa.cr[1] - txb.aaa.dr[1].


/* 02/10/2006 tsoy для DDA добавил vavl = txb.aaa.cbal по умолчанию */
   vavl = txb.aaa.cbal.

   if txb.aaa.hbal < 0 then do:
      vhbal = - txb.aaa.hbal.
      run savelog ("hbal", txb.aaa.aaa + " HBAL MINUS " + string (txb.aaa.hbal)).
   end. else vhbal = txb.aaa.hbal.

   vfbal = vbal - txb.aaa.cbal.
  find baaa where baaa.aaa = txb.aaa.craccnt no-lock no-error.
  if available baaa then do:
   vooo = baaa.aaa.
  /* vbal = vbal + baaa.cbal.  id00205  Показываем отрицательный остаток (без учета овера)*/


   vavl = txb.aaa.cbal + baaa.cbal.
   vcrlused = baaa.dr[1] - baaa.cr[1] + txb.aaa.dr[1] - txb.aaa.cr[1].
   if vcrlused lt 0 then vcrlused = 0.
   vcrline = baaa.opnamt.
  end.
  vavl = vavl - vhbal.
end.
else if txb.lgr.led = "ODA" then do:

   find baaa where baaa.aaa = txb.aaa.craccnt no-lock no-error.
   if available baaa then vooo = baaa.aaa.
   vcrlused =  baaa.dr[1] - baaa.cr[1] + txb.aaa.dr[1] - txb.aaa.cr[1].
   vbal = - vcrlused.
   if vcrlused lt 0 then vcrlused = 0.
   vcrline = txb.aaa.opnamt.

   if baaa.hbal < 0 then do:
      vavl = txb.aaa.cbal + baaa.cbal + baaa.hbal.
      run savelog ("hbal", baaa.aaa + " HBAL MINUS " + string (baaa.hbal)).
   end. else vavl = txb.aaa.cbal + baaa.cbal - baaa.hbal.

end.
else do:

   vbal = txb.aaa.cr[1] - txb.aaa.dr[1].

   if txb.aaa.hbal < 0 then do:
      vhbal = - txb.aaa.hbal.
      run savelog ("hbal", txb.aaa.aaa + " HBAL MINUS " + string (txb.aaa.hbal)).
   end. else vhbal = txb.aaa.hbal.

   vavl = txb.aaa.cbal - vhbal.
   vfbal = vbal - txb.aaa.cbal.
end.



