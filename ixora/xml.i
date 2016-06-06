/* xml.i
 * MODULE
        Вспомогательные функции для работы с XML
 * DESCRIPTION
        Вспомогательные функции для работы с XML
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        24/07/06 tsoy
 * CHANGES
        19/03/2008 madiyar - закомментировал две последние функции, обращающиеся к таблице uid-jh (БД ELX)
        16.03.2011 id00004 - добавил обработку комиссии За счет  отправителя, получателя для валютного платежа
        24.11.2011 id00004 добавил обработку БИК для RUR
        18.07.2012 evseev - ТЗ-1349
        28.08.2013 evseev - tz-926
        08.11.2013 zhassulan - ТЗ 1417, новые поля ИНН и КПП для рубл.платежей
*/

def stream  log-stream.

procedure x_log:

def input parameter fname    as char.
def input parameter s1       as char.
def input parameter s2       as char.

    output stream log-stream to value( "/tmp/" + fname + '.log') append no-echo.
    put stream log-stream unformatted string(today ) + ' ' + string( time, 'hh:mm:ss' ) + ' '
    s1 format 'x(22)'
    s2
    skip.
    output stream log-stream close.

end procedure.

procedure get-attr.

    def input  param p-in as handle.
    def input  param p-name as char.
    def input  param p-attr as char.
    def output param p-out as char.

    def var v-res as logi.

    v-res = false.

    def var h-root as handle.

    create x-noderef h-root no-error.

    p-in:get-document-element (h-root).

    /* в том случае есди искомая нода как root */
    if h-root:name = p-name then do:

        p-out = h-root:get-attribute (p-attr).
        v-res = true.
        return.

    end.

    if h-root:num-children < 1 then return.

    run find-child(input h-root, input-output p-name, input-output p-attr, input-output v-res, input-output p-out) .

    if v-res then do:

         if p-out = "" then
             return error 'Attribute empty ' + p-name + '->' + p-attr + ' (700001)'.
         else
             return.
    end.

    return error 'Attribute not found ' + p-name + '->' + p-attr + ' (700002)'.

end.

procedure find-child.
    def input  param p-root as handle.
    def input-output param p-name as char.
    def input-output param p-attr as char.
    def input-output param p-res as logi.
    def input-output param p-out as char.

    def var i as int.
    def var h-child-node as handle.
    create x-noderef h-child-node no-error.

    if p-root:name = p-name then do:
        p-out = p-root:get-attribute (p-attr).
        p-res = true.
        return.
    end.
    if p-root:num-children > 0  then do:
       do i = 1 to p-root:num-children.
           p-root:get-child(h-child-node, i).
           run find-child(input h-child-node, input-output p-name, input-output p-attr, input-output p-res, input-output p-out) .
       end.
    end.
end.

