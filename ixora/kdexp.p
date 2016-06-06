/* kdexp.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Потребители по валютным контрактам
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4.11.2 Бизнес 
 * AUTHOR
        27.01.2004 marinav
 * CHANGES
        30/04/2004 madiar - Просмотр клиентов филиалов в ГБ
        08/06/2004 madiar - Проверка корректности ввода валюты
    05/09/06   marinav - добавление индексов
*/



{global.i}
{kd.i}
{pksysc.f}

if s-kdcif = '' then return.

find kdcif where  kdcif.kdcif = s-kdcif and (kdcif.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.

if not avail kdcif then do:
  message skip " Клиент N" s-kdcif "не найдено !" skip(1)
    view-as alert-box buttons ok title " ОШИБКА ! ".
  return.
end.

def new shared var s-contract like vccontrs.contract.
def new shared var v-sumgtd as deci format "zzz,zzz,zzz,zzz,zz9.99-".
def new shared var v-suminv as deci format "zzz,zzz,zzz,zzz,zz9.99-".
def new shared var v-suminv% as deci format "zzz,zzz,zzz,zzz,zz9.99-".
def new shared var v-sumplat as deci format "zzz,zzz,zzz,zzz,zz9.99-".
def new shared var v-sumkon as deci format "zzz,zzz,zzz,zzz,zz9.99-".
def new shared var v-sumost as deci format "zzz,zzz,zzz,zzz,zz9.99-".
def new shared var v-sumexc as deci format "zzz,zzz,zzz,zzz,zz9.99-".
def new shared var v-sumakt as deci format "zzz,zzz,zzz,zzz,zz9.99-".
define var v-partnername as char.

define frame fr skip(1)
       kdaffil.dat         label "СРОК КОНТР " skip
       kdaffil.amount      label "СУММА КОНТР" format "zzz,zzz,zzz,zzz,zz9.99-" skip
       kdaffil.crc         label "ВАЛЮТА     " validate (can-find (crc where crc.crc = kdaffil.crc no-lock), " Неверный код ! Выберите из справочника") skip
       kdaffil.info[2]     label "ВАЛЮТА ПЛАТ" skip
       kdaffil.amount_bank label "ОПЛАЧЕНО   " format "zzz,zzz,zzz,zzz,zz9.99-" skip
       v-sumost            label "ОСТАТОК    " skip
       kdaffil.info[1]     label "ПРЕДМЕТ    " VIEW-AS EDITOR SIZE 60 by 4 skip
       kdaffil.info[3]     label "КОММЕНТАРИИ" VIEW-AS EDITOR SIZE 60 by 4 skip
       kdaffil.whn         label "ПРОВЕДЕНО  " kdaffil.who  no-label skip
       with overlay width 80 side-labels column 3 row 3 
       title "ИНФОРМАЦИЯ О КОНТРАКТАХ" .

if (s-ourbank = kdcif.bank) then do:

find first kdaffil where kdaffil.bank = s-ourbank and kdaffil.kdcif = s-kdcif 
                     and kdaffil.code = '25' no-lock no-error.
if not avail kdaffil then do:
    
    for each vccontrs where vccontrs.bank = s-ourbank and vccontrs.cif = s-kdcif 
                        and vccontrs.expimp = 'E' no-lock.
      s-contract = vccontrs.contract.
      run vcctsumm. 
      if vccontrs.ctsum - v-sumplat > 0 then do:
          find vcpartners where vcpartners.partner = vccontrs.partner no-lock no-error.
          if avail vcpartners then
             v-partnername = trim(trim(vcpartners.name) + ' ' + trim(vcpartners.formasob)).
             else v-partnername = ''.
          create kdaffil.
          assign kdaffil.bank = s-ourbank
                 kdaffil.kdcif = s-kdcif
                 kdaffil.code = '25'
                 kdaffil.name = v-partnername
                 kdaffil.res = vccontrs.ctnum
                 kdaffil.dat = vccontrs.lastdate
                 kdaffil.amount = vccontrs.ctsum
                 kdaffil.crc = vccontrs.ncrc
                 kdaffil.info[2] = vccontrs.ctvalpl
                 kdaffil.amount_bank = v-sumplat
                 kdaffil.who = g-ofc kdaffil.whn = g-today. 
      end.
    end.

end.

end. /* if (s-ourbank = kdcif.bank) */

define variable s_rowid as rowid.

{jabrw.i 
&start     = " "
&head      = "kdaffil"
&headkey   = "code"
&index     = "cifnomc"

&formname  = "pksysc"
&framename = "kdaffil25"
&where     = " kdaffil.kdcif = s-kdcif and kdaffil.code = '25' "

&addcon    = "(s-ourbank = kdcif.bank)"
&deletecon = "(s-ourbank = kdcif.bank)"
&precreate = " "
&postadd   = "      kdaffil.bank = s-ourbank. kdaffil.code = '25'. kdaffil.kdcif = s-kdcif. kdaffil.who = g-ofc. kdaffil.whn = g-today. 
                    update kdaffil.name kdaffil.res with frame kdaffil25 .
                    message 'F1 - Сохранить,   F4 - Выход без сохранения'.
                    v-sumost = kdaffil.amount - kdaffil.amount_bank.
                    displ kdaffil.dat kdaffil.amount kdaffil.crc kdaffil.info[2] kdaffil.amount_bank
                    v-sumost kdaffil.info[1] kdaffil.info[3] kdaffil.whn kdaffil.who with frame fr.                  
                    update kdaffil.dat kdaffil.amount kdaffil.crc kdaffil.info[2] kdaffil.amount_bank
                    v-sumost with frame fr. update kdaffil.info[1] with frame fr.
                    update kdaffil.info[3] with frame fr."
                     
&prechoose = " message ' F4 - Выход '. "
                       
&postdisplay = " "

&display   = "kdaffil.name kdaffil.res " 

&highlight = " kdaffil.name kdaffil.res "


&postkey   = "else if keyfunction(lastkey) = 'RETURN'
                      then do transaction on endkey undo, leave:
                          if s-ourbank = kdcif.bank then do:
                              update kdaffil.name kdaffil.res with frame kdaffil25.
                              message 'F1 - Сохранить,   F4 - Выход без сохранения'.
                              v-sumost = kdaffil.amount - kdaffil.amount_bank.
                              displ kdaffil.dat kdaffil.amount kdaffil.crc kdaffil.info[2] kdaffil.amount_bank
                                    v-sumost kdaffil.info[1] kdaffil.info[3] kdaffil.whn kdaffil.who with frame fr.
                              update kdaffil.dat kdaffil.amount kdaffil.crc kdaffil.info[2] kdaffil.amount_bank
                                     v-sumost with frame fr. message 'F1 - Сохранить,   F4 - Выход без сохранения'. update kdaffil.info[1] with frame fr.
                              message 'F1 - Сохранить,   F4 - Выход без сохранения'. update kdaffil.info[3] with frame fr.       
                              kdaffil.who = g-ofc. kdaffil.whn = g-today. 
                              hide frame fr no-pause. 
                          end.
                          else do:
                            v-sumost = kdaffil.amount - kdaffil.amount_bank.
                            displ kdaffil.dat kdaffil.amount kdaffil.crc kdaffil.info[2] kdaffil.amount_bank
                            v-sumost kdaffil.info[1] kdaffil.info[3] kdaffil.whn kdaffil.who with frame fr. 
                            pause.
                            hide frame fr no-pause.        
                          end.
                      end. "

&end = "hide frame kdaffil25. 
         hide frame fr."
}
hide message.


            

