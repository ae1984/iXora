/* pschk.i
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

/*
   01.10.2002 nadejda - наименование клиента заменено на форма собств + наименование 
*/

if gl.subled eq "ast"
  then do:
    find ast where ast.ast eq c-acc no-lock no-error.
    if not available ast
    or ast.gl ne gl.gl
    then c-acc = "".
else vv-crc = ast.crc. end.

if gl.subled eq "dfb"
  then do:
    find dfb where dfb.dfb eq c-acc no-lock no-error.
    if not available dfb
    or dfb.gl ne gl.gl
    then c-acc = "".
else vv-crc = dfb.crc. end.

else if gl.subled eq "arp" then do:
  find arp where arp.arp eq c-acc no-lock no-error.
  if not available arp
    or arp.gl ne gl.gl
  then c-acc = "".
else vv-crc = arp.crc. end.

else if gl.subled eq "bill"
  then do:
    find bill where bill.bill eq c-acc no-lock no-error.
    if not available bill
    or bill.gl ne gl.gl
    then c-acc = "".
else vv-crc = bill.crc. end.

else if gl.subled eq "cif"
  then do:
       find aaa where aaa.aaa eq c-acc no-lock no-error.
       if not available aaa
       or aaa.gl ne gl.gl
       then c-acc = "".
  else do:
       if aaa.sta = "C" then do:
          bell.
          {mesg.i 6207}.
          undo, retry.
       end.
  vv-crc = aaa.crc.
      find cif of aaa no-lock.
      if aaa.craccnt ne "" then
        find first xaaa where xaaa.aaa = aaa.craccnt no-lock no-error .
      if available xaaa then do:
      {mesg.i 0826} aaa.cr[1] - aaa.dr[1] - aaa.hbal + xaaa.cbal
      " Name: " trim(trim(cif.prefix) + " " + trim(cif.name)) .
       pause .
        end.
      else do:
      {mesg.i 0826} aaa.cr[1] - aaa.dr[1] - aaa.hbal
      " Name: " trim(trim(cif.prefix) + " " + trim(cif.name)) .
       pause .
       end.

   end.
  end.

else if gl.subled eq "eck"
  then do:
       find eck where eck.eck eq c-acc no-lock no-error.
       if not available eck
       or eck.gl ne gl.gl
       then c-acc = "".
else vv-crc = eck.crc. end.

else if gl.subled eq "eps"
  then do:
  find eps where eps.eps eq c-acc no-lock no-error.
  if not available eps
  or eps.gl ne gl.gl
  then c-acc = "".
else vv-crc = eps.crc. end.

else if gl.subled eq "fun"
  then do:
       find fun where fun.fun eq c-acc no-lock no-error.
       if not available fun
       or fun.gl ne gl.gl
       then c-acc = "".
else vv-crc = fun.crc. end.

else if gl.subled eq "lcr"
  then do:
       find lcr where lcr.lcr eq c-acc no-lock no-error.
       if not available lcr
       or lcr.gl ne gl.gl
       then c-acc = "".
else vv-crc = lcr.crc. end.

else if gl.subled eq "lon"
  then do:
       find lon where lon.lon eq c-acc no-lock no-error.
       vv-crc = lon.crc.
       if not available lon or gl.lev > 2 then c-acc = "".
       else
       do:
         if gl.lev eq 1 and lon.gl ne gl.gl
           then c-acc = "".
         else
         if gl.lev eq 2 then do:
                 find tgl where tgl.gl = lon.gl no-lock.
                 find sysc where sysc.sysc eq "DAYACR" no-lock.
                 if sysc.loval eq true
                    then do: if gl.gl ne tgl.autogl then c-acc = "". end.
                    else do: if gl.gl ne tgl.gl1 then c-acc = ""  . end.
                 end.
       end.
    end.
else if gl.subled eq "ock"
  then do:
       find ock where ock.ock eq c-acc no-lock no-error.
       if not available ock
        or ock.gl ne gl.gl
       then c-acc = "".
else vv-crc = ock.crc. end.
