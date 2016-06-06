/* kddock1.p Электронное кредитное досье

 * MODULE
     Кредитный модуль        
 * DESCRIPTION
       Список документов по залогу 
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

find kdlon where kdlon.kdcif = s-kdcif and kdlon.kdlon = s-kdlon and (kdlon.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.
find kdcif where kdcif.kdcif = s-kdcif. 

if not avail kdlon then do:
  message skip " Досье N" s-kdlon "не найдено !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

define var v-cod as char.
define var v-descr as char.

define frame fr1 skip(1)
       kddoclon.rdt[1]  label "ДАТА ПРИНЯТИЯ"  skip(1)
       kddoclon.vid     label "ВИД ДОК-ТА   "  format 'x(20)' skip(1)
       kddoclon.info[1]  label "ЗАМЕЧАНИЯ" VIEW-AS EDITOR SIZE 60 by 10 skip(1)
       kddoclon.whn      label "ПРОВЕДЕНО " kddoclon.who  no-label skip(1)
       with overlay width 80 side-labels column 3 row 3 
       title "ИНФОРМАЦИЯ О ДОКУМЕНТАХ ЗАЛОГОДАТЕЛЯ" .

on help of kddoclon.vid in frame fr1 do: 
  run uni_book ("kdvid", "*", output v-cod).  
  kddoclon.vid = entry(1, v-cod).
  find bookcod where bookcod.bookcod = "kdvid" and bookcod.code = kddoclon.vid no-lock no-error.
    if avail bookcod then v-descr = bookcod.name. 
    displ v-descr @ kddoclon.vid with frame fr1.
end.
define variable s_rowid as rowid.
define input parameter v-ln as inte .

find first kddoclon where kddoclon.kdcif = s-kdcif and kddoclon.kdlon = s-kdlon and kddoclon.lnn = v-ln no-lock no-error.
if not avail kddoclon then do:

   if s-ourbank = kdlon.bank then do:
   
      def var v-zal   as char format "x(20)".
      def var prz as deci.
      def button  btn1  label "    Физическое лицо    ".
      def button  btn2  label "    Юридическое лицо   ".
      def button  btn3  label "          Выход        ".
      
      def frame   frame1
          skip(1) btn1 skip(0) btn2 skip(0) btn3 with centered title "Список документов для КД:" row 5 .
      
      on choose of btn1,btn2,btn3 do:    
         if self:label = "Физическое лицо" then do:
               prz = 1.
               run uni_book ("zalog", "", output v-zal).
               end.
            else
              if self:label = "Юридическое лицо " then do:
                 prz = 0.
                 run uni_book ("zalog", "", output v-zal).
              end.
              else leave.    
      end.
      enable all with frame frame1.
      wait-for choose of btn1, btn2, btn3.
      if keyfunction(lastkey) eq "end-error" then return.
      v-zal = entry(1, v-zal).
      for each kddocs where kddocs.kb = kdlon.manager and kddocs.zaemfu = inte(kdcif.manager) and kddocs.fu = prz and kddocs.type = v-zal no-lock.
          create kddoclon.
          assign kddoclon.bank = s-ourbank
                 kddoclon.kdcif = s-kdcif
                 kddoclon.kdlon = s-kdlon
                 kddoclon.lnn = v-ln
                 kddoclon.ln = kddocs.ln
                 kddoclon.fu = kddocs.fu
                 kddoclon.type = kddocs.type.
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
&where     = " kddoclon.kdcif = s-kdcif and kddoclon.kdlon = s-kdlon and kddoclon.lnn = v-ln "

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
                         if s-ourbank = kdlon.bank then do:
                              message 'F1 - Сохранить,   F4 - Выход без сохранения'. 
                              if kddoclon.rdt[1] = ? then kddoclon.rdt[1] = g-today.
                         end.
                         else 
                           if kddoclon.rdt[1] = ? then do:
                              message skip ' Запрашиваемые данные не были введены ' skip(1) view-as alert-box buttons ok title ' Нет данных! '.
                              bell. undo, retry.
                           end.
                         displ kddoclon.rdt[1] kddoclon.vid kddoclon.info[1] kddoclon.whn  kddoclon.who with frame fr1.
                         if s-ourbank = kdlon.bank then do:
                              update kddoclon.rdt[1] kddoclon.vid kddoclon.info[1]  with frame fr1 scrollable. 
                              kddoclon.who = g-ofc. kddoclon.whn = g-today. 
                              pause 0.
                         end.
                         else do:
                              display kddoclon.rdt[1] kddoclon.vid kddoclon.info[1] kddoclon.who kddoclon.whn with frame fr1 scrollable. 
                              pause.
                         end.
                         hide frame fr1 no-pause.
                       end. "

&end = "hide frame kddocs1. 
         hide frame fr1."
}
hide message.

