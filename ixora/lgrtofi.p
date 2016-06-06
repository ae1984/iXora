/* lgrtofi.p
 * MODULE
        Программа общего назначения
 * DESCRIPTION
        Перенос групп счетов на филиалы
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        21/0?/2010 marinav
 * BASES
        BANK COMM
 * CHANGES
*/



def var vlgr as char format "x(3)".

find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if trim(sysc.chval) ne "txb00" then do:
    message 'Синхронизация выполняется только с ЦО !!!' view-as alert-box .
    return.
end.

update vlgr label  " Введите группу счетов lgr: " with side-label centered row 5 title " СИНХРОНИЗАЦИЯ ".

find first lgr where lgr.lgr = vlgr no-lock no-error.
if not avail lgr then do:
    message 'Такой группы нет ! Удалить группу с филиалов?' view-as alert-box question buttons yes-no title '' update choice1 as logical.
    if not choice1 then return.
end. 
  
    message 'Сделать синхронизацию группы счета ' vlgr ' с филиалами ?' view-as alert-box question buttons yes-no title '' update choice as logical.
    if not choice then return.
                  
      find sysc where sysc.sysc = 'GLTD' no-error.
      if avail sysc then  do trans: sysc.chval = vlgr. end.
      find current sysc no-lock.
      run txbs('lgrtofil.p').
      find sysc where sysc.sysc = 'GLTD' no-error.
      if avail sysc then do trans: sysc.chval = "". end.
      find current sysc no-lock.
