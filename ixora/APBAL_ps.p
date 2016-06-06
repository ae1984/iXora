/* APBAL_ps.p
 * MODULE
        Платежи Авангард-Плат
 * DESCRIPTION
        Процесс ПС для обновления остатка по Авангард-Плат и проведения готовых к отправке платежей
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
        13/10/2010 madiyar
 * BASES
        BANK COMM
 * CHANGES
        29/10/2010 k.gitalov перекомпиляция
        10.04.2013 damir - Внедрено Т.З. № 1577,1571.
*/

{global.i}


find first comm.pksysc where comm.pksysc.sysc = "comadm" no-lock no-error.
if avail comm.pksysc then
do:
  if comm.pksysc.loval = no then  return.
end.



function getErrorDes returns char (input err_code as integer).
    def var res as char no-undo.
    find first aperrlist where aperrlist.errcode = err_code no-lock no-error.
    if avail aperrlist then res = aperrlist.errdes. else res = string(err_code) + ": неизвестная ошибка".
    return res.
end function.

def var v-request as char no-undo.
def var v-reply as char no-undo.
def var sum as deci no-undo.
def var v-errcode as integer no-undo.
def var v-mess as char no-undo.
/* build request string */
v-request = '<BAL>'.

run savelog('ap','APBAL_ps->' + v-request).
run ap_send("tcp",no,v-request,output v-reply).
run savelog('ap','APBAL_ps<-' + v-reply).

v-errcode = 0.
if v-reply matches "mcberr*" then do:
    v-errcode = integer(entry(2,v-reply,'=')) no-error.
    run savelog('ap','APBAL_ps: (' + string(v-errcode) + ') ' + getErrorDes(v-errcode)).
    return.
end.

if v-reply = v-request then do:
    v-errcode = 9010. /* Сервис недоступен */
    run savelog('ap','APBAL_ps: (' + string(v-errcode) + ') ' + getErrorDes(v-errcode)).
    return.
end.

if v-reply matches '?*' then do:
    v-errcode = 9011. /* Ошибка обработки ответа на запрос */
    run savelog('ap','APBAL_ps: (' + string(v-errcode) + ') (?)' + getErrorDes(v-errcode)).
    return.
end.

if trim(v-reply) = '' then do:
    v-errcode = 9005. /* Сервис вернул пустую строку */
    run savelog('ap','APBAL_ps: (' + string(v-errcode) + ') (?)' + getErrorDes(v-errcode)).
    return.
end.

sum = 0.
if v-reply matches '*<BAL>' then do:
    sum = decimal(replace(entry(1,v-reply,';'),',','.')) no-error.
    if error-status:error then do:
        v-errcode = 9011. /* Ошибка обработки ответа на запрос */
        run savelog('ap','APBAL_ps: (' + string(v-errcode) + ') ' + getErrorDes(v-errcode) + ', конв. char->deci').
        return.
    end.
    else do transaction:
        find first pksysc where pksysc.credtype = '0' and pksysc.sysc = "apbal" exclusive-lock no-error.
        if not avail pksysc then do:
            create pksysc.
            assign pksysc.credtype = '0'
                   pksysc.sysc = 'apbal'
                   pksysc.des = "Остаток по Авангард-Плат".
        end.
        assign pksysc.daval = g-today
               pksysc.inval = time
               pksysc.deval = sum.
        find current pksysc no-lock.

        find first pksysc where pksysc.sysc = "comadm" no-lock no-error.
        if avail pksysc then
        do:
          if sum <= pksysc.deval and comm.pksysc.loval = yes then
          do:
           v-mess = "Необходимо пополнение счета в Авангард-Plat \r\n".
           v-mess = v-mess + "Текущий баланс - " + string(sum) + "\r\n".
           v-mess = v-mess + "Необходимый неснижаемый остаток - " + string(pksysc.deval).
           run mail(pksysc.chval, "bankadm@metrocombank.kz", "Проверка баланса в Авангард-Plat", v-mess , "", "", "").
          end.
        end.

    end.
end.
else do:
    v-errcode = 9011. /* Ошибка обработки ответа на запрос */
    run savelog('ap','APBAL_ps: (' + string(v-errcode) + ') ' + getErrorDes(v-errcode)).
    return.
end.

run comstat.

