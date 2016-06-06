/* CompayFunc.i
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
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
        --/--/2012 damir
 * BASES
        BANK COMM
 * CHANGES
        27.02.2013 damir - Внесены изменения, вступившие в силу 01/02/2013.
*/
procedure AddCalcProv:
    def input parameter p-FormulType as logi.
    def input parameter p-IdServ as inte. /*идентификатор сервиса*/
    def input parameter p-Curr as deci. /*последние показания*/
    def input parameter p-Prev as deci. /*предыдущие показания*/
    def input parameter p-tKoef as deci. /*коэффициент трансформации*/
    def input parameter p-lossesCount as deci. /*потери кВт.ч день*/
    def input parameter p-minTariffValue as deci. /*тариф менее лимита 1 день*/
    def input parameter p-middleTariffValue as deci. /*тариф сверх лимита 1 день*/
    def input parameter p-maxTariffValue as deci. /*тариф сверх лимита 2 день*/
    def input parameter p-minTariffThreshold as deci. /*норма 1 потребления кВт*ч в месяц*/
    def input parameter p-middleTariffThreshold as deci. /*норма 2 потребления кВт*ч в месяц*/
    def input parameter p-prevCountDate as date. /*дата предыдущих показаний день*/
    def input parameter p-lastCountDate as date. /*дата последних показаний день*/
    def input parameter p-parValue as inte. /*количество проживающих, зафиксированное на лицевом счете*/
    def input parameter p-ProvList as char. /*список идентификаторов сервисов*/
    def output parameter p-ForPay as deci.


    def var v-ElecCons as deci.
    def var v-K01 as deci.
    def var v-K02 as deci.
    def var v-NumDay as inte. /*количество дней между последними и предыдущими показаниями*/

    p-ForPay = 0. v-ElecCons = 0.
    if lookup(string(p-IdServ),p-ProvList) > 0 then do:
        if p-FormulType then do:
            v-ElecCons = ((p-Curr - p-Prev) * p-tKoef) + p-lossesCount.
            p-ForPay = v-ElecCons * p-minTariffValue.
        end.
        else do:
            v-NumDay = p-lastCountDate - p-prevCountDate.
            if v-NumDay < 30 then do:
                v-K01 = p-minTariffThreshold / 30.5 * v-NumDay * p-parValue.
                v-K02 = p-middleTariffThreshold / 30.5 * v-NumDay * p-parValue.
            end.
            else do:
                v-K01 = p-minTariffThreshold * p-parValue.
                v-K02 = p-middleTariffThreshold * p-parValue.
            end.
            v-ElecCons = (p-Curr - p-Prev) * p-tKoef + p-lossesCount.
            if v-ElecCons <= v-K01 then p-ForPay = v-ElecCons * p-minTariffValue.
            else if v-K01 < v-ElecCons and v-ElecCons <= v-K02 then p-ForPay = v-K01 * p-minTariffValue + (v-ElecCons - v-K01) * p-middleTariffValue.
            else if v-ElecCons > v-K02 then p-ForPay = v-K01 * p-minTariffValue + (v-K02 - v-K01) * p-middleTariffValue + (v-ElecCons - v-K02) *
            p-maxTariffValue.
        end.
    end.
end procedure.

