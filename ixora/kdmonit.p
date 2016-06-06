/* kddop.p   Электронное кредитное досье
 * MODULE
        Кредитное досье
 * DESCRIPTION
        Мониторинг для кредита
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-11-6
 * AUTHOR
        18.03.04 marinav
 * CHANGES
        30/04/2004 madiar - просмотр досье филиалов в ГБ
        18/05/2004 madiar - Исправил проблему с одновременным доступом к данным - теперь таблица лочится только в момент сохранения данных
        20/05/2004 madiar - В find kdlon добавил еще проверку на kdcif - иначе находилось несколько записей в kdlon с одинаковыми номерами досье
                            Поиск записей в kdaffil - не только по коду досье, но и по коду клиента
    05/09/06   marinav - добавление индексов
*/
   


{global.i}
{kd.i}
{pksysc.f}

def var kdaffilcod as char.

/*s-kdcif = 't11653'.
s-kdlon = 'KD10'.
*/

if s-kdlon = '' then return.

find kdlon where kdlon.kdcif = s-kdcif and kdlon.kdlon = s-kdlon and (kdlon.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.

if not avail kdlon then do:
  message skip " Досье N" s-kdcif "не найдено !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

if kdlon.bank = s-ourbank then kdaffilcod = '36'.
else kdaffilcod = '46'.

find kdcif where kdcif.kdcif = s-kdcif and (kdcif.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.

define frame fr skip(1) " МОНИТОРИНГ ПО КРЕДИТУ "  skip(1)
       kdaffil.info[1]  no-label VIEW-AS EDITOR SIZE 75 by 10 skip(1)
       kdaffil.whn      label "ПРОВЕДЕНО " kdaffil.who  no-label skip(1)
       with overlay width 80 side-labels column 3 row 3 .

      find first kdaffil where kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon and kdaffil.code = kdaffilcod no-lock no-error.
      if not avail kdaffil then do:
            create kdaffil. 
            kdaffil.bank = s-ourbank. kdaffil.code = kdaffilcod. kdaffil.kdlon = s-kdlon. 
            kdaffil.kdcif = s-kdcif. kdaffil.who = g-ofc. kdaffil.whn = g-today.
            find current kdaffil no-lock no-error.
      end.
      message 'F1 - Сохранить,   F4 - Выход без сохранения'.
      displ kdaffil.info[1] kdaffil.whn  kdaffil.who with frame fr.
      find current kdaffil exclusive-lock no-error.
      update kdaffil.info[1] with frame fr. 
      kdaffil.whn = g-today. kdaffil.who = g-ofc.
      find current kdaffil no-lock no-error.
