/* new-acc.p
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

/* new-acc.p

   new version by Vladimir Sushinin
   22.03.99
   changes:
           добавлен параметр при вызове процедуры acng
*/

def shared var s-lgr like lgr.lgr.
def shared var s-aaa like aaa.aaa.
def shared var s-cif like cif.cif.


/*  old version
def var vpar  as int.
def var vdiv  as int initial 10.
def var vweight as int extent 6 initial [3,9,7,1,3,9].
def var vcons as int initial 0.
def var vmod as int.
def var vcd  as int.
def var vaaa  as int format "9999999" label "ACCT#".
def var vtmp  like vaaa.
def var vinc as int.


find lgr where lgr.lgr eq s-lgr.
vtmp = lgr.nxt.
vpar = 0.
repeat vinc = 1 to 6:
  vpar = vpar + truncate(vtmp / exp(10,6 - vinc),0) * vweight[vinc].
  vtmp = vtmp mod exp(10,6 - vinc).
end.
vpar = vpar + vcons.
vmod = vpar mod vdiv.
vcd = (vdiv - vmod) mod vdiv.

vaaa = lgr.nxt * 10 + vcd.
lgr.nxt = lgr.nxt + 1.
s-aaa = lgr.lgr + string(vaaa,"9999999").
release lgr.
*/

/*
New version
*/


find lgr where lgr.lgr eq s-lgr no-lock no-error.
/*run acng(input lgr.gl, true, output s-aaa).*/
run acc_gen(input lgr.gl,lgr.crc,s-cif,'',true,output s-aaa).