procedure get-node.
    def input  param p-in as handle.

    def input  param p-ID as char.
    def input  param p-CANCELVAL as char.
    def input  param p-CANCEL as char.
    def input  param p-IS_SOCIAL as char.
    def input  param p-PAYMENT as char.
    def input  param p-PS_PAYMENT as char.
    def input  param p-CURRENCY_PAYMENT as char.
    def input  param p-CURRENCY_EXCHANGE as char.
    def input  param p-PAYER_RNN as char.
    def input  param p-CLIENT_RNN as char.
    def input  param p-PAYER_ACCOUNT as char.
    def input  param p-RCPT_ACCOUNT as char.
    def input  param p-AMOUNT as char.
    def input  param p-RCPT_BANK_BIC as char.
    def input  param p-RCPT_BANK_NAME as char.
    def input  param p-RCPT_NAME as char.
    def input  param p-DESTINATION_CODE as char.
    def input  param p-PAYMENT_DETAILS as char.
    def input  param p-PRIORITY as char.
    def input  param p-NUM_DOC as char.
    def input  param p-RCPT_RNN as char.
    def input  param p-VALUE_DATE as char.
    def input  param p-INTERMED_BANK_BIC as char.
    def input  param p-INTERMED_BANK_NAME as char.
    def input  param p-RCPT_CODE as char.
    def input  param p-COMMISSION_ACCOUNT as char.
    def input  param p-DATE_DOC as char.
    def input  param p-PURCHASE_ACCOUNT as char.
    def input  param p-SALE_ACCOUNT as char.
    def input  param p-IS_PURCHASE as char.
    def input  param p-KBK as char.
    def input  param p-PURCHASE_PURPOSE_TYPE as char.
    def input  param p-PURCHASE_AMOUNT as char.
    def input  param p-SALE_AMOUNT as char.
    def input  param p-PAYER_BANK_BIC as char.
    def input  param p-CLIENT_BIC as char.
    def input  param p-IS_CHARGE as char.
    def input  param p-PENSIA as longchar.
    def input  param p-COMISSION_TYPE as char.
    def input  param p-RUBIK as char.
    def input  param p-INTENT as char.
    def input  param p-RCPT_BANK_BIC_TYPE as char.
    def input  param p-INTERMED_BANK_BIC_TYPE as char.
    def input  param p-RUS_INN as char.
    def input  param p-RUS_KPP as char.

    def output param p-state as char.
    def output param p-pcancelval as char.
    def output param p-pcancel as char.
    def output param p-payissocial as char.
    def output param p-payment-kz as char.
    def output param p-payment-ps as char.
    def output param p-payment-cr as char.
    def output param p-payment-ex as char.
    def output param p-rnn as char.
    def output param p-clientrnn as char.
    def output param p-aaa as char.
    def output param p-rspnt as char.
    def output param p-amounts as char.
    def output param p-rcptbik as char.
    def output param p-rcptbank as char.
    def output param p-rcptname as char.
    def output param p-knp as char.
    def output param p-rcptdetails as char.
    def output param p-prioritys as char.
    def output param p-numdoc as char.
    def output param p-rsptrnn as char.
    def output param p-valdate as char.
    def output param p-intbic as char.
    def output param p-intname as char.
    def output param p-kbe as char.
    def output param p-comacc as char.
    def output param p-datedoc as char.
    def output param p-purchacc as char.
    def output param p-saleacc as char.
    def output param p-ispurchase as char.
    def output param p-pkbk as char.
    def output param p-purposetype as char.
    def output param p-purchaseamt as char.
    def output param p-saleamt as char.
    def output param p-payerbankBic as char.
    def output param p-clientbankBic as char.
    def output param p-payerischarge as char.
    def output param p-ppensia as longchar.
    def output param p-pCOMISSION_TYPE as char.
    def output param p-pRUBIK as char.
    def output param p-pINTENT as char.
    def output param p-pRCPT_BANK_BIC_TYPE as char.
    def output param p-pINTERMED_BANK_BIC_TYPE as char.
    def output param p-rusInn as char.
    def output param p-rusKpp as char.

    def var v-res as logi.

    v-res = false.

    def var h-root as handle.
    def var h-child-node as handle.
    create x-noderef h-child-node no-error.

    def var h-child-node-value as handle.
    create x-noderef h-child-node-value no-error.

    create x-noderef h-root no-error.

    p-in:get-document-element (h-root).

    /* в том случае есди искомая нода как root */

    if h-root:name = p-PAYMENT then do:
        h-root:get-child (h-child-node-value,1).
        p-payment-kz = h-child-node-value:node-value.
    end. else if h-root:name = p-PS_PAYMENT then do:
        h-root:get-child (h-child-node-value,1).
        p-payment-ps = h-child-node-value:node-value.
    end. else if h-root:name = p-CURRENCY_PAYMENT then do:
        h-root:get-child (h-child-node-value,1).
        p-payment-cr = h-child-node-value:node-value.
    end. else if h-root:name = p-CURRENCY_EXCHANGE then do:
        h-root:get-child (h-child-node-value,1).
        p-payment-ex = h-child-node-value:node-value.
    end. else if h-root:name = "MESSAGE_ORDER" then do:
        h-root:get-child (h-child-node-value,1).
        v-payment-order = h-child-node-value:node-value.
    end.


      if h-root:num-children < 1 then return.

      run find-child-node(input h-root,
            input-output p-ID,
            input-output p-CANCELVAL,
            input-output p-CANCEL,
            input-output p-IS_SOCIAL,
            input-output p-PAYMENT,
            input-output p-PS_PAYMENT,
            input-output p-CURRENCY_PAYMENT,
            input-output p-CURRENCY_EXCHANGE,
            input-output p-PAYER_RNN,
            input-output p-CLIENT_RNN,
            input-output p-PAYER_ACCOUNT,
            input-output p-RCPT_ACCOUNT,
            input-output p-AMOUNT,
            input-output p-RCPT_BANK_BIC,
            input-output p-RCPT_BANK_NAME,
            input-output p-RCPT_NAME,
            input-output p-DESTINATION_CODE,
            input-output p-PAYMENT_DETAILS,
            input-output p-PRIORITY,
            input-output p-NUM_DOC,
            input-output p-RCPT_RNN,
            input-output p-VALUE_DATE,
            input-output p-INTERMED_BANK_BIC,
            input-output p-INTERMED_BANK_NAME,
            input-output p-RCPT_CODE,
            input-output p-COMMISSION_ACCOUNT,
            input-output p-DATE_DOC,
            input-output p-PURCHASE_ACCOUNT,
            input-output p-SALE_ACCOUNT,
            input-output p-IS_PURCHASE,
            input-output p-KBK,
            input-output p-PURCHASE_PURPOSE_TYPE,
            input-output p-PURCHASE_AMOUNT,
            input-output p-SALE_AMOUNT,
            input-output p-PAYER_BANK_BIC,
            input-output p-CLIENT_BIC,
            input-output p-IS_CHARGE,
            input-output p-PENSIA,
            input-output p-COMISSION_TYPE,
            input-output p-RUBIK,
            input-output p-INTENT,
            input-output p-RCPT_BANK_BIC_TYPE,
            input-output p-INTERMED_BANK_BIC_TYPE,
            input-output p-RUS_INN,
            input-output p-RUS_KPP,


            input-output p-state,
            input-output p-pcancelval,
            input-output p-pcancel,
            input-output p-payissocial,
            input-output p-payment-kz,
            input-output p-payment-ps,
            input-output p-payment-cr,
            input-output p-payment-ex,
            input-output p-rnn,
            input-output p-clientrnn,
            input-output p-aaa,
            input-output p-rspnt,
            input-output p-amounts,
            input-output p-rcptbik,
            input-output p-rcptbank,
            input-output p-rcptname,
            input-output p-knp,
            input-output p-rcptdetails,
            input-output p-prioritys,
            input-output p-numdoc,
            input-output p-rsptrnn,
            input-output p-valdate,
            input-output p-intbic,
            input-output p-intname,
            input-output p-kbe,
            input-output p-comacc,
            input-output p-datedoc,
            input-output p-purchacc,
            input-output p-saleacc,
            input-output p-ispurchase,
            input-output p-pkbk,
            input-output p-purposetype,
            input-output p-purchaseamt,
            input-output p-saleamt,
            input-output p-payerbankBic,
            input-output p-clientbankBic,
            input-output p-payerischarge,
            input-output p-ppensia,
            input-output p-pCOMISSION_TYPE,
            input-output p-pRUBIK,
            input-output p-pINTENT,
            input-output p-pRCPT_BANK_BIC_TYPE,
            input-output p-pINTERMED_BANK_BIC_TYPE,
            input-output p-rusInn,
            input-output p-rusKpp
            ) .

   return.
