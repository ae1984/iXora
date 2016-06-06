/* create_mobipay.p
 * MODULE
        отправка платежей Картел  в он лайн через ЕПС mobipay
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        def var v-res as logi.
        def var v-err as char.
        def var v-pay-id as char.

        run create_mobipay ( "3332100393", "2", 100, output v-res, output v-pay-id, output v-err).
        displ v-res v-pay-id v-err.

 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        16/05/06 tsoy
 * CHANGES
	29.08.2006 tsoy    - обрабтка ошибки -40
    17/02/2010 madiyar - xml.i был сильно изменен для интернет-банкинга, старая версия i-шки используется здесь как xml_scan.i
*/


{xml_scan.i}

def input parameter p-tel-number as char.
def input parameter p-pay-type as char.
def input parameter p-pay-amout as deci.

def output parameter p-rez as logi.
def output parameter p-pay-id as char.
def output parameter p-err-name as char.

p-rez      = false.
p-err-name = "00".

def var v-s as char.
def var v-mpay-request as char.

def var m-mpay-request  as memptr.
def var m-mpay-check  as memptr.
def var m-mpay-payment  as memptr.

def var v-l as logi.

def var v-status_code as char.
def var v-pay_id as char.

define var mpay-request as handle.
create x-document mpay-request.

define var mpay-check as handle.
create x-document mpay-check.

define var mpay-payment as handle.
create x-document mpay-payment.

def var tempstr as char.

input through value( ' hostname ').
repeat:
    import tempstr.
end.
input close.

/*

if tempstr <> "texaka1" then return.
p-tel-number = "3332100393".
p-pay-amout  = 100.

*/

p-pay-type   = "4".


def var  v-err      as logi init false.
def var  v-errname  as char.

v-s             = "".
v-mpay-request  = "".

input through value("LC_ALL=C; export LC_ALL; /pragma/bin9/mpay-request.pl " + p-tel-number + " " + replace(string(p-pay-amout), ",",".") + " " + p-pay-type ) no-echo.
repeat:
   import unformatted v-s.
   v-mpay-request = v-mpay-request + v-s.
end.

set-size(m-mpay-request) = length(v-mpay-request + '\n' ) + 1.
put-string(m-mpay-request, 1) = v-mpay-request + '\n'.


v-l = mpay-request:load('memptr', m-mpay-request, false) no-error.

if not v-l then do:

   v-err     = true.
   v-errname = "Error: Создать платеж 1 " + error-status:get-message(1).

end.

/* анализируем ответ */

if not v-err then do:

   run get-node (mpay-request, "status_code", output v-status_code) no-error.
   run get-node (mpay-request, "pay_id", output v-pay_id) no-error.

   if v-status_code <> "20" then do:
       v-err     = true.
       v-errname = "Error: Создать платеж 2 " + v-status_code.
   end.

end.

/* посылаем запрос на проверку  транзакции */
if not v-err and v-pay_id <> "" then do:

      v-s             = "".
      v-mpay-request  = "".

      input through value("LC_ALL=C; export LC_ALL; /pragma/bin9/mpay-check.pl " + v-pay_id ) no-echo.
      repeat:
         import unformatted v-s.
         v-mpay-request = v-mpay-request + v-s.
      end.

      set-size(m-mpay-check) = length(v-mpay-request + '\n' ) + 1.
      put-string(m-mpay-check, 1) = v-mpay-request + '\n'.

      v-l = mpay-check:load('memptr', m-mpay-check, false) no-error.


      if not v-l then do:

         v-err     = true.
         v-errname = "Error: Проверить платеж 3 " + error-status:get-message(1).

      end.

      /* анализируем ответ */

      if not v-err then do:

         run get-node (mpay-check, "status_code", output v-status_code) no-error.

         if v-status_code <> "21" then do:
             v-err     = true.
             v-errname = "Error: Проверить платеж 4 " + v-status_code.
         end.

      end.

end.

/* посылаем запрос на акцепт транзакции */
if not v-err and v-pay_id <> "" then do:

     v-s             = "".
     v-mpay-request  = "".

     input through value("LC_ALL=C; export LC_ALL; /pragma/bin9/mpay-payment.pl " + v-pay_id ) no-echo.
     repeat:
        import unformatted v-s.
        v-mpay-request = v-mpay-request + v-s.
     end.

     set-size(m-mpay-payment) = length(v-mpay-request + '\n' ) + 1.
     put-string(m-mpay-payment, 1) = v-mpay-request + '\n'.

     v-l = mpay-payment:load('memptr', m-mpay-payment, false) no-error.

     if not v-l then do:

        v-err     = true.
        v-errname = "Error: Акцепт  платежа 5 " + error-status:get-message(1).

     end.

     /* анализируем ответ */

     if not v-err then do:

        run get-node (mpay-payment, "status_code", output v-status_code) no-error.

        if v-status_code <> "22" then do:
            v-err     = true.
             v-errname = "Error: Проверить платеж 6 " + v-status_code.
        end.

     end.

end.


if not v-err then do:
   p-rez      = true.
   p-err-name = v-status_code.
   p-pay-id  = v-pay_id.
end. else do:
   p-rez      = false.

   p-err-name = v-errname + " Code: " + v-status_code.

   if v-status_code = "-49" or v-status_code = "-59" or v-status_code = "-40" then
       if v-pay_id <> "" then
       p-err-name = v-status_code.

end.
