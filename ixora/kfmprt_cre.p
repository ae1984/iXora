/* kfmrpt_cre.p
 * MODULE
        Финансовый мониторинг
 * DESCRIPTION
        Создаем во временной таблице критерии по участникам операции
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
        30/03/2010 galina
 * BASES
        BANK COMM
 * CHANGES
        01/06/2010 galina - добавила kfm.i
        22/07/2010 galina - добавила парметр p-prtWhtFV
*/
def input parameter p-operId as int.
def input parameter p-partId as int.
def input parameter p-prtWhat as char.
def input parameter p-prtClien as char.
def input parameter p-prtWhat2 as char.

def input parameter p-prtRsd as char.

def input parameter p-prtRsdC as char.
def input parameter p-prtType as char.
def input parameter p-prtFPOF as char.

def input parameter p-prtFPOF2 as char.

def input parameter p-prtBAcc as char.
def input parameter p-prtBName as char.
def input parameter p-prtBCode as char.
def input parameter p-prtBCoun as char.
def input parameter p-prtCAcc as char.
def input parameter p-prtCBnk as char.
def input parameter p-prtCBnkC as char.
def input parameter p-prtCCoun as char.
def input parameter p-prtNameU as char.
def input parameter p-prtFIO1U as char.
def input parameter p-prtRNN as char.
def input parameter p-prtOKPO as char.
def input parameter p-prtOKED as char.
def input parameter p-prtIIN as char.
def input parameter p-prtFLNam  as char.
def input parameter p-prtFFNam  as char.
def input parameter p-prtFMNam  as char.
def input parameter p-prtPhone  as char.
def input parameter p-prtEmail  as char.

def input parameter p-prtUD as char.
def input parameter p-prtUdN as char.
def input parameter p-prtUdS as char.
def input parameter p-prtUdIs as char.
def input parameter p-prtUdDt as char.
def input parameter p-prtBirDt as char.
def input parameter p-prtBirPl as char.
def input parameter p-prtAddrU as char.
def input parameter p-prtAddrF as char.
def input parameter p-prtAdInf as char.
def input parameter p-prtWhtFV as char.

{kfm.i}

create t-kfmprt.
assign t-kfmprt.bank = s-ourbank
       t-kfmprt.operId = p-operId
       t-kfmprt.partId = p-partId.
       if trim(p-prtNameU) <> '' then t-kfmprt.partName = p-prtNameU.
       if trim(trim(p-prtFLNam) + ' ' + trim(p-prtFFNam) + ' ' + trim(p-prtFMNam)) <> '' then t-kfmprt.partName = trim(trim(p-prtFLNam) + ' ' + trim(p-prtFFNam) + ' ' + trim(p-prtFMNam)).

if trim(t-kfmprt.partName) = '' then t-kfmprt.partName = 'Невозможно установить'.


for each kfmkrit where kfmkrit.priz = 1 no-lock:
   create t-kfmprth.
   assign t-kfmprth.bank = s-ourbank
          t-kfmprth.operId = p-operId
          t-kfmprth.partId = p-partId
          t-kfmprth.dataCode = kfmkrit.dataCode
          t-kfmprth.showOrder = kfmkrit.showOrder
          t-kfmprth.dataName = kfmkrit.dataName
          t-kfmprth.dataSpr = kfmkrit.dataSpr.

          case t-kfmprth.dataCode:
            when "prtWhat" then t-kfmprth.dataValue = p-prtWhat.
            when "prtClien" then t-kfmprth.dataValue = p-prtClien.
            when "prtWhat2" then  t-kfmprth.dataValue = p-prtWhat2.
            when "prtWhtFV" then  t-kfmprth.dataValue = p-prtWhtFV.

            when "prtRsd" then t-kfmprth.dataValue = p-prtRsd.
            when "prtRsdC" then t-kfmprth.dataValue = p-prtRsdC.
            when "prtType" then t-kfmprth.dataValue = p-prtType.
            when "prtFPOF" then t-kfmprth.dataValue = p-prtFPOF.
            when "prtFPOF2" then t-kfmprth.dataValue = p-prtFPOF2.
            when "prtBAcc" then t-kfmprth.dataValue = p-prtBAcc.
            when "prtBName" then t-kfmprth.dataValue = p-prtBName.
            when "prtBCode" then t-kfmprth.dataValue = p-prtBCode.
            when "prtBCoun" then t-kfmprth.dataValue = p-prtBCoun.
            when "prtCAcc" then t-kfmprth.dataValue = p-prtCAcc.
            when "prtCBnk" then t-kfmprth.dataValue = p-prtCBnk.
            when "prtCBnkC" then t-kfmprth.dataValue = p-prtCBnkC.
            when "prtCCoun" then t-kfmprth.dataValue = p-prtCCoun.
            when "prtNameU" then t-kfmprth.dataValue = p-prtNameU.
            when "prtFIO1U" then t-kfmprth.dataValue = p-prtFIO1U.
            when "prtRNN" then t-kfmprth.dataValue = p-prtRNN.
            when "prtOKPO" then t-kfmprth.dataValue = p-prtOKPO.
            when "prtOKED" then t-kfmprth.dataValue = p-prtOKED.
            when "prtIIN" then t-kfmprth.dataValue = p-prtIIN.
            /*when "prtFIO" then t-kfmprth.dataValue = p-prtFIO.*/
            when "prtPhone" then t-kfmprth.dataValue = p-prtPhone.
            when "prtEmail" then t-kfmprth.dataValue = p-prtEmail.
            when "prtFLNam" then t-kfmprth.dataValue = p-prtFLNam.
            when "prtFFNam" then t-kfmprth.dataValue = p-prtFFNam.
            when "prtFMNam" then t-kfmprth.dataValue = p-prtFMNam.
            when "prtUD" then t-kfmprth.dataValue = p-prtUD.
            when "prtUdN" then t-kfmprth.dataValue = p-prtUdN.
            when "prtUdS" then t-kfmprth.dataValue = p-prtUdS.
            when "prtUdIs" then t-kfmprth.dataValue = p-prtUdIs.
            when "prtUdDt" then t-kfmprth.dataValue = p-prtUdDt.
            when "prtBirDt" then t-kfmprth.dataValue = p-prtBirDt.
            when "prtBirPl" then t-kfmprth.dataValue = p-prtBirPl.
            when "prtAddrU" then t-kfmprth.dataValue = p-prtAddrU.
            when "prtAddrF" then t-kfmprth.dataValue = p-prtAddrF.
            when "prtAdInf" then t-kfmprth.dataValue = p-prtAdInf.
          end case.

end.

