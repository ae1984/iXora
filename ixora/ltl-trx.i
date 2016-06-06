/* ltl-trx.i
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
        19/04/2005 madiar - добавил вывод в выписку штрафов и комиссий
        17/06/2005 madiar - добавил вывод в выписку индексации
        25/04/2012 evseev  - rebranding. Название банка из sysc.
*/

/* ==================================================================
=                                                                    =
=                        Statement Generator                             =
=                Deals Codes & Details Processing Unit                    =
=                                                                    =
================================================================== */
/*
   01.10.2002 nadejda - наименование клиента заменено на форма собств + наименование
*/
{nbankBik.i}

find trxcods where trxcods.trxh = b-jl.jh and trxcods.trxln = b-jl.ln and trxcods.codfr = v-codfr no-lock no-error.

if available trxcods then
    {1}.trxcode = trxcods.code.
else do:
    if b-jl.lev eq 1 or b-jl.lev eq 7 or b-jl.lev eq 8 then
        {1}.trxcode = "LON".
    else
    if b-jl.lev eq 2 or b-jl.lev eq 9 or b-jl.lev eq 10 then
        {1}.trxcode = "INT".
    else
    if b-jl.lev eq 16 then
        {1}.trxcode = "PEN".
    else
    if b-jl.lev eq 20 or b-jl.lev eq 22 then
        {1}.trxcode = "INDEX".
    else
    if lookup(string(b-jl.lev),"25,27,28,29") > 0 then
        {1}.trxcode = "LNCOM".
end.

if b-jl.dam <> 0 then do:
    {1}.dc = "d".
    {1}.amount = b-jl.dam.
end.
else do:
    if b-jl.cam <> 0 then do:
        {1}.dc = "c".
        {1}.amount = b-jl.cam.
    end.
end.

{1}.who = b-jl.who.



find remtrz where remtrz.remtrz eq substring(b-jl.rem[1],1,10) no-lock no-error.
if available remtrz then do:
  find first prfxset where (remtrz.remtrz begins prfxset.oppr) no-lock no-error.
  if available prfxset then do:

  run value(prfxset.procsr)(in_recid, output o_dealtrn, output o_custtrn,
  output o_ordins, output o_ordcust, output o_ordacc, output o_benfsr,
  output o_benacc, output o_benbank, output o_dealsdet, output o_bankinfo).
                     if return-value = "0" then do:
                        {1}.dealtrn  = o_dealtrn.
                        {1}.custtrn  = o_custtrn.
                        {1}.ordins   = o_ordins.
                        {1}.ordcust  = o_ordcust.
                        {1}.ordacc   = o_ordacc.
                        {1}.benfsr   = o_benfsr.
                        {1}.benbank  = o_benbank.
                        {1}.benacc   = o_benacc.
                        {1}.dealsdet = o_dealsdet.
                        {1}.bankinfo = o_bankinfo.
                     end.
  end.
end. /* available remtrz */
else do:

find lon where lon.lon eq b-jl.acc no-lock no-error.
if available lon then find cif where cif.cif eq lon.cif no-lock no-error.
if available cif then do:
v-cust = lon.lon + " " + trim(trim(cif.prefix) + " " + trim(cif.name)).
if cif.jss ne "" then v-cust = v-cust + " РНН " + cif.jss.
end.

if b-jl.jdt ge s-newstmtdt then do:
{1}.ordins   = v-nbankru.
if {1}.dc eq "D" then do:
{1}.ordcust  = v-cust.
{1}.ordacc   = lon.lon.
/*
{1}.benfsr   = b-jl.rem[4].
{1}.benacc   = substring(b-jl.rem[4],1,index(b-jl.rem[4]," ") - 1) no-error.
*/
end.
else do:
/*
{1}.ordcust  = b-jl.rem[4].

{1}.ordacc   = substring(b-jl.rem[4],1,index(b-jl.rem[4]," ") - 1) no-error.
*/
{1}.benfsr   = v-cust.
{1}.benacc   = lon.lon.
end.
{1}.bankinfo = b-jl.rem[4].
{1}.benbank  = v-nbankru.

