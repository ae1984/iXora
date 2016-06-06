/* aaa-plsy.p
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

 /* aaa-plsx.p*/

def shared var s-aaa like aaa.aaa.

def shared var s-aah as int.
def shared var s-line as int.
def shared var s-force as log.

find aal where aal.aah eq s-aah and aal.ln = s-line.
find aaa where aaa.aaa eq aal.aaa exclusive-lock.
find aax where aax.lgr eq aaa.lgr and aax.ln eq aal.aax no-lock.
find lgr where lgr.lgr eq aaa.lgr no-lock.

if aax.dev > 0 then aaa.dr[aax.dev]  = aaa.dr[aax.dev]  + aal.amt.
if aax.cev > 0 then aaa.cr[aax.cev]  = aaa.cr[aax.cev]  + aal.amt.

if aax.cnt > 0 then do:
                      if aal.amt gt 0
                      then aaa.cnt[aax.cnt] = aaa.cnt[aax.cnt] + 1.
                      else if aal.amt lt 0
                      then aaa.cnt[aax.cnt] = aaa.cnt[aax.cnt] + -1.
                    end.

if aal.fday gt 0 then aaa.fbal[aal.fday] = aaa.fbal[aal.fday] + aal.amt.

if aal.fday = 0 then aaa.cbal = aaa.cbal + aal.amt * aax.drcr * -1.

aal.sta = "".
