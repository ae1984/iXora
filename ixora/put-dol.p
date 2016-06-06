/* put-dol.p
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

{put-dol.f}.
define shared stream s2.
if index(raksts,"$") = 0
then return.
if index(ident,"^") = 0 or index(ident,":") = 0 or
   index(raksts,"$") = r-index(raksts,"$")
then do:
     message m1 ident m2 raksts.
     return.
end.
r1 = substring(ident,index(ident,":") + 1).
r5 = substring(ident,r-index(ident,"^") + 1).
r2 = "".
r3 = substring(r5,1,1).
repeat while r3 >= "0" and r3 <= "9":
   r2 = r2 + r3.
   r5 = substring(r5,2).
   r3 = substring(r5,1,1).
end.
if r2 = ""
then n0 = 0.
else n0 = integer(r2).
r5 = trim(substring(r5,1,index(r5,":") - 1)).
n = 0.
repeat while index(r1,":") > 0:
   r2 = substring(r1,1,index(r1,":")).
   r1 = substring(r1,index(r1,":") + 1).
   if index(r2,"=") > 0
   then next.
   n = n + 1.
   if index(r2,"#") > 0
   then r0[n] = "#".
   else r0[n] = "".
   r[n] = r0[n].
end.
if n0 = 0
then n0 = n.
v-r = "".
r7 = "".
input stream s1 from value(fls-1) no-echo.
repeat on endkey undo,leave:
   import stream s1 r1 r6 r2 r3 r4.
   if r1 <> r5
   then next.
   if r3 = "99"
   then do:
        r7 = r7 + r4 + "!".
        next.
   end.
   i = integer(r3).
   j = i modulo n0.
   if j = 0
   then j = n0.
   j = i - j + 1.
   if v-r <> r2 or j <> i0 and i0 <> 0
   then do:
        if v-r <> ""
        then {put-dol.i &last = "no"}.
        v-r = r2.
   end.
   i = integer(r3).
   i0 = i modulo n0.
   if i0 = 0
   then i0 = n0.
   i0 = i - i0 + 1.
   ata = substring(r4,1,1).
   if ata = "@" or ata = "%"
   then do:
        r4 = substring(r4,2).
        r3 = substring(r[i],index(r[i],"#") + 1).
        r[i] = substring(r[i],1,index(r[i],"#")).
        if ata = "@"
        then r[i] = r[i] + string(decimal(r3) +
                                  decimal(r4),"->,>>>,>>>,>>9.99").
        else r[i] = r[i] + string(integer(r3) +
                                  integer(r4),"-z,zzz,zzz,zz9").
   end.
   else r[i] = r[i] + r4.
end.
{put-dol.i &last = "yes"}.
input stream s1 close.
