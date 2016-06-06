/* Mt950ChkMt103.p
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
        12.10.2012 evseev ТЗ-1288
 * BASES
        BANK COMM
 * CHANGES
        26.11.2012 evseev - ДПС. СЗ от 26/11/2012
        19.12.2012
        16/09/2013 galina - ТЗ 2090 меяем вторую дату валютирования в remtrz на дату, указанную в файле сверки
*/

{global.i}

def var v-bic950 as char.
def var v-bic103 as char.
def var v-bnkname as char.

def var v-str as char.
def var v-int as int.
def var v-real as deci.
def var v-sum61 as decimal.
def var v-sum103 as decimal.
def var v-ref61-1 as char.
def var v-flag as char.
def var v-ref103 as char.
def var v-valdt2 as date.
def buffer b-swift_det for swift_det.
def buffer b-swift for swift.

{lgps.i "new"}
m_pid = "SWS" .
/*u_pid = "SWS_ps" .
v-option = "rmzSWS".*/

for each swift where swift.mt = "950" and swift.io = "O" and swift.dt >= today - 10 use-index idx_mt no-lock:
    /*find last swift_sts where swift_sts.swift_id = swift.swift_id use-index idx_swift_id no-lock no-error.
    if avail swift_sts and swift_sts.sts <> "new" then next.*/
    v-bic950 = ''.
    v-bnkname = ''.
    find first swift_det where swift_det.swift_id = swift.swift_id and swift_det.val matches "*\{2:*" no-lock no-error.
    if avail swift_det then do:
       v-bic950 = substr(swift_det.val,index(swift_det.val,"\{2:") + 17,8).
       find first swibic where swibic.bic = v-bic950 + "XXX" no-lock no-error.
       if not avail swibic then run InsSwiftSts(swift.swift_id, "BIC " + v-bic950 + " не найден в справочнике swibic","error").
       find first bankl where bankl.bic matches "*" + v-bic950 + "*" no-lock no-error.
       if avail bankl then v-bnkname = bankl.cbank.
       else run InsSwiftSts(swift.swift_id, "BIC " + v-bic950 + " не найден в справочнике bankl","error").
    end. else run InsSwiftSts(swift.swift_id, "Не найдено поле \{2:","error").

    find first swift_det where swift_det.swift_id = swift.swift_id and swift_det.fld = "61" no-lock no-error.
    if not avail swift_det then run InsSwiftSts(swift.swift_id, "Не найдено поле :61:","error").

    for each swift_det where swift_det.swift_id = swift.swift_id and swift_det.fld = "61" no-lock:
        v-str = ''.
        v-str = entry(3,swift_det.val,":") no-error.
        /*if index(v-str,"//") = 0 then next.*/
        /* :61:120914D -> 2420550, <- S103+RMZA821888//140912MEMA702777  */
        v-int = 0.     v-ref61-1 = ''.
        v-real = 0.    v-flag = ''.
        v-sum61 = 0.   v-ref103 = ''.
        v-sum103 = 0.
        /* убрано по СЗ от Милютиной
        if lookup(substr(v-str,7,2),"CD,DD") > 0 then do:
           v-flag = substr(v-str,7,2).
           v-sum61 = int(substr(v-str, 9,index(v-str,',') - 9)) no-error.
           if error-status:error then run InsSwiftSts(swift.swift_id, "Ошибка преобразования суммы в поле :61:, линия " + string(swift_det.line),"error").
           v-real = 0. v-real = decimal('0.' + substr(v-str,index(v-str,',') + 1, 2)) no-error.
           if error-status:error then v-real = decimal('0.' + substr(v-str,index(v-str,',') + 1, 1)) no-error.
           if v-real <> 0 then v-sum61 = v-sum61 + v-real.
           if v-sum61 = 0 then run InsSwiftSts(swift.swift_id, "Cумма в поле :61: равна 0, линия " + string(swift_det.line),"error").
        end. else if lookup(substr(v-str,7,1),"C,D") > 0 then do:
           v-flag = substr(v-str,7,1).
           v-sum61 = int(substr(v-str, 8,index(v-str,',') - 8)) no-error.
           if error-status:error then run InsSwiftSts(swift.swift_id, "Ошибка преобразования суммы в поле :61:, линия " + string(swift_det.line),"error").
           v-real = 0. v-real = decimal('0.' + substr(v-str,index(v-str,',') + 1, 2)) no-error.
           if error-status:error then v-real = decimal('0.' + substr(v-str,index(v-str,',') + 1, 1)) no-error.
           if v-real <> 0 then v-sum61 = v-sum61 + v-real.
           if v-sum61 = 0 then run InsSwiftSts(swift.swift_id, "Cумма в поле :61: равна 0, линия " + string(swift_det.line),"error").
        end. else run InsSwiftSts(swift.swift_id, "В поле :61: не найден признак C,D,CD,DD, линия " + string(swift_det.line),"error").
        */
        if index(v-str,"RMZ") > 0 then do:
           /* :61:120914D2420550,S103+ ->RMZA821888<- //140912MEMA702777  */
           v-ref61-1 = substr(v-str, index(v-str, "RMZ"), 10).
        end. else v-ref61-1 = "".
        if /*v-flag = "D" or v-flag = "DD"*/ v-ref61-1 <> "" then do:
           find first remtrz where remtrz.remtrz = v-ref61-1 no-lock no-error.
           if avail remtrz then do:
              if remtrz.jh2 = ? then do:

                 if /*remtrz.amt = v-sum61 and*/ remtrz.rbank = v-bnkname then do:
                    find first que where que.remtrz = remtrz.remtrz exclusive-lock no-error.
                    if avail que then do:
                       que.ptype = remtrz.ptype .
                       que.pid = m_pid.
                       que.rcod = "0" .
                       v-text = "Сквитован с МТ950, отсылка " + remtrz.remtrz + " по маршруту , тип = " + remtrz.ptype + " код возврата = " + que.rcod  .
                       run lgps.
                       que.con = "F".
                       que.dp = today.
                       que.tp = time.
                       release que .
                       v-valdt2 = date(substr(v-str,5,2) + '/' + substr(v-str,3,2) + '/' + substr(v-str,1,2)).
                       if not (error-status:error) then do:
                           find current remtrz exclusive-lock no-error.
                           remtrz.valdt2 = v-valdt2.
                       end.
                       release remtrz.
                       run InsSwiftSts(swift.swift_id, "RMZ " + v-ref61-1 + " отправлен в ПС, линия " + string(swift_det.line),"check").

                    end.
                 end. else do:
                    run InsSwiftSts(swift.swift_id, "В RMZ " + v-ref61-1 + " не верная сумма или банк " +
                                    string(remtrz.amt) + '=' + string(v-sum61) + ' ' +
                                    remtrz.rbank + '=' + v-bnkname + ' ' +
                                    " линия " + string(swift_det.line),"error").
                    /*run InsSwiftSts(swift.swift_id, "В RMZ " + v-ref61-1 + " не верная сумма или банк " + string(swift_det.line),"error").*/
                 end.
              end. /*else run InsSwiftSts(swift.swift_id, "В RMZ " + v-ref61-1 + " имеется вторая проводка " + string(remtrz.jh2) + " " + string(swift_det.line),"error").*/
           end. else run InsSwiftSts(swift.swift_id, "Не найден RMZ " + v-ref61-1 + " " + string(swift_det.line),"error").
        end. else  /*if v-flag = "C" or v-flag = "CD" then*/ do:
           for each b-swift where  b-swift.mt = "103" and b-swift.io = "O" and b-swift.dt >= today - 11 use-index idx_mt no-lock:
               find last swift_sts where swift_sts.swift_id = b-swift.swift_id use-index idx_swift_id no-lock no-error.
               if avail swift_sts and swift_sts.sts <> "new" then do:
                  next.
               end.
               find first b-swift_det where b-swift_det.swift_id = b-swift.swift_id and b-swift_det.fld = "20" no-lock no-error.
               if avail b-swift_det then do:
                  v-ref103 = trim(entry(3,b-swift_det.val,":")).
                  if v-ref103 begins "+" then v-ref103 = substr(v-ref103,2,16).
                  run savelog('mt950chk', '136. ' + v-ref103 ).
                  run savelog('mt950chk', '137. ' + v-str ).
                  run savelog('mt950chk', '138. ' + string(v-str matches "*" + v-ref103 + "*") ).
                  if v-str matches "*" + v-ref103 + "*" then do:
                     run savelog('mt950chk', '138. ').
                     /* убрано по СЗ от Милютиной
                     find first b-swift_det where b-swift_det.swift_id = b-swift.swift_id and b-swift_det.fld = "32A" no-lock no-error.
                     if avail b-swift_det then do:
                        v-sum103 = decimal(replace(substr(entry(3,b-swift_det.val,":"),10,length(b-swift_det.val)),",",".")) no-error.
                        if error-status:error then do:
                           run InsSwiftSts(swift.swift_id, "Ошибка определения суммы в поле :32A: МТ103 " + string(b-swift.swift_id) + " линия " + string(swift_det.line),"error").
                           run InsSwiftSts(b-swift.swift_id, "Ошибка определения суммы в поле :32A:","error").
                        end.
                     end. else do:
                        run InsSwiftSts(swift.swift_id, "Не найдено поле :32A: МТ103 " + string(b-swift.swift_id) + " линия " + string(swift_det.line),"error").
                        run InsSwiftSts(b-swift.swift_id, "Не найдено поле :32A:","error").
                     end.
                     */
                     find first b-swift_det where b-swift_det.swift_id = b-swift.swift_id and b-swift_det.val matches "*\{2:*" no-lock no-error.
                     if avail b-swift_det then do:
                        v-bic103 = substr(b-swift_det.val,index(b-swift_det.val,"\{2:") + 17,8).
                     end. else do:
                        run InsSwiftSts(swift.swift_id, "Не найдено поле \{2: МТ103 " + string(b-swift.swift_id) + " линия " + string(swift_det.line),"error").
                        run InsSwiftSts(b-swift.swift_id, "Не найдено поле \{2:","error").
                     end.
                     if /*v-sum103 = v-sum61 and*/ v-bic103 = v-bic950 then do:
                        run InsSwiftSts(swift.swift_id, "МТ103 " + v-ref103 + " найден " + string(swift_det.line),"check").
                        run InsSwiftSts(b-swift.swift_id, "Сквитован с МТ950 " + string(swift.swift_id) + " линия " + string(swift_det.line),"check").
                     end. else do:
                        run InsSwiftSts(swift.swift_id, "Не верная сумма или банк " +
                                    string(v-sum103) + '=' + string(v-sum61) + ' ' +
                                    v-bic103 + '=' + v-bic950 + ' ' +
                                    " линия " + string(swift_det.line),"error").
                        run InsSwiftSts(b-swift.swift_id, "Не верная сумма или банк " +
                                    string(v-sum103) + '=' + string(v-sum61) + ' ' +
                                    v-bic103 + '=' + v-bic950 + ' ' + string(swift.swift_id) +
                                    " линия " + string(swift_det.line),"new").
                        /*run InsSwiftSts(b-swift.swift_id, "Не верная сумма или банк " + string(swift.swift_id) + " линия " + string(swift_det.line),"error").*/
                     end.
                  end.
               end.
           end.
        end.
    end.
end.