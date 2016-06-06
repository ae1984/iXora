/* aicalcs.p
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
*/

def input parameter v-aaa like aaa.aaa.
def input parameter v-d as date.
def input parameter vbal as dec.
def output parameter v-intsum like glbal.bal.
def var v-accrued like aaa.accrued.
def var v-pri like prih.pri.
def var v-tmpbal like aab.bal.
def var v-itype like prih.itype.
def var intrat like lgr.rate.
def var v-inc as int.
def var v-max as dec.
def var v-min as dec.
def var v-intbal as dec.
def var v-cla as char.



v-intsum = 0.

find aaa where aaa.aaa eq v-aaa no-lock no-error.
if not available aaa then return.

find lgr where lgr.lgr eq aaa.lgr no-lock no-error.
if available lgr then do:
if lgr.intcal eq "n" then return.

    v-pri = lgr.pri.
   if  not (aaa.lgr begins 'd') then 
   do: 
    find last prih where prih.pri eq lgr.pri and prih.until le v-d no-lock     no-error.
    if not available prih then return. 
   end.
   else do:
    if length(string(aaa.cla)) = 1 then v-cla = '0' + string(aaa.cla).
    else v-cla = string(aaa.cla).
    find last prih where substring(prih.pri,2,1) = lgr.pri  
     and prih.until le v-d and 
    ( substring(prih.pri,3,2) = v-cla  or substring(prih.pri,3,2) = '99') no-lock  no-error.
    if not available prih then  return. 
   end.
    v-itype = prih.itype.

    if lgr.lookaaa eq false
    then do:
        if v-pri ne "F" then do:
            if v-itype eq 1 then intrat = prih.rat + lgr.rate.
        end.
        else intrat = lgr.rate.
    end.

    if lgr.lookaaa eq true
    then do:
        if v-pri ne "F" then do:
            if prih.itype eq 1 then intrat = prih.rat + aaa.rate.
        end.
        else intrat = aaa.rate.
    end.
    if  v-pri ne "F" and v-itype ne 1 then do:
        v-tmpbal = vbal.
        v-accrued = 0.
        repeat v-inc = 6 to 1 by -1:
            v-max = prih.tlimit[v-inc].
            if v-inc gt 1 then
            v-min = prih.tlimit[v-inc - 1].
            else v-min = 0.
            if v-tmpbal gt v-min and v-tmpbal le v-max then do:
                if prih.ttype[v-inc] eq 1 then do: /* Tiered */
                    v-intbal = v-tmpbal.
                    v-tmpbal = 0.
                end.
                else 
                if prih.ttype[v-inc] eq 2 then do: /* Interval */
                    v-intbal = v-tmpbal - v-min.
                    v-tmpbal = v-min.
                end.
                v-accrued = v-accrued + v-intbal
                        * prih.trate[v-inc] / 100 .
            end. /* In the range */
            if v-tmpbal eq 0 then leave.
        end. /* repeat */
    end. /* if aaa.prih ne "F" and prih.itype ne 1 */
    else do :
        if aaa.complex eq true then
        v-accrued = vbal * (exp(1 + intrat / (aaa.base * 100),aaa.base) - 1).
        else v-accrued = vbal * intrat / 100.
    end.
end.
v-intsum = v-accrued.
