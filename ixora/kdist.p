/* kdist.p   Электронное кредитное досье
 * MODULE
        Кредитное досье
 * DESCRIPTION
        Источники погашения
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
        11.03.04 marinav
 * CHANGES
        30/04/2004 madiar - Работа с досье филиалов в ГБ.
        18/05/2004 madiar - Исправил проблему с одновременным доступом к данным - теперь таблица лочится только в момент сохранения данных
        20/05/2004 madiar - В find kdlon добавил еще проверку на kdcif - иначе находилось несколько записей в kdlon с одинаковыми номерами досье
                            Поиск записей в kdaffil - не только по коду досье, но и по коду клиента
        04/06/2004 madiar - В связи с изменением проги r-lncifot.p дописал в ее вызов один входной параметр
    05/09/06   marinav - добавление индексов
*/
   


{global.i}
{kd.i}
{pksysc.f}

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

find kdcif where kdcif.kdcif = s-kdcif and (kdcif.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.

def var s-info as char extent 2.

define temp-table t-name
   field name as char.

define frame fr skip(1) "                    ПЕРВИЧНЫЙ ИСТОЧНИК ПОГАШЕНИЯ" skip(1)
       s-info[1]  no-label VIEW-AS EDITOR SIZE 75 by 10 skip(1)
       kdaffil.whn      label "ПРОВЕДЕНО " kdaffil.who  no-label skip(1)
       with overlay width 80 side-labels column 3 row 3 
       title " ИСТОЧНИКИ ПОГАШЕНИЯ " .

define frame fr2 skip(1) "                    ВТОРИЧНЫЙ ИСТОЧНИК ПОГАШЕНИЯ" skip(1)
       s-info[2]  no-label VIEW-AS EDITOR SIZE 75 by 10 skip(1)
       kdaffil.whn      label "ПРОВЕДЕН " kdaffil.who  no-label skip(1)
       with overlay width 80 side-labels column 3 row 3 
       title " ИСТОЧНИКИ ПОГАШЕНИЯ " .

define frame fr3 skip(1) "                         ОПИСАНИЕ ГАРАНТА" skip(1)
       kdaffil.info[1]  no-label  VIEW-AS EDITOR SIZE 75 by 10 skip(1)
       kdaffil.whn      label "ПРОВЕДЕН " kdaffil.who  no-label skip(1)
       with overlay width 80 side-labels column 3 row 3 
       title " ИСТОЧНИКИ ПОГАШЕНИЯ " .


define var v-sel as char.

  run sel ("Выбор :", 
           " 1. Первичный источник погашения | 2. Вторичный источник погашения | 3. Гаранты | 4. Выход ").
  v-sel = return-value.
  case v-sel:
    when "1" then do:
          find first kdaffil where  kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon and kdaffil.code = '26' no-lock no-error.
          if not avail kdaffil then do:
                create kdaffil. 
                kdaffil.bank = s-ourbank. kdaffil.code = '26'. kdaffil.kdlon = s-kdlon. 
                kdaffil.kdcif = s-kdcif. kdaffil.who = g-ofc. kdaffil.whn = g-today.
                find current kdaffil no-lock no-error.
          end.
          s-info[1] = kdaffil.info[1].
          message 'F1 - Сохранить,   F4 - Выход без сохранения'.
          displ s-info[1] kdaffil.whn kdaffil.who with frame fr.
          update s-info[1] with frame fr.
          find current kdaffil exclusive-lock no-error.
          kdaffil.info[1] = s-info[1].
          find current kdaffil no-lock no-error.
    end.
    when "2" then do:
          find first kdaffil where kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon and kdaffil.code = '26' no-lock no-error.
          if not avail kdaffil then do:
                create kdaffil.
                kdaffil.bank = s-ourbank. kdaffil.code = '26'. kdaffil.kdlon = s-kdlon.
                kdaffil.kdcif = s-kdcif. kdaffil.who = g-ofc. kdaffil.whn = g-today.
                find current kdaffil no-lock no-error.
          end.
          s-info[2] = kdaffil.info[2].
          message 'F1 - Сохранить,   F4 - Выход без сохранения'.
          displ s-info[2] kdaffil.whn kdaffil.who with frame fr2.
          update s-info[2] with frame fr2.
          find current kdaffil exclusive-lock no-error.
          kdaffil.info[2] = s-info[2].
          find current kdaffil no-lock no-error.
    end.
    when "3" then do:
          find first kdaffil where kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon and kdaffil.code = '27' no-lock no-error.
          
          if not avail kdaffil then do:
             for each kdaffil where kdaffil.kdcif = s-kdcif 
                                    and kdaffil.kdlon = s-kdlon and  kdaffil.code = '20' and kdaffil.lonsec = 6 no-lock.
                 create t-name.
                 t-name.name = kdaffil.name.
             end.
             for each t-name.
                create kdaffil. 
                kdaffil.bank = s-ourbank. kdaffil.code = '27'. kdaffil.kdlon = s-kdlon. 
                kdaffil.kdcif = s-kdcif. kdaffil.who = g-ofc. kdaffil.whn = g-today. 
                kdaffil.name = t-name.name.
                find first cif where caps(cif.name) matches "*" + caps(t-name.name) + "*" no-lock no-error.
                if avail cif then run r-lncifot (cif.cif, g-today).
                             else kdaffil.affilate = 'нет информации'.
             end.
             find current kdaffil no-lock no-error.
          end. /* if not avail kdaffil */
          
          define variable s_rowid as rowid.
          {jabrw.i 
          &start     = " "
          &head      = "kdaffil"
          &headkey   = "code"
          &index     = "cifnomc"
          
          &formname  = "pksysc"
          &framename = "kdaffil27"
          &where     = " kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon and kdaffil.code = '27' "
          
          &addcon    = "true"
          &deletecon = "true"
          &precreate = " "
          &postadd   = "  kdaffil.bank = s-ourbank. kdaffil.code = '27'. kdaffil.kdcif = s-kdcif. kdaffil.kdlon = s-kdlon.
                          kdaffil.who = g-ofc. kdaffil.whn = g-today.
                          update kdaffil.name with frame kdaffil27.
                          message 'F1 - Сохранить,   F4 - Выход без сохранения'.
                          displ kdaffil.info[1] kdaffil.whn  kdaffil.who with frame fr3.
                          update kdaffil.info[1] with frame fr3. "
                           
          &prechoose = "message 'F4-Выход,   INS-Вставка.'."
          
          &postdisplay = " "
          
          &display   = "kdaffil.name kdaffil.affilate" 
          
          &highlight = " kdaffil.name "
          
          
          &postkey   = "else if keyfunction(lastkey) = 'RETURN'
                                then do transaction on endkey undo, leave:
                                   update kdaffil.name with frame kdaffil27.
                                   message 'F1 - Сохранить,   F4 - Выход без сохранения'. 
                                   displ kdaffil.info[1] kdaffil.whn  kdaffil.who with frame fr3.
                                   update kdaffil.info[1]  with frame fr3 scrollable. 
                                   kdaffil.who = g-ofc. kdaffil.whn = g-today.
                                   hide frame fr3 no-pause.
                                end. "
          
          &end = "hide frame kdaffil27. 
                   hide frame fr3."
          }
          hide message.
    end.      
    when "4" then return.
end case.