end.

procedure find-child-node.
    def input  param p-root as handle.

    def input-output param p-ID as char.
    def input-output param p-CANCELVAL as char.
    def input-output param p-CANCEL as char.
    def input-output param p-IS_SOCIAL as char.
    def input-output param p-PAYMENT as char.
    def input-output param p-PS_PAYMENT as char.
    def input-output param p-CURRENCY_PAYMENT as char.
    def input-output param p-CURRENCY_EXCHANGE as char.
    def input-output param p-PAYER_RNN as char.
    def input-output param p-CLIENT_RNN as char.
    def input-output param p-PAYER_ACCOUNT as char.
    def input-output param p-RCPT_ACCOUNT as char.
    def input-output param p-AMOUNT as char.
    def input-output param p-RCPT_BANK_BIC as char.
    def input-output param p-RCPT_BANK_NAME as char.
    def input-output param p-RCPT_NAME as char.
    def input-output param p-DESTINATION_CODE as char.
    def input-output param p-PAYMENT_DETAILS as char.
    def input-output param p-PRIORITY as char.
    def input-output param p-NUM_DOC as char.
    def input-output param p-RCPT_RNN as char.
    def input-output param p-VALUE_DATE as char.
    def input-output param p-INTERMED_BANK_BIC as char.
    def input-output param p-INTERMED_BANK_NAME as char.
    def input-output param p-RCPT_CODE as char.
    def input-output param p-COMMISSION_ACCOUNT as char.
    def input-output param p-DATE_DOC as char.
    def input-output param p-PURCHASE_ACCOUNT as char.
    def input-output param p-SALE_ACCOUNT as char.
    def input-output param p-IS_PURCHASE as char.
    def input-output param p-KBK as char.
    def input-output param p-PURCHASE_PURPOSE_TYPE as char.
    def input-output param p-PURCHASE_AMOUNT as char.
    def input-output param p-SALE_AMOUNT as char.
    def input-output param p-PAYER_BANK_BIC as char.
    def input-output param p-CLIENT_BIC  as char.
    def input-output param p-IS_CHARGE as char.
    def input-output param p-PENSIA as longchar.
    def input-output param p-COMISSION_TYPE as char.
    def input-output param p-RUBIK as char.
    def input-output param p-INTENT as char.
    def input-output param p-RCPT_BANK_BIC_TYPE as char.
    def input-output param p-INTERMED_BANK_BIC_TYPE as char.
    def input-output param p-RUS_INN as char.
    def input-output param p-RUS_KPP as char.



    def input-output param p-state as char.
    def input-output param p-pcancelval as char.
    def input-output param p-pcancel as char.
    def input-output param p-payissocial as char.
    def input-output param p-payment-kz as char.
    def input-output param p-payment-ps as char.
    def input-output param p-payment-cr as char.
    def input-output param p-payment-ex as char.
    def input-output param p-rnn as char.
    def input-output param p-clientrnn as char.
    def input-output param p-aaa as char.
    def input-output param p-rspnt as char.
    def input-output param p-amounts as char.
    def input-output param p-rcptbik as char.
    def input-output param p-rcptbank as char.
    def input-output param p-rcptname as char.
    def input-output param p-knp as char.
    def input-output param p-rcptdetails as char.
    def input-output param p-prioritys as char.
    def input-output param p-numdoc as char.
    def input-output param p-rsptrnn as char.
    def input-output param p-valdate as char.
    def input-output param p-intbic as char.
    def input-output param p-intname as char.
    def input-output param p-kbe as char.
    def input-output param p-comacc as char.
    def input-output param p-datedoc as char.
    def input-output param p-purchacc as char.
    def input-output param p-saleacc as char.
    def input-output param p-ispurchase as char.
    def input-output param p-pkbk as char.
    def input-output param p-purposetype as char.
    def input-output param p-purchaseamt as char.
    def input-output param p-saleamt as char.
    def input-output param p-payerbankBic as char.
    def input-output param p-clientbankBic as char.
    def input-output param p-payerischarge as char.
    def input-output param p-ppensia as longchar.
    def input-output param p-pCOMISSION_TYPE as char.
    def input-output param p-pRUBIK as char.
    def input-output param p-pINTENT as char.
    def input-output param p-pRCPT_BANK_BIC_TYPE as char.
    def input-output param p-pINTERMED_BANK_BIC_TYPE as char.
    def input-output param p-rusInn as char.
    def input-output param p-rusKpp as char.

    def var i as int.
    def var h-child-node as handle.
    create x-noderef h-child-node no-error.

    def var h-child-node-value as handle.
    create x-noderef h-child-node-value no-error.


   if      p-root:name = p-ID                    then do:  p-root:get-child (h-child-node-value,1).   p-state = h-child-node-value:node-value.              end.
   else if p-root:name = p-CANCELVAL             then do:  p-root:get-child (h-child-node-value,1).   p-pcancelval = h-child-node-value:node-value.         end.
   else if p-root:name = p-CANCEL                then do:  p-root:get-child (h-child-node-value,1).   p-pcancel = h-child-node-value:node-value.            end.
   else if p-root:name = p-IS_SOCIAL             then do:  p-root:get-child (h-child-node-value,1).   p-payissocial = h-child-node-value:node-value.        end.
   else if p-root:name = p-PAYMENT               then do:  p-root:get-child (h-child-node-value,1).   p-payment-kz = h-child-node-value:node-value.         end.
   else if p-root:name = p-PS_PAYMENT            then do:  p-root:get-child (h-child-node-value,1).   p-payment-ps = h-child-node-value:node-value.         end.
   else if p-root:name = p-CURRENCY_PAYMENT      then do:  p-root:get-child (h-child-node-value,1).   p-payment-cr = h-child-node-value:node-value.         end.
   else if p-root:name = p-CURRENCY_EXCHANGE     then do:  p-root:get-child (h-child-node-value,1).   p-payment-ex = h-child-node-value:node-value.         end.
   else if p-root:name = p-PAYER_RNN             then do:  p-root:get-child (h-child-node-value,1).   p-rnn = h-child-node-value:node-value.                end.
   else if p-root:name = p-CLIENT_RNN            then do:  p-root:get-child (h-child-node-value,1).   p-clientrnn = h-child-node-value:node-value.          end.
   else if p-root:name = p-PAYER_ACCOUNT         then do:  p-root:get-child (h-child-node-value,1).   p-aaa = h-child-node-value:node-value.                end.
   else if p-root:name = p-RCPT_ACCOUNT          then do:  p-root:get-child (h-child-node-value,1).   p-rspnt = h-child-node-value:node-value.              end.
   else if p-root:name = p-AMOUNT                then do:  p-root:get-child (h-child-node-value,1).   p-amounts = h-child-node-value:node-value.            end.
   else if p-root:name = p-RCPT_BANK_BIC         then do:  p-root:get-child (h-child-node-value,1).   p-rcptbik = h-child-node-value:node-value.            end.
   else if p-root:name = p-RCPT_BANK_NAME        then do:  p-root:get-child (h-child-node-value,1).   p-rcptbank = h-child-node-value:node-value.           end.
   else if p-root:name = p-RCPT_NAME             then do:  p-root:get-child (h-child-node-value,1).   p-rcptname = h-child-node-value:node-value.           end.
   else if p-root:name = p-DESTINATION_CODE      then do:  p-root:get-child (h-child-node-value,1).   p-knp = h-child-node-value:node-value.                end.
   else if p-root:name = p-PAYMENT_DETAILS       then do:  p-root:get-child (h-child-node-value,1).   p-rcptdetails = h-child-node-value:node-value.        end.
   else if p-root:name = p-PRIORITY              then do:  p-root:get-child (h-child-node-value,1).   p-prioritys = h-child-node-value:node-value.          end.
   else if p-root:name = p-NUM_DOC               then do:  p-root:get-child (h-child-node-value,1).   p-numdoc = h-child-node-value:node-value.             end.
   else if p-root:name = p-RCPT_RNN              then do:  p-root:get-child (h-child-node-value,1).   p-rsptrnn = h-child-node-value:node-value.            end.
   else if p-root:name = p-VALUE_DATE            then do:  p-root:get-child (h-child-node-value,1).   p-valdate = h-child-node-value:node-value.            end.
   else if p-root:name = p-INTERMED_BANK_BIC     then do:  p-root:get-child (h-child-node-value,1).   p-intbic = h-child-node-value:node-value.             end.
   else if p-root:name = p-INTERMED_BANK_NAME    then do:  p-root:get-child (h-child-node-value,1).   p-intname = h-child-node-value:node-value.            end.
   else if p-root:name = p-RCPT_CODE             then do:  p-root:get-child (h-child-node-value,1).   p-kbe = h-child-node-value:node-value.                end.
   else if p-root:name = p-COMMISSION_ACCOUNT    then do:  p-root:get-child (h-child-node-value,1).   p-comacc = h-child-node-value:node-value.             end.
   else if p-root:name = p-DATE_DOC              then do:  p-root:get-child (h-child-node-value,1).   p-datedoc = h-child-node-value:node-value.            end.
   else if p-root:name = p-PURCHASE_ACCOUNT      then do:  p-root:get-child (h-child-node-value,1).   p-purchacc = h-child-node-value:node-value.           end.
   else if p-root:name = p-SALE_ACCOUNT          then do:  p-root:get-child (h-child-node-value,1).   p-saleacc = h-child-node-value:node-value.            end.
   else if p-root:name = p-IS_PURCHASE           then do:  p-root:get-child (h-child-node-value,1).   p-ispurchase = h-child-node-value:node-value.         end.
   else if p-root:name = p-KBK                   then do:  p-root:get-child (h-child-node-value,1).   p-pkbk = h-child-node-value:node-value.               end.
   else if p-root:name = p-PURCHASE_PURPOSE_TYPE then do:  p-root:get-child (h-child-node-value,1).   p-purposetype = h-child-node-value:node-value.        end.
   else if p-root:name = p-PURCHASE_AMOUNT       then do:  p-root:get-child (h-child-node-value,1).   p-purchaseamt = h-child-node-value:node-value.        end.
   else if p-root:name = p-SALE_AMOUNT           then do:  p-root:get-child (h-child-node-value,1).   p-saleamt = h-child-node-value:node-value.            end.

   if      p-root:name = p-PAYER_BANK_BIC        then do:  p-root:get-child (h-child-node-value,1).   p-payerbankBic = h-child-node-value:node-value.       end.
   if      p-root:name = p-CLIENT_BIC            then do:  p-root:get-child (h-child-node-value,1).   p-clientbankBic = h-child-node-value:node-value.      end.
   if      p-root:name = p-IS_CHARGE             then do:  p-root:get-child (h-child-node-value,1).   p-payerischarge = h-child-node-value:node-value.      end.
   if      p-root:name = p-PENSIA                then do:  p-root:get-child (h-child-node-value,1).   h-child-node-value:node-value-to-longchar(p-ppensia). end.

   if      p-root:name = p-COMISSION_TYPE        then do:  p-root:get-child (h-child-node-value,1).   p-pCOMISSION_TYPE = h-child-node-value:node-value.    end.
   if      p-root:name = p-RUBIK                 then do:  p-root:get-child (h-child-node-value,1).   p-pRUBIK          = h-child-node-value:node-value.    end.
   if      p-root:name = p-INTENT                then do:  p-root:get-child (h-child-node-value,1).  p-pINTENT         = h-child-node-value:node-value.    end.

   if      p-root:name = p-RCPT_BANK_BIC_TYPE                 then do:  p-root:get-child (h-child-node-value,1).   p-pRCPT_BANK_BIC_TYPE          = h-child-node-value:node-value.    end.
   if      p-root:name = p-INTERMED_BANK_BIC_TYPE                 then do:  p-root:get-child (h-child-node-value,1).  p-pINTERMED_BANK_BIC_TYPE         = h-child-node-value:node-value.    end.

   if      p-root:name = p-RUS_INN               then do:  p-root:get-child (h-child-node-value,1).  p-rusInn         = h-child-node-value:node-value.    end.
   if      p-root:name = p-RUS_KPP               then do:  p-root:get-child (h-child-node-value,1).  p-rusKpp         = h-child-node-value:node-value.    end.


   if p-root:num-children > 1  then do:
       do i = 1 to p-root:num-children.
           p-root:get-child(h-child-node, i).
           run find-child-node(input h-child-node,
                input-output p-ID,
                input-output p-CANCELVAL,
                input-output p-CANCEL,
                input-output p-IS_SOCIAL,
                input-output p-PAYMENT,
                input-output p-PS_PAYMENT,
                input-output p-CURRENCY_PAYMENT,
                input-output p-CURRENCY_EXCHANGE,
                input-output p-PAYER_RNN,
                input-output p-CLIENT_RNN,
                input-output p-PAYER_ACCOUNT,
                input-output p-RCPT_ACCOUNT,
                input-output p-AMOUNT,
                input-output p-RCPT_BANK_BIC,
                input-output p-RCPT_BANK_NAME,
                input-output p-RCPT_NAME,
                input-output p-DESTINATION_CODE,
                input-output p-PAYMENT_DETAILS,
                input-output p-PRIORITY,
                input-output p-NUM_DOC,
                input-output p-RCPT_RNN,
                input-output p-VALUE_DATE,
                input-output p-INTERMED_BANK_BIC,
                input-output p-INTERMED_BANK_NAME,
                input-output p-RCPT_CODE,
                input-output p-COMMISSION_ACCOUNT,
                input-output p-DATE_DOC,
                input-output p-PURCHASE_ACCOUNT,
                input-output p-SALE_ACCOUNT,
                input-output p-IS_PURCHASE,
                input-output p-KBK,
                input-output p-PURCHASE_PURPOSE_TYPE,
                input-output p-PURCHASE_AMOUNT,
                input-output p-SALE_AMOUNT,
                input-output p-PAYER_BANK_BIC,
                input-output p-CLIENT_BIC,
                input-output p-IS_CHARGE,
                input-output p-PENSIA,
                input-output p-COMISSION_TYPE,
                input-output p-RUBIK,
                input-output p-INTENT,
                input-output p-RCPT_BANK_BIC_TYPE,
                input-output p-INTERMED_BANK_BIC_TYPE,
                input-output p-RUS_INN,
                input-output p-RUS_KPP,

                input-output p-state,
                input-output p-pcancelval,
                input-output p-pcancel,
                input-output p-payissocial,
                input-output p-payment-kz,
                input-output p-payment-ps,
                input-output p-payment-cr,
                input-output p-payment-ex,
                input-output p-rnn,
                input-output p-clientrnn,
                input-output p-aaa,
                input-output p-rspnt,
                input-output p-amounts,
                input-output p-rcptbik,
                input-output p-rcptbank,
                input-output p-rcptname,
                input-output p-knp,
                input-output p-rcptdetails,
                input-output p-prioritys,
                input-output p-numdoc,
                input-output p-rsptrnn,
                input-output p-valdate,
                input-output p-intbic,
                input-output p-intname,
                input-output p-kbe,
                input-output p-comacc,
                input-output p-datedoc,
                input-output p-purchacc,
                input-output p-saleacc,
                input-output p-ispurchase,
                input-output p-pkbk,
                input-output p-purposetype,
                input-output p-purchaseamt,
                input-output p-saleamt,
                input-output p-payerbankBic,
                input-output p-clientbankBic,
                input-output p-payerischarge,
                input-output p-ppensia,
                input-output p-pCOMISSION_TYPE,
                input-output p-pRUBIK,
                input-output p-pINTENT,
                input-output p-pRCPT_BANK_BIC_TYPE,
                input-output p-pINTERMED_BANK_BIC_TYPE,
                input-output p-rusInn,
                input-output p-rusKpp
                ).
       end.
   end.
