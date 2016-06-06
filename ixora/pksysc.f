/* pksysc.f
 * MODULE
        Кредитование
 * DESCRIPTION
        Общие формы настроек
 * RUN

 * CALLER
        pksysc.p, kdsysc.p
 * SCRIPT

 * INHERIT

 * MENU
        4.x.5.1, 4.11
 * AUTHOR
        01.02.2003 marinav
 * CHANGES
        06.05.2004 nadejda - восстановлена форма pksysc после поломки
        30.09.2005 marinav - изменения для бизнес-кредитов
        30/09/2005 madiyar - добавил форму kdaffil19
        14/10/2005 madiyar - добавил признак юр/физ для залогодателя в форму kdaffil22
        03/11/2005 madiyar - добавил validate в kdaffil20 для поля "тип недвижимости"
        11/10/2011 madiyar - расширил фрейм
*/


form
     pksysc.sysc label "КОД" format "x(15)"
     pksysc.des label "НАИМЕНОВАНИЕ" format "x(43)"
     pksysc.daval label "ДАТА" format "99/99/9999"
     pksysc.deval label "ВЕЩЕСТВ" format "->,>>>,>>>,>>9.99"
     pksysc.inval label "ЦЕЛОЕ" format "->>>>>>>>>9"
     pksysc.loval label "ЛОГ"
     pksysc.general label "ОБ?"
     with row 3 centered scroll 1 30 down width 110 title " НАСТРОЙКИ " frame pksysc.

form
     sysc.sysc label "КОД"
     sysc.des label "НАИМЕНОВАНИЕ"
     sysc.daval label "ДАТА"
     sysc.deval label "ВЕЩЕСТВ"
     sysc.inval label "ЦЕЛОЕ"
     sysc.loval label "ЛОГ"
     with row 3 centered scroll 1 14 down title " НАСТРОЙКИ КРЕДИТНОГО ДОСЬЕ "
     frame kdsysc .

form skip
    kdaffil.name format "x(50)" label "НАИМЕНОВАНИЕ УЧРЕДИТЕЛЯ"
    kdaffil.amount format ">>9.99" label "ДОЛЯ"
    with row 5 centered scroll 1 10 down title " УЧРЕДИТЕЛИ ЗАЕМЩИКА "
    frame kdaffil .


form skip
    kdaffil.name format "x(50)" label "НАИМЕНОВАНИЕ КОМПАНИИ"
    with row 5 centered scroll 1 10 down title " АФФИЛИИРОВАННЫЕ КОМПАНИИ ЗАЕМЩИКА "
    frame kdaffil1 .

form skip
    kdaffil.name format "x(40)" label "НАИМЕНОВАНИЕ БАНКА"
    kdaffil.res format "x(15)" label "ОЦЕНКА" help " F2 - справочник"
    with row 5 centered scroll 1 10 down title " КРЕДИТНАЯ ИСТОРИЯ "
    frame kdaffil3 .


form
     kdaffil.name label "НАИМЕНОВАНИЕ ДЕБИТОРА" format  "x(40)"
     kdaffil.amount label "СУММА"
     kdaffil.datres[1] label "ДАТА ВОЗНИКНОВЕНИЯ"
     kdaffil.datres[2] label "ДАТА ПОГАШЕНИЯ"
     with row 4 centered scroll 1 14 down title " ДЕБИТОРЫ "
     frame kdaffil13 .

form
     kdaffil.name label "НАИМЕНОВАНИЕ КРЕДИТОРА" format  "x(40)"
     kdaffil.amount label "СУММА"
     kdaffil.datres[1] label "ДАТА ВОЗНИКНОВЕНИЯ"
     kdaffil.datres[2] label "ДАТА ПОГАШЕНИЯ"
     with row 4 centered scroll 1 14 down title " КРЕДИТОРЫ "
     frame kdaffil14 .

form skip
    kdaffil.name format "x(50)" no-label
    with row 5 centered scroll 1 10 down title " ОСНОВНЫЕ СРЕДСТВА "
    frame kdaffil15 .


form
     kdspr.nom label "КОД"
     kdspr.name label "НАИМЕНОВАНИЕ СТАТЬИ"
     with row 3 centered scroll 1 14 down title " НАСТРОЙКИ ОТЧЕТА О ФИН РЕЗУЛЬТАТАХ "
     frame kdspr .

form
     kdaffil.ln format ">9" label "N"
     kdaffil.lonsec format ">>9" label "ТИП"
     kdaffil.name format "x(20)" label "ИСТОЧНИК"
     kdaffil.crc label "ВАЛ"
     kdaffil.amount label "СТОИМОСТЬ"
     with row 4 centered scroll 1 14 down title " АНАЛИЗ РЫНКА "
     frame kdaffil19.

