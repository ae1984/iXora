/* pro-od.p
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

define input  parameter p-aaa like aaa.aaa.
define input  parameter p-dat1 as date.
define input  parameter p-dat2 as date.
define output parameter p-sm  as decimal.
define variable v-err   as logical.
define variable v-rate  like pri.rate.
define variable vrate   as decimal.
define variable vmtdacc like aaa.mtdacc.
define variable atl     as decimal.
define variable dat1    as date.
define variable dat2    as date.

find last aab where aab.aaa = p-aaa and aab.fdt < p-dat1
     no-lock no-error.
if available aab
then atl = aab.bal.
else atl = 0.
find aaa where aaa.aaa = p-aaa no-lock.
atl = atl / (1 + aaa.rate / aaa.base / 100.0 ).
dat1 = p-dat1.
dat2 = ?.
vmtdacc = 0.
for each aab where aab.aaa = p-aaa and aab.fdt >= p-dat1 no-lock:
    if aab.fdt > p-dat2
    then dat2 = p-dat2.
    else dat2 = aab.fdt - 1.
    vmtdacc = vmtdacc - atl * (dat2 - dat1 + 1).
    atl = aab.bal / (1 + aaa.rate / aaa.base / 100.0 ).
    dat1 = aab.fdt.
    if aab.fdt > p-dat2
    then leave.
end.
if dat2 = ? or dat2 < p-dat2
then vmtdacc = vmtdacc - atl * (p-dat2 - dat1 + 1).
find aaa where aaa.aaa = p-aaa no-lock.
find crc of aaa.
find lgr where lgr.lgr = aaa.lgr no-lock.
v-err = no.
vrate = 0.
if not lgr.complex
then do:
     if lgr.lookaaa
     then do:
          if lgr.pri <> "F"
          then do:
               find pri where pri.pri eq lgr.pri no-lock no-error.
               if available pri
               then do:
                    if pri.itype eq 1
                    then v-rate = pri.rate .
                    else v-err = yes.
               end.
               else v-err = yes.
          end.
          else v-rate = 0.
     end.
     else do:
          if lgr.pri <> "F"
          then do:
               find pri where pri.pri eq lgr.pri.
               if available pri
               then do:
                    if pri.itype eq 1
                    then v-rate = pri.rate + lgr.rate.
                    else v-err = yes.
               end.
               else v-err = yes.
          end.
          else v-rate = lgr.rate.
     end.
end.
else v-err = yes.
vrate = v-rate.
p-sm = 0.
if not v-err
then do:
     if lgr.lookaaa
     then vrate = v-rate + aaa.rate.
     p-sm = round(( vmtdacc * vrate / aaa.base / 100.0 ) , crc.decpnt).
end.
/*------------------------------------------------------------------------------
  #3.
     1.izmai‡a - izmainЁta procentu aprё±in–Ѕanas formula
     2.izmai‡a - novёrsta kµ­da pie aprё±in–Ѕanas, kad uzdotaj– laika period–
       nav bijuЅi apgrozЁjumi
------------------------------------------------------------------------------*/
