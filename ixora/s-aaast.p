/* s-aaast.p
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

/* checked */
/* s-aaast.p
*/

def new shared var s-date as date.
def new shared var s-dtstr as cha format "x(9)".

def  shared var s-aaa like aaa.aaa.

def var vbal like jl.dam format "z,zzz,zzz,zz9.99-".
def var vdam like vbal.
def var vcam like vbal.
def var vdr  like vbal.
def var vcr  like vdr.
def var fdt as date.
def var tdt as date.
def var nodr as int format "z,zz9".
def var nocr as int format "z,zz9".
def var gavg like jl.dam.
def var aavg like gavg.
def var vday as int format "zz9".
def var vchk as int format "zzzzz9".
def var cifname as char.

{global.i}

find aaa where aaa.aaa eq s-aaa.
find lgr where lgr.lgr eq aaa.lgr.
output to stmt.img page-size 60 append.

fdt = aaa.lstmdt + 1.
tdt = aaa.stmdt.
vday = tdt - fdt + 1.
if fdt gt tdt then next.
find cif where cif.cif eq aaa.cif.
cifname = trim(trim(cif.prefix) + " " + trim(cif.name)).
find crc where crc.crc eq aaa.crc.
find lgr of aaa .
find first cmp.
if cif.jame ne "" then
{aaastmt1.f}
if cif.jame ne "" then
view frame pagetop.
else view frame pagetop2.
  /*
  form header "PAGE" page-number format "zz9"
    with frame pagebottom no-box no-label page-bottom.
  view frame pagebottom.
  */

vbal = aaa.lstmgbal.
nodr = 0.
nocr = 0.
vdr = 0.
vcr = 0.

for each aal use-index aaa where aal.aaa eq aaa.aaa
              and  aal.regdt ge fdt
              and  aal.regdt le tdt
              and  aal.chk ne 0
              and  aal.sta eq "X":
  aal.sta = "".
end.

for each jl where jl.acc eq aaa.aaa
             and  jl.jdt ge fdt
             and  jl.jdt le tdt
            use-index jdt
   ,each gl where gl.gl eq jl.gl and gl.subled eq "cif" and gl.level eq 1
            by jl.jdt by jl.jh:

  if jl.dc eq "D"
    then do:
      vdr  = vdr + jl.dam.
      nodr = nodr + 1.
    end.
    else do:
      vcr  = vcr + jl.cam.
      nocr = nocr + 1.
    end.
  vbal = vbal + jl.cam - jl.dam.
end.
/*
if vbal ne aaa.stmgbal
  then do:
    bell.
    {mesg.i 1002}.
    return.
  end.
  */
gavg = aaa.lstmavg.

{aaastmt2.f}

vbal = aaa.lstmgbal.

s-date = fdt.
run s-dtstr.

{aaastmt3.f}

for each jl where jl.acc eq aaa.aaa
             and  jl.jdt ge fdt
             and  jl.jdt le tdt
            use-index jdt
   ,each gl where gl.gl eq jl.gl and gl.subled eq "cif" and gl.level eq 1
            by jl.jdt by jl.jh:
  vbal = vbal + jl.cam - jl.dam.
  s-date = jl.jdt.
  run s-dtstr.
  vdam = jl.dam.
  vcam = jl.cam.
  vchk = 0.
  if jl.dc eq "D"
  then do:
    find first aal where aal.aaa eq aaa.aaa and
                       aal.regdt eq jl.jdt and
                       aal.amt eq jl.dam and
                       aal.sta eq "" and
                       aal.aax eq 2
                       no-error.
    if available aal /* and aal.chk gt 0 */
      then do:
        vchk = aal.chk.
        aal.sta = "X".
      end.
    end.
display s-dtstr
        jl.rem[1] format "x(20)"
       /* vchk when vchk ne 0 */
        vcam to 69 when vcam ne 0 skip
        vdam to 50 when vdam ne 0
        vbal to 79
        with width 96 no-box no-label down frame jl.
end.
  /*
  aaa.stmgbal = vbal.
  aaa.stmdt = tdt.
  */
s-date = tdt.
run s-dtstr.
{aaastmt4.f}
output close.