if {1}.trxcode eq "LON" then
{1}.dealsdet =  trim(b-jl.rem[2]).
else
if {1}.trxcode eq "INT" then
{1}.dealsdet =  trim(b-jl.rem[3]).
else
if {1}.trxcode eq "PEN" then
{1}.dealsdet =  trim(b-jl.rem[5]).
else
if {1}.trxcode eq "LNCOM" then
{1}.dealsdet =  trim(b-jl.rem[1]).
else do:
{1}.dealsdet =  trim(b-jl.rem[1]) + " " +
trim(b-jl.rem[2]) + " " +
trim(b-jl.rem[3]) + " " +
trim(b-jl.rem[4]) + " " +
trim(b-jl.rem[5]).
{1}.bankinfo = "".
end.
end.
else do:

/*
{1}.ordins   = 'АО "TEXAKABANK" 190501914'.

if {1}.dc eq "D" then do:
{1}.ordcust  = v-cust.
{1}.ordacc   = lon.lon.
{1}.benfsr   = b-jl.rem[4].
{1}.benacc   = substring(b-jl.rem[4],1,index(b-jl.rem[4]," ") - 1) no-error.
end.
else do:
{1}.ordcust  = b-jl.rem[4].
{1}.ordacc   = substring(b-jl.rem[4],1,index(b-jl.rem[4]," ") - 1) no-error.
{1}.benfsr   = v-cust.
{1}.benacc   = lon.lon.
end.

{1}.benbank  = 'АО "TEXAKABANK" 190501914'.
*/

{1}.dealsdet =  trim(b-jl.rem[1]) + " " +
trim(b-jl.rem[2]) + " " +
trim(b-jl.rem[3]) + " " +
trim(b-jl.rem[4]) + " " +
trim(b-jl.rem[5]).


end.

end.
v-damname = fill(" ",20).
v-camname = fill(" ",20).
find gl where gl.gl eq b-jl.gl no-lock no-error.
if avail gl then
  if b-jl.dc eq "d" then v-damname = substring(gl.sname,1,20).
  else v-camname = substring(gl.sname,1,20).


find first b-jl where b-jl.jh eq b-jh.jh and b-jl.dam + b-jl.cam eq {1}.amount and b-jl.crc eq {1}.crc and b-jl.dc ne {1}.dc no-lock no-error.
if available b-jl then do:
find gl where gl.gl eq b-jl.gl no-lock no-error.
if avail gl then
  if b-jl.dc eq "d" then v-damname = substring(gl.sname,1,20).
  else v-camname = substring(gl.sname,1,20).
end.

/*
if b-jh.jh eq 214244 then message
string(b-jh.jh) + " " + string(available b-jl) + "\n"
 + "amount = " + string({1}.amount)
 + "crc = " + string({1}.crc)
 + "dc = " + string({1}.dc)
 view-as alert-box.
*/

if {1}.dealtrn eq "" then
{1}.dealtrn = fill(" ",35) + v-damname + " " + v-camname.
else do:
{1}.dealtrn = substring({1}.dealtrn,1,34).
{1}.dealtrn = {1}.dealtrn + fill(" ",35 - length({1}.dealtrn))
+ v-damname + " " + v-camname.
end.
if available b-jl and b-jl.jdt lt s-newstmtdt then do:
    find aaa where aaa.aaa eq b-jl.acc no-lock no-error.
    if available aaa then do:
        find cif where cif.cif eq aaa.cif no-lock no-error.
        if avail cif then do:
          {1}.bankinfo = aaa.aaa + " " + trim(trim(cif.prefix) + " " + trim(cif.name)) .
          if cif.jss ne "" then {1}.bankinfo = {1}.bankinfo + " " + cif.jss.
        end.
    end.
end.



