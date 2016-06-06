/* gltofi.p
 * MODULE
        Программа общего назначения
 * DESCRIPTION
        Перенос ГК на филиалы
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
        16/03/2010 marinav
 * BASES
        BANK 
 * CHANGES
        27.03.10 marinav - добавлено удаление счета 
*/



def var vgl as inte format '999999'.

update vgl label  " Введите номер счета ГК: " with side-label centered row 5 title " СИНХРОНИЗАЦИЯ ".

find first gl where gl.gl = vgl no-lock no-error.
/*if not avail gl then do:
    message 'Такого счета нет !' view-as alert-box.
    return.
end. */
  
    message 'Сделать синхронизацию счета ' vgl ' с филиалами ?' view-as alert-box question buttons yes-no title '' update choice as logical.
    if not choice then return.
                  
      find sysc where sysc.sysc = 'GLTD' no-error.
      if avail sysc then  do trans: sysc.inval = vgl. end.
      find current sysc no-lock.
      run txbs('gltofil').
      find sysc where sysc.sysc = 'GLTD' no-error.
      if avail sysc then do trans: sysc.inval = 0. end.
      find current sysc no-lock.
