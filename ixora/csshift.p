/* csshift.p
 * MODULE
        Кассовый модуль
 * DESCRIPTION
        Открытие/закрытие кассирской смены
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
 * BASES
        BANK COMM

 * CHANGES
                10/02/2012 Luiza - добавила возможность выбора сейфа

*/

{mainhead.i}

def var v-id as char no-undo.
def var v-dispensedAmt as deci no-undo.
def var v-acceptedAmt as deci no-undo.
def var v-auxOut as char no-undo.

def var s-ourbank as char no-undo.
find sysc where sysc.sysc = "ourbnk" no-lock no-error.
s-ourbank = trim(bank.sysc.chval).

/*find first csofc where  csofc.ofc = g-ofc no-lock no-error.
if avail csofc then v-nomer = csofc.nomer.
else do:
    message "Нет привязки к ЭК!" view-as alert-box error.
    return.
end.
find first cslist where cslist.nomer = v-nomer and cslist.bank = s-ourbank no-lock no-error.
if not avail cslist then do:
    message "Нет ЭК в справочнике или указан ЭК другого филиала!" view-as alert-box error.
    return.
end.*/

def var v-nomer as char.
def var v-side as char.
def var CsList as char.
for each csofc where csofc.ofc = g-ofc no-lock:
 if length(CsList) > 0 then CsList = CsList + "," + csofc.nomer.
 else CsList = csofc.nomer.
end.
if num-entries(CsList) > 1 then do:
  CsList = replace(CsList,",","|").
  run sel1("Сейф для операции", CsList).
  v-nomer = return-value.
  if v-nomer = "" then return.
end.
else do:
  v-nomer = CsList.
end.


def var rez as logi no-undo.

def var v-sel as integer no-undo.
run sel2 ("Операция :", " 1. Открытие смены кассира | 2. Закрытие смены кассира | 3. Выход ", output v-sel).
if (v-sel < 1) or (v-sel > 3) then return.

case v-sel:
    when 1 then do:
        rez = false.
        run smart_trx(g-ofc,v-nomer,replace(string(today) + string(time),"/",""),1,"",0,0,"",input-output v-id,output rez,output v-dispensedAmt,output v-acceptedAmt,output v-auxOut).
        if rez then message "Открытие смены прошло успешно!" view-as alert-box information.
    end.
    when 2 then do:
        rez = false.
        run smart_trx(g-ofc,v-nomer,replace(string(today) + string(time),"/",""),2,"",0,0,"",input-output v-id,output rez,output v-dispensedAmt,output v-acceptedAmt,output v-auxOut).
        if rez then message "Закрытие смены прошло успешно!" view-as alert-box information.
    end.
    when 3 then return.
end case.

