/* bal-txb.p
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
        COMM TXB
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        05/10/2006 tsoy для DDA добавил vavl = aaa.cbal по умолчанию
*/

def input  parameter vaaa     like txb.aaa.aaa.  /*Номер счета */
def output parameter vbal     like txb.jl.dam.   /*Остаток*/
def output parameter vavl     like txb.jl.dam.   /*Доступный остаток*/
def output parameter vhbal    like txb.jl.dam.   /*Заморож. средства*/
def output parameter vfbal    like txb.jl.dam.   /*Задержанные средства*/
def output parameter vcrline  like txb.jl.dam.   /*Откр.кредитная лин.*/
def output parameter vcrlused like txb.jl.dam.   /*Использ.кред. линия*/


def output parameter vooo     like txb.aaa.aaa.  /*Номер овердрафтного счета*/


def buffer baaa for txb.aaa.
def buffer taaa for txb.aaa.
def buffer blgr for txb.lgr.

   vbal = 0.     /*Full balance*/
   vavl = 0.     /*Available balance*/
   vhbal = 0.    /*Hold balance*/
   vfbal = 0.    /*Float balance*/
   vcrline = 0.  /*Credit line*/
   vcrlused = 0. /*Used credit line*/
   vooo = "".

find taaa where taaa.aaa = vaaa no-lock.
find blgr where blgr.lgr = taaa.lgr no-lock.

if blgr.led = "DDA" then do:
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

   vbal = taaa.cr[1] - taaa.dr[1].


/* 02/10/2006 tsoy для DDA добавил vavl = aaa.cbal по умолчанию */
   vavl = taaa.cbal.

   if taaa.hbal < 0 then do:
      vhbal = - taaa.hbal.
      run savelog ("hbal", taaa.aaa + " HBAL MINUS " + string (taaa.hbal)).
   end. else vhbal = taaa.hbal.

   vfbal = vbal - taaa.cbal.
  find baaa where baaa.aaa = taaa.craccnt no-lock no-error.
  if available baaa then do:
   vooo = baaa.aaa.
   /* vbal = vbal + baaa.cbal.  id00205  Показываем отрицательный остаток (без учета овера)*/

   vavl = taaa.cbal + baaa.cbal.
   vcrlused = baaa.dr[1] - baaa.cr[1] + taaa.dr[1] - taaa.cr[1].
   if vcrlused lt 0 then vcrlused = 0.
   vcrline = baaa.opnamt.
  end.
  vavl = vavl - vhbal.
end.
else if blgr.led = "ODA" then do:
   find baaa where baaa.aaa = taaa.craccnt no-lock no-error.
   if available baaa then vooo = baaa.aaa.
   vcrlused =  baaa.dr[1] - baaa.cr[1] + taaa.dr[1] - taaa.cr[1].
   vbal = - vcrlused.
   if vcrlused lt 0 then vcrlused = 0.
   vcrline = taaa.opnamt.

   if baaa.hbal < 0 then do:
      vavl = taaa.cbal + baaa.cbal + baaa.hbal.
      run savelog ("hbal", baaa.aaa + " HBAL MINUS " + string (baaa.hbal)).
   end. else vavl = taaa.cbal + baaa.cbal - baaa.hbal.

end.
else do:
   vbal = taaa.cr[1] - taaa.dr[1].

   if taaa.hbal < 0 then do:
      vhbal = - taaa.hbal.
      run savelog ("hbal", taaa.aaa + " HBAL MINUS " + string (taaa.hbal)).
   end. else vhbal = taaa.hbal.

   vavl = taaa.cbal - vhbal.
   vfbal = vbal - taaa.cbal.
end.



