/* kdzaem.p Электронное кредитное досье

 * MODULE
     Кредитный модуль        
 * DESCRIPTION
       Список документов по заемщику 
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
        11.01.04 marinav
 * CHANGES
        30/04/2004 madiar - просмотр досье филиалов в ГБ
        20/05/2004 madiar - В find kdlon добавил еще проверку на kdcif - иначе находилось несколько записей в kdlon с одинаковыми номерами досье
      30.09.2005 marinav - изменения для бизнес-кредитов
    05/09/06   marinav - добавление индексов
*/



{global.i}
{kd.i}
{pksysc.f}

if s-kdlon = '' then return.

find kdlon where kdlon.kdcif = s-kdcif and kdlon.kdlon = s-kdlon and (kdlon.bank = s-ourbank or s-ourbank = "TXB00")  no-lock no-error.

if not avail kdlon then do:
  message skip " Досье N" s-kdlon "не найдено !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

find kdcif where kdcif.kdcif = s-kdcif no-lock. 

define var v-cod as char.
define var v-descr as char.

define frame fr1 skip(1)
       kddoclon.rdt[1]  label "ДАТА ПРИНЯТИЯ"  skip(1)
       kddoclon.vid     label "ВИД ДОК-ТА   "  format 'x(20)' skip(1)
       kddoclon.info[1]  label "ЗАМЕЧАНИЯ" VIEW-AS EDITOR SIZE 60 by 9 skip(1)
       kddoclon.whn      label "ПРОВЕДЕНО " kddoclon.who  no-label skip(1)
       with overlay width 80 side-labels column 3 row 3 
       title "ИНФОРМАЦИЯ О ДОКУМЕНТАХ ЗАЕМЩИКА" .

on help of kddoclon.vid in frame fr1 do: 
  run uni_book ("kdvid", "*", output v-cod).  
  kddoclon.vid = entry(1, v-cod).
  find bookcod where bookcod.bookcod = "kdvid" and bookcod.code = kddoclon.vid no-lock no-error.
    if avail bookcod then v-descr = bookcod.name. 
    displ v-descr @ kddoclon.vid with frame fr1.
end.

define variable s_rowid as rowid.

find first kddoclon where kddoclon.kdcif = s-kdcif and kddoclon.kdlon = s-kdlon 
                      and kddoclon.fu = 3  no-lock no-error.
if not avail kddoclon then do:
   
   if kdlon.bank = s-ourbank then do:
      if keyfunction(lastkey) eq "end-error" then return.
      for each kddocs where kddocs.kb = kdlon.manager and kddocs.zaemfu = inte(kdcif.manager) and kddocs.fu = 3 no-lock.
          create kddoclon.
          assign kddoclon.bank = s-ourbank
                 kddoclon.kdcif = s-kdcif
                 kddoclon.kdlon = s-kdlon
                 kddoclon.ln = kddocs.ln
                 kddoclon.fu = kddocs.fu
                 kddoclon.type = kddocs.type
                 kddoclon.info[5] = string(kddocs.ud).
      end.
   end.
   else do:
     message skip " Запрашиваемые данные не были введены " skip(1) view-as alert-box buttons ok title " Нет данных! ".
     return.
   end.
end.


{jabrw.i 
&start     = " "
&head      = "kddoclon"
&headkey   = "lnn"
&index     = "ciflonlnn"

&formname  = "pksysc"
&framename = "kddocs1"
&where     = " kddoclon.kdcif = s-kdcif and kddoclon.kdlon = s-kdlon and kddoclon.fu = 3 and kddoclon.type = '00' "

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
                              message 'F1 - Сохранить,   F4 - Выход без сохранения'. 
                              if kddoclon.rdt[1] = ? then kddoclon.rdt[1] = g-today.
                         end.
                         else
                           if kddoclon.rdt[1] = ? then do:
                             message skip ' Запрашиваемые данные не были введены ' skip(1) view-as alert-box buttons ok title ' Нет данных! '.
                             bell. undo, retry.
                           end.
                         displ kddoclon.rdt[1] kddoclon.vid kddoclon.info[1] kddoclon.whn  kddoclon.who with frame fr1.
                         if kdlon.bank = s-ourbank then do:
                              update kddoclon.rdt[1] kddoclon.vid kddoclon.info[1]  with frame fr1 scrollable. 
                              kddoclon.who = g-ofc. kddoclon.whn = g-today. 
                              pause 0.
                         end.
                         else do:
                              displ kddoclon.rdt[1] kddoclon.vid kddoclon.info[1] kddoclon.who kddoclon.whn with frame fr1 scrollable.
                              pause.
                         end.
                         hide frame fr1 no-pause.
                       end. "

&end = "hide frame kddocs1. 
         hide frame fr1."
}
hide message.

