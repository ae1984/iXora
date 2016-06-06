/* kddocu.p Электронное кредитное досье

 * MODULE
     Кредитный модуль        
 * DESCRIPTION
       Список залогов и документов по залогам для юристов
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
        12.01.04 marinav
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

find kdlon where  kdlon.kdcif = s-kdcif and kdlon.kdlon = s-kdlon and (kdlon.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.

if not avail kdlon then do:
  message skip " Досье N" s-kdlon "не найдено !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

define variable s_rowid as rowid.

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
                 
&prechoose = " message 'F4-Выход,   INS-Вставка.'."

&postdisplay = " "

&display   = " kdaffil.ln kdaffil.lonsec kdaffil.name kdaffil.crc kdaffil.amount kdaffil.info[2] kdaffil.amount_bank " 

&highlight = " kdaffil.ln  kdaffil.lonsec "


&postkey   = "else  
                 if keyfunction(lastkey) = 'RETURN'
                 then do transaction on endkey undo, leave:
                   message 'F4-Выход, '. 
                   run kddocu1 (kdaffil.ln). 
                 end. "

&end = "hide frame kdaffil20. "
}
hide message.

