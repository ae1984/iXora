/* f-paycost.p
 * MODULE
        Главная бухгалтерская книга
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
        12.18
 * AUTHOR
        01.03.2011 k.gitalov
 * BASES
        BANK COMM TXB
 * CHANGES
        13.08.2013 damir - Внедрено Т.З. № 1182,1258,1257,1650. com_exp - getRMZExp (добавил CHF,AUD).
*/
def shared temp-table t-period no-undo
    field pid as integer
    field dtb as date
    field dte as date
    index idx is primary dtb.

def shared temp-table t-krit no-undo
    field kid as integer
    field kcode as char
    field bold_code as log
    field color_code as log
    field des_en as char
    field des_ru as char
    field level as integer
    index idx is primary kid
    index idx2 kcode.

def shared temp-table t-kritval no-undo
    field bank as char
    field kid as integer
    field pid as integer
    field sum as deci
    index idx is primary bank kid pid.



def var s-ourbank as char no-undo.
find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(txb.sysc.chval).

/* Получить сохраненное ранее значение */
function getStoredKritVal returns deci (input p-bank as char, input p-kcode as char, input p-dtb as date).
    def var v-res as deci no-undo.
    v-res = 0.
    find first uprdata where uprdata.bank = p-bank and uprdata.kcode = "fact_" + p-kcode and uprdata.dtb = p-dtb no-lock no-error.
    if avail uprdata then v-res = uprdata.kvalue.
    return v-res.
end function.

/* Сохранить значение для использования в других отчетах */
procedure setStoredKritVal.
    def input parameter p-bank as char no-undo.
    def input parameter p-kcode as char no-undo.
    def input parameter p-dtb as date no-undo.
    def input parameter p-sum as deci no-undo.
    do transaction:
        find first uprdata where uprdata.bank = p-bank and uprdata.kcode = "fact_" + p-kcode and uprdata.dtb = p-dtb exclusive-lock no-error.
        if not avail uprdata then do:
            create uprdata.
            assign uprdata.bank = p-bank
                   uprdata.kcode = "fact_" + p-kcode
                   uprdata.dtb = p-dtb.
        end.
        uprdata.kvalue = p-sum.
        find current uprdata no-lock.
    end. /* transaction */
end procedure.


def var PayKZT as int init 0.
def var PayRUB as int init 0.
def var PayUSD as int init 0.
def var PayEUR as int init 0.
def var PayGBP as int init 0.
def var PayAUD as int init 0.
def var PayCHF as int init 0.
/*
def var v-result as char.
def var repname as char.
repname = "log_getRMZExp_" + s-ourbank + "_" + replace(string(today,"99/99/9999"),"/","-") + "_" +  replace(string(time,"HH:MM:SS"),"/","-") + ".txt".
def stream rep.
output stream rep to value(repname).
*/
function getRMZExp returns decimal (input dt1 as date , input dt2 as date):
    def var res as decimal.
    def var v-type as char no-undo.

    res = 0.
    PayKZT = 0.
    PayRUB = 0.
    PayUSD = 0.
    PayEUR = 0.
    PayGBP = 0.
    PayAUD = 0.
    PayCHF = 0.

   /* put stream rep unformatted "~nC " string(dt1,"99/99/9999") " По " string(dt2,"99/99/9999") "~n".*/

    if s-ourbank = "txb00" then v-type = '6'. else v-type = '4'.
    for each txb.remtrz where txb.remtrz.valdt2 >= dt1 and txb.remtrz.valdt2 <= dt2 and txb.remtrz.ptype = v-type no-lock:
        if txb.remtrz.jh1 = ? or txb.remtrz.jh2 = ? then next.
        if s-ourbank <> "txb00" then do:
            if txb.remtrz.rbank begins "txb" then next.
        end.

       case txb.remtrz.fcrc:
         when 1 then do: PayKZT = PayKZT + 1. end.
         when 2 then do: PayUSD = PayUSD + 1. end.
         when 3 then do: PayEUR = PayEUR + 1. end.
         when 4 then do: PayRUB = PayRUB + 1. end.
         when 6 then do: PayGBP = PayGBP + 1. end.
         when 8 then do: PayAUD = PayAUD + 1. end.
         when 9 then do: PayCHF = PayCHF + 1. end.
       end case.

      /*
        if txb.remtrz.fcrc = 1 then do: res = res + getSprValR('',"payCostKZT",txb.remtrz.valdt2). PayKZT = PayKZT + 1. end.
        else
        if txb.remtrz.fcrc = 4 then do: res = res + getSprValR('',"payCostRUB",txb.remtrz.valdt2). PayRUB = PayRUB + 1. end.
        else do: res = res + getSprValR('',"payCostVal",txb.remtrz.valdt2). PayVal = PayVal + 1. end.
      */
       /* put stream rep unformatted txb.remtrz.remtrz ",".*/
    end.

  /*  put stream rep unformatted "~n KZT = " string(PayKZT) "~n RUB = " string(PayRUB) "~n VAL = " string(PayVal) "~n SUMM = " string(res,">>>>>>>>>>>>>>>9.99-") "~n".*/

    return res.
end function.


function getGL returns deci (input p-gl as integer, input p-dt as date).
    def var res as deci no-undo.
    def var res1 as deci no-undo.
    res = 0.
    for each txb.crc no-lock:
        find last txb.glday where txb.glday.gl = p-gl and txb.glday.crc = txb.crc.crc and txb.glday.gdt <= p-dt no-lock no-error.
        if avail txb.glday then do:

            if string(p-gl) = "359910" then res1 = txb.glday.bal.
            else res1 = txb.glday.dam - txb.glday.cam.

            if res1 <> 0 then do:
                if txb.crc.crc = 1 then res = res + res1.
                else do:
                    find last txb.crchis where txb.crchis.crc = txb.crc.crc and txb.crchis.rdt <= p-dt no-lock no-error.
                    if avail txb.crchis then res = res + res1 * txb.crchis.rate[1].
                end.
            end.
        end.
    end.
    return res.
