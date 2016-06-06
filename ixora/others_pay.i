/* other_pay.i
 * MODULE
        Комунальные (прочие) платежи
 * DESCRIPTION
        Отправка прочих платежей
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
        24/02/04 kanat
 * CHANGES
        13/03/04 kanat - переделал формирование назначения платежа и теперь референсы пишутся в таблицу toters
        30/04/04 kanat - в назначение платежа добавил commonpl.npl
        18/08/04 kanat - убрал печать платежных поручений при отправке
        23/08/04 kanat - поменял поля для ввода и зачисления лицевых счетов по квитанциям получателей. 
        30/09/04 kanat - добавил обработку commonpl.type при снятиях комиссий банка с отправителя (commonls.comprc)
        24/05/06   marinav  - добавлен параметр даты факт приема платежа
*/

        def var v-interest as decimal init 0.

        find first sysc where sysc.sysc = "NETGRO" no-lock no-error.


        for each tcommpl no-lock.
        create temp-comp.
        buffer-copy tcommpl to temp-comp.
        end.   

        output to svodrep.txt. 
        put unformatted "                                      РЕЕСТР " skip.
        put unformatted "                          прочих платежей для зачисления " skip.
        put unformatted "                                  за " dat skip(2).

        for each temp-comp no-lock.
        put unformatted "Квитанция: " temp-comp.dnum skip 
                        "ПЛАТЕЛЬЩИК. РНН: [" temp-comp.rnn "]. " temp-comp.fioadr skip 
                        "ПОЛУЧАТЕЛЬ. РНН: [" temp-comp.rnnbn "]. " temp-comp.info[4] skip 
                        "Счет: [" temp-comp.info[2] "]" skip
                        "БИК: [" temp-comp.info[3] "]" skip
                        "Лицевой счет: [" temp-comp.diskont "]" skip
                        "Назначение: [" temp-comp.npl "]" skip
                        "Сумма: [" temp-comp.sum "]" skip
                        "КОД: [" temp-comp.chval[1] "]" skip
                        "КБЕ: [" temp-comp.chval[2] "]" skip
                        "КНП: [" temp-comp.chval[3] "]" skip
                        "КБК: [" temp-comp.kb "]" skip.        
        put unformatted fill("-",20) format "x(20)" skip.
        end.
        output close.
        run menu-prt ("svodrep.txt").

        if not yes-no ("", " Отправить прочие платежи по реестру ?") then
        return.

	for each tcommpl:

		 find first commonpl where rowid(commonpl) = tcommpl.rid no-lock no-error.
		 if avail commonpl then do:

		 find first commonls where commonls.txb  = commonpl.txb and 
                                           commonls.grp  = commonpl.grp and 
                                           commonls.type = commonpl.type no-lock no-error. 

                 v-interest = commonls.comprc.

		 summa = commonpl.sum.
                 sumx = summa - (summa * v-interest).

        tmp = 'Принятые прочие платежи' + ', сумма ' + trim( string(summa,">>>>>>>>9.99") ) + 
              ' в тенге от ' + string(dat,"99.99.9999") + ' ' + string(commonpl.kb) + ' ' + trim(commonpl.diskont) + ' ' + 
               trim(commonpl.npl) + ' ' + ' комиссия ' + trim( string((summa * v-interest), ">>>>>>>>>9.99") ) + ' тенге, в тч НДС'.

                 if sumx + 100 >= sysc.deval then cover = 2.  
                                             else cover = 1. 

        if selbik = commonpl.info[3] then do:   

            s-jh = 0.
            run trxgen("ALX0005", "|",  
            string(sumx) + "|" + 
            selarp + "|" + 
            commonpl.info[2] + "|" +
            tmp +
            "|" + trim(substring(commonpl.chval[1],1,1)) + 
            "|" + trim(substring(commonpl.chval[2],1,1)) +
            "|" + trim(substring(commonpl.chval[1],2,1)) +
            "|" + trim(substring(commonpl.chval[2],2,1)) +
            "|" + trim(commonpl.chval[3]),
            "cif", "", 
            output rcode, 
            output rdes, 
            input-output s-jh).

            if rcode ne 0 then do :
                message " Ошибка проводки rcode = " + string(rcode) + ":" +
                rdes + " " + string(s-jh). pause.
                return.
            end.    
            run vou_bank(2).
            run jl-stmp.


        create toters.
        assign 
            toters.g = rowid(commonpl)
            toters.d = string(s-jh).    

          end.
          else do:

                 if cover = 2 then do: 
                    run commpl ( 
                    commonpl.dnum,
                    sumx,                   
                    selarp,
                    commonpl.info[3],
                    commonpl.info[2],
                    commonpl.kb,                      
                    no,                     
                    trim(commonpl.info[4]),      
                    trim(commonpl.rnnbn),         
                    trim(commonpl.chval[3]),
                    trim(commonpl.chval[1]),
                    trim(commonpl.chval[2]),
                    tmp,
                    if seltxb = 0 then commonls.que else "1P",         
                    0,  /* печать экземпляров платежек */
                    2,
                    commonpl.rnn,
                    commonpl.fioadr,
                    commonpl.date). 


        create toters.
        assign 
            toters.g = rowid(commonpl)
            toters.d = return-value.    

                 end.
                 else do:            
                       run commpl (
                       commonpl.dnum,
                       sumx,       
                       selarp,
                       commonpl.info[3],
                       commonpl.info[2],
                       commonpl.kb,                      
                       no,                     
                       trim(commonpl.info[4]),      
                       trim(commonpl.rnnbn),         
                       trim(commonpl.chval[3]),
                       trim(commonpl.chval[1]),
                       trim(commonpl.chval[2]),
                       tmp,
                       if seltxb = 0 then commonls.que else "1P",     
                       0, /* печать экземпляров платежек */
                       1,
                       commonpl.rnn,
                       commonpl.fioadr,
                       commonpl.date). 


        create toters.
        assign 
            toters.g = rowid(commonpl)
            toters.d = return-value.    

                 end.
            end.  /* if selbik ne TXB */
                 end.  /* if avail commonpl */
	end. /* for each commpl */


