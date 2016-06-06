/* delpay.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
 * BASES
        BANK COMM 
 * AUTHOR
        26/03/09 id00205
        13.10.2010 k.gitalov перекомпиляция
 * CHANGES
       
*/

{global.i}

def input param Doc AS CLASS COMPAYDOCClass.
if not VALID-OBJECT(Doc) then do: message "Документ не инициализирован!" view-as alert-box. return. end.


def var pd-list as char.
def var Rez as char.
def var v-rec as char.
def var v-send as char.
def var v-tem as char.
def var v-mess as char.


find first comm.pksysc where comm.pksysc.sysc = "comadm" no-lock no-error.
if avail comm.pksysc then v-rec = comm.pksysc.chval.
else do:
  message "Не найден адрес старшего кассира Авангард-Plat!" view-as alert-box.
  return.
end.

pd-list = "1.Отказ по инициативе клиента|2.Отказ по инициативе Банка|3.Неожидаемый отказ клиента|4.Ошибка менеджера|5.Технические причины|6.Сбой АБС Ixora".
                            
run sel ("Выберите причину", pd-list).
Rez = return-value.


if Rez = "" then 
do:
 message "Необходимо выбрать причину!" view-as alert-box.
 return.
end. 


        v-send = g-ofc + "@metrocombank.kz".
        v-tem  = "Заявка на отмену платежа".
        v-mess = "Необходимо отменить документ:\n".
        v-mess = v-mess + "№ " + string(Doc:docno) + "\n".
        v-mess = v-mess + "Проводка: " + string(Doc:jh) + "\n".
        v-mess = v-mess + "Поставщик: " + Doc:suppname + "\n".
        v-mess = v-mess + "Сумма: " + string(Doc:summ , "zzz,zzz,zz9.99-") + "\n".
        v-mess = v-mess + "Филиал: " + Doc:b-name  + "\n".
        v-mess = v-mess + "Кассир:" + doc:who_cr + "  " + Doc:ofcname + "\n".
        v-mess = v-mess + "Причина: " + ENTRY(integer(Rez), pd-list,"|").
     
        run mail(v-rec, v-send, v-tem, v-mess, "", "", "").
       
     
        if Doc:state = 2 then Doc:SetState(3,"").
        if Doc:state = -1 then Doc:SetState(-3,"").
      
        
               