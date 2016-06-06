/* newyear.p
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
        05.01.04 nataly добавлена программа по обнулению 9-го уровня тек счетов клиентов dcls_lev.p
        02/06/06 marinav - 9 уровень не обнулять !
*/

/* new year  Закомментировано обнуление доходов-расходов   */

define var inc as int.
{global.i}
display "Now Moving EOY Balance for All Ledgers...." with frame rem row 5
         centered no-label.

run dcls_dr.
/*run dcls_lev.*/
for each crc where crc.sts ne 9:
  for each gl:
    find glbal where glbal.gl eq gl.gl and glbal.crc eq crc.crc.
    if gl.type eq "A"
      then do:
        glbal.dam = glbal.dam - glbal.cam.
        glbal.cam = 0.
      end.
    else if gl.type eq "L" or gl.type eq "O"
      then do:
        glbal.cam = glbal.cam - glbal.dam.
        glbal.dam = 0.
      end.
   /* else if gl.type eq "R" or gl.type eq "E"
      then do:
        glbal.dam = 0.     glbal.cam = 0.
       end.*/
    glbal.mdam = glbal.dam.   glbal.mcam = glbal.cam.
    glbal.ydam = glbal.dam.   glbal.ycam = glbal.cam.
  end. /* for each gl */
end. /* crc */
for each eps:
 find gl where gl.gl eq eps.gl no-error.
 if available gl then
  if gl.type eq "E" or gl.type eq "R" then do:
  repeat inc = 1 to 13:
    eps.pdr[inc] = 0.
    eps.pcr[inc] = 0.
  end.
  eps.dam = 0.
  eps.cam = 0.
  eps.basic   = 0.
  eps.addr    = 0.
  eps.movein  = 0.
  eps.moveout = 0.
  eps.red     = 0.
 end.
end.

for each gl no-lock :
if gl.type eq "R" or gl.type eq "E" then do:
if gl.subled ne "" then 
for each trxbal where trxbal.sub eq gl.subled and trxbal.lev eq gl.lev :
trxbal.dam = 0.
trxbal.cam = 0.
end.
end.
end.

inc = 1.
{monyear.i lon}
{monyear.i bill}
{monyear.i fun}
{monyear.i lcr}
{monyear.i ock}
{monyear.i eck}
{monyear.i eps}
for each iof:
  iof.dam[5] = 0.
  iof.cam[5] = 0.
end.
{monyear.i iof}
{monyear.i dfb}
for each aaa:
  aaa.mdr[1] = aaa.dr[1]. aaa.mcr[1] = aaa.cr[1].
  aaa.mdr[2] = aaa.dr[2]. aaa.mcr[2] = aaa.cr[2].
  aaa.mdr[3] = aaa.dr[3]. aaa.mcr[3] = aaa.cr[3].
  aaa.mdr[4] = aaa.dr[4]. aaa.mcr[4] = aaa.cr[4].
  aaa.mdr[5] = aaa.dr[5]. aaa.mcr[5] = aaa.cr[5].
  aaa.idr[1] = aaa.dr[1]. aaa.icr[1] = aaa.cr[1].
  aaa.idr[2] = aaa.dr[2]. aaa.icr[2] = aaa.cr[2].
  aaa.idr[3] = aaa.dr[3]. aaa.icr[3] = aaa.cr[3].
  aaa.idr[4] = aaa.dr[4]. aaa.icr[4] = aaa.cr[4].
  aaa.idr[5] = aaa.dr[5]. aaa.icr[5] = aaa.cr[5].
  aaa.mcnt[1] = aaa.cnt[1].
  aaa.mcnt[2] = aaa.cnt[2].
  aaa.mcnt[3] = aaa.cnt[3].
  aaa.mcnt[4] = aaa.cnt[4].
  aaa.mcnt[5] = aaa.cnt[5].
  aaa.ytdacc = 0.
  aaa.mtdacc = 0.
  aaa.rsv-dec[1] = 0.
  aaa.rsv-dec[2] = 0.

  aaa.pdr[1] = 0.
  aaa.pcr[1] = 0.
end.

/** перенос невыплаченных процентов в старый год **/
for each lgr where lgr.led eq "CDA" no-lock:
    for each aaa where aaa.lgr eq lgr.lgr:
        aaa.ratmin = aaa.accrued.
    end.
end.

pause 0.
run mvgltot.
bell. bell. bell.
{mesg.i 0877}.
pause 0.