end function.


function str2GL returns integer (input p-glstr as char, input p-gltype as char).
    def var res as integer no-undo.
    res = 0.
    def var v-i as integer no-undo.
    v-i = ?.
    def var v-c as char no-undo.
    v-c = ''.
    p-glstr = trim(p-glstr).
    if (p-gltype = "start") or (p-gltype = "end") then do:
        if p-gltype = "start" then v-c = '0'. else v-c = '9'.
        if (p-glstr <> '') and length(p-glstr) <= 6 then do:
            v-i = integer(p-glstr) no-error.
            if (v-i <> ?) and (v-i > 0) then do:
                res = integer(p-glstr + fill(v-c,6 - length(p-glstr))).
            end.
        end.
    end.
    return res.
end function.


function getGroupGL returns deci (input p-gr as char, input p-ex as char, input p-dt as date).
    def var res as deci no-undo.
    def var v-i as integer no-undo.
    def var v-j as integer no-undo.
    def var gr as char no-undo.
    p-gr = trim(p-gr).
    p-ex = trim(p-ex).
    res = 0.
    if p-gr <> '' then do:
        do v-i = 1 to num-entries(p-gr):
            gr = entry(v-i,p-gr).
         g: for each txb.gl where txb.gl.gl >= str2GL(gr,"start") and txb.gl.gl <= str2GL(gr,"end") no-lock:
                /* gl.totact = no gl.totlev = 1 */
                if gl.totact and p-gr <> "359910" then next.
                if p-ex <> '' then do:
                    do v-j = 1 to num-entries(p-ex):
                        if substring(string(txb.gl.gl),1,length(entry(v-j,p-ex))) = entry(v-j,p-ex) then next g.
                    end.
                end.

                res = res + getGL(txb.gl.gl,p-dt).

            end.
        end. /* do v-i */
    end. /* if p-gr <> '' */
    return res.
end function.

/*******************************************************************************************************/
for each t-period no-lock:
   getRMZExp(t-period.dtb,t-period.dte).

   run setStoredKritVal( s-ourbank , "payCostKZT_Count" , t-period.dtb , PayKZT ).
   run setStoredKritVal( s-ourbank , "payCostRUB_Count" , t-period.dtb , PayRUB ).
   run setStoredKritVal( s-ourbank , "payCostUSD_Count" , t-period.dtb , PayUSD ).
   run setStoredKritVal( s-ourbank , "payCostEUR_Count" , t-period.dtb , PayEUR ).
   run setStoredKritVal( s-ourbank , "payCostGBP_Count" , t-period.dtb , PayGBP ).
   run setStoredKritVal( s-ourbank , "payCostAUD_Count" , t-period.dtb , PayAUD ).
   run setStoredKritVal( s-ourbank , "payCostCHF_Count" , t-period.dtb , PayCHF ).

  if month(t-period.dtb) = 1 then do:
   run setStoredKritVal( s-ourbank , "com_exp_KZT" , t-period.dtb , getGroupGL('560800,560811,560812','',t-period.dte)  ).
   run setStoredKritVal( s-ourbank , "com_exp_RUB" , t-period.dtb , getGroupGL('560111','',t-period.dte)  ).
   run setStoredKritVal( s-ourbank , "com_exp_USD" , t-period.dtb , getGroupGL('560100','',t-period.dte)  ).
   run setStoredKritVal( s-ourbank , "com_exp_EUR" , t-period.dtb , getGroupGL('560110','',t-period.dte)  ).
   run setStoredKritVal( s-ourbank , "com_exp_GBP" , t-period.dtb , getGroupGL('560112','',t-period.dte)  ).
   run setStoredKritVal( s-ourbank , "com_exp_AUD" , t-period.dtb , getGroupGL('560114','',t-period.dte)  ).
   run setStoredKritVal( s-ourbank , "com_exp_CHF" , t-period.dtb , getGroupGL('560113','',t-period.dte)  ).
  end.
  else do:
   run setStoredKritVal( s-ourbank , "com_exp_KZT" , t-period.dtb , getGroupGL('560800,560811,560812','',t-period.dte) - getGroupGL('560800,560811,560812','',t-period.dtb - 1) ).
   run setStoredKritVal( s-ourbank , "com_exp_RUB" , t-period.dtb , getGroupGL('560111','',t-period.dte) - getGroupGL('560111','',t-period.dtb - 1) ).
   run setStoredKritVal( s-ourbank , "com_exp_USD" , t-period.dtb , getGroupGL('560100','',t-period.dte) - getGroupGL('560100','',t-period.dtb - 1) ).
   run setStoredKritVal( s-ourbank , "com_exp_EUR" , t-period.dtb , getGroupGL('560110','',t-period.dte) - getGroupGL('560110','',t-period.dtb - 1) ).
   run setStoredKritVal( s-ourbank , "com_exp_GBP" , t-period.dtb , getGroupGL('560112','',t-period.dte) - getGroupGL('560112','',t-period.dtb - 1) ).
   run setStoredKritVal( s-ourbank , "com_exp_AUD" , t-period.dtb , getGroupGL('560114','',t-period.dte) - getGroupGL('560114','',t-period.dtb - 1) ).
   run setStoredKritVal( s-ourbank , "com_exp_CHF" , t-period.dtb , getGroupGL('560113','',t-period.dte) - getGroupGL('560113','',t-period.dtb - 1) ).
  end.

end.
/*******************************************************************************************************/

