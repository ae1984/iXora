/* kdkomob.p Электронное кредитное досье

 * MODULE
     Кредитный модуль        
 * DESCRIPTION
       Комментарии к залогам
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
         
 * AUTHOR
        05.03.04 marinav
 * CHANGES
        30/04/2004 madiar - просмотр досье филиалов в ГБ
        17/05/2004 madiar - Исправил проблему с одновременным доступом к данным - теперь таблица лочится только в момент сохранения данных
        20/05/2004 madiar - В find kdlon добавил еще проверку на kdcif - иначе находилось несколько записей в kdlon с одинаковыми номерами досье
    05/09/06   marinav - добавление индексов
*/



{global.i}
{kd.i}

if s-kdlon = '' then return.

find kdlon where kdlon.kdcif = s-kdcif and kdlon.kdlon = s-kdlon and (kdlon.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.

if not avail kdlon then do:
  message skip " Досье N" s-kdlon "не найдено !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

define var s-info as char.
define var s-tit as char format "x(50)".
define var stitle as char.
define frame fr skip(1) space(30) s-tit no-label skip(1)
       s-info  no-label VIEW-AS EDITOR SIZE 75 by 10 skip(1)
       with overlay width 80 side-labels column 3 row 3 
       title " КОММЕНТАРИИ К ОБЕСПЕЧЕНИЮ " .

  find first kdaffil where kdaffil.kdcif = s-kdcif 
                           and kdaffil.kdlon = s-kdlon and kdaffil.code = '20' and (kdaffil.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.
  if not avail kdaffil then do:
     if s-ourbank = kdlon.bank then do:
        create kdaffil. 
        kdaffil.bank = s-ourbank. kdaffil.code = '20'. kdaffil.dat = g-today. 
        kdaffil.kdcif = s-kdcif. kdaffil.kdlon = s-kdlon.
        find current kdaffil no-lock no-error.
     end.
     else do:
        message skip " Запрашиваемые данные не были введены " skip(1) view-as alert-box buttons ok title " Нет данных! ".
        return.
     end.
  end.
  message 'F1 - Сохранить,   F4 - Выход без сохранения'.

  s-tit = 'Комментарии'.
  s-info = kdaffil.info[3].
  displ s-tit s-info with frame fr scrollable.
  if s-ourbank = kdlon.bank then do:
    find current kdaffil exclusive-lock no-error.
    update s-info with frame fr.
    kdaffil.info[3] = s-info.
    find current kdaffil no-lock no-error.
  end.
  else pause.

