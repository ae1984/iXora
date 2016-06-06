/* kdobes.p Электронное кредитное досье

 * MODULE
     Кредитный модуль        
 * DESCRIPTION
       Список залогов 
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
        11.12.03 marinav
 * CHANGES     
        11.01.04 marinav - добавила пор номер залога для связки его со списком документов
        30/04/2004 madiar - просмотр досье филиалов в ГБ
        20/05/2004 madiar - В find kdlon добавил еще проверку на kdcif - иначе находилось несколько записей в kdlon с одинаковыми номерами досье
    05/09/06   marinav - добавление индексов
*/



{global.i}
{kd.i}
{pksysc.f}

def var kdaffilcod as char.

if s-kdlon = '' then return.

find kdlon where kdlon.kdcif = s-kdcif and kdlon.kdlon = s-kdlon and (kdlon.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.

if not avail kdlon then do:
  message skip " Досье N" s-kdlon "не найдено !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

if kdlon.bank = s-ourbank then kdaffilcod = '35'.
else kdaffilcod = '45'.

define frame fr skip(1)
       kdaffil.info[1] label "Описание" VIEW-AS EDITOR SIZE 60 by 10  skip(1)
       kdaffil.whn      label "ПРОВЕДЕНО " kdaffil.who  no-label skip(1)
       with overlay width 80 side-labels column 3 row 3 
       title "ИНФОРМАЦИЯ ОБ ОБЕСПЕЧЕНИИ" .


define new shared variable grp as integer init 5.
define var v-cod as char.
define variable s_rowid as rowid.
define var v-ln as inte init 1.
define buffer b-kdaffil for kdaffil.

find first kdaffil where kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon and kdaffil.code = kdaffilcod no-lock no-error.
if not avail kdaffil then do:
   for each b-kdaffil where b-kdaffil.kdcif = s-kdcif and b-kdaffil.kdlon = s-kdlon and b-kdaffil.code = '20' no-lock:
       create kdaffil.
       kdaffil.code = kdaffilcod.
       buffer-copy b-kdaffil except b-kdaffil.code to kdaffil.
       find first crc where crc.crc = kdaffil.crc no-lock no-error.
       if avail crc then kdaffil.info[3] = crc.code.    /*запишем сюда код валюты*/
       find first lonsec where lonsec.lonsec = kdaffil.lonsec no-lock no-error.
       if avail lonsec then kdaffil.info[4] = lonsec.des. /*сюда вид обеспечения*/
   end.
   release kdaffil.
end.

{jabrw.i 
&start     = " "
&head      = "kdaffil"
&headkey   = "code"
&index     = "cifnomc"

&formname  = "pksysc"
&framename = "kdaffil35"
&where     = " kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon and kdaffil.code = kdaffilcod "

&addcon    = "false"
&deletecon = "true"
&precreate = " "
&postadd   = " "
                 
&prechoose = " message 'F4-Выход,     Enter-Описание залога,      Ctrl+D - удалить залог'."
&postdisplay = " "
&predisplay   = " "
&display   = " kdaffil.ln kdaffil.info[4] kdaffil.info[3] kdaffil.amount_bank " 
&highlight = " kdaffil.ln  kdaffil.info[4] kdaffil.info[3] kdaffil.amount_bank "
&postkey   = "else 
                  if keyfunction(lastkey) = 'RETURN'
                  then do transaction on endkey undo, leave:
                          message 'F1, Enter - Выход '. 
                          displ kdaffil.info[1] kdaffil.whn  kdaffil.who with frame fr. pause .
                          kdaffil.who = g-ofc. kdaffil.whn = g-today. 
                          hide frame fr no-pause. 
                  end. "

&end = "hide frame kdaffil35. 
         hide frame fr."
}
hide message.



