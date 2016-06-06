/* tdaaabhist.p
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
       05/11/03 nataly программа по отображению начисленных %% по МБД
                       для счетов ГК 1-го класса
*/

def input parameter vfun like fun.fun.
def shared var g-lang as char.
def shared var g-today as date.
def var vbal as decimal.
def var v-day as integer.

def temp-table temp like hisfun.
def var v-dat as date.
def var v-dam as decimal.
def var v-cam as decimal.

for each temp. delete temp. end.
def buffer bhisfun for hisfun.
def var lbl1 as char.
def var lbl2 as char.

for each hisfun where hisfun.fun = vfun.
   create temp.
   buffer-copy hisfun to temp.
   find first bhisfun where bhisfun.fun = hisfun.fun and bhisfun.fdt > hisfun.fdt no-lock no-error.
   if avail bhisfun then  temp.duedt = bhisfun.fdt.
   else temp.duedt = g-today .
  temp.rdt = hisfun.fdt.
end.  

find fun no-lock where fun.fun = vfun no-error.
find trxlevgl  no-lock where trxlevgl.gl = fun.gl  and sub = 'fun' and lev = 2 use-index glsublev  no-error.

for each temp.
  v-dam = 0. v-cam = 0.
 do v-dat = temp.rdt to  temp.duedt - 1. 
  for each jl where jl.acc = temp.fun and jl.jdt = v-dat.
     if jl.gl <> trxlevgl.glr then next.
     v-dam  = v-dam + jl.dam.
     v-cam  = v-cam + jl.cam.
  end.
 end.
  temp.dam[2] = v-dam. temp.cam[2] = v-cam.
end.

{jabro.i
&start = " "
&head = "temp"
&headkey = "fun"
&where = "temp.fun = vfun"
&index = "hisfun"
&formname = "histfunA"
&framename = "aab"
&addcon = "false"
&deletecon = "false"
&viewframe = " "
&predisplay = " vbal = temp.dam[1] - temp.cam[1]. 
                if vbal < 0 then lbl1 =   'Погашен %' . else lbl1 = 'Начисл % '.
                if vbal > 0 then lbl2 =   'Начисл % ' . else lbl2 = 'Погашен %' .
                if vbal < 0 then vbal = - vbal.
                v-day = temp.duedt - temp.rdt.  "
&display = " vbal format 'z,zzz,zzz,zz9.99' temp.rdt temp.duedt  v-day format 'zz9' 
             temp.rate format 'zz9.99'    
             temp.dam[2] format 'zzzzzz9.99'   
             temp.cam[2] format 'zzzzzz9.99'   "
&highlight = "vbal"
&predelete = " "
&precreate = " "
&postadd = " "
&prechoose = " "
&postdelete = " "
&postkey = " "
&end = "hide frame aab. hide message."
}

