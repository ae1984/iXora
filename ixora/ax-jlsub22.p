/* ax-jlsub22.p
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

      /* x-jlsub2.p
	 BY S. CHOI  */

{global.i}

def shared var s-jh like jh.jh.
def shared var s-aah as int.
def shared var s-line as int.
def shared var s-force as log initial false.
def var vans as log.

vans = no.
{mesg.i 0824} update vans.
if vans then do:
  find jh where jh.jh eq s-jh.
  for each jl of jh  transaction  :
    find gl of jl no-lock.
    {jlupd-f.i -}

    /***********************************/
    if gl.subled eq "ast" then do:
	for each astjl where astjl.ajh eq s-jh:
	    delete astjl.
	end.
    end.
    /***********************************/

    if gl.subled eq "ast" and
      ast.dam[1] eq 0 and ast.cam[1] eq 0 and
      ast.dam[2] eq 0 and ast.cam[2] eq 0 and
      ast.dam[3] eq 0 and ast.cam[3] eq 0 and
      ast.dam[4] eq 0 and ast.cam[4] eq 0 and
      ast.dam[5] eq 0 and ast.cam[5] eq 0
      then delete ast.
    else if gl.subled eq "bill" and
      bill.dam[1] eq 0 and bill.cam[1] eq 0 and
      bill.dam[2] eq 0 and bill.cam[2] eq 0 and
      bill.dam[3] eq 0 and bill.cam[3] eq 0 and
      bill.dam[4] eq 0 and bill.cam[4] eq 0 and
      bill.dam[5] eq 0 and bill.cam[5] eq 0
      then delete bill.
    else if gl.subled eq "fun" and
      fun.dam[1] eq 0 and fun.cam[1] eq 0 and
      fun.dam[2] eq 0 and fun.cam[2] eq 0 and
      fun.dam[3] eq 0 and fun.cam[3] eq 0 and
      fun.dam[4] eq 0 and fun.cam[4] eq 0 and
      fun.dam[5] eq 0 and fun.cam[5] eq 0
      then delete fun.
    else if gl.subled eq "lcr" and
      lcr.dam[1] eq 0 and lcr.cam[1] eq 0 and
      lcr.dam[2] eq 0 and lcr.cam[2] eq 0 and
      lcr.dam[3] eq 0 and lcr.cam[3] eq 0 and
      lcr.dam[4] eq 0 and lcr.cam[4] eq 0 and
      lcr.dam[5] eq 0 and lcr.cam[5] eq 0
      then delete lcr.
      /*else if gl.subled eq "lon" then do:
      lon.dam[1] eq 0 and lon.cam[1] eq 0 and
      lon.dam[2] eq 0 and lon.cam[2] eq 0 and
      lon.dam[3] eq 0 and lon.cam[3] eq 0 and
      lon.dam[4] eq 0 and lon.cam[4] eq 0 and
      lon.dam[5] eq 0 and lon.cam[5] eq 0
      then delete lon.*/
    else if gl.subled eq "ock" and
      ock.dam[1] eq 0 and ock.cam[1] eq 0 and
      ock.dam[2] eq 0 and ock.cam[2] eq 0 and
      ock.dam[3] eq 0 and ock.cam[3] eq 0 and
      ock.dam[4] eq 0 and ock.cam[4] eq 0 and
      ock.dam[5] eq 0 and ock.cam[5] eq 0
      then delete ock.

    delete jl.
  end.
  {mesg.i 0846}.
end.
