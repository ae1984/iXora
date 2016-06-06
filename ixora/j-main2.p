/* j-main2.p
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
 * BASES
        BANK COMM
 * CHANGES
        добавлен ввод символа кассплана во время транзакции по кассе 21.05.01
        Изменена taxdelj на comm-dj 22.08.01
        обменные операции добавляет статут "del" при удалении 24.09.01
        добавлено обновление таблицы CASHOFC для кассового модуля 15.10.01

        09.04.2003 sasco, снятие спец. инструкции по блокировке суммы после контроля
        27.12.2004 tsoy,  добавил контроль параметров
        12.01.2005 tsoy,  добавил исключение для избранных департаментов
        14.06.2005 suchkov - добавил контроль КНП
        29.03.2006 sasco - исправил release и конце обработки b1 на find current... no-lock чтобы
                           в обработе b2 всегда был avail найденный joudoc
        02.02.10 marinav - расширение поля счета до 20 знаков
        20.05.2011 Luiza добавила автом заполнение данных окна контроля согласно допол к ТЗ 880.
        29/09/2011 Luiza добавила обработку перехода на ИИН
        30/09/2011 Luiza снятие спец инстр по внутренним платежам с счета клиента вызов jou-aasdel2
        26.03.2012 damir  - добавил keysign.i, сохранение документов для отображения подписей в ордерах.
        09/04/2012 Luiza - добавила проверку для контроля в данном п.м. только внутренних докум
        11.04.2012 damir - добавил signdocum.p.
        13.04.2012 damir - изменил формат с "yes/no" на "да/нет".
        10.05.2012 damir - перекомпиляция.
        21/05/2012 Luiza - изменила проверку для контроля в данном п.м. только внутренних докум
        27/06/2012 Luiza - уже отштампованные проводки не контролируются согласно  СЗ от 25/06/2012
        02/08/2012 id00810 - добавила в проверку joudop.type CS8 и вызов pcpay.i для доп.обработки транзакций по пополнению счетов по ПК
        19/06/2013 Luiza   - ТЗ 1904
*/


{mainhead.i}
{get-dep.i}
{keysign.i}

define new shared buffer bcrc for crc.
define new shared buffer ccrc for crc.
define new shared variable s-aaa   like aaa.aaa.
define new shared variable s-jh    like jh.jh label "TRX#".
define new shared variable jou     as character.
define new shared variable v_doc   like joudoc.docnum.
define new shared variable loccrc1 as character format "x(3)".
define new shared variable loccrc2 as character format "x(3)".
define new shared variable f-code  like crc.code.
define new shared variable t-code  like crc.code.
define new shared var vrat as deci decimals 2 .

def var is_aprove as logi no-undo.
def var v-dep  as char  no-undo.
def var v-deps as char no-undo.
def var quest2   as logical format "да/нет" init "yes" no-undo.
def var exist   as logical no-undo.
def var v-chk-amt   as deci no-undo.
def var v-chk-dracc like aaa.aaa no-undo.
def var v-chk-cramt like aaa.aaa no-undo.
def var v-chk-dname as char.
def var v-chk-cname as char.
def var v-ciff as char.
def var v-detpay as char.
def var v-chk-knp   as char no-undo.
def var v-chk-rnn   as char no-undo.
def var v-chk       as logi no-undo.
def var doc as integer no-undo.
def var vjh like jh.jh no-undo.
define variable v-cash   as logical no-undo.

/*define button b1 label "ПОИСК" .*/
/*define button b2 label "ШТАМПОВАТЬ" .*/

/*define frame a2
    b1 b2     with side-labels no-box.*/


def var v-bin as logi init no.
def var v-label as char.
find first sysc where sysc.sysc = 'bin' no-lock no-error.
if avail sysc then v-bin = sysc.loval.
if v-bin  then v-label = "ИИН получателя           ". else v-label = "РНН получателя           ".

/* 27.12.04 tsoy */
def frame f-chk
   v-chk-amt       label "Сумма                    "  format "zzz,zzz,zzz,zzz.99" skip
   v-chk-knp       label "КНП                      "  format "x(9)"               skip
   v-chk-dracc     label "Cчет плательщика         "                 skip
   v-chk-dname     label "Наименование плательщика "  format "x(30)"               skip
   v-chk-cramt     label "Cчет получателя          "                 skip
   v-chk-cname     label "Наименование получателя  "  format "x(30)"               skip
   v-label no-label format "x(25)" v-chk-rnn  no-label colon 26  format "x(12)"               skip
   v-detpay        label "Назначение платежа       "  format "x(40)"               skip
with centered overlay row 7 side-labels title " КОНТРОЛЬ ПАРАМЕТРОВ ".