form
     kdaffil.ln format ">9" label "N"
     kdaffil.lonsec format ">>9" label "ТИП" validate(can-find(lonsec where lonsec.lonsec = kdaffil.lonsec)," Некорректный тип! ")
     kdaffil.name format "x(20)" label "СОБСТВЕННИК"
     kdaffil.crc label "ВАЛ"
     kdaffil.amount format ">>,>>>,>>>,>>9.99" label "АУДИТ. ОЦЕНКА"
     kdaffil.info[2] format "x(5)" label "ЛИКВ"
     kdaffil.amount_bank label "ЗАЛОГОВАЯ СТ-ТЬ"
     with row 4 centered scroll 1 14 down title " ОБЕСПЕЧЕНИЕ "
     frame kdaffil20 .

form
     kdaffil.ln format ">9" label "N"
     kdaffil.info[4] format "x" label "T" help "0 - юридическое лицо, 1 - физическое лицо" validate(kdaffil.info[4] = '0' or kdaffil.info[4] = '1', " Введите корректный код! ")
     kdaffil.name format "x(35)" label "ЗАЛОГОДАТЕЛЬ"
     kdaffil.datres[1] label "ДАТА 1 РЕГ" help "Дата первой регистрации"
     kdaffil.datres[2] label "ДАТА РЕГ" help "Дата регистрации"
     kdaffil.res format "x(14)" label "РЕГ НОМЕР"
     with row 4 centered scroll 1 14 down title " ЗАЛОГОДАТЕЛИ "
     frame kdaffil22 .

form
     kddocs.ln label "N" format '>>>9'
     kddocs.kb label "К/Б" format 'x(2)'
     kddocs.zaemfu label "Кл-т" format '>9'
     kddocs.fu label "Ф/Ю" format '>9'
     kddocs.type label "ЗАЛ"  format 'x(4)'
     kddocs.name label "НАИМЕНОВАНИЕ" format 'x(55)'
     with row 3 centered scroll 1 14 down title " НАСТРОЙКИ ДОКУМЕНТОВ "
     frame kddocs .

form
     kddocs.name label "НАИМЕНОВАНИЕ ДОКУМЕНТА" format 'x(65)'
     with row 3 centered scroll 1 14 down title "  "
     frame kddocs1 .


form skip
    kdaffil.name format "x(40)" label "НАИМЕНОВАНИЕ ПОСТАВЩИКА"
    kdaffil.res format "x(15)" label "КОНТРАКТ"
    with row 5 centered scroll 1 10 down title " ПОСТАВЩИКИ "
    frame kdaffil24 .

form skip
    kdaffil.name format "x(40)" label "НАИМЕНОВАНИЕ ПОТРЕБИТЕЛЯ"
    kdaffil.res format "x(15)" label "КОНТРАКТ"
    with row 5 centered scroll 1 10 down title " ПОТРЕБИТЕЛИ "
    frame kdaffil25 .

form skip
    kdaffil.name format "x(40)" label "НАИМЕНОВАНИЕ ГАРАНТА"
    kdaffil.affilate format "x(15)" no-label
    with row 5 centered scroll 1 10 down title " ГАРАНТЫ ЗАЕМЩИКА "
    frame kdaffil27 .

form
    kdaffil.info[1]  label "                       ФИО, ДОЛЖНОСТЬ " format "x(65)"
    with 10 down title "ПРЕДСЕДАТЕЛЬ КРЕДИТНОГО КОМИТЕТА" overlay centered row 5
    frame kdkk1.


form
    kdaffil.info[1]  label "                       ФИО, ДОЛЖНОСТЬ " format "x(65)"
    with 10 down title "ЧЛЕНЫ КРЕДИТНОГО КОМИТЕТА" overlay centered row 5
    frame kdkk2.

form
     kdaffil.ln format ">9" label "N"
     kdaffil.info[4] format "x(40)" label "ТИП"
     kdaffil.info[3] format "x(5)" label "ВАЛ"
     kdaffil.amount_bank label "ЗАЛОГОВАЯ СТ-ТЬ"
     with row 4 centered scroll 1 14 down title " ОБЕСПЕЧЕНИЕ "
     frame kdaffil35 .

form
     kdaffil.res format "x" label "N"
     kdaffil.name format "x(40)" label "ОТВЕТСТВЕННОЕ ЛИЦО"
     with row 4 centered scroll 1 14 down title " "
     frame kdaffil37 .

/*
form
    t-kdvip.choice no-label format "x"
    t-kdvip.code  label "ВОПР" format ">>9"
    t-kdvip.name  label "НАИМЕНОВАНИЕ" format "x(65)"
with 11 down title '' overlay centered row 6 frame kdvip.
  */
