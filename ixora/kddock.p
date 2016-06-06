/* kddock.p Электронное кредитное досье

 * MODULE
     Кредитный модуль        
 * DESCRIPTION
       Список залогов и документов по залогам 
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

if s-kdlon = '' then return.

find kdlon where kdlon.kdcif = s-kdcif and kdlon.kdlon = s-kdlon and (kdlon.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.

if not avail kdlon then do:
  message skip " Досье N" s-kdlon "не найдено !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

define variable s_rowid as rowid.
define var ja as logi init no.


{jabrw.i 
&start     = " "
&head      = "kdaffil"
&headkey   = "code"
&index     = "cifnomc"

&formname  = "pksysc"
&framename = "kdaffil20"
&where     = " kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon and kdaffil.code = '20' "

&addcon    = "false"
&deletecon = "false"
&precreate = " "
&postadd   = " "
                 
&prechoose = " message 'F4-Выход,   INS-Вставка,   F10 - удалить список документов'."

&postdisplay = " "

&display   = " kdaffil.ln kdaffil.lonsec kdaffil.name kdaffil.crc kdaffil.amount kdaffil.info[2] kdaffil.amount_bank " 

&highlight = " kdaffil.ln  kdaffil.lonsec "


&postkey   = "else  
                 if keyfunction(lastkey) = 'RETURN'
                 then do transaction on endkey undo, leave:
                   message 'F4-Выход, '. 
                   run kddock1 (kdaffil.ln). 
                 end. 
                 if  lastkey = KEYCODE('F10') and s-ourbank = kdlon.bank
                 then do transaction on endkey undo, leave:
                    find first kddoclon where kddoclon.kdcif = s-kdcif and kddoclon.kdlon = s-kdlon 
                           and kddoclon.lnn = kdaffil.ln no-lock no-error.  
                    if avail kddoclon then do:  message 'Удалить список документов ?' update ja.
                    if ja then do: for each kddoclon where kddoclon.kdcif = s-kdcif and kddoclon.kdlon = s-kdlon 
                           and kddoclon.lnn = kdaffil.ln . delete kddoclon. end. end. end.
                 end. "

&end = "hide frame kdaffil20. "
}
hide message.