end.

function get-amount returns char (v as decimal).
    return replace(replace(string(v, '->>>>>>>>>>>>>>>>>>>>>>>9.99'), ' ', ''), ".",",").
end.

function is-correct-amount returns logical (v as char, nd as int).
    if v matches ',' then
        return false.
    if v matches ' ' then
        return false.

    def var v-d as decimal.

    v-d = decimal(v) no-error.
    if error-status:error then
        return false.

    if v-d <> truncate(v-d, nd) then
        return false.

    return true.
end.

function get-datetime returns char (v-dat as date, v-tim as int).
    return string(year(v-dat), '9999') + '-' +
           string(month(v-dat), '99') + '-' +
           string(day(v-dat), '99') + ' ' +
           string(v-tim, 'HH:MM:SS').
end.


function get-dat-datetime returns date (v-datetime as char).

    def var v-dat as char.
    v-dat = entry(1, v-datetime, ' ') no-error.

    return date(integer(entry(2, v-dat, '-')), integer(entry(3, v-dat, '-')), integer(entry(1, v-dat, '-'))).
end.

function get-tim-datetime returns int (v-datetime as char).

    def var v-tim as char.
    v-tim = entry(2, v-datetime, ' ') no-error.

    return integer(entry(1, v-tim, ':')) * 3600 +
           integer(entry(2, v-tim, ':')) * 60 +
           integer(entry(3, v-tim, ':')).
