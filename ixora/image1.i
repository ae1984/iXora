/* image1.i
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
 * BASES
        BANK COMM
 * CHANGES
        07.03.2012 damir - добавил исключения для некоторых пунктов меню,добавил v-noord...
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
*/

/* image1.i
   image file handling part 1
   5.22.87 created by yong k. yoon
   10.9.87 modified by yong k. yoon
   12-07-88 revised by Simon Y. Kim
   {1} = constant image file name

   1. Include this file at the beginning of your procedure before accepting
      any user specified selections.
   2. Refer os-test.i and file-be.i

   880203:
     this change does not affect old procedures
     image file handling screen show or not show
*/

def var v-noord as logi format "да/нет" init no.
find first sysc where sysc.sysc eq "noorder" no-lock no-error.
if avail sysc then v-noord = sysc.loval. /*Переход на новые и старые форматы форм*/

define variable vimgfname   as character format "x(12)".
define variable vappend     as logical initial false format "Append/Overwrite".
define variable vprint      as logical initial true.
define variable vfilebody   as character format "x(8)".
define variable vfileext    as character format "x(3)".
define variable vans        as logical initial true.
define variable dest        as character format "x(40)".

vimgfname = "./" + "{1}".

     if vimgfname = "rpt.img"   then dest = g-lprpt.
else if vimgfname = "lab.img"   then dest = g-lplab.
else if vimgfname = "let.img"   then dest = g-lplet.
else if vimgfname = "stmt.img"  then dest = g-lpstmt.
else                                 dest = "joe".

{image1.f}

if g-batch eq false then do:
    if g-fname = "r-cashsp" or g-fname = "r-cash110" or g-fname = "TARPDAT" or g-fname = "TRXGL0" then do:
        if v-noord = no then do:
            if search(vimgfname) eq vimgfname then update vappend with frame image1.
            update vprint with frame image1.
            if vprint eq true then update dest with frame image1.
        end.
    end.
    else do:
        if search(vimgfname) eq vimgfname then update vappend with frame image1.
        update vprint with frame image1.
        if vprint eq true then update dest with frame image1.
    end.
end.
