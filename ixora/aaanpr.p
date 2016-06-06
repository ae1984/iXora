/* aaanpr.p
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

/* aaanpr.p
   Print account number
   UPDT H.T. CHO
*/

{proghead.i "PRINT ACCOUNT CONTROL BOOK"}

def var vfaaa as int format "zzzzz9" label "ACCOUNT# FR".
def var vtaaa like vfaaa label "ACCOUNT# TO".
def var vaaa like vfaaa.
def var vaout  as int format "zzzzzz9" label "ACCOUNT#".
def var vtmp  like vaaa.
def var vname like aaa.name.
def var vinc  as int.
def var vpar  as int.
def var vdiv  as int initial 11.
def var vweight as int extent 6 initial [4,9,1,4,9,1].
def var vcons as int initial 7.
def var vmod as int.
def var vcd  as int.
def var vdate   as char format "x(10)" label "DATE".
def var vtitles as char format "x(20)" label "ACCOUNT TITLE".
def var vaddr   as char format "x(25)" label "ADDRESS".
def var vtele   as char format "x(12)" label "TELEPHONE".
def var vrem    as char format "x(43)" label "REMARKS".
def var vpre    as char format "x(4)"  label "PRE".
def var vchk    as char format "x(3)"  label "CK".

{image1.i rpt.img}
update vfaaa vtaaa
   with centered row 7 side-label no-box.
{image2.i}

{report1.i 59}
vtitle = "ACCOUNT CONTROL BOOK  AS-OF " + string(g-today).

repeat vaaa = vfaaa to vtaaa:
  {report2.i 132}
  vpar = 0.
  vtmp = vaaa.
  repeat vinc = 1 to 6:
    vpar = vpar + truncate(vtmp / exp(10,6 - vinc),0) * vweight[vinc].
    vtmp = vtmp mod exp(10,6 - vinc).
  end.
  vpar = vpar + vcons.
  vmod = vpar mod vdiv.
  if      vmod eq 10 or vmod eq 1
    then vcd = 0.
  else if vmod eq 0
    then vcd = 1.
  else   vcd = vdiv - vmod.

  vaout = vaaa * 10 + vcd.
  display vdate ":"
	  string(string(vaout,"9999999"),"9-9-99999") format "x(9)"
	  label "ACCOUNT#"
	  ":" vname
	  ":" vtele ":" vrem ":" vpre ":" vchk skip(2)
	  with width 132 down frame aaa.

end.
{report3.i}
{image3.i}