end.

procedure add-root.

    def input  param p-x-doc as handle.
    def input  param p-x-doc-root-elem-name  as char.
    def input-output param p-x-doc-root-elem as handle.

    p-x-doc:create-node (p-x-doc-root-elem, p-x-doc-root-elem-name, "ELEMENT").
    p-x-doc:append-child (p-x-doc-root-elem).
end procedure.

procedure add-element.

    def input  param p-x-doc as handle.
    def input  param p-x-doc-elem-name as char.
    def input  param p-x-doc-elem-type as char.
    def input-output param p-x-doc-parent-elem as handle.
    def input-output param p-x-doc-child-elem as handle.

    def var v-parent-child as handle.
    create x-noderef v-parent-child.


    if p-x-doc-elem-type = "TEXT" then do:

       p-x-doc:create-node (v-parent-child, p-x-doc-elem-name, "ELEMENT").
       p-x-doc-parent-elem:append-child (v-parent-child).

       p-x-doc:create-node (p-x-doc-child-elem, "", p-x-doc-elem-type).
       v-parent-child:append-child (p-x-doc-child-elem).

    end.

    if p-x-doc-elem-type = "ELEMENT" then do:
       p-x-doc:create-node (p-x-doc-child-elem, p-x-doc-elem-name, "ELEMENT").
       p-x-doc-parent-elem:append-child (p-x-doc-child-elem).

    end.
end procedure.