{mframe2.i "new shared"}

find sysc where sysc.sysc = "j-main2" no-lock no-error.
if avail sysc then v-deps = sysc.chval.

find ofc where ofc.ofc = g-ofc no-lock no-error.
if avail ofc then v-dep = string(ofc.titcd).

is_aprove = false.
if index (v-deps, v-dep) > 0 and avail sysc then is_aprove = true.

on help of v_doc in frame f_main do:
    run help-joudoc2.
end.

/** N…KO№AIS **/

    DO TRANSACTION:
       v-chk-amt    = 0.
       v-chk-dracc  = "".
       v-chk-dname =  "".
       v-chk-cramt  = "".
       v-chk-cname =  "".
       v-chk-knp    = "".
       v-chk-rnn    = "".
        v-detpay    = "".

       s-jh  = ?.
       v_doc = "".
       clear frame f_main.
       update v_doc with frame f_main.
       find last joudoc where joudoc.docnum eq v_doc exclusive-lock no-error.
       if locked joudoc then do:
          message "ДОКУМЕНТ ЗАНЯТ ДРУГИМ ПОЛЬЗОВАТЕЛЕМ.".
          pause 3.
          undo, return.
       end.

       find last ujo where ujo.docnum eq v_doc exclusive-lock no-error .
       if locked ujo then do:
          message "ДОКУМЕНТ ЗАНЯТ ДРУГИМ ПОЛЬЗОВАТЕЛЕМ.".
          pause 3.
          undo, return.
       end.

       if not available joudoc and not available ujo then do:
          message "ДОКУМЕНТ НЕ НАЙДЕН.".
          pause 3.
          undo, return.
       end.

       exist = true.

       if available joudoc then  do:
          doc = 1.
          vjh = joudoc.jh.
          find first jh where jh.jh = vjh no-lock.
          if jh.sts = 6 then do:
              message " Проводка " + string(vjh)  + " уже отштампована!!" view-as alert-box.
              return.
          end.
       end.
       else  do:
          doc = 2.
          vjh = ujo.jh.
       end.
       display vjh with frame f_main.

       if exist then do:
          case doc:
               when 1 then do:
                 if joudoc.jh = ? then do:
                     message "Документ не найден!" view-as alert-box.
                     return.
                 end.
                 find first joudop where joudop.docnum = joudoc.docnum no-lock no-error.
                 if available joudop and not can-do("CS3,CS8",joudop.type) then do:
                      message "В данном п.м контролируются только внутренние переводы !" view-as alert-box.
                      return.
                 end.
               end. /*when 1*/
               when 2 then do:
                 if ujo.jh = ? then do:
                     message "Документ не найден!" view-as alert-box.
                     return.
                 end.
               end. /*when 2 */
          end case.
       end. /*if exist*/

    case doc:
         when 1 then if avail joudoc then find current joudoc no-lock.
         when 2 then if avail ujo then find current ujo no-lock.
    end case.
    release jl.
    /* штамп*****************************************************************************/
   if v_doc eq "" then undo, retry.

    /* Котроль реквизитов. */
    v-chk = false.
    if doc = 1  and not (is_aprove) then do:
    /* Luiza добавила автом заполнение данных окна контроля*/
       if (joudoc.crcur = 1 and joudoc.drcur = 1) or (available joudop and joudop.type  = "CS8") then do:
            v-chk-amt =  joudoc.dramt.
            find first trxcods where trxcods.trxh  = joudoc.jh and trxcods.trxln = 1 and trxcods.codfr = "spnpl" no-lock no-error.
            if avail trxcods then v-chk-knp = trxcods.code.
            v-chk-dracc  = joudoc.dracc.
            v-chk-cramt  = joudoc.cracc.
            find first aaa where aaa.aaa = joudoc.dracc no-lock no-error.
            if avail aaa then do:
                v-ciff =  aaa.cif.
                find first cif where cif.cif = v-ciff no-lock no-error.
                if avail cif then v-chk-dname = trim(trim(cif.prefix) + " " + trim(cif.name)).
            end.
            find first aaa where aaa.aaa = joudoc.cracc no-lock no-error.
            if avail aaa then do:
                v-ciff =  aaa.cif.
                find first cif where cif.cif = v-ciff no-lock no-error.
                if avail cif then v-chk-cname = trim(trim(cif.prefix) + " " + trim(cif.name)).
            end.
            v-detpay = trim(joudoc.remark[1]) + " " + trim(joudoc.remark[2]) + " " + trim(joudoc.rescha[3]).
        /*-------------------------------------------------------*/

           repeat while not v-chk.
                 displ v-chk-dname v-chk-cname v-detpay v-label with frame f-chk.
                 update
                      v-chk-amt
                      v-chk-knp
                      v-chk-dracc
                      v-chk-cramt
                      v-chk-rnn
                 with frame f-chk.

                 v-chk = true.

                 if v-chk-amt  <> joudoc.dramt then do:
                    message "Не верная сумма !" view-as alert-box.
                    v-chk = false.
                    next.
                 end.

                 if not can-find (trxcods where trxcods.trxh  = joudoc.jh
                                            and trxcods.trxln = 1
                                            and trxcods.codfr = "spnpl"
                                            and trxcods.code  = v-chk-knp no-lock) then do:
                    message "Не верный код назначения платежа !" view-as alert-box.
                    v-chk = false.
                    next.
                 end.

                 if v-chk-dracc  <> joudoc.dracc then do:
                    message "Не верный счет плательщика !" view-as alert-box.
                    v-chk = false.
                    next.
                 end.

                 if v-chk-cramt  <> joudoc.cracc then do:
                    message "Не верный счет получателя !" view-as alert-box.
                    v-chk = false.
                    next.
                 end.

                 find aaa where aaa.aaa = joudoc.cracc no-lock no-error.
                 if avail aaa then do:
                    find cif where cif.cif = aaa.cif no-lock no-error.
                    if avail cif then do:
                       if v-bin then do:
                           if v-chk-rnn  <> cif.bin then do:
                              message "Не верный ИИН !" view-as alert-box.
                              v-chk = false.
                              next.
                           end.
                       end.
                       else do:
                           if v-chk-rnn  <> cif.jss then do:
                              message "Не верный РНН !" view-as alert-box.
                              v-chk = false.
                              next.
                           end.
                        end.
                    end.
                 end.
                 else do:
                    find first arp where arp.arp = joudoc.cracc no-lock no-error.
                    if avail arp then do:
                        find first cmp no-lock no-error.
                        find sysc where sysc.sysc = "bnkbin" no-lock no-error.
                        if v-bin then do:
                            if v-chk-rnn  <> trim(sysc.chval) then do:
                                message "Неверный БИН !" view-as alert-box.
                                v-chk = false.
                                next.
                            end.
                        end. else do:
                            if v-chk-rnn  <> trim(cmp.addr[2]) then do:
                                message "Неверный РНН !" view-as alert-box.
                                v-chk = false.
                                next.
                            end.
                        end.
                    end.
                 end.
          end.
       end.
    end.
    if doc = 2 then v-chk = true.
    if doc = 1 then do:
       if (joudoc.crcur <> 1 or joudoc.drcur <> 1)  then v-chk = true.
    end.
    if  doc = 1 and (is_aprove) then v-chk = true.

    hide frame f-chk.
    if not v-chk then undo, return.

    quest2 = false.
    case doc:
         when 1 then s-jh = joudoc.jh.
         when 2 then s-jh = ujo.jh.
    end case.

    if doc = 1 and not (is_aprove) then do:
       if joudoc.crcur = 1 and joudoc.drcur = 1 then do:
          message "Детали " + joudoc.rem[1] + joudoc.rem[2] + "\n Штамповать(y/n)?" view-as alert-box question buttons yes-no update quest2 /*as logical*/ .
                       if not quest2 then undo, return.
       end.
       else do:
            {mesg.i 6811} update quest2.
            if not quest2 then undo, return.
       end.
    end.
    else do:
         {mesg.i 6811} update quest2.
         if not quest2 then undo, return.
    end.
    if quest2 then do:  /*stamp*/

        if avail joudoc then run jou-aasdel2(joudoc.cracc, joudoc.cramt, joudoc.jh). /* Luiza сняти спец инстр по внутренним платежам с счета клиента */

        /* sasco - снятие спец. инструкции с суммы */
        if avail joudoc then run jou-aasdel (joudoc.cracc, joudoc.cramt, joudoc.jh).
        find jh where jh.jh = s-jh no-lock no-error.
        if available jh then do:
            for each jl of jh:
              if jl.acc ne "" and  jl.aax = 1  then do:
                 find aaa where aaa.aaa = jl.acc exclusive-lock no-error.
                 if avail aaa then do:
                    aaa.cbal = aaa.cbal + jl.dam + jl.cam .
                    aaa.fbal[1] = aaa.fbal[1] - (jl.dam + jl.cam).
                    jl.aax = 0.
                 end.
              end.
            end.
        end. /* if vailable jh*/
        run jl-stmp.
        if avail jh then if v-transsign = yes then run signdocum(input jh.sub,input jh.ref).
        {pcpay.i}
        release jh.
        release jl.
        release aaa.
        clear frame f_main.
        /*  on endkey undo, return. */
        return.
    end.
end. /* transaction*/
