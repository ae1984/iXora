/* kdsysc1.f
 * MODULE
        Мониторинг заемщика
 * DESCRIPTION
        Формы для мониторинга
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        4.11
 * AUTHOR
        01.03.2005 marinav
 * CHANGES
        05.03.05 marinav добавлена форма 
*/


form skip
    kdaffilh.name format "x(50)" label "НАИМЕНОВАНИЕ УЧРЕДИТЕЛЯ"
    kdaffilh.amount format ">>9.99" label "ДОЛЯ"
    with row 5 centered scroll 1 10 down title " УЧРЕДИТЕЛИ ЗАЕМЩИКА "
    frame kdaffil .


form skip
    kdaffilh.name format "x(50)" label "НАИМЕНОВАНИЕ КОМПАНИИ"
    with row 5 centered scroll 1 10 down title " АФФИЛИИРОВАННЫЕ КОМПАНИИ ЗАЕМЩИКА "
    frame kdaffil1 .

form skip
    kdaffilh.name format "x(40)" label "НАИМЕНОВАНИЕ БАНКА"
    kdaffilh.res format "x(15)" label "ОЦЕНКА" help " F2 - справочник"
    with row 5 centered scroll 1 10 down title " КРЕДИТНАЯ ИСТОРИЯ "
    frame kdaffil3 .


form
     kdaffilh.name label "НАИМЕНОВАНИЕ ДЕБИТОРА" format  "x(40)"
     kdaffilh.amount label "СУММА"
     kdaffilh.datres[1] label "ДАТА ВОЗНИКНОВЕНИЯ"
     kdaffilh.datres[2] label "ДАТА ПОГАШЕНИЯ"
     with row 4 centered scroll 1 14 down title " ДЕБИТОРЫ "
     frame kdaffil13 .

form
     kdaffilh.name label "НАИМЕНОВАНИЕ КРЕДИТОРА" format  "x(40)"
     kdaffilh.amount label "СУММА"
     kdaffilh.datres[1] label "ДАТА ВОЗНИКНОВЕНИЯ"
     kdaffilh.datres[2] label "ДАТА ПОГАШЕНИЯ"
     with row 4 centered scroll 1 14 down title " КРЕДИТОРЫ "
     frame kdaffil14 .

form skip
    kdaffilh.name format "x(50)" no-label 
    with row 5 centered scroll 1 10 down title " ОСНОВНЫЕ СРЕДСТВА "
    frame kdaffil15 .


form
     kdaffilh.ln format ">9" label "N"
     kdaffilh.lonsec format ">>9" label "ТИП" 
     kdaffilh.name format "x(20)" label "СОБСТВЕННИК"
     kdaffilh.crc label "ВАЛ"
     kdaffilh.amount label "АУДИТ. ОЦЕНКА"
     kdaffilh.info[2] format "x(5)" label "К-Т ЛИКВ"
     kdaffilh.amount_bank label "ЗАЛОГОВАЯ СТ-ТЬ"
     with row 4 centered scroll 1 14 down title " ОБЕСПЕЧЕНИЕ "
     frame kdaffil20 .

form
     kdaffilh.ln format ">9" label "N"
     kdaffilh.name format "x(35)" label "ЗАЛОГОДАТЕЛЬ"
     kdaffilh.datres[1] label "ДАТА ПЕРВ РЕГ"
     kdaffilh.datres[2] label "ДАТА РЕГ"
     kdaffilh.res format "x(14)" label "РЕГ НОМЕР"
     with row 4 centered scroll 1 14 down title " ЗАЛОГОДАТЕЛИ "
     frame kdaffil22 .


form skip
    kdaffilh.name format "x(40)" label "НАИМЕНОВАНИЕ ПОСТАВЩИКА"
    kdaffilh.res format "x(15)" label "КОНТРАКТ"
    with row 5 centered scroll 1 10 down title " ПОСТАВЩИКИ "
    frame kdaffil24 .

form skip
    kdaffilh.name format "x(40)" label "НАИМЕНОВАНИЕ ПОТРЕБИТЕЛЯ"
    kdaffilh.res format "x(15)" label "КОНТРАКТ"
    with row 5 centered scroll 1 10 down title " ПОТРЕБИТЕЛИ "
    frame kdaffil25 .

form skip
    kdaffilh.name format "x(40)" label "НАИМЕНОВАНИЕ ГАРАНТА"
    kdaffilh.affilate format "x(15)" no-label 
    with row 5 centered scroll 1 10 down title " ГАРАНТЫ ЗАЕМЩИКА "
    frame kdaffil27 .


form
     kdaffilh.ln format ">9" label "N"
     kdaffilh.info[4] format "x(40)" label "ТИП" 
     kdaffilh.info[3] format "x(5)" label "ВАЛ"
     kdaffilh.amount_bank label "ЗАЛОГОВАЯ СТ-ТЬ"
     with row 4 centered scroll 1 14 down title " ОБЕСПЕЧЕНИЕ "
     frame kdaffil35 .

form
     kdaffilh.res format "x" label "N"
     kdaffilh.name format "x(40)" label "ОТВЕТСТВЕННОЕ ЛИЦО" 
     with row 4 centered scroll 1 14 down title " "
     frame kdaffil37 .

form skip
    kdaffilh.kdlon format "x(9)" label "Счет"
    kdaffilh.dat label "Дата изменений"
    kdaffilh.name format "x(40)" label "Основание"
    with row 5 centered scroll 1 10 down title " ИЗМЕНЕНИЕ УСЛОВИЙ КРЕДИТОВАНИЯ "
    frame kdaffil62 .
