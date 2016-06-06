/* pkphlink.p
 * MODULE
        Потребительские кредиты
 * DESCRIPTION
        Привязка фотографий к анкете
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
        02/08/2005 madiyar
 * CHANGES
        27/09/2005 madiyar - добавил Атырау
        29/09/2005 madiyar - добавил Уральск
        12/10/2005 madiyar - работают все филиалы
        02/12/2005 madiyar - пауза между rcp,rsh
        16/01/2006 madiyar - убрал вывод фоток для Актобе
        05/03/2007 madiyar - вывод фоток для всех
        02/07/2007 madiyar - убрал упоминание кодов конкретных филиалов
        31/10/2008 madiyar - альтернативная директория для загрузки фотографий
*/

{global.i}
{pk.i}

def var pcoun as integer no-undo.
def var wdir as integer no-undo.
def var choice as logical no-undo.

run check_photos(output pcoun, output wdir).
if (pcoun <= 0) or (wdir <= 0) then do:
  message " Фотографии отсутствуют! " view-as alert-box buttons ok title " Ошибка! ".
  return.
end.
else do:
  choice = no.
  message " К анкете будут привязаны " pcoun " фото. ~n Продолжить? " view-as alert-box buttons ok title " Внимание! " update choice.
  if not choice then return.
end.

find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.ln = s-pkankln no-lock no-error.
if avail pkanketa then do:
  run mv_photos(s-pkankln,pkanketa.rdt,s-credtype,wdir).
  run pkphview.
end.
else do:
  message " Анкета не найдена! " view-as alert-box buttons ok title " Ошибка! ".
  return.
end.
