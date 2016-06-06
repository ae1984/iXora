/* kfmoperh_cre.p
 * MODULE
        Финансовый мониторинг
 * DESCRIPTION
        Создаем во временной таблице критерии операции
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
*/
{global.i}


def input parameter p-opState as char.
def input parameter p-msgReas as char.
def input parameter p-opId as char.
def input parameter p-opType as char.
def input parameter p-opEknp as char.
def input parameter p-opNumPrt as char.
def input parameter p-opCrc as char.
def input parameter p-opSum as char.
def input parameter p-opSumKZT as char.
def input parameter p-opReas  as char.
def input parameter p-opDocN  as char.
def input parameter p-opDocDt  as char.
def input parameter p-opSus1 as char.
def input parameter p-opSus2 as char.
def input parameter p-opSus3 as char.
def input parameter p-opSusDes as char.
def input parameter p-msgReas2 as char.
def input parameter p-opAddInf as char.

def output parameter p-operId as integer.


{kfm.i}


p-operId = next-value(kfmOperId).



for each kfmkrit where kfmkrit.priz = 0 no-lock:
    create t-kfmoperh.
    assign t-kfmoperh.bank = s-ourbank
           t-kfmoperh.operId = p-operId
           t-kfmoperh.dataCode = kfmkrit.dataCode
           t-kfmoperh.showOrder = kfmkrit.showOrder
           t-kfmoperh.dataName = kfmkrit.dataName
           t-kfmoperh.dataSpr = kfmkrit.dataSpr.



           case t-kfmoperh.dataCode:
                when "fm1Num" then t-kfmoperh.dataValue = string(p-operId).
                when "fm1Date" then t-kfmoperh.dataValue = string(g-today,'99/99/9999').

                when "opState" then t-kfmoperh.dataValue = p-opState.
                when "msgReas" then t-kfmoperh.dataValue = p-msgReas.
                when "msgReas2" then t-kfmoperh.dataValue = p-msgReas2.

                when "opId" then t-kfmoperh.dataValue = p-opId.
                when "opType" then t-kfmoperh.dataValue = p-opType.
                when "opEknp" then t-kfmoperh.dataValue = p-opEknp.
                when "opNumPrt" then t-kfmoperh.dataValue = p-opNumPrt.
                when "opCrc" then t-kfmoperh.dataValue = p-opCrc.
                when "opSum" then t-kfmoperh.dataValue = p-opSum.
                when "opSumKZT" then t-kfmoperh.dataValue = p-opSumKZT.
                when "opReas" then t-kfmoperh.dataValue = p-opReas.
                when "opDocN" then t-kfmoperh.dataValue = p-opDocN.
                when "opDocDt" then t-kfmoperh.dataValue = p-opDocDt.
                when "opSus1" then t-kfmoperh.dataValue = p-opSus1.
                when "opSus2" then t-kfmoperh.dataValue = p-opSus2.
                when "opSus3" then t-kfmoperh.dataValue = p-opSus3.
                when "opSusDes" then t-kfmoperh.dataValue = p-opSusDes.
                when "opAddInf" then t-kfmoperh.dataValue = p-opAddInf.

           end case.
end.

