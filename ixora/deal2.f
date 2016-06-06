/* deal2.p
 * MODULE
        Модуль ЦБ 
 * DESCRIPTION
        Открытие и редактирование сделок по ЦБ 
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        11-9-2 
 * BASES
        BANK 
 * AUTHOR
        24/11/03 nataly
 * CHANGES
        04/10/04 tsoy покупная стоимость 8 разрядов
        04/10/04 tsoy увеличил формат до 10 разрядов
*/

form deal.deal     label "Номер сделки" 
     v-scugrp      label "          Группа......" format "zz9" skip
     vgl           label "Гл.Книга...." 
     gl.des format "x(55)" no-label skip
     v-bankl       label "МФО....." validate(can-find(bankl where
                         bankl.bank = v-bankl)," ")  skip
     deal.atvalueon[3] label "Эмитент... "  format 'x(40)'  
     deal.dval[4]  label "ТипЭмит" format "z9" 
     deal.dval[5]  label "ВидЭмит" format "z9"   skip
    /* bankl.name    format "x(55)" no-label*/
     deal.prn      label "Сумма......." format "z,zzz,zzz,zzz,zz9.99"  
     deal.yield    label "Прибыль....." skip
     v-crc         label "Валюта......" format "z9" space(3)
     v-code        no-label  space(5)
     v-rate        label "Курс на дату покупки"  format "zz9.99" skip
     deal.intamt   label "Сумма проц.." format "z,zzz,zzz,zzz,zz9.99" 
     deal.totamt   label "Общая сумма." format "z,zzz,zzz,zzz,zz9.99" 
     deal.regdt    label "Дата сделки." space(13)
     deal.valdt    label "Дата валютир"  
          validate(deal.valdt >= g-today and deal.valdt >= deal.regdt," ") skip
     deal.maturedt label "Дата погашен" 
          validate(deal.maturedt >= deal.valdt," ") skip 
/*     deal.maturedt label "Дата вып ЦБ " 
          validate(deal.maturedt >= deal.valdt," ")  */
     deal.trm      label "К-во дней..." space(5) skip
     deal.intrate  label "% ставка...." format "zz9.9999" space(13) 
     deal.inttype  label "Вид........." 
                   validate(deal.inttype = "A" or deal.inttype = "D"," ") 
     space(8)
     days          label "Дней........" skip
     deal.broke    label "Партнер....." format "x(43)" skip
     deal.rem[3]   label "Код ЦБ......" format 'x(12)' space(9) 
     codfr.name[1] label "Наим-ие ЦБ.." skip
     deal.ncrc[1]  label "Номинал ЦБ.." format "zz,zzz,zzz,zz9" space(7)
     deal.ncrc[2]  label "Кол-во ЦБ..." format "zzz,zzz,zz9" space(3)  
     deal.arrange  label "Орг........." skip

     deal.dval[6]  label "Покупная стоимость, KZT"   format "z,zzz,zzz,zzz,zz9.9999999999" 
     deal.info[3]  label "Листниг/Рейтинг" format "x(4)" skip

     deal.dval[1]  label "Доходность к погашению" format "zzz,zzz,zz9.9999999999" space(4)
     deal.info[2]  label "Дата выплаты купона..." format "99/99/99" skip
     deal.dval[2]  label "Дней до погашения....." format "zzz,zzz,zz9" space(9)
     deal.dval[3]  label "Дней до выплаты купона" format "zzz,zzz,zz9"

/*     "Дата валютир   Банк : " deal.atvalueon[1] no-label format "x(10)"
                              deal.atvalueon[2] no-label skip
     "               FRB# : " deal.valfrb no-label skip
     "               Счет#: " deal.atvalueon[3] no-label skip
     "Дата закрытия  Банк : " deal.atmaton[1] no-label format "x(10)"
                              deal.atmaton[2] no-label skip
     "               FRB# : " deal.matfrb no-label skip
     "Через     корр-счет#: " deal.atmaton[3] no-label skip
     "Прим даты валютир.  : " deal.rem[1] no-label skip
     "Прим даты закрытия  : " deal.rem[2] format "x(20)" no-label skip*/
     with frame deal row 3 side-label centered  no-box width 80.

form cmd with frame slct row 21 no-box no-label overlay centered.

form 
     deal.geo format "x(3)" label "ГЕО........"
        validate(can-find(geo where geo.geo eq geo)
        or deal.geo eq "", "")
     deal.zalog   label "Залог ?...."
     deal.lonsec  label "Обеспеч...." 
        validate(can-find(lonsec where lonsec.lonsec eq lonsec) 
        or deal.lonsec eq 0, "")
     deal.risk    label "Риск......."
        validate(can-find(risk where risk.risk eq risk) 
        or deal.risk eq 0, "")
     deal.penny   label "% пени....." validate(penny <= 100, "") 
     sub-cod.ccode  label "Сектор экономики"

     with frame funacr row 10 centered 1 col width 60 overlay 
     title "ТИП".
