/* cstms_pay.i
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
        07/06/03 kanat
 * CHANGES
        07.07.03 kanat - добавил передачу РНН плательщика для таможенных платежей 
        01.14.04 kanat - добавил передачу в платежное поручение номеров КТС, ДВС и т.д.
        02.17.04 kanat - в commpl передается наименование плательщика (commonpl.fioadr) последним параметром
        02.20.04 kanat - подправил формирование назначений платежей по КТС таможенных платежей
        02.24.04 kanat - уменьшил строку назначения платежа. end в конце перенес в comm-cif.
        20.08.04 kanat - по просьбе таможенного комитета поменял назначение платежа
        20.08.04 sasco - в целях минимизации трафика убрал из назначение платежа сумму, комиссию, кбк                         
        03.05.05 kanat - если нет КНП, то формирование альтернативного КНП
        10.05.05 kanat - в назначение платежа добавлена обработка полей commonpl.info[4] и commonpl.info[5]
        24/05/06   marinav  - добавлен параметр даты факт приема платежа
*/

	message 'Зачисление таможенных платежей' view-as alert-box title 'Внимание'.

        find first sysc where sysc.sysc = "NETGRO" no-lock no-error.

	for each tcommpl:

		 find first commonpl where rowid(commonpl) = tcommpl.rid no-lock no-error.
		 if avail commonpl then do:

		 summa = commonpl.sum.

                 sumx = summa - (summa * selprc).

                 /*
                 i_doc_count = i_doc_count + 1.
                 */

/*
        tmp = 'Залоговая сумма ' + trim(string(summa,">>>>>>>>9.99")) + 
              ' от ' + string(dat,"99.99.9999") + ' комиссия ' + 
               trim( string((summa * commonls.comprc), ">>>>>>>>>9.99")) + 'тенге, КБ:' + 
               string(commonpl.kb) + ' РНН:' + commonpl.rnn + ' КТС:' + commonpl.info[2] + ' ФИО:' + commonpl.fioadr + ' ' + commonpl.info[1].
*/

        define variable tempFIO as character.

        tempFIO = trim ( trim (commonpl.fioadr) + ' ' + trim (commonpl.info[1]) ).
        if tempFIO <> '' then tempFIO = 'ФИО: ' + tempFIO.

        if commonpl.kb = 0 then
        tmp = 'Обеспечение уплаты таможенных платежей и налогов  КТС:' + commonpl.info[2] + trim(commonpl.info[4]) + trim(commonpl.info[5]).
        else
        tmp = 'Залоговая сумма КБК:' + string(commonpl.kb) + ' КТС:' + commonpl.info[2] + trim(commonpl.info[4]) + trim(commonpl.info[5]).


                 if sumx + 100 >= sysc.deval then cover = 2.  /* GROSS */
                                              else cover = 1. /* CLEAR */

                 if cover = 2 then do: /*GROSS*/

                    run commpl ( 
                    commonpl.dnum,
                    sumx,                   
                    selarp,
                    commonls.bikbn,
                    commonls.iik,
                    commonpl.kb,                      
                    no,                     
                    trim(commonls.bn),      
                    commonls.rnnbn,         
                    commonls.knp,
                    commonls.kod,
                    commonls.kbe,
                    tmp,
                    if seltxb = 0 then commonls.que else "1P",                 
                    0, 
                    2,
                    commonpl.rnn,
                    commonpl.fioadr,
                    commonpl.date). 


        create trmz.
        assign 
            trmz.g = rowid(commonpl)
            trmz.d = return-value.    

                 end.

                 else do:            /*CLEAR*/

                       run commpl (
                       commonpl.dnum,
                       sumx,       
                       selarp,
                       commonls.bikbn,
                       commonls.iik,
                       commonpl.kb,                      
                       no,                     
                       trim(commonls.bn),      
                       commonls.rnnbn,         
                       commonls.knp,
                       commonls.kod,
                       commonls.kbe,
                       tmp,
                       if seltxb = 0 then commonls.que else "1P",
                       0,
                       1,
                       commonpl.rnn,
                       commonpl.fioadr,
                       commonpl.date). 

        create trmz.
        assign 
            trmz.g = rowid(commonpl)
            trmz.d = return-value.    

                 end.
                 end.
	end.



