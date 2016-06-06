/* kdzaemu.p Электронное кредитное досье

 * MODULE
     Кредитный модуль        
 * DESCRIPTION
       Список документов по заемщику для юристов
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
        13.01.04 marinav
 * CHANGES
        30/04/2004 madiar - просмотр досье филиалов в ГБ
        20/05/2004 madiar - В find kdlon добавил еще проверку на kdcif - иначе находилось несколько записей в kdlon с одинаковыми номерами досье
        25.04.2005 marinav - в форме "примечение" заменено на 3 других поля
        03.05.2005 marinav - добавлена в форму помощь
      30.09.2005 marinav - изменения для бизнес-кредитов
    05/09/06   marinav - добавление индексов
*/



{global.i}
{kd.i}
{pksysc.f}

if s-kdlon = '' then return.

find kdlon where  kdlon.kdcif = s-kdcif and kdlon.kdlon = s-kdlon and (kdlon.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.

if not avail kdlon then do:
  message skip " Досье N" s-kdlon "не найдено !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

define var v-cod as char.
define var v-descr as char.

define frame fr1 skip(1)
       kddoclon.rdt[2]  label "ДАТА ПРИНЯТИЯ"  skip
       kddoclon.vid     label "ВИД ДОК-ТА   "  format 'x(20)' skip
       "ЗАМЕЧАНИЯ, ПОДЛЕЖАЩИЕ УСТРАНЕНИЮ ДО ПРЕДОСТАВЛЕНИЯ ЗАЙМА:" skip
       kddoclon.info[2]  no-label VIEW-AS EDITOR SIZE 65 by 3 skip
       "ЗАМЕЧАНИЯ, ПОДЛЕЖАЩИЕ УСТРАНЕНИЮ ПОСЛЕ ПРЕДОСТАВЛЕНИЯ ЗАЙМА:" skip
       kddoclon.info[3]  no-label  VIEW-AS EDITOR SIZE 65 by 3 skip
       "ЗАМЕЧАНИЯ, НОСЯЩИЕ ИНФОРМАЦИОННЫЙ ХАРАКТЕР:" skip
       kddoclon.info[4]  no-label VIEW-AS EDITOR SIZE 65 by 3 skip
       kddoclon.whnu      label "ПРОВЕДЕНО " kddoclon.whou  no-label skip(1)
       with overlay width 80 side-labels column 3 row 3 
       title "ИНФОРМАЦИЯ О ДОКУМЕНТАХ ЗАЕМЩИКА" .

define variable s_rowid as rowid.

find first kddoclon where kddoclon.kdcif = s-kdcif and kddoclon.kdlon = s-kdlon 
                      and kddoclon.fu = 3 and kddoclon.info[5] = '1' no-lock no-error.
if not avail kddoclon then do:
         message skip " По этому клиенту нет документов в досье !~n Обратитесь в Кредитный департамент ! " skip(1)
                view-as alert-box buttons ok title " ВНИМАНИЕ ! ".
         return.
end.

{jabrw.i 
&start     = " "
&head      = "kddoclon"
&headkey   = "lnn"
&index     = "ciflonlnn"

&formname  = "pksysc"
&framename = "kddocs1"
&where     = " kddoclon.kdcif = s-kdcif and kddoclon.kdlon = s-kdlon and kddoclon.fu = 3 and kddoclon.type = '00' and kddoclon.info[5] = '1' "

&addcon    = "false"
&deletecon = "false"
&predisplay = " find first kddocs where kddocs.ln = kddoclon.ln no-lock no-error. "
&precreate = " "
&postadd   = " " 
                 
&prechoose = "hide frame fr1. message 'F4-Выход '."

&postdisplay = " "

&display   = " kddocs.name " 

&highlight = " kddocs.name "

&postkey   = "else if keyfunction(lastkey) = 'RETURN'
                 then do transaction on endkey undo, leave:
                    if kdlon.bank = s-ourbank then do:
                         message 'TAB - переход м/у полями, F1 - Сохранить,   F4 - Выход без сохранения'.
                         if kddoclon.rdt[2] = ? then kddoclon.rdt[2] = g-today.
                    end.
                    else
                      if kddoclon.rdt[2] = ? then do:
                         message skip ' Запрашиваемые данные не были введены ' skip(1) view-as alert-box buttons ok title ' Нет данных! '.
                         bell. undo, retry.
                      end.
                    displ kddoclon.rdt[2] kddoclon.vid kddoclon.info[2] kddoclon.info[3] kddoclon.info[4] kddoclon.whnu  kddoclon.whou with frame fr1.
                    if kdlon.bank = s-ourbank then do:
                         update kddoclon.rdt[2] kddoclon.info[2]  kddoclon.info[3] kddoclon.info[4] with frame fr1 scrollable. 
                         kddoclon.whou = g-ofc. kddoclon.whnu = g-today. 
                         pause 0.
                    end.
                    else do:
                         display kddoclon.rdt[2] kddoclon.info[2] kddoclon.info[3] kddoclon.info[4] kddoclon.whou kddoclon.whnu with frame fr1 scrollable. 
                         pause.
                    end.
                    hide frame fr1 no-pause.
                  end. "

&end = "hide frame kddocs1. 
         hide frame fr1."
}
hide message.

