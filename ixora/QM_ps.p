/* QM_ps.p
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
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
*/

def var i as int .
def var v-sts as cha . 
{lgps.i}

def temp-table sts field pid like que.pid
  field nw as int initial ? field np as int field nf as int
  field nwt as int field npt as int field nft as int
  field nwtn as int field nptn as int field nftn as int.
def var ifi as int.
def var swt as cha .
def var spt as cha .
def var sft as cha .

find sysc where sysc.sysc = "ps-cls" no-lock no-error .
if not avail sysc then 
 return .

find first que  
 use-index fprc no-lock no-error .
 v-sts = string(today) + "#" + string(time,"hh:mm:ss") + "#". 
if  avail que  then do: 
repeat : 
 if que.pid = "ARC" then
  do:
    find last  que where que.pid = "ARC"  use-index fprc no-lock .
    find next que  use-index fprc no-lock no-error.
    if not avail que then leave .
  end .

  if que.pid = "F" then
    do:
        find last  que where que.pid = "F"  use-index fprc no-lock .
        find next que  use-index fprc no-lock no-error.
        if not avail que then leave .
    end .

 find first sts where que.pid eq sts.pid no-error.
 if not avail sts then do:
  create sts.
  sts.pid = que.pid .
  sts.nw = 0 . sts.np = 0. sts.nf = 0.
  sts.nwt = 0 . sts.npt = 0. sts.nft = 0.
  sts.nwtn = 0 . sts.nptn = 0. sts.nftn = 0.
 end.
 if que.con = "W" then
   do : sts.nw = sts.nw + 1.
        sts.nwtn = sts.nwtn + 1 .
        sts.nwt = time - que.tf + sts.nwt .
   end.
 else
 if que.con = "F" then
   do : sts.nf = sts.nf + 1.
        sts.nftn = sts.nftn + 1.
        sts.nft = time - que.tp + sts.nft .
   end.
 find next que  use-index fprc no-lock no-error .
 if not avail que then leave .
end.

for each sts no-lock break by sts.pid  .
 if sts.nw eq 0 and sts.np eq 0 and sts.nf eq 0 then delete sts . 
 else
 do:
 if sts.nw ne 0 then swt = string(int(sts.nwt / sts.nw ),"hh:mm:ss").
                else swt = "  ----  ".
 if sts.nf ne 0 then sft = string(int(sts.nft / sts.nf ),"hh:mm:ss").
                else sft = "  ----  ".
  v-sts = v-sts + string(sts.pid,"x(3)") + string(sts.nw, "zzzzzz9") + "  " +
   swt + "  " + string(sts.nf,"zzzzzz9") + "  " + sft + "#".
  end.
 end.
end.
 do transact:
  find first sysc where sysc.sysc = "ps-cls" exclusive-lock .
   sysc.stc = v-sts .
   release sysc.
 end.
