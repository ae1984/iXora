/* qpay_import.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание программы
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        21/07/2011 k.gitalov
 * BASES
        BANK COMM
 * CHANGES
        13.03.2012 k.gitalov Обработка переводов с конвертацией
        11/09/2012 Luiza использование функции CODEPAGE-CONVERT.
*/

{classes.i}
{xmlParser.i}

def input parameter Doc as class QPayClass.
def output parameter p-errcode as integer no-undo init 0.
def output parameter p-errdes as char no-undo init ''.


def buffer bt-node for t-node.
def buffer bt1-node for t-node.
def buffer bt2-node for t-node.

def var v-parseErr as char no-undo.
def var Amount as int.
def var Exp as int.
def var Cur as char.
def var PNameID as char.
def var PValue as char.



if not Doc:CopyDoc() then do:
 p-errcode = 1.
 p-errdes = "Документ не найден!".
 return.
end.

run parseFileXML(Doc:v-name,output v-parseErr).
if v-parseErr <> '' then do:
 p-errcode = 2.
 p-errdes = "Ошибка parseFileXML".
 return.
end.


   find first t-node where t-node.nodeName = 'TransferData' no-lock no-error.
   if avail t-node then do:
     if t-node.NumChildren > 0 then do:
       find first t-node where t-node.nodeName = 'UIN' no-lock no-error.
       if avail t-node then do:
         if t-node.nodeValue <> Doc:UIN then do:
           p-errcode = 5.
           p-errdes = "Несоответствие номера документа!".
           return.
         end.
       end.
       find first t-node where t-node.nodeName = 'Message' no-lock no-error.
       if avail t-node then Doc:PayeeMessage   = t-node.nodeValue.

       find first t-node where t-node.nodeName = 'TransferStatus' no-lock no-error.
       if avail t-node then Doc:TransferStatus = integer(t-node.nodeValue).

       find first t-node where t-node.nodeName = 'ToCountryISO' no-lock no-error.
       if avail t-node then Doc:ToCountryISO = t-node.nodeValue.

       find first t-node where t-node.nodeName = 'FromCountryISO' no-lock no-error.
       if avail t-node then Doc:FromCountryISO = t-node.nodeValue.

       find first t-node where t-node.nodeName = 'PayeeIsResident' no-lock no-error.
       if avail t-node then Doc:PayeeIsResident = integer(t-node.nodeValue).

       find first t-node where t-node.nodeName = 'PayerIsResident' no-lock no-error.
       if avail t-node then Doc:PayerIsResident = integer(t-node.nodeValue).

       find first t-node where t-node.nodeName = 'PayeeCountryISO' no-lock no-error.
       if avail t-node then Doc:PayeeCountryISO = t-node.nodeValue.

       find first t-node where t-node.nodeName = 'PayerCountryISO' no-lock no-error.
       if avail t-node then Doc:PayerCountryISO = t-node.nodeValue.

       find first t-node where t-node.nodeName = 'Message' no-lock no-error.
       if avail t-node then Doc:TransferMessage = t-node.nodeValue.

       find first t-node where t-node.nodeName = 'DebetPayDocID' no-lock no-error.
       if avail t-node then Doc:DebetPayDocID = t-node.nodeValue.

       find first t-node where t-node.nodeName = 'DebetPayDocDate' no-lock no-error.
       if avail t-node then Doc:DebetPayDocDate = t-node.nodeValue.

       find first t-node where t-node.nodeName = 'CreditPayDocID' no-lock no-error.
       if avail t-node then Doc:CreditPayDocID = t-node.nodeValue.

       find first t-node where t-node.nodeName = 'CreditPayDocDate' no-lock no-error.
       if avail t-node then Doc:CreditPayDocDate = t-node.nodeValue.

       find first t-node where t-node.nodeName = 'PayerCard' no-lock no-error.
       if avail t-node then Doc:PayerCard = t-node.nodeValue.

       find first t-node where t-node.nodeName = 'Control' no-lock no-error.
       if avail t-node then Doc:TransferControl = t-node.nodeValue.

       find first t-node where t-node.nodeName = 'PaymentPurpose' no-lock no-error.
       if avail t-node then Doc:PaymentPurpose = t-node.nodeValue.


        find first t-node where t-node.nodeName = 'DstFunds' no-lock no-error.
        if not avail t-node then do:
            find first t-node where t-node.nodeName = 'PayFunds' no-lock no-error.
            if not avail t-node then do: p-errcode = 9. return. end.
            for each bt-node where bt-node.nodeParentId = t-node.nodeId no-lock:
              if bt-node.nodeName = "Amount" then Amount = integer(bt-node.nodeValue).
              if bt-node.nodeName = "Exp" then Exp = integer(bt-node.nodeValue).
              if bt-node.nodeName = "Cur" then Cur = bt-node.nodeValue.
              Doc:PayFunds = Amount / EXP(10 , Exp ).
              Doc:PayFundsCRCISO = Cur.
            end.
            Amount = 0. Exp = 0. Cur = "".
        end.
        else do:
            for each bt-node where bt-node.nodeParentId = t-node.nodeId no-lock:
              if bt-node.nodeName = "Amount" then Amount = integer(bt-node.nodeValue).
              if bt-node.nodeName = "Exp" then Exp = integer(bt-node.nodeValue).
              if bt-node.nodeName = "Cur" then Cur = bt-node.nodeValue.
              Doc:PayFunds = Amount / EXP(10 , Exp ).
              Doc:PayFundsCRCISO = Cur.
            end.
            Amount = 0. Exp = 0. Cur = "".
           /* message "Данный перевод сформирован с конвертацией!" view-as alert-box title "ВНИМАНИЕ!".*/
        end.


        find first t-node where t-node.nodeName = 'Comission' no-lock no-error.
        if not avail t-node then do: p-errcode = 10. return. end.
        for each bt-node where bt-node.nodeParentId = t-node.nodeId no-lock:
          if bt-node.nodeName = "Amount" then Amount = integer(bt-node.nodeValue).
          if bt-node.nodeName = "Exp" then Exp = integer(bt-node.nodeValue).
          if bt-node.nodeName = "Cur" then Cur = bt-node.nodeValue.
          Doc:Comission = Amount / EXP(10 , Exp ).
          Doc:ComissionCRCISO = Cur.
        end.
        Amount = 0. Exp = 0. Cur = "".
        find first t-node where t-node.nodeName = 'PayAmount' no-lock no-error.
        if not avail t-node then do: p-errcode = 11. return. end.
        for each bt-node where bt-node.nodeParentId = t-node.nodeId no-lock:
          if bt-node.nodeName = "Amount" then Amount = integer(bt-node.nodeValue).
          if bt-node.nodeName = "Exp" then Exp = integer(bt-node.nodeValue).
          if bt-node.nodeName = "Cur" then Cur = bt-node.nodeValue.
          Doc:PayAmount = Amount / EXP(10 , Exp ).
          Doc:PayAmountCRCISO = Cur.
        end.
        Amount = 0. Exp = 0. Cur = "".
        find first t-node where t-node.nodeName = 'SenderComission' no-lock no-error.
        if not avail t-node then do: p-errcode = 12. return. end.
        for each bt-node where bt-node.nodeParentId = t-node.nodeId no-lock:
          if bt-node.nodeName = "Amount" then Amount = integer(bt-node.nodeValue).
          if bt-node.nodeName = "Exp" then Exp = integer(bt-node.nodeValue).
          if bt-node.nodeName = "Cur" then Cur = bt-node.nodeValue.
          Doc:SenderComission = Amount / EXP(10 , Exp ).
          Doc:SenderComissionCRCISO = Cur.
        end.
        Amount = 0. Exp = 0. Cur = "".
        find first t-node where t-node.nodeName = 'ReceiverComission' no-lock no-error.
        if not avail t-node then do: p-errcode = 13. return. end.
        for each bt-node where bt-node.nodeParentId = t-node.nodeId no-lock:
          if bt-node.nodeName = "Amount" then Amount = integer(bt-node.nodeValue).
          if bt-node.nodeName = "Exp" then Exp = integer(bt-node.nodeValue).
          if bt-node.nodeName = "Cur" then Cur = bt-node.nodeValue.
          Doc:ReceiverComission = Amount / EXP(10 , Exp ).
          Doc:ReceiverComissionCRCISO = Cur.
        end.
        Amount = 0. Exp = 0. Cur = "".


        /*Отправитель перевода*/
        for each t-node where t-node.nodeName = 'Payer' no-lock:
          for each bt-node where bt-node.nodeParentId = t-node.nodeId no-lock:
           if bt-node.nodeName = "FullName" then Doc:PayerFname = CODEPAGE-CONVERT(bt-node.nodeValue,"kz-1048","utf-8").
           if bt-node.nodeName = "Phone" then Doc:PayerPhone = bt-node.nodeValue.
           if bt-node.nodeName = "CountryISO" and bt-node.nodeValue <> "XXX" then Doc:PayerCountryISO = bt-node.nodeValue.


           if bt-node.nodeName = "PaperCredentials" then do:
             for each bt1-node where bt1-node.nodeParentId = bt-node.nodeId no-lock:
                if bt1-node.nodeName = "CType" then Doc:PayerCType = CODEPAGE-CONVERT(bt1-node.nodeValue,"kz-1048","utf-8").
                if bt1-node.nodeName = "CNumber" then Doc:PayerCNumber = CODEPAGE-CONVERT(bt1-node.nodeValue,"kz-1048","utf-8").
                if bt1-node.nodeName = "SerialNumber" then Doc:PayerSerialNumber = CODEPAGE-CONVERT(bt1-node.nodeValue,"kz-1048","utf-8").
                if bt1-node.nodeName = "Issuer" then Doc:PayerIssuer = CODEPAGE-CONVERT(bt1-node.nodeValue,"kz-1048","utf-8").
                if bt1-node.nodeName = "IssueDate" then Doc:PayerIssueDate = bt1-node.nodeValue.
             end.
           end.

           if bt-node.nodeName = "Registry" then do:
             for each bt1-node where bt1-node.nodeParentId = bt-node.nodeId no-lock:
                if bt1-node.nodeName = "PNameID" then PNameID = bt1-node.nodeValue.
                if bt1-node.nodeName = "PValue" then PValue = bt1-node.nodeValue.

                if PNameID <> "" and PValue <> "" then do:
                  case PNameID:
                    when "BIRTHDATE" then do:
                      Doc:PayerBirthDate = PValue.
                    end.
                    when "BIRTHCITY" then do:
                      Doc:PayerBirthCity = PValue.
                    end.
                    when "ADDRESS" then do:
                      Doc:PayerAddress = PValue.
                    end.
                    when "BIRTHCOUNTRY" then do:
                      Doc:PayerBirthCountry = PValue.
                    end.
                    when "INN" then do:
                      Doc:PayerINN = PValue.
                    end.
                    when "REGADDRESS" then do:
                      Doc:PayerREGADDRESS = CODEPAGE-CONVERT(PValue,"kz-1048","utf-8").
                    end.
                    when "REGCITY" then do:
                      Doc:PayerREGCITY = CODEPAGE-CONVERT(PValue,"kz-1048","utf-8").
                    end.
                    when "REGCOUNTRY" then do:
                      Doc:PayerREGCOUNTRY = CODEPAGE-CONVERT(PValue,"kz-1048","utf-8").
                    end.
                    when "KBEKOD" then do:
                      Doc:PayerKbeKod = PValue.
                    end.
                    when "KNP" then do:
                      Doc:PayerKNP = PValue.
                    end.

                    otherwise do:
                     /* message "Неизвестный ключ " PNameID view-as alert-box.*/
                    end.
                  end case.

                  PNameID = "".
                  PValue = "".
                end.
             end.
           end.

          end. /*end Registry*/

        end. /*end Payer*/


        /*Получатель перевода*/
        for each t-node where t-node.nodeName = 'Payee' no-lock:
          for each bt-node where bt-node.nodeParentId = t-node.nodeId no-lock:
           if bt-node.nodeName = "FullName" then Doc:PayeeFname = CODEPAGE-CONVERT(bt-node.nodeValue,"kz-1048","utf-8").
           if bt-node.nodeName = "Phone" then Doc:PayeePhone = CODEPAGE-CONVERT(bt-node.nodeValue,"kz-1048","utf-8").
           if bt-node.nodeName = "CountryISO" and bt-node.nodeValue <> "XXX" then Doc:PayeeCountryISO = CODEPAGE-CONVERT(bt-node.nodeValue,"kz-1048","utf-8").



           if bt-node.nodeName = "PaperCredentials" then do:
             for each bt1-node where bt1-node.nodeParentId = bt-node.nodeId no-lock:
                if bt1-node.nodeName = "CType" then Doc:PayeeCType = CODEPAGE-CONVERT(bt1-node.nodeValue,"kz-1048","utf-8").
                if bt1-node.nodeName = "CNumber" then Doc:PayeeCNumber = CODEPAGE-CONVERT(bt1-node.nodeValue,"kz-1048","utf-8").
                if bt1-node.nodeName = "SerialNumber" then Doc:PayeeSerialNumber = CODEPAGE-CONVERT(bt1-node.nodeValue,"kz-1048","utf-8").
                if bt1-node.nodeName = "Issuer" then Doc:PayeeIssuer = CODEPAGE-CONVERT(bt1-node.nodeValue,"kz-1048","utf-8").
                if bt1-node.nodeName = "IssueDate" then Doc:PayeeIssueDate = bt1-node.nodeValue.
             end.
           end.

           if bt-node.nodeName = "Registry" then do:
             for each bt1-node where bt1-node.nodeParentId = bt-node.nodeId no-lock:
                if bt1-node.nodeName = "PNameID" then PNameID = bt1-node.nodeValue.
                if bt1-node.nodeName = "PValue" then PValue = bt1-node.nodeValue.

                if PNameID <> "" and PValue <> "" then do:
                  case PNameID:
                    when "BIRTHDATE" then do:
                      Doc:PayeeBirthDate = PValue.
                    end.
                    when "BIRTHCITY" then do:
                      Doc:PayeeBirthCity = PValue.
                    end.
                    when "ADDRESS" then do:
                      Doc:PayeeAddress = CODEPAGE-CONVERT(PValue,"kz-1048","utf-8").
                    end.
                    when "BIRTHCOUNTRY" then do:
                      Doc:PayeeBirthCountry = PValue.
                    end.
                    when "INN" then do:
                      Doc:PayeeINN = PValue.
                    end.
                    when "REGADDRESS" then do:
                      Doc:PayeeREGADDRESS = CODEPAGE-CONVERT(PValue,"kz-1048","utf-8").
                    end.
                    when "REGCITY" then do:
                      Doc:PayeeREGCITY = CODEPAGE-CONVERT(PValue,"kz-1048","utf-8").
                    end.
                    when "REGCOUNTRY" then do:
                      Doc:PayeeREGCOUNTRY = CODEPAGE-CONVERT(PValue,"kz-1048","utf-8").
                    end.
                    when "KBEKOD" then do:
                      Doc:PayeeKbeKod = PValue.
                    end.
                    when "KNP" then do:
                      Doc:PayeeKNP = PValue.
                    end.
                    when "ACCOUNT" then do:
                      Doc:PayeeAccount = PValue.
                    end.

                    otherwise do:
                     /* message "Неизвестный ключ " PNameID view-as alert-box.*/
                    end.
                  end case.

                  PNameID = "".
                  PValue = "".
                end.
             end.
           end.

          end. /*end Registry*/

        end. /*end Payee*/

     end.
     else p-errcode = 4.
   end.
   else p-errcode = 3.

  if not Doc:CheckDoc() then do: p-errcode = 25. p-errdes = "Неверный статус документа!". return. end.

if p-errcode > 0 then p-errdes = "Ошибка обработки xml!".

