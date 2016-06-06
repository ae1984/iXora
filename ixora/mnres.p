/* mnres.p 

 * MODULE
        Мониторинг заемщика
 * DESCRIPTION
        Резюме
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-11-3 Рзюме 
 * AUTHOR
        18.03.05 marinav
 * CHANGES
    05/09/06   marinav - добавление индексов
*/


{global.i}
{kd.i}
{sysc.i}

def var v-cod as char.

if s-kdcif = '' then return.

find kdcifhis where kdcifhis.kdcif = s-kdcif and kdcifhis.nom = s-nom and (kdcifhis.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.

if not avail kdcifhis then do:
  message skip " Мониторинг N" s-nom "не найдено !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.


  define frame fr1 skip(1)
         kdaffilh.info[2]  label "Сильные стор заемщика " VIEW-AS EDITOR SIZE 50 by 4 skip(1)
         kdaffilh.info[3]  label "Слабые стор заемщика " VIEW-AS EDITOR SIZE 50 by 4 skip(1)
         kdaffilh.info[4]  label "Сост реал-ции проекта " VIEW-AS EDITOR SIZE 50 by 4 skip(1)
         kdaffilh.whn      label "ПРОВЕДЕНО    " kdaffilh.who  no-label skip(1)
         with overlay width 80 side-labels column 3 row 3 
         title "Резюме по монитоингу " .


  find first kdaffilh where kdaffilh.bank = s-ourbank and kdaffilh.code = '21' and kdaffilh.kdcif = s-kdcif and kdaffilh.nom = s-nom no-lock no-error.
  if not avail kdaffilh then do:
        create kdaffilh. 
        kdaffilh.bank = s-ourbank. kdaffilh.code = '21'.
        kdaffilh.kdcif = s-kdcif. kdaffilh.nom = s-nom. kdaffilh.who = g-ofc. kdaffilh.whn = g-today.
        find current kdaffilh no-lock no-error.
  end.
  message 'F1 - Сохранить,   F4 - Выход без сохранения'.
  pause 0.
  displ kdaffilh.info[2] kdaffilh.info[3]kdaffilh.info[4] kdaffilh.who kdaffilh.whn with frame fr1.
  find current kdaffilh exclusive-lock no-error.
  update kdaffilh.info[2] with frame fr1.
  update kdaffilh.info[3] with frame fr1.
  update kdaffilh.info[4] with frame fr1.
  kdaffilh.who = g-ofc. kdaffilh.whn = g-today.
  find current kdaffilh no-lock no-error.
  hide message.


