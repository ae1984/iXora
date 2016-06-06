/* out_Gcps.p
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
 * AUTHOR
        31/12/99 pragma
 * CHANGES

                06/10/2011 Luiza  - добавила проверку акцепта кассира на поступление денег на арп счет.

*/


def new shared var v-option as cha.
define new shared variable s-title as character.
define new shared variable s-newrec as logical format "Да/Нет" .

{lgps.i "new"}
m_pid = "G" .
u_pid = "out_Gcps".
v-option = "rmz3gout".

def var v-crc like remtrz.tcrc.
def var v-amt like remtrz.payment.
def var v-rmz5 like remtrz.remtrz label "Платеж" .
def new shared var s-remtrz like remtrz.remtrz.
def var v-sname like cif.sname.
def var v-sacc like remtrz.sacc label "Счет плательщика".
def var v-racc like remtrz.racc.
def var v-rbank like remtrz.rbank .


form skip v-rmz5 with frame rmzor  side-label row 3  centered .
form skip v-crc v-amt with frame rmzoc  side-label row 6  centered .
form skip v-sacc with frame rbb side-label row 9 centered .

repeat :
{mainhead.i }

 update v-rmz5 validate (can-find (remtrz where remtrz.remtrz = v-rmz5),
    "Платеж не найден!" )
    with frame rmzor .
  s-remtrz = v-rmz5.
   find first remtrz where remtrz.remtrz = s-remtrz no-lock.

 if remtrz.source = "O" or remtrz.source = "RKO" or remtrz.source = "RKOTXB" then do:

    if remtrz.rwho = g-ofc then do :
       Message g-ofc " не может проверять платеж созданный им самим." .
       pause. undo, retry.
    end.

/* Luiza ----для тех платежей у которыx  retrz.jh3 > 0 -------------------------------------------*/
    find remtrz where remtrz.remtrz = s-remtrz no-lock no-error.
    if avail remtrz then do:
        if remtrz.jh3 > 0 then do:
            find last jl where jl.jh = remtrz.jh3 no-lock no-error.
            if not avail jl then do:
                message "Проводка поступления денег на арп счет не найдена! ~n№ транзакции "  + string(remtrz.jh3) view-as alert-box.
                return .
            end.
            if jl.sts <> 6 then do:
                message "Проводка поступления денег на арп счет не акцептована кассиром! ~n№ транзакции "  + string(remtrz.jh3) view-as alert-box.
                return.
            end.
        end.
    end.
/*--------------------------------------------------------------------------------*/



        update v-crc validate
        (can-find (crc where crc.crc = v-crc)
        and v-crc = remtrz.tcrc, "Неверный код валюты " )
        v-amt validate (v-amt = remtrz.payment, "Неверная сумма платежа")
        with frame rmzoc .

        /*** KOVAL Для валютчиков уберем проверку получателя ***/
        if v-crc = 1 then do:

           if remtrz.sacc ne "" then
           do :
             update  v-sacc
                with frame rbb.
             if trim(remtrz.sacc) ne trim(v-sacc) then
             do:
                  message "Некорректный счет плательщика!" .
                  pause 3 .
                  undo .
             end.
           end.

           if remtrz.racc ne "" then
           do :
              update "Счет получателя: " v-racc
                   with no-label row 9 centered frame rbb1.
              if trim(remtrz.racc) ne trim(v-racc) then
              do:
                  message "Некорректный счет получателя!" .
                  pause 3 .
                  undo .
              end.
           end.

         end. /*** v-crc = 1 ***/

     find first sysc where sysc.sysc = "lbnstr" no-lock no-error .
     if not avail sysc then do :
         message "Отсутствует запись LBNSTR в таблице SYSC!" .
         pause 3 .
         undo .
     end .

    if remtrz.cracc = sysc.chval then
    do :
        update " БАНК ПОЛУЧАТЕЛЬ : " v-rbank
            with no-label row 9 centered frame rbb1.
        find first bankl where substr(bankl.bank,7,3) = v-rbank
             no-lock no-error.
        if avail bankl and v-rbank <> "190" then
           v-rbank = bankl.bank .
        if remtrz.rbank <> v-rbank then do :
           message "Некорректный банк получателя!" .
           pause 3 .
           undo .
        end .
    end .

              /*
        if remtrz.tcrc = v-crc and remtrz.payment = v-amt
         then do :
         */
         run s-remtrz.
         hide all.
         v-crc = 1.
         v-amt = 0.
         s-remtrz = "".
         /*
         end.
        else do :
        Message "Неправильная валюта или сумма!!! ". pause.
        undo, retry.
       end.
           */
 end.
 else do:
    run s-remtrz.
    hide all.
    v-crc = 1.
    v-amt = 0.
    s-remtrz = "".
 end.
end.
