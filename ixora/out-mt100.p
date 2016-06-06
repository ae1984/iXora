/* out-mt100.p
 * MODULE
        Платежная система
 * DESCRIPTION
        ввод свифтовой части формы МТ100  
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        5.3.1, 5.3.2
 * AUTHOR
        01.03.2003 sasco
 * CHANGES
        28.11.2003 sasco Запуск МТ103 вместо МТ100

*/

def shared variable s-remtrz like remtrz.remtrz.
def new shared var s-sqn as cha .
def new shared var destination as char format "x(12)". /* real bic code    */
def new shared buffer sw-bank  for bankl.         

find remtrz where remtrz.remtrz = s-remtrz.
remtrz.cover = 4. /* СВИФТ */

do: 
  find first sw-bank where bank = "TXB00". /* ПО УМОЛЧАНИЮ */

  /* KOVAL */
  run swin("103").

  if lastkey eq keycode('pf4') then undo,retry.
end.

