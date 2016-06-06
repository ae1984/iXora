/* KMOB_ps.p
 * MODULE
        
 * DESCRIPTION
        Отправка уведомлений KMobile
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
        23.08.2002 sasco
 * CHANGES
        16.01.2004 nadejda - отправитель письма по эл.почте изменен на общий адрес iXora@metrobank.kz
        14.03.2005 sasco   - Добавил вывод 333 в формат файла
        03.08.2005 kanat   - Добавил условие по просьбе получателя платежей - если платеж - безнал., то 
        		     вместо префикса и номера телефлона ставим 1000000000,
                             так как есть номер телефона 1000000 в K-Mobile.
	25/11/05 u00121    - заменил kartel.kz на kar-tel.kz
	24.06.2006 tsoy    - Отправка платежа в он лайн
	29.08.2006 tsoy    - обрабтка ошибки -40 
	24.04.2007 id00004 - изменил адреса электронной почты
*/


{lgps.i "new"}

def var dlm as char init " " format "x(1)".
def var crlf as char format "x(1)".
def var cnt as int init 0.
def var fname as char.
def var cnt0 as int init 0.
def var cTitle as char.
def var dates as char.
def var v-s as char.
def var v-v as char.


def var v-res as logi.
def var v-err as char.
def var v-pay-id as char.

def var v-trx-amount-beeline as char.

crlf = chr(10).

for each mobtemp where state = 0: mobtemp.state = 1. end.


select count (*) into cnt0 from mobtemp where state = 1.

if can-find (first mobtemp where mobtemp.state = 1 no-lock) then do:

      run savelog ("kmob_ps", "").
      run savelog ("kmob_ps", "Начало отправки платежей").

      output to mobtemp.txt.

      for each mobtemp where state = 1:

          v-trx-amount-beeline = "0".
          v-res = false.
          v-trx-amount-beeline = replace(string(mobtemp.sum), ",","."). 

          run create_mobipay ( mobtemp.phone, "2", v-trx-amount-beeline, output v-res, output v-pay-id, output v-err).

          if v-res then do: 

                find mobi-pay where mobi-pay.receipt_num = mobtemp.ref  no-error.

                if avail mobi-pay then do:
                   mobi-pay.pay_id  = integer (v-pay-id) no-error.    
                end.

                run savelog ("kmob_ps", " - тел. " + mobtemp.phone + 
                                        " дата "   + string (valdate) +
                                        " время "  + string(mobtemp.ctime, "hh:mm:ss") +
                                        " сумма "  + string(mobtemp.sum, "zzzzzzzzz9.99") +
                                        " л/с "    + string(mobtemp.ls) +
                                        " jh "     + string(mobtemp.ref) +
                                        " "        + mobtemp.npl).

                cnt = cnt + 1.

                mobtemp.state = 2.

                run mail("it@metrobank.kz", 
                         "METROBANK SENDER <iXora@metrobank.kz>",
                         "K-MOBILE PAYMENTS",
                         "K-MOBILE PAYMENTS. " + mobtemp.phone + " " + string(mobtemp.sum, "zzzzzzzzz9.99") + " " + string(mobtemp.ref),
                         "1",
                         "",
                         "" ).

                
          end. else do:

                run savelog ("kmob_ps", " ERRRO: - тел. " + v-err + mobtemp.phone + 
                                        " дата "   + string (valdate) +
                                        " время "  + string(mobtemp.ctime, "hh:mm:ss") +
                                        " сумма "  + string(mobtemp.sum, "zzzzzzzzz9.99") +
                                        " л/с "    + string(mobtemp.ls) +
                                        " jh "     + string(mobtemp.ref) +
                                        " "        + mobtemp.npl).

               /*  -49 или -59 тогда не повоторять а просить Картел разобраться  */
               if v-err = "-49" or v-err = "-59" or v-err = "-40" then 
                    mobtemp.state = 2.



                run mail("it@metrobank.kz", 
                         "TEXAKABANK SENDER <abpk@elexnet.kz>",
                         "K-MOBILE PAYMENTS. Error ",
                         "K-MOBILE PAYMENTS. Error " + v-err + "  " + mobtemp.phone + " " + string(mobtemp.sum, "zzzzzzzzz9.99") + " " + string(mobtemp.ref),
                         "1",
                         "",
                         "" ).


         end.

      end.

      output close.

end.

for each mobtemp where mobtemp.valdate < today  and mobtemp.state = 2:
       delete mobtemp.
end.
